/*
    - This contract represents the core of the studio.
    - It allows to initialze studio, and correspondingly create collections and tokens.
    - tokens logic is built on top of aptos_token.move.
    - A user can create the following:
        - Collections.
        - Object token (oNFT): A token V2 that represents a specific object.
        - Composable token (cNFT): A token V2 that can hold oNFTs inside.
        - <name-token>: A token V2 that can hold oNFTs, cNFTs, and fungible assets.

    TODO: add reference to aptos_token.move
    TODO: add events.
    TODO: add asserts module. (one of the asserts: assert the inputed data is not empty - Input Sanitization?)
    TODO: add init_module? (to initialize the studio with example tokens)
    TODO: enforce #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    TODO: add function to transform a Composable nft into a object token. (compress?)
    TODO: add functions to add/remove properties to a token.
    TODO: add tokens accessors.
    TODO: add tokens mutators.
    TODO: add tokens view functions.
    TODO: add rarity concept to object tokens.
    TODO: complete fast compose function. (does this have to be implemented onchain?)
    TODO: in function description, mention whether it's customer or creator specific.
    TODO: REFARCTOR trait token -> object token.
    TODO: re-write create_composable_token_internal, check collection_object inline function.
*/
module townespace::new_core {
    use aptos_framework::create_signer::create_signer;
    use aptos_framework::event::{Self, EventHandle};
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
    use townespace::events::{
        CreateTokenCollectionEvent,
        CreateTraitTokenEvent,  // TODO: refactor to CreateObjectTokenEvent
        CreateComposableTokenEvent,
        ComposeTokenEvent,
        DecomposeTokenEvent
    };

    /// ------
    /// Errors
    /// ------
    
    /// ---------
    /// Constants
    /// ---------
    // TODO: constants for fast compose function

    /// -------
    /// Structs
    /// -------
    
    // Storage state for managing Token Collection
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TokenCollection has key {
        collection: Object<aptos_token::AptosCollection>,
        name: String,
        symbol: String,
        // TODO: create_collection_events
        // TODO: delete_collection_events
    }

    // Storage state for managing Composable token
    // TODO: is property map needed?
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ComposableToken has key {
        token: Object<aptos_token::AptosToken>,
        // Token supply: Represents the number of composable tokens in circulation. 
        // Same as total_supply
        token_supply: TokenSupply,  // token_supply -> total_supply -> rarity (minted objects)
        // The object tokens to store in the composable token.
        object_tokens: vector<Object<ObjectToken>>, // TODO: this must be extended to each object type.
        // TODO: transfer event
        // burn_events: ,
        // mint_events: EventHandle<CreateTraitTokenEvent> // TODO: refactor to CreateObjectTokenEvent
    }

    // Storage state for managing Object Token
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ObjectToken has key {
        token: Object<aptos_token::AptosToken>,
        // rarity: u64, to be calulated offchain?
        // TODO: Timestamp
        // TODO: add events
        // TODO: transfer event
        // burn_events: ,
        // mint_events: EventHandle<CreateTraitTokenEvent> // TODO: refactor to CreateObjectTokenEvent
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for tracking composable token supply.
    struct TokenSupply has key, store {
        // TODO: supply -> max_supply || total_supply
        total_supply: u64,
        remaining_supply: u64,
        total_minted: u64,
        // burn_events: ,
        // mint_events: ,
    }

    /// ---------------
    /// Entry Functions
    /// ---------------
    
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
        // TODO: asserts here (to reduce gas fees)
        // TODO assert the signer is the creator.
        create_token_collection_internal(
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
    ) {
        // TODO: Assert collection exists
        // TODO: Assert signer is the creator
        // TODO: Assert token supply >= 1
        mint_composable_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            total_supply,
            object_tokens,
            property_keys,
            property_types,
            property_values
        );
    }

    // Mint an object token
    public entry fun mint_object_token(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        composable_token: Object<ComposableToken> // needed for token supply
    ) acquires TokenSupply {
        // TODO: assert the token collection exists.
        // TODO: assert the composable token exists.
        // TODO: assert the token supply <= remaining supply
        mint_object_token_internal(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
            composable_token
        );
        
    }

