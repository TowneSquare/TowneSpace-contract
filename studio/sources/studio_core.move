/*
    OUTDATED DESCRIPTION:
    TODO: update description
    - This contract is the core of the studio.
    - It allows to create studio, and correspondingly tokens and collections.
    - tokens logics is built on top of aptos_token.move.
    - A user can mint the following:
        - Plain token: a token V2.
        - Dynamic token: composed of two or more plain tokens.
        - Composed token: TBA.
        - Collections.

    TODO: add reference to aptos_token.move
    TODO: add events.
    TODO: add asserts.
    TODO: organise functions
    TODO: add init_module
    TODO: create collection for dynamic tokens.
    TODO: enforce #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    TODO: add function to transform a dynamic nft into a plain token. (compress?)
    TODO: add function to add properties to a token.
*/
module townesquare::studio_core {

    use aptos_framework::object::{Self, ConstructorRef, Object};
    use aptos_framework::timestamp;
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::collection;
    use aptos_token_objects::property_map;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;
    use std::error;
    use std::features;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    /// ------
    /// Errors
    /// ------
    
    /// ---------
    /// Constants
    /// ---------
    // TODO: constants for fast combine function

    // -------
    // Structs
    // -------
    
    // Replicated from https://github.com/aptos-labs/aptos-core/blob/3791dc07ec457496c96e5069c494d46c1ff49b41/aptos-move/framework/aptos-token-objects/sources/aptos_token.move#L36C1-L36C1
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Storage state for managing the no-code Collection.
    struct AptosCollection has key {
        /// Used to mutate collection fields
        mutator_ref: Option<collection::MutatorRef>,
        /// Used to mutate royalties
        royalty_mutator_ref: Option<royalty::MutatorRef>,
        /// Determines if the creator can mutate the collection's description
        mutable_description: bool,
        /// Determines if the creator can mutate the collection's uri
        mutable_uri: bool,
        /// Determines if the creator can mutate token descriptions
        mutable_token_description: bool,
        /// Determines if the creator can mutate token names
        mutable_token_name: bool,
        /// Determines if the creator can mutate token properties
        mutable_token_properties: bool,
        /// Determines if the creator can mutate token uris
        mutable_token_uri: bool,
        /// Determines if the creator can burn tokens
        tokens_burnable_by_creator: bool,
        /// Determines if the creator can freeze tokens
        tokens_freezable_by_creator: bool,
    }

    // Storage state for managing Token Collection
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TokenCollection has key {
        name: String,
        symbol: String,
        // TODO: Timestamp
        // TODO: add more data?
        // TODO: add events
    }

    // Storage state for managing Plain Token
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TraitToken has key {
        collection: String,
        description: String,
        name: String,
        uri: String,
        // TODO: Timestamp
        // TODO: add events
    }

    // Storage state for managing Dynamic token
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct DynamicToken has key {
        collection: String,
        description: String,
        name: String,
        uri: String,
        // TODO: is there specific attributes that should be standardised?
        // The trait_tokens of the dynamic token.
        trait_tokens: vector<Object<TraitToken>>, // vector of trait_tokens
        // Allows to burn the dynamic token.
        burn_ref: Option<token::BurnRef>,
        // Controls the transfer of the dynamic token.
        transfer_ref: Option<object::TransferRef>,
        // Allows to mutate fields of the dynamic token.
        mutator_ref: Option<token::MutatorRef>,
        // Allows to mutate properties of the dynamic token.
        property_mutator_ref: property_map::MutatorRef,
        // TODO: Timestamp
        // TODO: add events
    }

    // ---------------
    // Entry Functions
    // ---------------

    // Create a new collection
    public entry fun create_collection(
        creator: &signer,
        description: String,
        max_supply: u64,
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
        royalty_numerator: u64,
        royalty_denominator: u64,
    ) acquires TokenCollection {
        create_collection_internal(
            creator,
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
            royalty_denominator,
        );
    }

    fun create_collection_internal(
        creator: &signer,
        description: String,
        max_supply: u64,
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
        royalty_numerator: u64,
        royalty_denominator: u64,
    ) acquires TokenCollection {
        // TODO assert the signer is the creator.
        aptos_token::create_collection(
            creator,
            description,
            max_supply,
            name,
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
            royalty_denominator,
        );
        let creator_address = signer::address_of(creator);
        let collection = borrow_global_mut<TokenCollection>(creator_address);

        let collection_name = collection.name;
        // Move to resource account.
        let new_token_collection = TokenCollection {
            name: collection_name,
            symbol: symbol,
            // TODO: see what other attributes to include
        };
        move_to(creator, new_token_collection);

        // TODO Add events
    }

