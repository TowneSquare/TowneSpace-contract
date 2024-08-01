/*
    - This module is a no-code implementation for the composability contract.
    - It is responsible for creating collections, creating tokens,
    and composing and decomposing tokens.
    - It is also responsible for transferring tokens.

    TODO:
        - add view function to calculate rarity
*/

module townespace::studio {

    use aptos_framework::event;
    use aptos_framework::object::{Self, ConstructorRef, Object};
    use aptos_std::table::{Self, Table};
    use aptos_token_objects::collection;
    use aptos_token_objects::token::{Token};
    use composable_token::composable_token::{Self, Named, Collection, Composable, Trait};
    use std::option::{Option};
    use std::signer;
    use std::string::{Self, String};
    use std::string_utils;
    use std::vector;

    // ------
    // Errors
    // ------

    /// Token names and count length mismatch
    const ELENGTH_MISMATCH: u64 = 1;
    /// Token count reached max supply
    const EMAX_SUPPLY_REACHED: u64 = 2;
    /// New total supply should be greater than the current total supply
    const ENEW_SUPPLY_LESS_THAN_OLD: u64 = 3;
    /// The signer is not the collection owner
    const ENOT_OWNER: u64 = 4;

    // -------
    // Structs
    // -------

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Global storage to track minting 
    struct Tracker has key {
        // collection object
        collection_obj: Object<collection::Collection>,
        // table for tracking minting per type. <Type, Total mint>
        table: Table<String, TokenTracker>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Global storage to track token counts per type
    struct TokenTracker has key, store {
        // total supply
        total_supply: u64,
        // total minted
        count: u64
    }

    // ------
    // Events
    // ------

    #[event]
    struct TrackerInitialized has drop, store { collection_obj: Object<collection::Collection> }

    #[event]
    struct TypeAdded has drop, store { collection_obj_addr: address, type: String }

    #[event]
    struct TokensCreated has drop, store { addresses: vector<address> }

    // ---------------
    // Entry functions
    // ---------------

    /// create a collection and initialize the tracker
    public entry fun create_collection_with_tracker<SupplyType: key>(
        signer_ref: &signer,
        // collection properties
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
        tokens_burnable_by_collection_owner: bool,
        tokens_freezable_by_collection_owner: bool,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
    ) {
        create_collection_with_tracker_internal<SupplyType>(
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
            tokens_burnable_by_collection_owner,
            tokens_freezable_by_collection_owner,
            royalty_numerator,
            royalty_denominator
        );  
    }

    /// Add a type to the tracker table; callable only by the collection owner
    public entry fun add_type_to_tracker(
        signer_ref: &signer,
        collection_obj_addr: address,
        type: String,
        total_supply: u64
    ) acquires Tracker {
        // asserting the signer is the collection owner
        assert!(object::is_owner<Collection>(object::address_to_object<Collection>(collection_obj_addr), signer::address_of(signer_ref)), ENOT_OWNER);
        // asserting type not in tracker is being handled in table.move (L139)
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let token_tracker = TokenTracker { total_supply, count: 0 };
        table::add<String, TokenTracker>(&mut tracker.table, type, token_tracker);

        // emit event
        event::emit(TypeAdded { collection_obj_addr, type });
    }
    /// Create a batch of tokens
    public entry fun create_batch<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        descriptions: vector<String>,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) acquires Tracker {
        let constructor_refs = create_batch_internal<T>(
            signer_ref,
            collection,
            descriptions,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values
        );

        let addresses = vector::empty<address>();
        for (i in 0..count) {
            let addr = object::address_from_constructor_ref(vector::borrow<ConstructorRef>(&constructor_refs, i));
            vector::push_back(&mut addresses, addr);
        };

        event::emit<TokensCreated>( TokensCreated { addresses } );
    }