    // Compose one object; should not have internal
    public entry fun compose_object(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        object: Object<ObjectToken>
    ) acquires ComposableToken {
        // TODO: move these asserts to entry function
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        let owner_address = signer::address_of(owner);
        let composable_token_object = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        
        // index = vector length
        let index = vector::length(&composable_token_object.object_tokens);
        // TODO: Assert transfer is not freezed (object not equiped to composable nft)
        // TODO: Assert the signer is the owner 
        // TODO: Assert the object does not exist in the composable token

        // Add the object to the vector
        vector::insert<Object<ObjectToken>>(&mut composable_token_object.object_tokens, index, object);
        // TODO: Transfer the object to the composable token
        object::transfer_to_object(owner, object, composable_token);
        // Freeze transfer
        aptos_token::freeze_transfer(owner, object);
        // TODO: event here (overall events here, explicit ones in internal) 
    }

    // Fast compose function
    /*
        The user can choose two or more trait_tokens to compose,
        this will mint a composable token and transfer the trait_tokens to it.
        The user can later set the properties of the composable token.
    */
    public entry fun fast_compose(
        owner: &signer,
        name: String,
        uri: String, // User should not prompt this! It should be generated by the studio.
        trait_tokens: vector<Object<ObjectToken>>
    ) acquires TokenCollection {
        let owner_address = signer::address_of(owner);
        let collection = borrow_global_mut<TokenCollection>(owner_address);
        mint_composable_token_internal(
            owner,
            collection.name,
            string::utf8(b"fast composed"), // Description
            name,
            uri,  // TODO: URI must be generated
            1,   // Total supply; fast compose don't have supply.
            trait_tokens,
            vector::empty(),
            vector::empty(),
            vector::empty()
        );
        // TODO: event fast compose
    }

    // Decompose one object; should not have internal
    public entry fun decompose_object(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        object: Object<ObjectToken>,
        uri: String // User should not prompt this! It should be generated by the studio.
    ) acquires ComposableToken {
        // TODO: move these asserts to entry function
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        let composable_token_object = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        // TODO: get the index "i" of the object. Prob use borrow and inline funcs
        // TODO: store it in i
        // pattern matching
        let (_, index) = vector::index_of(&composable_token_object.object_tokens, &object);
        // TODO: assert the object exists in the composable token
        // Unfreeze transfer
        aptos_token::unfreeze_transfer(owner, object);
        // Remove the object from the vector
        vector::remove<Object<ObjectToken>>(&mut composable_token_object.object_tokens, index);
        // Transfer
        object::transfer(owner, object, signer::address_of(owner));
        // TODO: event decompose token
    }

    // Decompose an entire composable token; should not have internal
    public entry fun decompose_composable_token(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        uri: String // User should not prompt this! It should be generated by the studio.
    ) acquires ComposableToken {
        // TODO: move these asserts to entry function
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        // TODO: assert the composable token is not empty
        let composable_token_object = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        // Iterate through the vector
        let i = 0;
        while (i < vector::length(&composable_token_object.object_tokens)) {
            // For each object, unfreeze transfer, transfer to owner, remove from vector
            let object = *vector::borrow(&composable_token_object.object_tokens, i);
            aptos_token::unfreeze_transfer(owner, object);
            object::transfer(owner, object, signer::address_of(owner));
            vector::remove<Object<ObjectToken>>(&mut composable_token_object.object_tokens, i);
            // TODO: event decompose token
        }
        
        
    }

    // Directly transfer a token to a user.
    public entry fun raw_transfer<T: key>(
        owner: &signer, 
        token_address: address,
        new_owner_address: address,
    ) {
        // TODO assert token exists
        // TODO: If token is object_token, assert transfer is unfreezed (object not equiped to composable nft)
        // TODO: Assert the signer is the token owner
        let owner_address = signer::address_of(owner);
        // Transfer
        let token = object::address_to_object<T>(token_address);
        object::transfer(owner, token, new_owner_address);
        // TODO: event
    }

    // Transfer with a fee function
    public entry fun transfer_with_fee<T: key>(
        owner: &signer, 
        token_address: address,
        new_owner_address: address,
    ) {
        // TODO assert token exists
        // TODO: If token is object_token, assert transfer is unfreezed (object not equiped to composable nft)
        // TODO: Assert the signer is the token owner
        let owner_address = signer::address_of(owner);
        // Transfer
        let token = object::address_to_object<T>(token_address);
        // TODO: Charge a small fee that will be sent to studio address.
        object::transfer(owner, token, new_owner_address);
        // TODO: event
    }

    /// ------------------
    /// Internal Functions
    /// ------------------
    
