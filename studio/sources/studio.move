/*
    TODO: description
*/

module townespace::studio {
    use aptos_framework::object::{Self, Object};

    //use std::error;
    // use std::features;
    use std::string::{String};

    use townespace::core::{
        Self,  
        ComposableToken, 
        ObjectToken
        };

    use townespace::events;

    // -------
    // Structs
    // -------

    // --------------
    // Initialization
    // --------------

    // ---------------
    // Entry Functions
    // ---------------
    
    // Create a new collection
    public entry fun create_token_collection(
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
        mutable_token_uri: bool,    // this have to be enforced to `True`
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,  // sets whether a creator can freeze transfer for a token
        royalty_numerator: u64,
        royalty_denominator: u64,
        seed: vector<u8> // used when auid is disabled.
    ) {
        // TODO assert the signer is the creator.
        let (collection_object, _) = core::create_token_collection_internal(
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
            seed
        );
        let collection_address = object::object_address(&collection_object);
        // emit collection created event
        events::emit_token_collection_created_event(
            collection_address,
            events::token_collection_metadata(collection_object)
        );
    }

    // Mint a composable token
    public entry fun mint_composable_token(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        total_supply: u64,  // objects supply must be less or equal than token supply
        object_tokens: vector<Object<ObjectToken>>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        seed: vector<u8> // used when auid is disabled.
    ) {
        // TODO: Assert collection exists
        // TODO: Assert signer is the creator
        // TODO: Assert token supply >= 1
        let (token_object, _) = core::mint_composable_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            total_supply,
            object_tokens,
            property_keys,
            property_types,
            property_values,
            seed
        );
        let token_address = object::object_address(&token_object);
        // emit composable token minted event
        events::emit_composable_token_minted_event(
            token_address,
            events::composable_token_metadata(token_object)
        );
    }

    // Mint an object token
    public entry fun mint_object_token(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,  // e.g: store categories
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        composable_token_object: Object<ComposableToken>, // needed for token supply
        seed: vector<u8> // used when auid is disabled.
    ) {
        // TODO: assert the token collection exists.
        // TODO: assert the composable token exists.
        // TODO: assert property_keys, property_types, and property_values have the same length. 
        let (token_object, _) = core::mint_object_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
            composable_token_object,
            seed
        ); 
        let token_address = object::object_address(&token_object);
        // emit object token minted event
        events::emit_object_token_minted_event(
            token_address,
            events::object_token_metadata(token_object)
        );  
    }

    // TODO: delete collection

    // Burn composable token
    /*
        This will involve decomposing the composable token, 
        transferring all the associated object tokens
        to the owner, and then burning the aptos token.
    */
    public entry fun burn_composable_token(
        owner: &signer,
        composable_token_object: Object<ComposableToken>
    ) {
        // TODO: assert input sanitazation 
        core::burn_composable_token_internal(owner, composable_token_object);
        // TODO: events
    }

    // burn object token
    public entry fun burn_object_token(
        owner: &signer,
        composable_token_object: Object<ComposableToken>,
        object_token_object: Object<ObjectToken>
    ) {
        // TODO: assert input sanitazation 
        core::burn_object_token_internal(owner, composable_token_object, object_token_object);
        // TODO: events
    }

    // Compose one object
    public entry fun compose_object(
        owner: &signer,
        composable_token_object: Object<ComposableToken>,
        object_token_object: Object<ObjectToken>
        // TODO: update uri
    ) {
        // TODO: assert input sanitazation 
        core::compose_object_internal(owner, composable_token_object, object_token_object);
        // TODO: events
    }

    // Decompose one object
    public entry fun decompose_object(
        owner: &signer,
        composable_token_object: Object<ComposableToken>,
        object_token_object: Object<ObjectToken>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        // TODO: assert input sanitazation 
        core::decompose_object_internal(owner, composable_token_object, object_token_object);
        // Update uri
        set_uri(owner, composable_token_object, new_uri);
        // TODO: events
    }

    // Decompose an entire composable token
    public entry fun decompose_entire_token(
        owner: &signer,
        composable_token_object: Object<ComposableToken>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        // TODO: assert input sanitazation 
        core::decompose_entire_token_internal(owner, composable_token_object); 
        // Update uri
        set_uri(owner, composable_token_object, new_uri);
        // TODO: events
    }

    // Directly transfer a token to a user.
    public entry fun raw_transfer<T: key>(
        owner: &signer, 
        token_address: address,
        new_owner_address: address,
    ) {
        // TODO: assert input sanitazation 
        core::raw_transfer_internal<T>(owner, token_address, new_owner_address);
        // TODO: events
    }

    // Transfer with a fee function
    public entry fun transfer_with_fee<T: key>(
        owner: &signer,
        token_address: address,
        new_owner_address: address,
        //fee: u64
    ){
        // TODO: assert input sanitazation 
        core::transfer_with_fee_internal<T>(owner, token_address, new_owner_address);
        // TODO: events
    }

    // --------
    // Mutators
    // --------
    // Composable Token
    public entry fun set_uri(
        owner: &signer,
        token: Object<ComposableToken>,
        new_uri: String
    ) {
        // TODO: asserts 
        core::set_uri_internal(owner, token, new_uri);
        // TODO: events
    }

}