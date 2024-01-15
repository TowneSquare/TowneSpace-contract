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
        - improve error handling
        - change the name for the module: Token creator? Token factory?
        - Organize the functions
        - Add events
        
*/

module townespace::core {
    
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
    use std::string::{Self, String};
    use std::vector;

    // use townespace::asserts;

    // ------
    // Errors
    // ------

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
        traits: vector<Object<Trait>>,
        base_mint_price: u64,
        refs: References
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for traits
    struct Trait has key {
        index: u64, // index from the vector
        base_mint_price: u64,
        refs: References
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for token references, sticked to the token object
    struct References has key, store {
        burn_ref: Option<token::BurnRef>,
        extend_ref: object::ExtendRef,
        mutator_ref: Option<token::MutatorRef>,
        transfer_ref: object::TransferRef,
        property_mutator_ref: property_map::MutatorRef
    }

    struct Named has key {}

    struct Indexed has key {}

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
    ): object::ConstructorRef {
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

        // TODO: emit event
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
    ): object::ConstructorRef acquires Collection {
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
    ) acquires Collection {
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
                Composable {
                    traits,
                    base_mint_price: 0,
                    refs
                }
            );
        } else if (type_info::type_of<Type>() == type_info::type_of<Trait>()) {
            let index = 0;
            // create the trait resource
            move_to(
                &obj_signer, 
                Trait {
                    index,
                    base_mint_price: 0,
                    refs
                }
            );
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
    ): object::ConstructorRef acquires Collection {
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

        // TODO: emit event
        constructor_ref
    }

    // Compose trait to a composable token
    public fun equip_trait_internal(
        signer_ref: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable 
        let composable_res = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait_refs = borrow_global_mut<References>(object::object_address(&trait_object));
        // Add the object to the end of the vector
        vector::push_back<Object<Trait>>(&mut composable_res.traits, trait_object);
        // Assert ungated transfer enabled for the object token.
        assert!(object::ungated_transfer_allowed(trait_object) == true, EUNGATED_TRANSFER_DISABLED);
        // Transfer
        object::transfer_to_object(signer_ref, trait_object, composable_object);
        // Disable ungated transfer for trait object
        object::disable_ungated_transfer(&trait_refs.transfer_ref);
    }

    // equip fa; transfer fa to a token; token can be either composable or trait
    public fun equip_fa_to_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) {
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
    }

    // unequip fa; transfer fa from a token to the owner
    public fun unequip_fa_from_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) {
        // assert signer is the owner of the token object
        assert!(object::is_owner<Token>(token_obj, signer::address_of(signer_ref)), ENOT_OWNER);
        // assert Token is either composable or trait
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            EUNKNOWN_TOKEN_TYPE
        );
        // transfer 
        primary_fungible_store::transfer(signer_ref, fa, signer::address_of(signer_ref), amount);
    }

    // Decompose a trait from a composable token. Tests panic.
    public fun unequip_trait_internal(
        signer_ref: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable
        let composable_resource = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        let (trait_exists, index) = vector::index_of(&composable_resource.traits, &trait_object);
        assert!(trait_exists == true, ETRAIT_DOES_NOT_EXIST);
        // Enable ungated transfer for trait object
        object::enable_ungated_transfer(&trait_references.transfer_ref);
        // Transfer trait object to owner
        object::transfer(signer_ref, trait_object, signer::address_of(signer_ref));
        // Remove the object from the vector
        vector::remove(&mut composable_resource.traits, index);
    }

    // transfer digital assets; from user to user.
    public fun transfer_token<Token: key>(
        signer_ref: &signer,
        token_address: address,
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
        object::transfer<TokenV2>(signer_ref, object::address_to_object(token_address), new_owner)
    }

    // transfer fa from user to user.
    public fun transfer_fa<FA: key>(
        signer_ref: &signer,
        recipient: address,
        fa: Object<FA>,
        amount: u64
    ) {
        assert!(!object::is_object(recipient), ENOT_OWNER);
        primary_fungible_store::transfer<FA>(signer_ref, fa, recipient, amount)
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
        let token_address = object::object_address(token);
        assert!(
            exists<Composable>(token_address),
            error::not_found(ECOMPOSABLE_DOES_NOT_EXIST),
        );
        borrow_global<Composable>(token_address)
    }

    inline fun borrow_trait<T: key>(token: &Object<T>): &Trait {
        let token_address = object::object_address(token);
        assert!(
            exists<Trait>(token_address),
            error::not_found(ETRAIT_DOES_NOT_EXIST),
        );
        borrow_global<Trait>(token_address)
    }

    public fun borrow_mut_traits(composable_address: address): vector<Object<Trait>> acquires Composable {
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

    // --------------
    // View Functions
    // --------------

    #[view]
    public fun get_collection_name(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).name
    }

    #[view]
    public fun get_collection_symbol(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).symbol
    }

    #[view]
    // get mint price of a token
    public fun get_base_mint_price<T: key>(object_address: address): u64 acquires Composable, Trait {
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            borrow_global<Composable>(object_address).base_mint_price
        } else { borrow_global<Trait>(object_address).base_mint_price }
    }

    #[view]
    public fun get_traits_from_composable(composable_object: Object<Composable>): vector<Object<Trait>> acquires Composable {
        let object_address = object::object_address(&composable_object);
        borrow_global<Composable>(object_address).traits  
    }

    #[view]
    public fun are_properties_mutable<T: key>(token: Object<T>): bool acquires Collection {
        let collection = token::collection_object(token);
        borrow_collection(&collection).mutable_token_properties
    }

    #[view]
    public fun is_burnable<T: key>(token: Object<T>): bool acquires Composable, Trait {
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            option::is_some(&borrow_composable(&token).refs.burn_ref)
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            option::is_some(&borrow_trait(&token).refs.burn_ref)
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    #[view]
    public fun is_freezable_by_creator<T: key>(token: Object<T>): bool acquires Collection {
        are_collection_tokens_freezable(token::collection_object(token))
    }

    #[view]
    public fun is_mutable_description<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_description(token::collection_object(token))
    }

    #[view]
    public fun is_mutable_name<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_name(token::collection_object(token))
    }

    #[view]
    public fun is_mutable_uri<T: key>(token: Object<T>): bool acquires Collection {
        is_mutable_collection_token_uri(token::collection_object(token))
    }

    // --------
    // Mutators
    // --------

    inline fun authorized_composable_borrow<T: key>(token: &Object<T>, creator: &signer): &Composable {
        let token_address = object::object_address(token);
        assert!(
            exists<Composable>(token_address),
            error::not_found(ECOMPOSABLE_DOES_NOT_EXIST),
        );

        assert!(
            token::creator(*token) == signer::address_of(creator),
            error::permission_denied(ENOT_CREATOR),
        );
        borrow_global<Composable>(token_address)
    }

    inline fun authorized_trait_borrow<T: key>(token: &Object<T>, creator: &signer): &Trait {
        let token_address = object::object_address(token);
        assert!(
            exists<Trait>(token_address),
            error::not_found(ETRAIT_DOES_NOT_EXIST),
        );

        assert!(
            token::creator(*token) == signer::address_of(creator),
            error::permission_denied(ENOT_CREATOR),
        );
        borrow_global<Trait>(token_address)
    }

    // burn token based on type
    public fun burn_token<Type: key>(creator: &signer, token: Object<Type>) acquires Composable, Trait {
        if (type_info::type_of<Type>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            assert!(
                option::is_some(&composable.refs.burn_ref),
                error::permission_denied(ECOMPOSABLE_DOES_NOT_EXIST),
            );
            move composable;
            let composable = move_from<Composable>(object::object_address(&token));
            let Composable {
                traits: _,
                base_mint_price: _,
                refs: References {
                    burn_ref,
                    extend_ref: _,
                    mutator_ref: _,
                    transfer_ref: _,
                    property_mutator_ref ,
                }
            } = composable;
            property_map::burn(property_mutator_ref);
            token::burn(option::extract(&mut burn_ref));
        } else if (type_info::type_of<Type>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            assert!(
                option::is_some(&trait.refs.burn_ref),
                error::permission_denied(ETRAIT_DOES_NOT_EXIST),
            );
            move trait;
            let trait = move_from<Trait>(object::object_address(&token));
            let Trait {
                index: _,
                base_mint_price: _,
                refs: References {
                    burn_ref,
                    extend_ref: _,
                    mutator_ref: _,
                    transfer_ref: _,
                    property_mutator_ref ,
                }
            } = trait;
            property_map::burn(property_mutator_ref);
            token::burn(option::extract(&mut burn_ref));
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // freeze token based on type
    public fun freeze_transfer<T: key>(creator: &signer, token: Object<T>) acquires Collection, Composable, Trait {
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            assert!(
                are_collection_tokens_freezable(token::collection_object(token)),
                error::permission_denied(EFIELD_NOT_MUTABLE),
            );
            object::disable_ungated_transfer(&composable.refs.transfer_ref);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            assert!(
                are_collection_tokens_freezable(token::collection_object(token)),
                error::permission_denied(EFIELD_NOT_MUTABLE),
            );
            object::disable_ungated_transfer(&trait.refs.transfer_ref);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // unfreeze token based on type
    public fun unfreeze_transfer<T: key>(creator: &signer, token: Object<T>) acquires Collection, Composable, Trait {
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            assert!(
                are_collection_tokens_freezable(token::collection_object(token)),
                error::permission_denied(EFIELD_NOT_MUTABLE),
            );
            object::enable_ungated_transfer(&composable.refs.transfer_ref);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            assert!(
                are_collection_tokens_freezable(token::collection_object(token)),
                error::permission_denied(EFIELD_NOT_MUTABLE),
            );
            object::enable_ungated_transfer(&trait.refs.transfer_ref);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token description 
    public fun set_description<T: key>(
        creator: &signer,
        token: Object<T>,
        description: String,
    ) acquires Collection, Composable, Trait {
        assert!(
            is_mutable_description(token),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            token::set_description(option::borrow(&composable.refs.mutator_ref), description);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            token::set_description(option::borrow(&trait.refs.mutator_ref), description);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token name
    public fun set_name<T: key>(
        creator: &signer,
        token: Object<T>,
        name: String,
    ) acquires Collection, Composable, Trait {
        assert!(
            is_mutable_name(token),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            token::set_name(option::borrow(&composable.refs.mutator_ref), name);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            token::set_name(option::borrow(&trait.refs.mutator_ref), name);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token uri
    // TODO: should this be for both composable and trait?
    public fun set_uri<T: key>(
        owner: &signer,
        token: Object<T>,
        uri: String,
    ) acquires Collection, Composable, Trait {
        assert!(
            is_mutable_uri(token),
            error::permission_denied(EFIELD_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, owner);
            token::set_uri(option::borrow(&composable.refs.mutator_ref), uri);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, owner);
            token::set_uri(option::borrow(&trait.refs.mutator_ref), uri);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // set token properties
    public fun add_property<T: key>(
        creator: &signer,
        token: Object<T>,
        key: String,
        type: String,
        value: vector<u8>,
    ) acquires Collection, Composable, Trait {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            property_map::add(&composable.refs.property_mutator_ref, key, type, value);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            property_map::add(&trait.refs.property_mutator_ref, key, type, value);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    public fun add_typed_property<T: key, V: drop>(
        creator: &signer,
        token: Object<T>,
        key: String,
        value: V,
    ) acquires Collection, Composable, Trait {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            property_map::add_typed(&composable.refs.property_mutator_ref, key, value);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            property_map::add_typed(&trait.refs.property_mutator_ref, key, value);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // remove token properties
    public fun remove_property<T: key>(
        creator: &signer,
        token: Object<T>,
        key: String,
    ) acquires Collection, Composable, Trait {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            property_map::remove(&composable.refs.property_mutator_ref, &key);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            property_map::remove(&trait.refs.property_mutator_ref, &key);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }

    // update token properties
    public fun update_property<T: key>(
        creator: &signer,
        token: Object<T>,
        key: String,
        value: vector<u8>,
    ) acquires Collection, Composable, Trait {
        assert!(
            are_properties_mutable(token),
            error::permission_denied(EPROPERTIES_NOT_MUTABLE),
        );
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = authorized_composable_borrow(&token, creator);
            property_map::update_typed(&composable.refs.property_mutator_ref, &key, value);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = authorized_trait_borrow(&token, creator);
            property_map::update_typed(&trait.refs.property_mutator_ref, &key, value);
        } else { abort EUNKNOWN_TOKEN_TYPE }
    }
}