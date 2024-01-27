/*
    Module of composability.

    - Forked from aptos_token_objects::aptos_token.move
    - This contract represents the core of the studio.
    - Allows to create collections and mint tokens.
    - Leverages aptos_token_objects.
    - All functions are internals and has limited visibility (check NOTES).
    - A user can create the following:
        - Collections using aptos_token_objects/collection.move
        - Trait token: A token V2 that represents a trait.
        - Composable token (cNFT): A token V2 that can hold Trait tokens.
    TODOs:
        - improve error handling: should implement assert functions to eliminate redundancy.
        - change the name for the module: Token creator? Token factory?
        - Organize the functions
        - add "add_royalty_to_collection/token" function
*/

module townespace::composables {
    
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;

    use aptos_std::type_info;

    use aptos_token_objects::collection;
    use aptos_token_objects::property_map;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token::{Self, Token as TokenV2};

    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::String;
    use std::vector;

    // -------
    // Asserts
    // -------

    // The collection type is not recognised.
    const EUNKNOWN_COLLECTION_TYPE: u64 = 0;
    // The token type is not recognised.
    const EUNKNOWN_TOKEN_TYPE: u64 = 1;
    // The naming style is not recognised.
    const EUNKNOWN_NAMING_TYPE: u64 = 2;
    // The collection does not exist.
    const ECOLLECTION_DOES_NOT_EXIST: u64 = 3;
    // The composable token does not exist.
    const ECOMPOSABLE_DOES_NOT_EXIST: u64 = 4;
    // The trait token does not exist.
    const ETRAIT_DOES_NOT_EXIST: u64 = 5;
    // The creator is not the signer.
    const ENOT_CREATOR: u64 = 6;
    // The field is not mutable.
    const EFIELD_NOT_MUTABLE: u64 = 7;
    // The properties are not mutable.
    const EPROPERTIES_NOT_MUTABLE: u64 = 8;
    // The ungated transfer is disabled.
    const EUNGATED_TRANSFER_DISABLED: u64 = 9;
    // The signer is not the owner of the token.
    const ENOT_OWNER: u64 = 10;
    // The references does not exist.
    const EREFS_DOES_NOT_EXIST: u64 = 11;

    // TODO: add asserts functions here.

    // ---------
    // Resources
    // ---------
     
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for collections
    struct Collection has key {
        // Name of the collection
        name: String,
        // Symbol of the collection
        symbol: String,
        // Supply type of the collection; can be fixed, unlimited or concurrent
        supply_type: String,
        // Used to mutate collection fields
        mutator_ref: Option<collection::MutatorRef>,
        // Used to mutate royalties
        royalty_mutator_ref: Option<royalty::MutatorRef>,
        // Determines if the creator can mutate the collection's description
        mutable_description: bool,
        // Determines if the creator can mutate the collection's uri
        mutable_uri: bool,
        // Determines if the creator can mutate token descriptions
        mutable_token_description: bool,
        // Determines if the creator can mutate token names
        mutable_token_name: bool,
        // Determines if the creator can mutate token properties
        mutable_token_properties: bool,
        // Determines if the creator can mutate token uris
        mutable_token_uri: bool,
        // Determines if the creator can burn tokens
        tokens_burnable_by_creator: bool,
        // Determines if the creator can freeze tokens
        tokens_freezable_by_creator: bool
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for composables; aka, the atom/primary of the token
    struct Composable has key {
        traits: vector<Object<Trait>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for traits
    struct Trait has key {
        index: u64, // index from the vector
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for token references, sticked to the token object
    struct References has key {
        burn_ref: Option<token::BurnRef>,
        extend_ref: object::ExtendRef,
        mutator_ref: Option<token::MutatorRef>,
        transfer_ref: object::TransferRef,
        property_mutator_ref: property_map::MutatorRef
    }

    // Used to determine the naming style of the token
    struct Indexed has key {}
    struct Named has key {}

    // ------
    // Events
    // ------

    // Collection related

    struct CollectionMetadata has drop, store {
        creator: address,
        collection_addr: address,
        supply_type: String,   // Fixed, Unlimited or Concurrent
        description: String,
        max_supply: Option<u64>,    // if the collection is set to haved a fixed or concurrent supply.
        name: String,
        symbol: String,
        uri: String,
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
    }

    inline fun collection_metadata(
        collection_object: Object<Collection>, 
        max_supply: Option<u64>,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
    ): CollectionMetadata acquires Collection {
        let creator_addr = collection::creator<Collection>(collection_object);
        let collection_addr = object::object_address(&collection_object);
        let supply_type = get_collection_supply_type(collection_object);
        let description = collection::description<Collection>(collection_object);
        let name = collection::name<Collection>(collection_object);
        let symbol = get_collection_symbol(collection_object);
        let uri = collection::uri<Collection>(collection_object);
        let mutable_description = is_mutable_collection_description(collection_object);
        let mutable_royalty = is_mutable_collection_royalty(collection_object);
        let mutable_uri = is_mutable_collection_uri(collection_object);
        let mutable_token_description = is_mutable_collection_token_description(collection_object);
        let mutable_token_name = is_mutable_collection_token_name(collection_object);
        let mutable_token_properties = is_mutable_collection_token_properties(collection_object);
        let mutable_token_uri = is_mutable_collection_token_uri(collection_object);
        let tokens_burnable_by_creator = are_collection_tokens_burnable(collection_object);
        let tokens_freezable_by_creator = are_collection_tokens_freezable(collection_object);

        CollectionMetadata {
            creator: creator_addr,
            collection_addr,
            supply_type,
            description,
            max_supply,
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            royalty_numerator,
            royalty_denominator
        }
    }