    /// Create a batch of composable tokens with soulbound traits
    public entry fun create_batch_composables_with_soulbound_traits(
        signer_ref: &signer,
        collection: Object<Collection>,
        // trait related fields
        trait_descriptions: vector<String>,
        trait_uri: vector<String>,
        trait_name_with_index_prefix: vector<String>,
        trait_name_with_index_suffix: vector<String>,
        trait_property_keys: vector<String>,
        trait_property_types: vector<String>,
        trait_property_values: vector<vector<u8>>,
        // composable related fields
        composable_description: String,
        composable_uri: vector<String>,
        composable_name_with_index_prefix: vector<String>,
        composable_name_with_index_suffix: vector<String>,
        composable_property_keys: vector<String>,
        composable_property_types: vector<String>,
        composable_property_values: vector<vector<u8>>,
        // common
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
    ) acquires Tracker {
        let constructor_refs = create_batch_composables_with_soulbound_traits_internal(
            signer_ref,
            collection,
            // trait related fields
            trait_descriptions,
            trait_uri,
            trait_name_with_index_prefix,
            trait_name_with_index_suffix,
            trait_property_keys,
            trait_property_types,
            trait_property_values,
            // composable related fields
            composable_description,
            composable_uri,
            composable_name_with_index_prefix,
            composable_name_with_index_suffix,
            composable_property_keys,
            composable_property_types,
            composable_property_values,
            // common
            count,
            royalty_numerator,
            royalty_denominator
        );

        let addresses = vector::empty<address>();
        for (i in 0..count) {
            let addr = object::address_from_constructor_ref(vector::borrow<ConstructorRef>(&constructor_refs, i));
            vector::push_back(&mut addresses, addr);
        };

        event::emit<TokensCreated>( TokensCreated { addresses } );
    }

    /// Update the total supply in the tracker; callable only by the collection owner
    public entry fun update_type_total_supply(
        signer_ref: &signer,
        collection_obj: Object<Collection>,
        key: String,
        new_total_supply: u64
    ) acquires Tracker {
        assert!(object::is_owner<Collection>(collection_obj, signer::address_of(signer_ref)), ENOT_OWNER);
        update_type_total_supply_internal(object::object_address(&collection_obj), key, new_total_supply);
    }
    
    // -------
    // Helpers
    // -------

    /// Helper function for creating a collection and initializing the tracker
    public fun create_collection_with_tracker_internal<SupplyType: key>(
        signer_ref: &signer,
        // collection properties
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
        tokens_burnable_by_collection_owner: bool,
        tokens_freezable_by_collection_owner: bool,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>
    ): ConstructorRef {
        let constructor = composable_token::create_collection<SupplyType>(
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
            tokens_burnable_by_collection_owner,
            tokens_freezable_by_collection_owner,
            royalty_numerator,
            royalty_denominator
        );

        let collection_obj = object::object_from_constructor_ref<collection::Collection>(&constructor);
        let collection_obj_signer = object::generate_signer(&constructor);
        // initialize the tracker
        move_to(
            &collection_obj_signer,
            Tracker {
                collection_obj,
                table: table::new<String, TokenTracker>()
            }
        );

        let collection_obj = object::object_from_constructor_ref<collection::Collection>(&constructor);

        // emit event
        event::emit(TrackerInitialized { collection_obj });

        constructor
    }

