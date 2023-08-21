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
    TODO: mint_object_token_internal and mint_composable_token_internal can be done in one function.
    TODO: Update fast compose function with to_use flag.
    TOOD: Update decompose function with to_use flag.
*/
module townespace::core {
    //use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::object::{Self, Object};
    use aptos_token_objects::aptos_token::{Self, AptosCollection, AptosToken};
    //use aptos_token_objects::collection;
    //use std::error;
    use std::features;
    use std::signer;
    use std::string::{String};
    use std::vector;
  //use townespace::events::{
  //    CreateTokenCollectionEvent,
  //    CreateTraitTokenEvent,  // TODO: refactor to CreateObjectTokenEvent
  //    CreateComposableTokenEvent,
  //    ComposeTokenEvent,
  //    DecomposeTokenEvent
  //};

    // ------
    // Errors
    // ------
    
    // ---------
    // Constants
    // ---------
    // TODO: constants for fast compose function

    // -------
    // Structs
    // -------
    
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
        //token_supply: TokenSupply, // TODO: replicate collection supply
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
    struct TokenSupply has key {
        // TODO: supply -> max_supply || total_supply
        total_supply: u64,
        remaining_supply: u64,
        total_minted: u64,
        // burn_events: ,
        // mint_events: ,
    }

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
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty_numerator: u64,
        royalty_denominator: u64,
        seed: vector<u8> // used when auid is disabled.
    ) {
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
            seed
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
            property_values,
            seed
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
        composable_token_object: Object<ComposableToken>, // needed for token supply
        seed: vector<u8> // used when auid is disabled.
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
            composable_token_object,
            seed
        );
        
    }

    // Compose one object; should not have internal
    public entry fun compose_object(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        object: Object<ObjectToken>
    ) acquires ComposableToken, ObjectToken {
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        // TODO: assert the object token is not in use (bool = false)
        let composable_token_address = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        // index = vector length
        let index = vector::length(&composable_token_address.object_tokens);
        // TODO: Assert transfer is not freezed (object not equiped to composable nft)
        // TODO: Assert the signer is the owner 
        // TODO: Assert the object does not exist in the composable token
        // Transfer the object to the composable token
        object::transfer_to_object(owner, object, composable_token);
        // Freeze transfer for both objects
        //let composable_aptos_token = composable_token_address.token;
        let object_token_address = borrow_global_mut<ObjectToken>(object::object_address(&object));
        let object_aptos_token = object_token_address.token;
        aptos_token::freeze_transfer(owner, object_aptos_token);
        // Add the object to the vector
        vector::insert<Object<ObjectToken>>(&mut composable_token_address.object_tokens, index, object);
        // object::transfer(owner, composable_aptos_token, @townespace); TODO: add this to unit testing, we send object token to the composable token, and we freeze transfer for the object token, we send the composable token to another address, and the object token is transfered with it.
        // TODO: event here (overall events here, explicit ones in internal) 
    }

    // TODO: Fast compose function
    /*
        The user can choose two or more trait_tokens to compose,
        this will mint a composable token and transfer the trait_tokens to it.
        The user can later set the properties of the composable token.
    */
    //public entry fun fast_compose(
    //    owner: &signer,
    //    name: String,
    //    uri: String, // User should not prompt this! It should be generated by the studio.
    //    trait_tokens: vector<Object<ObjectToken>>
    //) acquires TokenCollection {
    //    let owner_address = signer::address_of(owner);
    //    let collection = borrow_global_mut<TokenCollection>(owner_address);
    //    mint_composable_token_internal(
    //        owner,
    //        collection.name,
    //        string::utf8(b"fast composed"), // Description
    //        name,
    //        uri,  // TODO: URI must be generated
    //        1,   // Total supply; fast compose don't have supply.
    //        trait_tokens,
    //        vector::empty(),
    //        vector::empty(),
    //        vector::empty()
    //    );
    //    // TODO: event fast compose
    //}

    // Decompose one object; should not have internal
    public entry fun decompose_object(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        object_token_object: Object<ObjectToken>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) acquires ComposableToken, ObjectToken {
        // TODO: move these asserts to entry function
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        let composable_token_object = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        // get the index "i" of the object. Needed for removing object from vector.
        // pattern matching
        let (_, index) = vector::index_of(&composable_token_object.object_tokens, &object_token_object);
        // TODO: assert the object exists in the composable token
        // Transfer both objects
        let object_token_address = borrow_global_mut<ObjectToken>(object::object_address(&object_token_object));
        let object_aptos_token = object_token_address.token;
        // Unfreeze transfer
        aptos_token::unfreeze_transfer(owner, object_token_address.token);
        object::transfer(owner, object_aptos_token, signer::address_of(owner));
        object::transfer(owner, object_token_object, signer::address_of(owner));
        // Remove the object from the vector
        vector::remove<Object<ObjectToken>>(&mut composable_token_object.object_tokens, index);
        // Update uri
        set_uri(owner, composable_token, new_uri);
        
        // TODO: event decompose token
        
    }

    // TODO: Decompose an entire composable token; should not have internal
    public entry fun decompose_entire_token(
        owner: &signer,
        composable_token: Object<ComposableToken>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) acquires ComposableToken, ObjectToken {
        // TODO: move these asserts to entry function
        // TODO: assert the signer is the owner
        // TODO: assert both tokens exist
        // TODO: assert the composable token is not empty
        let composable_token_address = borrow_global_mut<ComposableToken>(object::object_address(&composable_token)); 
        // Iterate through the vector
        let i = 0;
        while (i < vector::length(&composable_token_address.object_tokens)) {
            // For each object, unfreeze transfer, transfer to owner, remove from vector
            let object = *vector::borrow(&composable_token_address.object_tokens, i);
            let object_token_address = borrow_global_mut<ObjectToken>(object::object_address(&object));
            let object_aptos_token = object_token_address.token;
            aptos_token::unfreeze_transfer(owner, object_aptos_token);
            object::transfer(owner, object_aptos_token, signer::address_of(owner));
            vector::remove<Object<ObjectToken>>(&mut composable_token_address.object_tokens, i);
            // TODO: event decompose token
        };
        // Update uri
        set_uri(owner, composable_token, new_uri);
        
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
        
        // Transfer
        let token = object::address_to_object<T>(token_address);
        // TODO: Charge a small fee that will be sent to studio address.
        object::transfer(owner, token, new_owner_address);
        // TODO: event
    }

    // ------------------
    // Internal Functions
    // ------------------
    
    // Collection
    public fun create_token_collection_internal(
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
        seed: vector<u8> // used when auid is disabled.
    ): (Object<TokenCollection>, Object<AptosCollection>) {
        // TODO: assert max supply is not 0
        // TODO: assert royalty numerator is not 0
        // TODO: assert royalty denominator is not 0
        // TODO: assert royalty numerator is not greater than royalty denominator because it's a percentage and it must be between 0 and 1.
        // TODO: assert collection exists 
        // Create composable token object.
        let creator_address = signer::address_of(creator);
        // If auid is enabled, create the object with the creator address.
        // Otherwise, create it with the creator address and the seed.
        let constructor_ref = if (features::auids_enabled()) {
            object::create_object(creator_address)
        } else {
            object::create_named_object(creator, seed)
        };
        // Generate the object signer, used to publish a resource under the token object address.
        let object_signer = object::generate_signer(&constructor_ref);
        // Create aptos collection object.
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

        // Initialize token supply and publish it in the composable token object account.
        // Initialize it with object_tokens vector if it exists. Empty otherwise.
        move_to(&object_signer, TokenCollection {
            collection: aptos_collection_object,
            name: name,
            symbol: symbol,});
        // TODO Add events

        // Return both objects.
        let token_collection_object = object::object_from_constructor_ref(&constructor_ref);
        (token_collection_object, aptos_collection_object)
    }

    // Composable token
    public fun mint_composable_token_internal(
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
        seed: vector<u8> // used when auid is disabled.
    ): (Object<ComposableToken>, Object<AptosToken>) {
        // Create composable token object.
        let creator_address = signer::address_of(creator);
        // If auid is enabled, create the object with the creator address.
        // Otherwise, create it with the creator address and the seed.
        let constructor_ref = if (features::auids_enabled()) {
            object::create_object(creator_address)
        } else {
            object::create_named_object(creator, seed)
        };
        
        // Generate the object signer, used to publish a resource under the token object address.
        let object_signer = object::generate_signer(&constructor_ref);
        // Create aptos token object.
        let aptos_token_object = aptos_token::mint_token_object(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        );

        let new_token_supply = TokenSupply {
            total_supply: total_supply,
            remaining_supply: total_supply,
            total_minted: 0,
            //mint_events: object::new_event_handle(&composable_token_object_signer),
        };
        // Initialize token supply and publish it in the composable token object account.
        // Initialize it with object_tokens vector if it exists. Empty otherwise.
        if (vector::length(&object_tokens) == 0) {
            move_to(&object_signer, ComposableToken {
                token: aptos_token_object,
                object_tokens: vector::empty(),
            });
        } else {
            move_to(&object_signer, ComposableToken {
                token: aptos_token_object,
                object_tokens: object_tokens,
            });
            
        };
        move_to(&object_signer, new_token_supply);
        
        // Return both objects.
        let composable_token_object = object::object_from_constructor_ref(&constructor_ref);
        (composable_token_object, aptos_token_object)
    }

    // Object token
    public fun mint_object_token_internal(
        creator: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        composable_token_object: Object<ComposableToken>, // to use for tracking supply
        seed: vector<u8> // used only when auid is disabled
    ): (Object<ObjectToken>, Object<AptosToken>) acquires TokenSupply {
        // Create composable token object.
        let creator_address = signer::address_of(creator);
        // If auid is enabled, create the object with the creator address.
        // Otherwise, create it with the creator address and the seed.
        let constructor_ref = if (features::auids_enabled()) {
            object::create_object(creator_address)
        } else {
            object::create_named_object(creator, seed)
        };
        // Generate the object signer, used to publish a resource under the token object address.
        let object_signer = object::generate_signer(&constructor_ref);
        // create object for aptos token
        let aptos_token_object = aptos_token::mint_token_object(
            creator,
            collection,
            description,
            name,
            uri,
            property_keys,
            property_types,
            property_values,
        );
        // TODO event object token created
        // update the token supply; decrement by one
        decrement_token_supply(&composable_token_object/*, object_token_address*/);
        // Get the object token address
        //let object_token_address = object::object_address(&aptos_token_object);

        // Initialize token supply and publish it in the composable token object account.
        // Initialize it with object_tokens vector if it exists. Empty otherwise.
        // new object to move to resource account
        move_to(&object_signer, ObjectToken {
            token: aptos_token_object,
            //mint_events: object::new_event_handle(&object_signer),
        });
        
        // Return both objects.
        let object_token_object = object::object_from_constructor_ref(&constructor_ref);
        (object_token_object, aptos_token_object)
    }
    
    // ---------
    // Accessors
    // ---------
    
    

    // --------
    // Mutators
    // --------
    
    // Collection

    // Token
    // Change uri
    public entry fun set_uri(
        owner: &signer,
        token: Object<ComposableToken>,
        new_uri: String
    ) acquires ComposableToken {
        // TODO: Asserts 
        let token_address = object::object_address(&token);
        let composable_token_object = borrow_global_mut<ComposableToken>(token_address);
        let aptos_token = composable_token_object.token;
        aptos_token::set_uri(owner, aptos_token, new_uri);
    }
    // Token Supply
    // Decrement the remaining supply on each object token minted.
    inline fun decrement_token_supply(
        composable_token_object: &Object<ComposableToken>,
        //minted_token: address
    ) acquires TokenSupply {
        // TODO: assert the composable token exists.
        // TODO: assert the object token exists.
        // Get the composable token address
        let composable_token_address = object::object_address(composable_token_object);
        let token_supply = borrow_global_mut<TokenSupply>(composable_token_address);
        // TODO: assert total supply > 1
        token_supply.total_supply = token_supply.total_supply - 1;
        // TODO: assert the remaining supply > 0.
        token_supply.remaining_supply = token_supply.remaining_supply - 1;
        token_supply.total_minted = token_supply.total_minted + 1;
        // TODO: event supply updated (store new values with the minted token)
    }

    // Increment the remaining supply on each object token minted.
    inline fun increment_token_supply(
        composable_token_address: address,
        token_supply: &mut TokenSupply,
        object_token: address
    ): (u64, u64, u64) acquires TokenSupply {
        // TODO: assert the composable token exists.
        // TODO: assert the object token exists.
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