    #[event]
    struct CollectionCreatedEvent has drop, store { metadata: CollectionMetadata }
    fun emit_collection_created_event<SupplyType: key>(
        collection_object: Object<Collection>,
        max_supply: Option<u64>,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
    ) acquires Collection {
        let metadata = collection_metadata(
            collection_object,
            max_supply,
            royalty_numerator,
            royalty_denominator
        );
        event::emit<CollectionCreatedEvent>( CollectionCreatedEvent { metadata });
    }

    // Token related

    #[event]
    struct TokenBurnedEvent has drop, store { token_addr: address, token_type: String }
    fun emit_token_burned_event(
        token_addr: address,
        token_type: String
    ) {
        event::emit<TokenBurnedEvent>( TokenBurnedEvent { token_addr, token_type });
    }

    #[event]
    struct TokenDescriptionUpdatedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        old_description: String,
        new_description: String
    }  
    fun emit_token_description_updated_event(
        token_addr: address,
        token_type: String,
        old_description: String,
        new_description: String
    ) {
        event::emit<TokenDescriptionUpdatedEvent>(
            TokenDescriptionUpdatedEvent { 
                token_addr, 
                token_type,
                old_description,
                new_description
            }
        );
    }  

    #[event]
    struct TokenNameUpdatedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        old_name: String,
        new_name: String
    }
    fun emit_token_name_updated_event(
        token_addr: address,
        token_type: String,
        old_name: String,
        new_name: String
    ) {
        event::emit<TokenNameUpdatedEvent>(
            TokenNameUpdatedEvent { 
                token_addr, 
                token_type,
                old_name,
                new_name
            }
        );
    }

    #[event]
    struct TokenUriUpdatedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        old_uri: String,
        new_uri: String
    }
    fun emit_token_uri_updated_event(
        token_addr: address,
        token_type: String,
        old_uri: String,
        new_uri: String
    ) {
        event::emit<TokenUriUpdatedEvent>(
            TokenUriUpdatedEvent { 
                token_addr, 
                token_type,
                old_uri,
                new_uri
            }
        );
    }