    // Mint a plain token
    public entry fun mint_plain_token(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) {
        // TODO assert the token collection exists.
        mint_plain_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        )
    }

    fun mint_plain_token_internal(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) {
        aptos_token::mint(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        );
        // TODO move to plain token resource
        let new_plain_token = TraitToken {
            collection: collection,
            description: description,
            name: name,
            uri: uri,
        };
        move_to(creator, new_plain_token);
        // TODO: event plain token minted
    }

    // Mint a dynamic token
    /*
        The user have two or more plain tokens and wants to combine them,
        to do so, the user has to use this function.
        This will mint a new dynamic token and combine the trait_tokens.
        - The user has to specify the dynamic token's attributes.
        - The user has to specify which trait_tokens to combine.
        - params:
    */
    fun mint_dynamic_token(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        trait_tokens: vector<Object<TraitToken>>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): Object<DynamicToken> acquires TokenCollection, DynamicToken, AptosCollection {
        let constructor_ref = mint_dynamic_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            trait_tokens,
            property_keys,
            property_types,
            property_values,
        );

        let collection = collection_object(creator, &collection);
        // TODO: check if this function is not written.
        // Asserts the creator is the owner of the collection.
        
        // If tokens are freezable, add a transfer ref to be able to freeze transfers
        let freezable_by_creator = aptos_token::are_collection_tokens_freezable(collection);
        if (freezable_by_creator) {
            let dynamic_token_address = object::address_from_constructor_ref(&constructor_ref);
            let dynamic_token = borrow_global_mut<DynamicToken>(dynamic_token_address);
            let transfer_ref = object::generate_transfer_ref(&constructor_ref);
            option::fill(&mut dynamic_token.transfer_ref, transfer_ref);
        };

        object::object_from_constructor_ref(&constructor_ref)

        // TODO: event dynamic token minted
    }

    fun mint_dynamic_token_internal(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        trait_tokens: vector<Object<TraitToken>>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): ConstructorRef acquires AptosCollection, TokenCollection {
        let constructor_ref = if (features::auids_enabled()) {
            token::create(
                creator,
                collection,
                description,
                name,
                option::none(),
                uri,
            )
        } else {
            token::create_from_account(
                creator,
                collection,
                description,
                name,
                option::none(),
                uri,
            )
        };

        let object_signer = object::generate_signer(&constructor_ref);

        let collection_obj = collection_object(creator, &collection);
        let collection = borrow_collection(&collection_obj);

        let mutator_ref = if (
            collection.mutable_token_description
                || collection.mutable_token_name
                || collection.mutable_token_uri
        ) {
            option::some(token::generate_mutator_ref(&constructor_ref))
        } else {
            option::none()
        };

        let burn_ref = if (collection.tokens_burnable_by_creator) {
            option::some(token::generate_burn_ref(&constructor_ref))
        } else {
            option::none()
        };

        let creator_address = signer::address_of(creator);
        let collection = borrow_global_mut<TokenCollection>(creator_address);

        let collection_name = collection.name;

        // TODO: initialze it with trait_tokens vector if it exists. Empty otherwise.
        if (vector::length(&trait_tokens) == 0) {
            let new_dynamic_token = DynamicToken {
            collection: collection_name,
            description: description,
            name: name,
            uri: uri,  
            trait_tokens: vector::empty(),
            burn_ref,
            transfer_ref: option::none(),
            mutator_ref,
            property_mutator_ref: property_map::generate_mutator_ref(&constructor_ref),
        };
        move_to(&object_signer, new_dynamic_token);
        } else {
            let new_dynamic_token = DynamicToken {
            collection: collection_name,
            description: description,
            name: name,
            uri: uri,  
            trait_tokens: trait_tokens,
            burn_ref,
            transfer_ref: option::none(),
            mutator_ref,
            property_mutator_ref: property_map::generate_mutator_ref(&constructor_ref),
        };
        move_to(&object_signer, new_dynamic_token);
        };

        let properties = property_map::prepare_input(property_keys, property_types, property_values);
        property_map::init(&constructor_ref, properties);

        constructor_ref
    }

    // Combine object.
    // TODO: this should be used in both dynamic and composite tokens?
    public entry fun combine_object(
        creator: &signer, 
        dynamic_token: Object<DynamicToken>,
        object: Object<TraitToken>
    ) acquires DynamicToken {    
        combine_object_internal(creator, dynamic_token, object);
    }

    fun combine_object_internal(
        creator: &signer, 
        dynamic_token: Object<DynamicToken>,
        object: Object<TraitToken>
    ) acquires DynamicToken {
        // TODO assert token exists
        let creator_address = signer::address_of(creator);
        let dynamic_token_object = borrow_global_mut<DynamicToken>(object::object_address(&dynamic_token)); 
        
        // index = vector length
        let index = vector::length(&dynamic_token_object.trait_tokens);
        // TODO: Assert transfer is not freezed (object not equiped to dynamic nft)
        // TODO: Assert the signer is the owner 
        // TODO: Assert the object does not exist in the dynamic token

        
        // TODO: add the object to the vector
        vector::insert<Object<TraitToken>>(&mut dynamic_token_object.trait_tokens, index, object);
        // TODO: Transfer the object to the dynamic token
        object::transfer_to_object(creator, object, dynamic_token);
        // Freeze transfer
        aptos_token::freeze_transfer(creator, object);
        // TODO: event here (overall events here, explicit ones in internal) 
    }

    // Uncombine tokens
    // TODO: this should be used in both dynamic and composite tokens?
    public entry fun uncombine_object(
        owner: &signer, 
        dynamic_token: Object<DynamicToken>,
        object: Object<TraitToken>
    ) acquires DynamicToken {  
        uncombine_object_internal(owner, dynamic_token, object);
        // TODO: event here (overal events here, explicit ones in internal)
    }

    fun uncombine_object_internal(
        owner: &signer,
        dynamic_token: Object<DynamicToken>,
        object: Object<TraitToken>
    ) acquires DynamicToken {
        // TODO assert token exists
        let dynamic_token_object = borrow_global_mut<DynamicToken>(object::object_address(&dynamic_token)); 
        // TODO: get the index "i" of the object. Prob use borrow and inline funcs
        // TODO: store it in i
        // pattern matching
        let (_, index) = vector::index_of(&dynamic_token_object.trait_tokens, &object);
        // TODO: assert the object exists in the dynamic token
        // Unfreeze transfer
        aptos_token::unfreeze_transfer(owner, object);
        // Remove the object from the vector
        vector::remove<Object<TraitToken>>(&mut dynamic_token_object.trait_tokens, index);
        // Transfer
        object::transfer(owner, object, signer::address_of(owner));
        // TODO: events
    }

    // Fast combine function
    /*
        The user can choose two or more trait_tokens to combine,
        this will mint a dynamic token and transfer the trait_tokens to it.
        The user can later set the properties of the dynamic token.
    */
    public entry fun fast_combine(
        creator: &signer,
        collection_name: String,
        token_name: String,
        trait_tokens_to_combine: vector<Object<TraitToken>>
    ) acquires TokenCollection, DynamicToken, AptosCollection {
        let property_keys = vector::empty<String>();
        let property_types = vector::empty<String>();
        let property_values = vector::empty<vector<u8>>();

        // TODO: Mint a dynamic token with constant properties.
        mint_dynamic_token(
        creator,
        collection_name,
        string::utf8(b"Fast Combined"), // description
        token_name,
        string::utf8(b"uri"), 
        trait_tokens_to_combine,
        property_keys,
        property_types,
        property_values,
        );
        let i = 0;
        while (i < vector::length(&trait_tokens_to_combine)) {
            let object = vector::borrow(&trait_tokens_to_combine, i);
            // TODO assert token exists
            // TODO: Freeze transfer.
            i = i + 1;
        }
    }
        
    // TODO: Delete a dynamic token
    /*
        steps:
        - Uncombines the dynamic token
        - Burns the dynamic token
    */
    public entry fun burn_dynamic_token(

    ) {
        // TODO assert token exists

    }

    // TODO: freeze transfer
    /*
        TODO: - should the user interact directly with aptos_token.move?
    */

    // Transfer function
    public entry fun raw_transfer(
        owner: &signer, 
        object_address: address,
    ) {
        // TODO assert token exists
        // TODO: Assert transfer is unfreezed (object not equiped to dynamic nft)
        // TODO: Assert the signer is the object owner
        let owner_address = signer::address_of(owner);
        // Transfer
        let object = object::address_to_object<TraitToken>(object_address);
        object::transfer(owner, object, owner_address);
        // TODO: event
    }

    // Transfer with a fee function
    public entry fun transfer_with_fee(
        owner: &signer, 
        object_address: address,
    ) {
        // TODO assert token exists
        // TODO: Assert transfer is unfreezed (object not equiped to dynamic nft)
        // TODO: Assert the signer is the object owner
        let owner_address = signer::address_of(owner);
        // TODO: Include a small fee
        // Transfer
        let object = object::address_to_object<TraitToken>(object_address);
        object::transfer(owner, object, owner_address);
        // TODO: event
    }

    // --------------
    // View Functions
    // --------------

    // --------
    // Mutators
    // --------

    // ---------
    // Accessors
    // ---------

    // Collection
    inline fun collection_object(creator: &signer, name: &String): Object<aptos_token::AptosCollection> {
        let collection_addr = collection::create_collection_address(&signer::address_of(creator), name);
        object::address_to_object<aptos_token::AptosCollection>(collection_addr)
    }

    inline fun borrow_collection<T: key>(token: &Object<T>): &AptosCollection {
        let collection_address = object::object_address(token);
        assert!(
            exists<AptosCollection>(collection_address),
            error::not_found(1), //ECOLLECTION_DOES_NOT_EXIST
        );
        borrow_global<AptosCollection>(collection_address)
    }
    
}