    /// Helper function for creating a batch of tokens
    public fun create_batch_internal<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        descriptions: vector<String>,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): vector<ConstructorRef> acquires Tracker {
        assert!(count == vector::length(&descriptions), ELENGTH_MISMATCH);
        assert!(count == vector::length(&uri), ELENGTH_MISMATCH);
        assert!(count == vector::length(&name_with_index_prefix), ELENGTH_MISMATCH);
        let constructor_refs = vector::empty<ConstructorRef>();
        let collection_obj_addr = object::object_address(&collection);
        for (i in 0..count) {
            let description = *vector::borrow<String>(&descriptions, i);
            let token_index = count_from_tracker(collection_obj_addr, description) + 1;
            let uri = *vector::borrow<String>(&uri, i);
            // token name: prefix + # + index + suffix
            let name = *vector::borrow<String>(&name_with_index_prefix, i);
            string::append_utf8(&mut name, b" #");
            string::append(&mut name, string_utils::to_string(&token_index));
            // string::append(&mut suffix, name_with_index_suffix);
            let constructor = composable_token::create_token<T, Named>(
                signer_ref,
                collection,
                description,
                name,  // name
                string::utf8(b""), // prefix: ignored as we're using a custom indexing
                string::utf8(b""),  // suffix: ignored as we're using a custom indexing
                uri,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values
            );

            vector::push_back(&mut constructor_refs, constructor);
            // update the count in the tracker
            increment_count(collection_obj_addr, description);
        };

        constructor_refs
    }

    /// Helper function for creating composable tokens for minting with trait tokens bound to them
    /// Returns the constructor refs of the created composable tokens
    public fun create_batch_composables_with_soulbound_traits_internal(
        signer_ref: &signer,
        collection: Object<Collection>,
        // trait related fields
        trait_descriptions: vector<String>,
        trait_uri: vector<String>,
        trait_name_with_index_prefix: vector<String>,
        trait_name_with_index_suffix: vector<String>,
        trait_property_keys: vector<String>,
        trait_property_types: vector<String>,
        trait_property_values: vector<vector<u8>>,
        // composable related fields
        composable_description: String,
        composable_uri: vector<String>,
        composable_name_with_index_prefix: vector<String>,
        composable_name_with_index_suffix: vector<String>,
        composable_property_keys: vector<String>,
        composable_property_types: vector<String>,
        composable_property_values: vector<vector<u8>>,
        // common
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
    ): vector<ConstructorRef> acquires Tracker {
        // create composable tokens
        let composable_descriptions = vector::empty<String>();
        for (i in 0..count) {
            vector::push_back(&mut composable_descriptions, composable_description);
        };
        let (composable_constructor_refs) = create_batch_internal<Composable>(
            signer_ref,
            collection,
            composable_descriptions,
            composable_uri,
            composable_name_with_index_prefix,
            composable_name_with_index_suffix,
            count,
            royalty_numerator,
            royalty_denominator,
            composable_property_keys,
            composable_property_types,
            composable_property_values,
        );
        // create trait tokens
        let (trait_constructor_refs) = create_batch_internal<Trait>(
            signer_ref,
            collection,
            trait_descriptions,
            trait_uri,
            trait_name_with_index_prefix,
            trait_name_with_index_suffix,
            vector::length(&composable_constructor_refs),
            royalty_numerator,
            royalty_denominator,
            trait_property_keys,
            trait_property_types,
            trait_property_values,
        );
        // soulbind the trait tokens to the composable tokens
        let composables_objs = vector::empty<Object<Composable>>();
        for (i in 0..vector::length(&composable_constructor_refs)) {
            let composable_obj = object::object_from_constructor_ref(vector::borrow<ConstructorRef>(&composable_constructor_refs, i));
            vector::push_back(&mut composables_objs, composable_obj);
        };
        vector::zip(composables_objs, trait_constructor_refs, |composable_obj, trait_constructor_ref| {
            composable_token::equip_soulbound_trait(
                signer_ref,
                composable_obj, 
                &trait_constructor_ref,
                0x4::token::uri<Composable>(composable_obj),
            );
        });

        composable_constructor_refs
    }

    /// Helper function to update the tracker
    /// Used when a token is created
    inline fun increment_count(collection_obj_addr: address, key: String) acquires Tracker {
        // // assert total supply of the type is not reached
        // let current_total_supply = count_from_tracker(collection_obj_addr, key);
        // let total_supply = total_supply_from_tracker(collection_obj_addr, key);
        // assert!((current_total_supply + 1) <= total_supply, EMAX_SUPPLY_REACHED);
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let count = table::borrow_mut<String, TokenTracker>(&mut tracker.table, key).count;
        table::borrow_mut<String, TokenTracker>(&mut tracker.table, key).count = count + 1;
    }

    /// Helper function to return count from Token Tracker given a collection object address and the type key
    inline fun count_from_tracker(collection_obj_addr: address, key: String): u64 {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        table::borrow<String, TokenTracker>(&tracker.table, key).count
    }
    
    /// Helper function to return the total supply from Token Tracker given a collection object address and the type key
    fun total_supply_from_tracker(collection_obj_addr: address, key: String): u64 acquires Tracker {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        table::borrow<String, TokenTracker>(&tracker.table, key).total_supply
    }

    /// Helper function to update the total supply in the tracker; new total supply should be greater than the current total supply
    inline fun update_type_total_supply_internal(collection_obj_addr: address, key: String, new_total_supply: u64) acquires Tracker {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let current_total_supply = table::borrow<String, TokenTracker>(&tracker.table, key).total_supply;
        assert!(new_total_supply > current_total_supply, ENEW_SUPPLY_LESS_THAN_OLD);
        table::borrow_mut<String, TokenTracker>(&mut tracker.table, key).total_supply = new_total_supply;
    }

    // -----------
    // Public APIs
    // -----------

    #[view]
    /// Gets a wallet address plus a list of token addresses, and returns only the owned tokens.
    public fun owned_tokens(wallet_addr: address, token_addrs: vector<address>): vector<address> {
        let owned_tokens = vector::empty<address>();
        for (i in 0..vector::length(&token_addrs)) {
            // get the object
            let token_obj = object::address_to_object<Token>(*vector::borrow(&token_addrs, i));
            // if true, push to owned_tokens
            if (object::is_owner<Token>(token_obj, wallet_addr)) {
                vector::push_back(&mut owned_tokens, *vector::borrow(&token_addrs, i));
            }
        };

        owned_tokens
    }

    #[view]
    /// Gets the total supply of a token type and the count of minted tokens of the type; useful for calculating rarity
    public fun token_supply(collection_obj_addr: address, type: String): (u64, u64) acquires Tracker {
        let total_supply = total_supply_from_tracker(collection_obj_addr, type);
        let minted_tokens_count = count_from_tracker(collection_obj_addr, type);
        (total_supply, minted_tokens_count)
    }

    // ------------
    // Unit Testing
    // ------------

    #[test_only]
    use std::debug;
    #[test_only]
    use std::option;
    #[test_only]
    use aptos_token_objects::collection::{FixedSupply};
    #[test_only]
    use aptos_token_objects::token;
    #[test_only]
    use townespace::common;

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    fun test_e2e(std: &signer, creator: &signer, minter: &signer) acquires Tracker {

        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        // creator creates a collection
        let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
            true,
            true, 
            true,
            true,
            true, 
            true,
            true,
            true, 
            true,
            option::none(),
            option::none(),
        );

        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
        // Add base type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 5);

        // print count
        debug::print<String>(&string::utf8(b"BASE COUNT BEFORE MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Base")));
    
        // creator creates a batch of tokens
        let constructor_refs = create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base")
            ],
            vector[
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b"")
            ],
            5,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );

        // let constructor_ref2 = vector::borrow<ConstructorRef>(&constructor_refs, 1);
        // let constructor_ref3 = vector::borrow<ConstructorRef>(&constructor_refs, 2);
        // let constructor_ref4 = vector::borrow<ConstructorRef>(&constructor_refs, 3);
        // let constructor_ref5 = vector::borrow<ConstructorRef>(&constructor_refs, 4);

        let token1_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs, 0));
        let token2_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs, 1));
        let token3_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs, 2));
        let token4_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs, 3));
        let token5_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs, 4));

        // print names
        let token1_name = token::name<Trait>(token1_obj);
        let token2_name = token::name<Trait>(token2_obj);
        let token3_name = token::name<Trait>(token3_obj);
        let token4_name = token::name<Trait>(token4_obj);
        let token5_name = token::name<Trait>(token5_obj);

        // print uris
        let token1_uri = token::uri<Trait>(token1_obj);
        let token2_uri = token::uri<Trait>(token2_obj);
        let token3_uri = token::uri<Trait>(token3_obj);
        let token4_uri = token::uri<Trait>(token4_obj);
        let token5_uri = token::uri<Trait>(token5_obj);

        debug::print<String>(&string::utf8(b"Token Names:"));
        debug::print<String>(&token1_name);
        debug::print<String>(&token2_name);
        debug::print<String>(&token3_name);
        debug::print<String>(&token4_name);
        debug::print<String>(&token5_name);

        debug::print<String>(&string::utf8(b"Token URIs:"));
        debug::print<String>(&token1_uri);
        debug::print<String>(&token2_uri);
        debug::print<String>(&token3_uri);
        debug::print<String>(&token4_uri);
        debug::print<String>(&token5_uri);

        debug::print<String>(&string::utf8(b"Token desctiptions:"));
        debug::print<String>(&token::description<Trait>(token1_obj));
        debug::print<String>(&token::description<Trait>(token2_obj));
        debug::print<String>(&token::description<Trait>(token3_obj));
        debug::print<String>(&token::description<Trait>(token4_obj));
        debug::print<String>(&token::description<Trait>(token5_obj));

        // print count
        debug::print<String>(&string::utf8(b"BASE COUNT AFTER MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Base")));

        // add body and sloth type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Body"), 5);
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Sloth"), 5);
        // print count
        debug::print<String>(&string::utf8(b"BODY COUNT BEFORE MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Body")));

        debug::print<String>(&string::utf8(b"SLOTH COUNT BEFORE MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Sloth")));

        // create composable tokens with soulbound traits
        let composable_constructor_refs = create_batch_composables_with_soulbound_traits_internal(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            // trait related fields
            vector[
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body")
            ],
            vector[
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth")
            ],
            vector[
                string::utf8(b"Body Sloth"), 
                string::utf8(b"Body Sloth"), 
                string::utf8(b"Body Sloth"),
                string::utf8(b"Body Sloth"),
                string::utf8(b"Body Sloth")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b"")
            ],
            vector[],
            vector[],
            vector[],
            // composable related fields
            string::utf8(b"Sloth"),
            vector[
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth")
            ],
            vector[
                string::utf8(b"Composable Sloth"), 
                string::utf8(b"Composable Sloth"), 
                string::utf8(b"Composable Sloth"),
                string::utf8(b"Composable Sloth"),
                string::utf8(b"Composable Sloth")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b"")
            ],
            vector[],
            vector[],
            vector[],
            // common
            5,
            option::none(),
            option::none(),
        );

        let composable1_obj = object::object_from_constructor_ref(vector::borrow(&composable_constructor_refs, 0));
        let composable2_obj = object::object_from_constructor_ref(vector::borrow(&composable_constructor_refs, 1));
        let composable3_obj = object::object_from_constructor_ref(vector::borrow(&composable_constructor_refs, 2));
        let composable4_obj = object::object_from_constructor_ref(vector::borrow(&composable_constructor_refs, 3));
        let composable5_obj = object::object_from_constructor_ref(vector::borrow(&composable_constructor_refs, 4));
        
        // print names
        let composable1_name = token::name<Composable>(composable1_obj);
        let composable2_name = token::name<Composable>(composable2_obj);
        let composable3_name = token::name<Composable>(composable3_obj);
        let composable4_name = token::name<Composable>(composable4_obj);
        let composable5_name = token::name<Composable>(composable5_obj);

        debug::print<String>(&string::utf8(b"Composable Names:"));
        debug::print<String>(&composable1_name);
        debug::print<String>(&composable2_name);
        debug::print<String>(&composable3_name);
        debug::print<String>(&composable4_name);
        debug::print<String>(&composable5_name);

        // assert they have tokens bound to them
        let bound_tokens1 = composable_token::traits_from_composable(composable1_obj);
        let bound_tokens2 = composable_token::traits_from_composable(composable2_obj);
        let bound_tokens3 = composable_token::traits_from_composable(composable3_obj);
        let bound_tokens4 = composable_token::traits_from_composable(composable4_obj);
        let bound_tokens5 = composable_token::traits_from_composable(composable5_obj);

        // print the bound children
        let bound_token1 = vector::borrow(&bound_tokens1, 0);
        let bound_token2 = vector::borrow(&bound_tokens2, 0);
        let bound_token3 = vector::borrow(&bound_tokens3, 0);
        let bound_token4 = vector::borrow(&bound_tokens4, 0);
        let bound_token5 = vector::borrow(&bound_tokens5, 0);

        debug::print<String>(&string::utf8(b"Bound children:"));
        debug::print<address>(&object::object_address(bound_token1));
        debug::print<address>(&object::object_address(bound_token2));
        debug::print<address>(&object::object_address(bound_token3));
        debug::print<address>(&object::object_address(bound_token4));
        debug::print<address>(&object::object_address(bound_token5));

        // print their names
        let bound_token1_name = token::name<Trait>(*bound_token1);
        let bound_token2_name = token::name<Trait>(*bound_token2);
        let bound_token3_name = token::name<Trait>(*bound_token3);
        let bound_token4_name = token::name<Trait>(*bound_token4);
        let bound_token5_name = token::name<Trait>(*bound_token5);

        debug::print<String>(&string::utf8(b"Bound children names:"));
        debug::print<String>(&bound_token1_name);
        debug::print<String>(&bound_token2_name);
        debug::print<String>(&bound_token3_name);
        debug::print<String>(&bound_token4_name);
        debug::print<String>(&bound_token5_name);

        // print count after mint
        debug::print<String>(&string::utf8(b"BODY COUNT AFTER MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Body")));

        debug::print<String>(&string::utf8(b"SLOTH COUNT AFTER MINT: "));
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Sloth")));

        // // create more tokens
        // let constructor_refs2 = create_batch<Trait>(
        //     creator,
        //     object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
        //     string::utf8(b"Token Description"),
        //     vector[
        //         string::utf8(b"token%20cat"),
        //         string::utf8(b"token%20dog"),
        //         string::utf8(b"token%20horse"),
        //         string::utf8(b"token%20bird"),
        //         string::utf8(b"token%20fish")
        //     ],
        //     vector[
        //         string::utf8(b"token_cat"), 
        //         string::utf8(b"token_dog"), 
        //         string::utf8(b"token_horse"),
        //         string::utf8(b"token_bird"),
        //         string::utf8(b"token_fish")
        //     ],
        //     vector[
        //         string::utf8(b"suffix"),
        //         string::utf8(b"suffix"),
        //         string::utf8(b"suffix"),
        //         string::utf8(b"suffix"),
        //         string::utf8(b"suffix")
        //     ],
        //     5,
        //     option::none(),
        //     option::none(),
        //     vector::empty(),
        //     vector::empty(),
        //     vector::empty()
        // );
        
        // let token6_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs2, 0));
        // let token7_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs2, 1));
        // let token8_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs2, 2));
        // let token9_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs2, 3));
        // let token10_obj = object::object_from_constructor_ref(vector::borrow(&constructor_refs2, 4));

        // // print names
        // let token6_name = token::name<Trait>(token6_obj);
        // let token7_name = token::name<Trait>(token7_obj);
        // let token8_name = token::name<Trait>(token8_obj);
        // let token9_name = token::name<Trait>(token9_obj);
        // let token10_name = token::name<Trait>(token10_obj);

        // // print uris
        // let token6_uri = token::uri<Trait>(token6_obj);
        // let token7_uri = token::uri<Trait>(token7_obj);
        // let token8_uri = token::uri<Trait>(token8_obj);
        // let token9_uri = token::uri<Trait>(token9_obj);
        // let token10_uri = token::uri<Trait>(token10_obj);

        // debug::print<String>(&string::utf8(b"Added Token Names:"));
        // debug::print<String>(&token6_name);
        // debug::print<String>(&token7_name);
        // debug::print<String>(&token8_name);
        // debug::print<String>(&token9_name);
        // debug::print<String>(&token10_name);

        // debug::print<String>(&string::utf8(b"Added Token URIs:"));
        // debug::print<String>(&token6_uri);
        // debug::print<String>(&token7_uri);
        // debug::print<String>(&token8_uri);
        // debug::print<String>(&token9_uri);
        // debug::print<String>(&token10_uri);
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222), expected_failure(abort_code = EMAX_SUPPLY_REACHED)]
    /// Test updating the total supply in the tracker
    fun test_total_supply_exceeded(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // creator creates a collection
        let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
            true,
            true, 
            true,
            true,
            true, 
            true,
            true,
            true, 
            true,
            option::none(),
            option::none(),
        );

        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
        // Add base type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 5);
        
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 0, 1);

        // create traits
        let constructor_refs = create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base")
            ],
            vector[
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b"")
            ],
            5,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );

        // assert total supply is 5
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // assert count is 5
        debug::print<u64>(&count_from_tracker(collection_obj_addr, string::utf8(b"Base")));
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // create one more token; should fail
        create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
            ],
            vector[
                string::utf8(b"Sloth Base"),
            ],
            vector[
                string::utf8(b""),
            ],
            1,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    /// Test updating the total supply in the tracker
    fun test_update_type_total_supply(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // creator creates a collection
        let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
            true,
            true, 
            true,
            true,
            true, 
            true,
            true,
            true, 
            true,
            option::none(),
            option::none(),
        );

        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
        // Add base type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 5);
        
        // assert total supply is 5
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // assert count is 0
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 0, 1);

        // create traits
        let constructor_refs = create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base")
            ],
            vector[
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Base")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b""),
                // string::utf8(b"")
            ],
            5,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );


        // assert count is 5
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // update total supply
        update_type_total_supply_internal(collection_obj_addr, string::utf8(b"Base"), 6);

        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 6, 1);
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // create one more token
        create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
            ],
            vector[
                string::utf8(b"Sloth Base"),
            ],
            vector[
                string::utf8(b""),
            ],
            1,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );

        // assert!(
        //     total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base"))
        //     == count_from_tracker(collection_obj_addr, string::utf8(b"Base")), 
        //     1
        // );
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222), expected_failure(abort_code = ENEW_SUPPLY_LESS_THAN_OLD)]
    /// Test update total supply with a new total supply less than the current total supply
    fun test_update_type_total_supply_less_than_current(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // creator creates a collection
        let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
            true,
            true, 
            true,
            true,
            true, 
            true,
            true,
            true, 
            true,
            option::none(),
            option::none(),
        );

        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
        // Add base type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 5);
        
        // assert total supply is 5
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // assert count is 0
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 0, 1);

        // update total supply
        update_type_total_supply_internal(collection_obj_addr, string::utf8(b"Base"), 4);
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    /// Test add new type to the tracker
    fun test_add_new_type_to_tracker(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // creator creates a collection
        let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
            true,
            true, 
            true,
            true,
            true, 
            true,
            true,
            true, 
            true,
            option::none(),
            option::none(),
        );

        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
        // Add base type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 5);
        
        // assert total supply is 5
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 5, 1);

        // assert count is 0
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 0, 1);

        // add another type
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Body"), 5);

        // assert total supply is 5
        assert!(total_supply_from_tracker(collection_obj_addr, string::utf8(b"Body")) == 5, 1);

        // assert count is 0
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Body")) == 0, 1);

        // create traits
        let constructor_refs = create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Body"),
                string::utf8(b"Body"),
            ],
            vector[
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Body"),
                string::utf8(b"Sloth%20Body"),
            ],
            vector[
                string::utf8(b"Sloth Base"),
                string::utf8(b"Sloth Body"),
                string::utf8(b"Sloth Body"),
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                // string::utf8(b""),
            ],
            3,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );

        // assert count is 1 for base and 2 for body
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Base")) == 1, 1);
        assert!(count_from_tracker(collection_obj_addr, string::utf8(b"Body")) == 2, 1);
    }
}