    // Collection
    fun create_token_collection_internal(
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
    ): address acquires TokenCollection {
        // TODO: assert max supply is not 0
        // TODO: assert royalty numerator is not 0
        // TODO: assert royalty denominator is not 0
        // TODO: assert royalty numerator is not greater than royalty denominator because it's a percentage and it must be between 0 and 1.
        // TODO: assert collection exists 
        let aptos_collection_object = aptos_token::create_collection_object(
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
            collection: aptos_collection_object,
            name: collection_name,
            symbol: symbol,
            // TODO: see what other attributes to include
        };
        let token_collection_address = object::object_address(&aptos_collection_object);
        // Move to resource account.
        move_to(creator, new_token_collection);

        // TODO Add events

        // Return the address of the created collection.
        token_collection_address
    }

    // Composable token
    fun mint_composable_token_internal(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        total_supply: u64,
        object_tokens: vector<Object<ObjectToken>>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): address {
        // Create the composable token object.
        let composable_token_object = aptos_token::mint_token_object(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        );
        let composable_token_address = object::object_address(&composable_token_object);
        // create send supply tracker to resource account
        let new_token_supply = TokenSupply {
            total_supply: total_supply,
            remaining_supply: total_supply,
            total_minted: 0,
            //mint_events: object::new_event_handle(&composable_token_object_signer),
        };

        // Initialize it with object_tokens vector if it exists. Empty otherwise.
        if (vector::length(&object_tokens) == 0) {
            let new_composable_token = ComposableToken {
                token: composable_token_object, // TODO: token: Object<aptos_token::AptosToken>
                token_supply: new_token_supply, 
                object_tokens: vector::empty(),
            };
            move_to(creator, new_composable_token);
        } else {
            let new_composable_token = ComposableToken {
                token: composable_token_object,
                token_supply: new_token_supply, 
                object_tokens: object_tokens,
            };           
            move_to(creator, new_composable_token);
        };

        composable_token_address
    }

    // Object token
    fun mint_object_token_internal(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        composable_token: Object<ComposableToken> // to use for tracker
    ):address acquires TokenSupply{
        // create object for the object token
        let object_token_object = aptos_token::mint_token_object(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        );
        let object_token_address = object::object_address(&object_token_object);
        // TODO event object token created
        // update the token supply; decrement by one
        let creator_address = signer::address_of(creator);
        let token_supply = borrow_global_mut<TokenSupply>(creator_address);
        decrement_supply(&composable_token, token_supply, object_token_address);

        object_token_address
    }
    
    /// ---------
    /// Accessors
    /// ---------
    
    

    /// --------
    /// Mutators
    /// --------
    
    // Collection

    // Token
    // Change uri
    public entry fun set_uri(
        creator: &signer,
        token: Object<ComposableToken>,
        new_uri: String,
    ) {
        // TODO: Asserts 
        aptos_token::set_uri(creator, token, new_uri);
    }
    // Token Supply
    // Decrement the remaining supply on each object token minted.
    inline fun decrement_supply(
        composable_token: &Object<ComposableToken>,
        token_supply: &mut TokenSupply,
        object_token: address
    ): (u64, u64, u64) acquires TokenSupply {
        // TODO: assert the composable token exists.
        // TODO: assert the object token exists.
        let composable_token_address = object::object_address(composable_token);
        let token_supply = borrow_global_mut<TokenSupply>(composable_token_address);
        let remaining_supply = token_supply.remaining_supply;
        let total_minted = token_supply.total_minted;
        // TODO: assert the remaining supply > 0.
        let total_supply = token_supply.total_supply;
        let remaining_supply = remaining_supply - 1;
        let total_minted = total_minted + 1;
        // TODO: event supply updated (store new values)
        (total_supply, remaining_supply, total_minted)
    }

    // Increment the remaining supply on each object token minted.
    inline fun increment_supply(
        composable_token: &Object<ComposableToken>,
        token_supply: &mut TokenSupply,
        object_token: address
    ): (u64, u64, u64) acquires TokenSupply {
        // TODO: assert the composable token exists.
        // TODO: assert the object token exists.
        let composable_token_address = object::object_address(composable_token);
        let token_supply = borrow_global_mut<TokenSupply>(composable_token_address);
        let remaining_supply = token_supply.remaining_supply;
        let total_minted = token_supply.total_minted;
        // TODO: assert the remaining supply > 0.
        let total_supply = token_supply.total_supply;
        let remaining_supply = remaining_supply + 1;
        let total_minted = total_minted - 1;

        // TODO: event supply updated (store new values)
        (total_supply, remaining_supply, total_minted)
    }

}