    #[event]
    struct PropertyAddedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        key: String,
        type: String,
        value: vector<u8>
    }
    fun emit_property_added_event(
        token_addr: address,
        token_type: String,
        key: String,
        type: String,
        value: vector<u8>
    ) {
        event::emit<PropertyAddedEvent>(
            PropertyAddedEvent { 
                token_addr, 
                token_type,
                key,
                type,
                value
            }
        );
    }

    #[event]
    struct TypedPropertyAddedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        key: String,
        value: String
    }
    fun emit_typed_property_added_event(
        token_addr: address,
        token_type: String,
        key: String,
        value: String
    ) {
        event::emit<TypedPropertyAddedEvent>(
            TypedPropertyAddedEvent { 
                token_addr, 
                token_type,
                key,
                value
            }
        );
    }

    #[event]
    struct PropertyRemovedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        key: String
    } 
    fun emit_property_removed_event(
        token_addr: address,
        token_type: String,
        key: String
    ) {
        event::emit<PropertyRemovedEvent>(
            PropertyRemovedEvent { 
                token_addr, 
                token_type,
                key
            }
        );
    }

    #[event]
    struct PropertyUpdatedEvent has drop, store { 
        token_addr: address, 
        token_type: String,
        key: String,
        old_value: vector<u8>,
        new_value: vector<u8>
    }
    fun emit_property_updated_event(
        token_addr: address,
        token_type: String,
        key: String,
        old_value: vector<u8>,
        new_value: vector<u8>
    ) {
        event::emit<PropertyUpdatedEvent>(
            PropertyUpdatedEvent { 
                token_addr, 
                token_type,
                key,
                old_value,
                new_value
            }
        );
    }

    // Composable 

    struct ComposableMetadata has drop, store {
        creator: address,
        token_address: address,
        name: String,
        uri: String,
        mutable_description: bool,
        mutable_name: bool,
        mutable_uri: bool,
        mutable_properties: bool,
        burnable: bool,
        freezable: bool
    }

    inline fun composable_metadata(
        composable_object: Object<Composable>
    ): ComposableMetadata acquires Collection, Composable, References, Trait {
        let creator_addr = token::creator<Composable>(composable_object);
        let token_address = object::object_address(&composable_object);
        let name = token::name<Composable>(composable_object);
        let uri = token::uri<Composable>(composable_object);
        let mutable_description = is_mutable_description(composable_object);
        let mutable_name = is_mutable_name(composable_object);
        let mutable_uri = is_mutable_uri(composable_object);
        let mutable_properties = are_properties_mutable(composable_object);
        let burnable = is_burnable(composable_object);
        let freezable = are_collection_tokens_freezable(token::collection_object(composable_object));

        ComposableMetadata {
            creator: creator_addr,
            token_address,
            name,
            uri,
            mutable_description,
            mutable_name,
            mutable_uri,
            mutable_properties,
            burnable,
            freezable
        }
    }

    #[event]
    struct ComposableCreatedEvent has drop, store { metadata: ComposableMetadata }
    fun emit_composable_created_event(
        composable_object: Object<Composable>
    ) acquires Collection, References {
        let metadata = composable_metadata(composable_object);
        ComposableCreatedEvent { metadata };
    }

    // Trait

    struct TraitMetadata has drop, store {
        creator: address,
        token_address: address,
        name: String,
        uri: String,
        mutable_description: bool,
        mutable_name: bool,
        mutable_uri: bool,
        mutable_properties: bool,
        burnable: bool,
        freezable: bool
    }

    inline fun trait_metadata(
        trait_object: Object<Trait>
    ): TraitMetadata acquires Collection, Composable, References, Trait {
        let creator_addr = token::creator<Trait>(trait_object);
        let token_address = object::object_address(&trait_object);
        let name = token::name<Trait>(trait_object);
        let uri = token::uri<Trait>(trait_object);
        let mutable_description = is_mutable_description(trait_object);
        let mutable_name = is_mutable_name(trait_object);
        let mutable_uri = is_mutable_uri(trait_object);
        let mutable_properties = are_properties_mutable(trait_object);
        let burnable = is_burnable(trait_object);
        let freezable = are_collection_tokens_freezable(token::collection_object(trait_object));

        TraitMetadata {
            creator: creator_addr,
            token_address,
            name,
            uri,
            mutable_description,
            mutable_name,
            mutable_uri,
            mutable_properties,
            burnable,
            freezable
        }
    }

    #[event]
    struct TraitCreatedEvent has drop, store { metadata: TraitMetadata }
    fun emit_trait_created_event(
        trait_object: Object<Trait>
    ) acquires Collection, References {
        let metadata = trait_metadata(trait_object);
        event::emit<TraitCreatedEvent>( TraitCreatedEvent { metadata });
    }

    // Composition related

    #[event]
    struct TraitEquippedEvent has drop, store {
        composable: ComposableMetadata,
        trait: TraitMetadata,
        index: u64,
        new_uri: String
    }
    fun emit_trait_equipped_event(
        composable_object: Object<Composable>,
        trait_object: Object<Trait>,
        index: u64,
        new_uri: String
    ) acquires Collection, References {
        let composable_metadata = composable_metadata(composable_object);
        let trait_metadata = trait_metadata(trait_object);
        event::emit<TraitEquippedEvent>(
            TraitEquippedEvent {
                composable: composable_metadata,
                trait: trait_metadata,
                index,
                new_uri
            }
        );
    }

    #[event]
    struct TraitUnequippedEvent has drop, store {
        composable: ComposableMetadata,
        trait: TraitMetadata,
        index: u64,
        new_uri: String
    }
    fun emit_trait_unequipped_event(
        composable_object: Object<Composable>,
        trait_object: Object<Trait>,
        index: u64,
        new_uri: String
    ) acquires Collection, References {
        let composable_metadata = composable_metadata(composable_object);
        let trait_metadata = trait_metadata(trait_object);
        event::emit<TraitUnequippedEvent>(
            TraitUnequippedEvent {
                composable: composable_metadata,
                trait: trait_metadata,
                index,
                new_uri
            }
        );
    }

    // FA related

    #[event]
    struct FAEquippedEvent has drop, store {
        composable: ComposableMetadata,
        fa: address,
        amount: u64
    }
    fun emit_fa_equipped_event(
        composable_object: Object<Composable>,
        fa: address,
        amount: u64
    ) acquires Collection, References {
        let composable_metadata = composable_metadata(composable_object);
        event::emit<FAEquippedEvent>(
            FAEquippedEvent {
                composable: composable_metadata,
                fa,
                amount
            }
        );
    }

    #[event]
    struct FAUnequippedEvent has drop, store {
        composable: ComposableMetadata,
        fa: address,
        amount: u64
    }
    fun emit_fa_unequipped_event(
        composable_object: Object<Composable>,
        fa: address,
        amount: u64
    ) acquires Collection, References {
        let composable_metadata = composable_metadata(composable_object);
        event::emit<FAUnequippedEvent>(
            FAUnequippedEvent {
                composable: composable_metadata,
                fa,
                amount
            }
        );
    }

    // Transfer related

    #[event]
    struct TokenTransferredEvent has drop, store {
        token_addr: address,
        from: address,
        to: address
    }
    fun emit_token_transferred_event(
        token_addr: address,
        from: address,
        to: address
    ) {
        event::emit<TokenTransferredEvent>( TokenTransferredEvent { token_addr, from, to });
    }

    #[event]
    struct FATransferredEvent has drop, store {
        fa: address,
        from: address,
        to: address,
        amount: u64
    }
    fun emit_fa_transferred_event(
        fa: address,
        from: address,
        to: address,
        amount: u64
    ) {
        event::emit<FATransferredEvent>( FATransferredEvent { fa, from, to, amount });
    }

    #[event]
    struct TransferFrozenEvent has drop, store { token_addr: address, token_type: String }
    fun emit_transfer_frozen_event(token_addr: address, token_type: String) {
        event::emit<TransferFrozenEvent>( TransferFrozenEvent { token_addr, token_type });
    }

    #[event]
    struct TransferUnfrozenEvent has drop, store { token_addr: address, token_type: String }
    fun emit_transfer_unfrozen_event(token_addr: address, token_type: String) {
        event::emit<TransferUnfrozenEvent>( TransferUnfrozenEvent { token_addr, token_type });
    }

    // ------------------   
    // Internal Functions
    // ------------------

    // create royalty; used when creating a collection or a token
    inline fun create_royalty_internal(
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        payee_addr: address
    ): Option<royalty::Royalty> {
        if (option::is_some(&royalty_numerator) && option::is_some(&royalty_denominator)) {
            let royalty_resource = royalty::create(
                option::extract(&mut royalty_numerator),
                option::extract(&mut royalty_denominator),
                payee_addr
            );
            option::some<royalty::Royalty>(royalty_resource)
        } else { option::none<royalty::Royalty>() }
    }
    // setup collection; internal function used when creating a collection
    inline fun collection_create_common(
        constructor_ref: &object::ConstructorRef,
        name: String,
        symbol: String,
        supply_type: String,
        mutable_description: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        mutable_royalty: bool
    ) {
        let obj_signer = object::generate_signer(constructor_ref);
        let mutator_ref = if (mutable_description || mutable_uri) {
        option::some(collection::generate_mutator_ref(constructor_ref))
        } else {
            option::none()
        };

        let royalty_mutator_ref = if (mutable_royalty) {
            option::some(royalty::generate_mutator_ref(object::generate_extend_ref(constructor_ref)))
        } else {
            option::none()
        };  
        // move the collection resource to the object
        // TODO: should not be transferable, test it.
        move_to(
            &obj_signer, 
            Collection {
                name,
                symbol,
                supply_type,
                mutator_ref,
                royalty_mutator_ref,
                mutable_description,
                mutable_uri,
                mutable_token_description,
                mutable_token_name,
                mutable_token_properties,
                mutable_token_uri,
                tokens_burnable_by_creator,
                tokens_freezable_by_creator
            }
        );
    }

    // create a collection internal
    inline fun create_collection_internal<SupplyType: key>(
        signer_ref: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty: Option<royalty::Royalty>
    ): object::ConstructorRef {
        if (type_info::type_of<SupplyType>() == type_info::type_of<collection::FixedSupply>()) {
            // constructor reference, needed to generate signer object and references.
            let constructor_ref = collection::create_fixed_collection(
                signer_ref,
                description,
                option::extract(&mut max_supply),
                name,
                // payee address is the creator by default, it can be changed after creation.
                royalty,
                uri
            );
            collection_create_common(
                &constructor_ref,
                name,
                symbol,
                type_info::type_name<collection::FixedSupply>(),
                mutable_description,
                mutable_uri,
                mutable_token_description,
                mutable_token_name,
                mutable_token_properties,
                mutable_token_uri,
                tokens_burnable_by_creator,
                tokens_freezable_by_creator,
                mutable_royalty
            );
            
            constructor_ref
        } 
        // if type is unlimited
        else if (type_info::type_of<SupplyType>() == type_info::type_of<collection::UnlimitedSupply>()) {
            // constructor reference, needed to generate signer object and references.
            let constructor_ref = collection::create_unlimited_collection(
                signer_ref,
                description,
                name,
                // payee address is the creator by default, it can be changed after creation.
                royalty,
                uri
            );
            collection_create_common(
                &constructor_ref,
                name,
                symbol,
                type_info::type_name<collection::UnlimitedSupply>(),
                mutable_description,
                mutable_uri,
                mutable_token_description,
                mutable_token_name,
                mutable_token_properties,
                mutable_token_uri,
                tokens_burnable_by_creator,
                tokens_freezable_by_creator,
                mutable_royalty
            );
            
            constructor_ref
        }
        // if type is concurrent
        // else if (type_info::type_of<SupplyType>() == type_info::type_of<collection::ConcurrentSupply>()) {}
        // If type is not recognised, abort.
        else { abort EUNKNOWN_COLLECTION_TYPE }
    }

    // Create a collection; 
    // this will create a collection resource, a collection object, 
    // and returns the constructor reference of the collection.
    public fun create_collection<SupplyType: key>(
        signer_ref: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
        // TODO: add payee address option that if it is ignored then the payee addr will be the signer.
    ): object::ConstructorRef acquires Collection {
        // TODO: assert supply type is either fixed, unlimited, or concurrent.
        let signer_addr = signer::address_of(signer_ref);
        let royalty = create_royalty_internal(royalty_numerator, royalty_denominator, signer_addr);
        let constructor_ref = create_collection_internal<SupplyType>(
            signer_ref,
            description,
            max_supply,
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            royalty
        );

        // emit event
        emit_collection_created_event<SupplyType>(
            object::address_to_object<Collection>(collection::create_collection_address(&signer_addr, &name)),
            max_supply,
            royalty_numerator,
            royalty_denominator
        );

        constructor_ref
    }

    // create token internal
    inline fun create_token_internal<Type: key, NamingStyle: key>(
        signer_ref: &signer,
        collection_name: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        royalty: Option<royalty::Royalty>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ): object::ConstructorRef acquires Collection, References {
        // Naming style is named
        let constructor_ref = if (type_info::type_of<NamingStyle>() == type_info::type_of<Named>()) {
            // constructor reference, needed to generate signer object and references.
            token::create_named_token(
                signer_ref,
                collection_name,
                description,
                name,
                royalty,
                uri,
            )
        } else if (type_info::type_of<NamingStyle>() == type_info::type_of<Indexed>()) {
            // constructor reference, needed to generate signer object and references.
            token::create_numbered_token(
                signer_ref,
                collection_name,
                description,
                name_with_index_prefix,
                name_with_index_suffix,
                royalty,
                uri,
            )
        } else { abort EUNKNOWN_NAMING_TYPE };

        // create token commons
        token_create_common<Type>(
            signer_ref,
            &constructor_ref,
            collection_name
        );

        let properties = property_map::prepare_input(property_keys, property_types, property_values);
        property_map::init(&constructor_ref, properties);

        constructor_ref
    }

    // create token commons
    inline fun token_create_common<Type>(
        signer_ref: &signer,
        constructor_ref: &object::ConstructorRef,
        collection_name: String
    ) acquires Collection, References {
        let obj_signer = object::generate_signer(constructor_ref);
        let collection_obj = collection_object(signer_ref, &collection_name);
        let collection = borrow_collection(&collection_obj);

        let mutator_ref = if (
            collection.mutable_token_description
                || collection.mutable_token_name
                || collection.mutable_token_uri
        ) {
            option::some(token::generate_mutator_ref(constructor_ref))
        } else {
            option::none()
        };

        let burn_ref = if (collection.tokens_burnable_by_creator) {
            option::some(token::generate_burn_ref(constructor_ref))
        } else {
            option::none()
        };

        let refs = References {
            burn_ref,
            extend_ref: object::generate_extend_ref(constructor_ref),
            mutator_ref,
            transfer_ref: object::generate_transfer_ref(constructor_ref),
            property_mutator_ref: property_map::generate_mutator_ref(constructor_ref)
        };
        // if type is composable
        if (type_info::type_of<Type>() == type_info::type_of<Composable>()) {
            let traits = vector::empty();
            // create the composable resource
            move_to(
                &obj_signer, 
                Composable { traits }
            );
            // move refs resource under the token signer.
            move_to(&obj_signer, refs);
        } else if (type_info::type_of<Type>() == type_info::type_of<Trait>()) {
            let index = 0;
            // create the trait resource
            move_to(
                &obj_signer, 
                Trait { index }
            );
            // move refs resource under the token signer.
            move_to(&obj_signer, refs);
        } else { abort EUNKNOWN_TOKEN_TYPE };
    }

    // setup token; internal function used when creating a token

    // Create a token based on type. Either a trait or a composable;
    // this will create a token resource, a token object,
    // and returns the constructor reference of the token.
    public fun create_token<Type: key, NamingStyle: key>(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ): object::ConstructorRef acquires Collection, References {
        // TODO: assert Type is either trait or composable.
        let signer_addr = signer::address_of(signer_ref);
        let royalty = create_royalty_internal(royalty_numerator, royalty_denominator, signer_addr);
        let constructor_ref = create_token_internal<Type, NamingStyle>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            royalty,
            property_keys,
            property_types,
            property_values
        );

        // emit event
        if (type_info::type_of<Type>() == type_info::type_of<Composable>()) {
            emit_composable_created_event(
                object::address_to_object<Composable>(token::create_token_address(&signer_addr, &collection, &name)),
            );
        } else if (type_info::type_of<Type>() == type_info::type_of<Trait>()) {
            emit_trait_created_event(
                object::address_to_object<Trait>(token::create_token_address(&signer_addr, &collection, &name)),
            );
        } else { abort EUNKNOWN_TOKEN_TYPE };

        constructor_ref
    }

    // Compose trait to a composable token
    public fun equip_trait(
        signer_ref: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>,
        new_uri: String
    ) acquires Collection, References, Composable, Trait {
        // Assert ungated transfer enabled for the object token.
        assert!(object::ungated_transfer_allowed(trait_object) == true, EUNGATED_TRANSFER_DISABLED);
        // Add the object to the end of the vector
        vector::push_back<Object<Trait>>(&mut authorized_composable_mut_borrow(&composable_object, signer_ref).traits, trait_object);
        // Transfer
        object::transfer_to_object(signer_ref, trait_object, composable_object);
        // Disable ungated transfer for trait object
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        object::disable_ungated_transfer(&trait_references.transfer_ref);
        // Update the composable uri
        update_composable_uri(signer_ref, composable_object, new_uri);
        // emit event
        emit_trait_equipped_event(
            composable_object,
            trait_object,
            get_trait_index(trait_object),
            token::uri<Trait>(trait_object)
        );
    }

    inline fun update_composable_uri(
        owner: &signer,
        composable_obj: Object<Composable>,
        new_uri: String
    ) acquires Collection {
        let old_uri = token::uri<Composable>(composable_obj);
        let refs = authorized_borrow_refs(&composable_obj, owner);
        token::set_uri(option::borrow(&refs.mutator_ref), new_uri);
        emit_token_uri_updated_event(
            object::object_address(&composable_obj),
            type_info::type_name<Composable>(),
            old_uri,
            new_uri
        );
    }

    // equip fa; transfer fa to a token; token can be either composable or trait
    public fun equip_fa_to_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) acquires Collection, References {
        // assert signer is the owner of the token object
        assert!(object::is_owner<Token>(token_obj, signer::address_of(signer_ref)), ENOT_OWNER);
        let token_obj_addr = object::object_address(&token_obj);
        // assert Token is either composable or trait
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            EUNKNOWN_TOKEN_TYPE
        );
        // transfer 
        primary_fungible_store::transfer(signer_ref, fa, token_obj_addr, amount);
        // emit event
        emit_fa_equipped_event(
            object::address_to_object<Composable>(token_obj_addr),
            signer::address_of(signer_ref),
            amount
        );
    }

    // unequip fa; transfer fa from a token to the owner
    public fun unequip_fa_from_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) acquires Collection, References {
        // assert signer is the owner of the token object
        assert!(object::is_owner<Token>(token_obj, signer::address_of(signer_ref)), ENOT_OWNER);
        // assert Token is either composable or trait
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            EUNKNOWN_TOKEN_TYPE
        );
        // transfer 
        primary_fungible_store::transfer(signer_ref, fa, signer::address_of(signer_ref), amount);
        // emit event
        emit_fa_unequipped_event(
            object::address_to_object<Composable>(object::object_address(&token_obj)),
            signer::address_of(signer_ref),
            amount
        );
    }

    // Decompose a trait from a composable token. Tests panic.
    public fun unequip_trait(
        signer_ref: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>,
        new_uri: String
    ) acquires Collection, Composable, References {
        let (trait_exists, index) = vector::index_of(&mut authorized_composable_mut_borrow(&composable_object, signer_ref).traits, &trait_object);
        assert!(trait_exists == true, ETRAIT_DOES_NOT_EXIST);
        // Enable ungated transfer for trait object
        let trait_refs = borrow_global_mut<References>(object::object_address(&trait_object));
        object::enable_ungated_transfer(&trait_refs.transfer_ref);
        // Transfer trait object to owner
        object::transfer(signer_ref, trait_object, signer::address_of(signer_ref));
        // Remove the object from the vector
        vector::remove(&mut authorized_composable_mut_borrow(&composable_object, signer_ref).traits, index);
        // Update the composable uri
        update_composable_uri(signer_ref, composable_object, new_uri);
        // emit event
        emit_trait_unequipped_event(
            composable_object,
            trait_object,
            index,
            new_uri
        );
    }

    // transfer digital assets; from user to user.
    public fun transfer_token<Token: key>(
        signer_ref: &signer,
        token_addr: address,
        new_owner: address
    ) {
        // assert Token is either composable, trait or FA
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() 
            || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            EUNKNOWN_TOKEN_TYPE
        );

        // assert new owner is not a token
        assert!(!object::is_object(new_owner), ENOT_OWNER);

        // transfer
        object::transfer<TokenV2>(signer_ref, object::address_to_object(token_addr), new_owner);
        // emit event
        emit_token_transferred_event(
            token_addr,
            signer::address_of(signer_ref),
            new_owner
        );
    }

    // transfer fa from user to user.
    public fun transfer_fa<FA: key>(
        signer_ref: &signer,
        recipient: address,
        fa: Object<FA>,
        amount: u64
    ) {
        assert!(!object::is_object(recipient), ENOT_OWNER);
        primary_fungible_store::transfer<FA>(signer_ref, fa, recipient, amount);
        // emit event
        emit_fa_transferred_event(
            object::object_address(&fa),
            signer::address_of(signer_ref),
            recipient,
            amount
        );
    }

    // ---------
    // Accessors
    // ---------

    inline fun collection_object(creator: &signer, name: &String): Object<Collection> {
        let collection_addr = collection::create_collection_address(&signer::address_of(creator), name);
        object::address_to_object<Collection>(collection_addr)
    }

    inline fun borrow_collection<T: key>(token: &Object<T>): &Collection {
        let collection_address = object::object_address(token);
        assert!(
            exists<Collection>(collection_address),
            error::not_found(ECOLLECTION_DOES_NOT_EXIST),
        );
        borrow_global<Collection>(collection_address)
    }
    
    inline fun borrow_composable<T: key>(token: &Object<T>): &Composable {
        let token_addr = object::object_address(token);
        assert!(
            exists<Composable>(token_addr),
            error::not_found(ECOMPOSABLE_DOES_NOT_EXIST),
        );
        borrow_global<Composable>(token_addr)
    }

    inline fun borrow_trait<T: key>(token: &Object<T>): &Trait {
        let token_addr = object::object_address(token);
        assert!(
            exists<Trait>(token_addr),
            error::not_found(ETRAIT_DOES_NOT_EXIST),
        );
        borrow_global<Trait>(token_addr)
    }

    inline fun borrow_refs<T: key>(token: &Object<T>): &References acquires References {
        let token_addr = object::object_address(token);
        assert!(
            exists<References>(token_addr),
            error::not_found(EREFS_DOES_NOT_EXIST),
        );
        borrow_global<References>(token_addr)
    }

    inline fun borrow_mut_traits(composable_address: address): vector<Object<Trait>> acquires Composable {
        borrow_global_mut<Composable>(composable_address).traits
    }

    public fun is_mutable_collection_description<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_description
    }

    public fun is_mutable_collection_royalty<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        option::is_some(&borrow_collection(&collection).royalty_mutator_ref)
    }

    public fun is_mutable_collection_uri<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_uri
    }

    public fun is_mutable_collection_token_description<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_token_description
    }

    public fun is_mutable_collection_token_name<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_token_name
    }

    public fun is_mutable_collection_token_uri<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_token_uri
    }

    public fun is_mutable_collection_token_properties<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).mutable_token_properties
    }

    public fun are_collection_tokens_burnable<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).tokens_burnable_by_creator
    }

    public fun are_collection_tokens_freezable<T: key>(
        collection: Object<T>,
    ): bool acquires Collection {
        borrow_collection(&collection).tokens_freezable_by_creator
    }

    public fun get_collection_name(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).name
    }

    public fun get_collection_symbol(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).symbol
    }

    public fun get_collection_supply_type(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).supply_type
    }

    public fun get_trait_index(trait_object: Object<Trait>): u64 acquires Trait {
        let object_address = object::object_address(&trait_object);
        borrow_global<Trait>(object_address).index
    }

    public fun get_traits_from_composable(composable_object: Object<Composable>): vector<Object<Trait>> acquires Composable {
        let object_address = object::object_address(&composable_object);
        borrow_global<Composable>(object_address).traits  
    }

    public fun are_properties_mutable<T: key>(token: Object<T>): bool acquires Collection {
        let collection = token::collection_object(token);
        borrow_collection(&collection).mutable_token_properties
    }

    public fun is_burnable<T: key>(token: Object<T>): bool acquires References {
        option::is_some(&borrow_refs(&token).burn_ref)
    }

    public fun is_freezable_by_creator<T: key>(token: Object<T>): bool acquires Collection {
        are_collection_tokens_freezable(token::collection_object(token))
    }

    public fun is_mutable_description<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_description(token::collection_object(token))
    }

    public fun is_mutable_name<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_name(token::collection_object(token))
    }

    public fun is_mutable_uri<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_uri(token::collection_object(token))
    }

    public fun get_token_signer<T: key>(token: Object<T>): signer acquires References {
        object::generate_signer_for_extending(&borrow_refs(&token).extend_ref)
    }

    // --------
    // Mutators
    // --------

    inline fun authorized_composable_borrow<T: key>(token: &Object<T>, owner: &signer): &Composable {
        let token_addr = object::object_address(token);
        assert!(
            exists<Composable>(token_addr),
            error::not_found(ECOMPOSABLE_DOES_NOT_EXIST),
        );

        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_CREATOR),
        );
        borrow_global<Composable>(token_addr)
    }

    inline fun authorized_composable_mut_borrow<T: key>(token: &Object<T>, owner: &signer): &mut Composable {
        let token_addr = object::object_address(token);
        assert!(
            exists<Composable>(token_addr),
            error::not_found(ECOMPOSABLE_DOES_NOT_EXIST),
        );

        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_OWNER),
        );
        borrow_global_mut<Composable>(token_addr)
    }

    inline fun authorized_trait_borrow<T: key>(token: &Object<T>, owner: &signer): &Trait {
        let token_addr = object::object_address(token);
        assert!(
            exists<Trait>(token_addr),
            error::not_found(ETRAIT_DOES_NOT_EXIST),
        );

        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_OWNER),
        );
        borrow_global<Trait>(token_addr)
    }

    inline fun authorized_trait_mut_borrow<T: key>(token: &Object<T>, owner: &signer): &mut Trait {
        let token_addr = object::object_address(token);
        assert!(
            exists<Trait>(token_addr),
            error::not_found(ETRAIT_DOES_NOT_EXIST),
        );

        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_OWNER),
        );
        borrow_global_mut<Trait>(token_addr)
    }

    inline fun authorized_borrow_refs<T: key>(token: &Object<T>, owner: &signer): &References acquires References {
        let token_addr = object::object_address(token);
        assert!(
            exists<References>(token_addr),
            error::not_found(EREFS_DOES_NOT_EXIST),
        );
        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_OWNER),
        );
        borrow_global<References>(token_addr)
    }

    inline fun authorized_mut_borrow_refs<T: key>(token: &Object<T>, owner: &signer): &mut References acquires References {
        let token_addr = object::object_address(token);
        assert!(
            exists<References>(token_addr),
            error::not_found(EREFS_DOES_NOT_EXIST),
        );
        assert!(
            object::is_owner(*token, signer::address_of(owner)),
            error::permission_denied(ENOT_OWNER),
        );
        borrow_global_mut<References>(token_addr)
    }

    // owner burns token based on type
    public fun burn_token<Type: key>(owner: &signer, token: Object<Type>) acquires Composable, References, Trait {
        // TODO: assert is a composable or trait
        let token_addr = object::object_address(&token);
        let refs = authorized_borrow_refs(&token, owner);
        if (type_info::type_of<Type>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, owner);
            assert!(
                option::is_some(&refs.burn_ref),
                error::permission_denied(ECOMPOSABLE_DOES_NOT_EXIST),
            );
            move composable;
            let composable = move_from<Composable>(object::object_address(&token));
            let Composable { traits: _ } = composable;
            emit_token_burned_event(token_addr, type_info::type_name<Composable>());
        } else if (type_info::type_of<Type>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, owner);
            assert!(
                option::is_some(&refs.burn_ref),
                error::permission_denied(ETRAIT_DOES_NOT_EXIST),
            );
            move trait;
            let trait = move_from<Trait>(object::object_address(&token));
            let Trait { index: _ } = trait;
            emit_token_burned_event(token_addr, type_info::type_name<Trait>());
        } else { abort EUNKNOWN_TOKEN_TYPE };
        
        move refs;
        let refs = move_from<References>(object::object_address(&token));
        let References {
            burn_ref,
            extend_ref: _,
            mutator_ref: _,
            transfer_ref: _,
            property_mutator_ref ,
        } = refs;
        property_map::burn(property_mutator_ref);
        token::burn(option::extract(&mut burn_ref));
    }

    // freeze token based on type
    public fun freeze_transfer<T: key>(creator: &signer, token: Object<T>) acquires Collection, References {
        assert!(
            are_collection_tokens_freezable(token::collection_object(token)),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        let refs = authorized_borrow_refs(&token, creator);
        object::disable_ungated_transfer(&refs.transfer_ref);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_transfer_frozen_event(object::object_address(&token), type_info::type_name<Composable>());
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_transfer_frozen_event(object::object_address(&token), type_info::type_name<Trait>());
        } else { abort EUNKNOWN_TOKEN_TYPE };
        
    }

    // unfreeze token based on type
    public fun unfreeze_transfer<T: key>(creator: &signer, token: Object<T>) acquires Collection, References {
        assert!(
            are_collection_tokens_freezable(token::collection_object(token)),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        let refs = authorized_borrow_refs(&token, creator);
        object::enable_ungated_transfer(&refs.transfer_ref);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_transfer_unfrozen_event(object::object_address(&token), type_info::type_name<Composable>());
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_transfer_unfrozen_event(object::object_address(&token), type_info::type_name<Trait>());
        } else { abort EUNKNOWN_TOKEN_TYPE };
        
    }

    // set token description 
    public fun set_description<T: key>(
        creator: &signer,
        token: Object<T>,
        description: String,
    ) acquires Collection, References {
        assert!(
            is_mutable_description(token),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        let old_description = token::description(token);
        let refs = authorized_borrow_refs(&token, creator);
        token::set_description(option::borrow(&refs.mutator_ref), description);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_token_description_updated_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                old_description,
                description,
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_token_description_updated_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                old_description,
                description,
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token name
    public fun set_name<T: key>(
        creator: &signer,
        token: Object<T>,
        name: String,
    ) acquires Collection, References {
        assert!(
            is_mutable_name(token),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        let old_name = token::name(token);
        let refs = authorized_borrow_refs(&token, creator);
        token::set_name(option::borrow(&refs.mutator_ref), name);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_token_name_updated_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                old_name,
                name,
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_token_name_updated_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                old_name,
                name,
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token uri
    // Can be used only on traits that have a mutable uri.
    public fun set_trait_uri(
        owner: &signer,
        trait_obj: Object<Trait>,
        uri: String,
    ) acquires Collection, References {
        // assert signer is the owner of the token object
        // TODO: is this needed
        assert!(object::is_owner<Trait>(trait_obj, signer::address_of(owner)), ENOT_OWNER);
        assert!(
            is_mutable_uri(trait_obj),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        let old_uri = token::uri(trait_obj);
        let refs = authorized_borrow_refs(&trait_obj, owner);
        token::set_uri(option::borrow(&refs.mutator_ref), uri);
        emit_token_uri_updated_event(
            object::object_address<Trait>(&trait_obj),
            type_info::type_name<Trait>(),
            old_uri,
            uri,
        );
    }

    // set token properties
    public fun add_property<T: key>(
        owner: &signer,
        token: Object<T>,
        key: String,
        type: String,
        value: vector<u8>,
    ) acquires Collection, References {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        let refs = authorized_borrow_refs(&token, owner);
        property_map::add(&refs.property_mutator_ref, key, type, value);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_property_added_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                key,
                type,
                value,
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_property_added_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                key,
                type,
                value,
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    public fun add_typed_property<T: key, V: drop>(
        owner: &signer,
        token: Object<T>,
        key: String,
        value: V,
    ) acquires Collection, References {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        let refs = authorized_borrow_refs(&token, owner);
        property_map::add_typed(&refs.property_mutator_ref, key, value);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_typed_property_added_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                key,
                type_info::type_name<V>(),
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_typed_property_added_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                key,
                type_info::type_name<V>(),
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // remove token properties
    public fun remove_property<T: key>(
        owner: &signer,
        token: Object<T>,
        key: String,
    ) acquires Collection, References {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        let refs = authorized_borrow_refs(&token, owner);
        property_map::remove(&refs.property_mutator_ref, &key);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_property_removed_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                key,
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_property_removed_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                key,
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // update token properties
    public fun update_property<T: key>(
        owner: &signer,
        token: Object<T>,
        key: String,
        value: vector<u8>,
    ) acquires Collection, References {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        let (_, old_value) = property_map::read(&token, &key);
        let refs = authorized_borrow_refs(&token, owner);
        property_map::update_typed(&refs.property_mutator_ref, &key, value);
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            emit_property_updated_event(
                object::object_address(&token),
                type_info::type_name<Composable>(),
                key,
                old_value,
                value,
            );
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            emit_property_updated_event(
                object::object_address(&token),
                type_info::type_name<Trait>(),
                key,
                old_value,
                value,
            );
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }
}