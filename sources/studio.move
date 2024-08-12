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
    use aptos_std::smart_table::{Self, SmartTable};
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
    /// The type exists in the tracker
    const ETYPE_EXISTS: u64 = 5;
    /// The type does not exist in the tracker
    const ETYPE_DOES_NOT_EXIST: u64 = 6;
    /// The variant exists in the tracker
    const EVARIANT_EXISTS: u64 = 7;
    /// The variant does not exist in the tracker
    const EVARIANT_DOES_NOT_EXIST: u64 = 8;
    /// The tracker does not exist in the collection
    const ETRACKER_DOES_NOT_EXIST: u64 = 9;

    // -------
    // Structs
    // -------

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Global storage to track minting 
    struct Tracker has key {
        /// collection object
        collection_obj: Object<collection::Collection>,
        /// table to track minting <String, vector<Variant>>.
        table: SmartTable<String, vector<Variant>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Variant Data Structure
    struct Variant has copy, drop, key, store {
        /// variant name
        name: String,
        /// total supply
        max_supply: u64,
        /// total minted count
        total_minted: u64
    }

    // ------
    // Events
    // ------

    #[event]
    struct TrackerInitialized has drop, store { collection_obj: Object<collection::Collection> }

    #[event]
    struct TypeAdded has drop, store { 
        collection_obj_addr: address, 
        type_name: String,
    }

    #[event]
    struct VariantAdded has drop, store { 
        collection_obj_addr: address, 
        type_name: String, 
        variant_name: String,
        initial_supply: u64
    }

    #[event]
    struct TokensCreated has drop, store { addresses: vector<address> }

    // ----------------
    // Assert functions
    // ----------------

    /// Asserts the type exists in the tracker
    inline fun assert_type_exists(collection_obj_addr: address, type_name: String) {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        // map to names
        let types = smart_table::keys<String, vector<Variant>>(&tracker.table);
        let (type_exists, _) = vector::index_of(&types, &type_name);
        assert!(type_exists, ETYPE_DOES_NOT_EXIST);
    }

    /// Asserts the type does not exist in the tracker
    inline fun assert_type_does_not_exist(collection_obj_addr: address, type: String) {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        // get a list of type names
        let types = smart_table::keys<String, vector<Variant>>(&tracker.table);
        let (type_exists, _) = vector::index_of(&types, &type);
        assert!(!type_exists, ETYPE_EXISTS);
    }

    // /// Asserts the variant exists in the tracker
    // inline fun assert_variant_exists(collection_obj_addr: address, type: String, variant: String) {
    //     let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
    //     // get a list of variant names
    //     let variants = *smart_table::borrow<String, vector<Variant>>(&tracker.table, type);
    //     let variant_exists: bool = false;
    //     for (i in 0..vector::length(&variants)) {
    //         if (variant == (*vector::borrow(&variants, i)).name) {
    //             variant_exists = true;
    //             break
    //         }
    //     };
    //     // assert!(variant_exists, EVARIANT_DOES_NOT_EXIST);
    // }

    /// Asserts the variant does not exist in the tracker
    inline fun assert_variant_does_not_exist(collection_obj_addr: address, type: String, variant: String) {
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        // get a list of variant names
        let variants = *smart_table::borrow<String, vector<Variant>>(&tracker.table, type);
        let variant_exists: bool = false;
        for (i in 0..vector::length(&variants)) {
            if (variant == (*vector::borrow(&variants, i)).name) {
                variant_exists = true;
                break
            }
        };
        assert!(!variant_exists, EVARIANT_EXISTS);
    }

    // /// Helper function to check if the requested count is equal or less than (max supply - total minted)
    // inline fun assert_count(collection_obj_addr: address, type_name: String, variant_name: String, count: u64) {
    //     let total_minted = variant_count(collection_obj_addr, type_name, variant_name);
    //     let max_supply = variant_from_variant_name(collection_obj_addr, type_name, variant_name).max_supply;
    //     assert!(count <= (max_supply - total_minted), EMAX_SUPPLY_REACHED);
    // }

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
        type_name: String,
    ) acquires Tracker {
        // asserting the signer is the collection owner
        assert!(object::is_owner<Collection>(object::address_to_object<Collection>(collection_obj_addr), signer::address_of(signer_ref)), ENOT_OWNER);
        // asserting type not in tracker
        assert_type_does_not_exist(collection_obj_addr, type_name);
        // initialize values
        let variants = vector::empty<Variant>();
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        smart_table::add<String, vector<Variant>>(&mut tracker.table, type_name, variants);

        // emit event
        event::emit(TypeAdded { collection_obj_addr, type_name });
    }

    /// Add variant to a type in the tracker table; callable only by the collection owner
    public entry fun add_variant_to_type(
        signer_ref: &signer,
        collection_obj_addr: address,
        type_name: String,
        variant_name: String,
        supply: u64
    ) acquires Tracker {
        // asserting the signer is the collection owner
        assert!(object::is_owner<Collection>(object::address_to_object<Collection>(collection_obj_addr), signer::address_of(signer_ref)), ENOT_OWNER);
        // assert variant does not exist in the tracker
        assert_variant_does_not_exist(collection_obj_addr, type_name, variant_name);
        // add variant to the tracker
        let variant = Variant { name: variant_name, max_supply: supply, total_minted: 0 };
        let variants = smart_table::borrow_mut<String, vector<Variant>>(&mut borrow_global_mut<Tracker>(collection_obj_addr).table, type_name);
        vector::push_back(variants, variant);

        // emit event
        event::emit( VariantAdded { collection_obj_addr, type_name, variant_name, initial_supply: supply });
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
        composable_descriptions: vector<String>,
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
            composable_descriptions,
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
        type_name: String,
        variant_name: String,
        new_total_supply: u64
    ) acquires Tracker {
        assert!(object::is_owner<Collection>(collection_obj, signer::address_of(signer_ref)), ENOT_OWNER);
        update_variant_total_supply_internal(object::object_address(&collection_obj), type_name, variant_name, new_total_supply);
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
                table: smart_table::new<String, vector<Variant>>()
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
        types: vector<String>,
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
        assert!(count == vector::length(&types), ELENGTH_MISMATCH);
        assert!(count == vector::length(&uri), ELENGTH_MISMATCH);
        assert!(count == vector::length(&name_with_index_prefix), ELENGTH_MISMATCH);
        let constructor_refs = vector::empty<ConstructorRef>();
        let collection_obj_addr = object::object_address(&collection);
        for (i in 0..count) {
            let type = *vector::borrow<String>(&types, i);
            let input_name = *vector::borrow<String>(&name_with_index_prefix, i);
            // assert_count(object::object_address(&collection), type, input_name, 1);
            let token_index = variant_count(collection_obj_addr, type, input_name) + 1;
            let uri = *vector::borrow<String>(&uri, i);
            // token name: prefix + # + index + suffix
            let name = input_name;
            string::append_utf8(&mut name, b" #");
            string::append(&mut name, string_utils::to_string(&token_index));
            // string::append(&mut suffix, name_with_index_suffix);
            let constructor = composable_token::create_token<T, Named>(
                signer_ref,
                collection,
                type,
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
            increment_count(collection_obj_addr, type, input_name);
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
        composable_descriptions: vector<String>,
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
    inline fun increment_count(collection_obj_addr: address, type_name: String, variant_name: String) acquires Tracker {
        // increment variant count
        let mut_variant = mut_variant_from_variant_name(collection_obj_addr, type_name, variant_name);
        mut_variant.total_minted = mut_variant.total_minted + 1;
    }

    /// Helper function to return the total minted number of a variant
    inline fun variant_count(collection_obj_addr: address, type: String, variant: String): u64 acquires Tracker {
        let variant = mut_variant_from_variant_name(collection_obj_addr, type, variant);
        variant.total_minted
    }

    /// Helper function to update the total supply in the tracker; new total supply should be greater than the current total supply
    inline fun update_variant_total_supply_internal(collection_obj_addr: address, type_name: String, variant_name: String, new_total_supply: u64) acquires Tracker {
        // let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let variant = variant_from_variant_name(collection_obj_addr, type_name, variant_name);
        let current_total_supply = variant.max_supply;
        assert!(new_total_supply > current_total_supply, ENEW_SUPPLY_LESS_THAN_OLD);
        let variant = mut_variant_from_variant_name(collection_obj_addr, type_name, variant_name);
        variant.max_supply = new_total_supply;
    }

    /// Helper function to get a variant from a given type name
    inline fun variant_from_variant_name(collection_obj_addr: address, type_name: String, variant_name: String): Variant acquires Tracker {
        // assert_variant_exists(collection_obj_addr, type_name, variant_name);
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let variants = *smart_table::borrow<String, vector<Variant>>(&tracker.table, type_name);
        let variant_names = vector::empty<String>();
        for (i in 0..vector::length(&variants)) {
            vector::push_back(&mut variant_names, (*vector::borrow(&variants, i)).name);
        };
        let (_, variant_index) = vector::index_of(&variant_names, &variant_name);
        *vector::borrow<Variant>(
            smart_table::borrow<String, vector<Variant>>(&tracker.table, type_name), 
            variant_index
        )
    }

    /// Helper function to get a mut variant from a given type name
    inline fun mut_variant_from_variant_name(collection_obj_addr: address, type_name: String, variant_name: String): &mut Variant acquires Tracker {
        // assert_variant_exists(collection_obj_addr, type_name, variant_name);
        let variants = smart_table::borrow_mut<String, vector<Variant>>(&mut borrow_global_mut<Tracker>(collection_obj_addr).table, type_name);
        let variant_names = vector::empty<String>();
        for (i in 0..vector::length(variants)) {
            vector::push_back(&mut variant_names, (*vector::borrow(variants, i)).name);
        };
        let (_, variant_index) = vector::index_of(&variant_names, &variant_name);
        vector::borrow_mut<Variant>(
            variants,
            variant_index
        )
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
    /// Returns all types in the tracker
    public fun all_types(collection_obj_addr: address): vector<String> acquires Tracker {
        assert!(exists<Tracker>(collection_obj_addr), ETRACKER_DOES_NOT_EXIST);
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        smart_table::keys<String, vector<Variant>>(&tracker.table)
    }

    #[view]
    /// Returns all variants of a token type
    public fun all_variants_from_type(collection_obj_addr: address, type: String): vector<String> acquires Tracker {
        assert!(exists<Tracker>(collection_obj_addr), ETRACKER_DOES_NOT_EXIST);
        let tracker = borrow_global_mut<Tracker>(collection_obj_addr);
        let variants = *smart_table::borrow<String, vector<Variant>>(&tracker.table, type);
        let variant_names = vector::empty<String>();
        for (i in 0..vector::length(&variants)) {
            vector::push_back(&mut variant_names, (*vector::borrow(&variants, i)).name);
        };
        variant_names
    }

    #[view]
    /// Returns the total supply of a token type and the count of minted tokens of the type; useful for calculating rarity
    public fun type_supply(collection_obj_addr: address, type: String): (u64, u64) acquires Tracker {
        assert!(exists<Tracker>(collection_obj_addr), ETRACKER_DOES_NOT_EXIST);
        // get all variants of the type
        let variants = *smart_table::borrow<String, vector<Variant>>(&borrow_global_mut<Tracker>(collection_obj_addr).table, type);
        // get the total minted count and the max supply count for each variant
        let max_supply = 0;
        let total_minted = 0;
        for (i in 0..vector::length(&variants)) {
            max_supply = max_supply + (*vector::borrow(&variants, i)).max_supply;
            total_minted = total_minted + (*vector::borrow(&variants, i)).total_minted;
        };

        (max_supply, total_minted)
    }

    #[view]
    /// Returns the total supply of a token variant and the count of minted tokens of the variant; useful for calculating rarity
    public fun variant_supply(collection_obj_addr: address, type: String, variant: String): (u64, u64) acquires Tracker {
        assert!(exists<Tracker>(collection_obj_addr), ETRACKER_DOES_NOT_EXIST);
        let variant = variant_from_variant_name(collection_obj_addr, type, variant);
        (variant.max_supply, variant.total_minted)
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

        let (_creator_addr, _) = common::setup_test(std, creator, minter);
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
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
        // Add variants to the base type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_1"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_2"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_3"),
            1
        );

        let (max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(max_supply == 5, 1);
        assert!(total_minted == 0, 1);
    
        // creator creates a batch of tokens
        let constructor_refs = create_batch_internal<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            // types
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            // uris
            vector[
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base"),
                string::utf8(b"Sloth%20Base")
            ],
            // variants
            vector[
                string::utf8(b"variant_1"),
                string::utf8(b"variant_2"),
                string::utf8(b"variant_3"),
                string::utf8(b"variant_1"),
                string::utf8(b"variant_2")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b"")
            ],
            5,
            option::none(),
            option::none(),
            vector::empty(),
            vector::empty(),
            vector::empty()
        );

        let (max_supply, total_minted) = variant_supply(collection_obj_addr, string::utf8(b"Base"), string::utf8(b"variant_1"));
        assert!(max_supply == 2, 1);
        assert!(total_minted == 2, 1);
        let (max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(max_supply == 5, 1);
        debug::print<u64>(&total_minted);
        assert!(total_minted == 5, 1);

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
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        debug::print<String>(&string::utf8(b"BASE COUNT AFTER MINT: "));
        debug::print<u64>(&total_minted);

        // add body and sloth type to the tracker
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Body"));
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Sloth"));
        // add variants to the body type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Body"), 
            string::utf8(b"body_variant_1"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Body"), 
            string::utf8(b"body_variant_2"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Body"), 
            string::utf8(b"body_variant_3"),
            1
        );

        // add variants to the sloth type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Sloth"), 
            string::utf8(b"sloth_variant_1"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Sloth"), 
            string::utf8(b"sloth_variant_2"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Sloth"), 
            string::utf8(b"sloth_variant_3"),
            1
        );

        // print count
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Body"));
        debug::print<String>(&string::utf8(b"BODY COUNT BEFORE MINT: "));
        debug::print<u64>(&total_minted);

        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Sloth"));
        debug::print<String>(&string::utf8(b"SLOTH COUNT BEFORE MINT: "));
        debug::print<u64>(&total_minted);

        // create composable tokens with soulbound traits
        let composable_constructor_refs = create_batch_composables_with_soulbound_traits_internal(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            // trait type
            vector[
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body"),
                string::utf8(b"Body")
            ],
            // uri
            vector[
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth"),
                string::utf8(b"Body%20Sloth")
            ],
            // variant
            vector[
                string::utf8(b"body_variant_1"),
                string::utf8(b"body_variant_2"),
                string::utf8(b"body_variant_3"),
                string::utf8(b"body_variant_1"),
                string::utf8(b"body_variant_2")
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
            // composable type
            vector[
                string::utf8(b"Sloth"),
                string::utf8(b"Sloth"),
                string::utf8(b"Sloth"),
                string::utf8(b"Sloth"),
                string::utf8(b"Sloth")
            ],
            // uri
            vector[
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth"),
                string::utf8(b"Composable%20Sloth")
            ],
            // variant
            vector[
                string::utf8(b"sloth_variant_1"),
                string::utf8(b"sloth_variant_2"),
                string::utf8(b"sloth_variant_3"),
                string::utf8(b"sloth_variant_1"),
                string::utf8(b"sloth_variant_2")
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
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Body"));
        debug::print<String>(&string::utf8(b"BODY COUNT AFTER MINT: "));
        debug::print<u64>(&total_minted);

        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Sloth"));
        debug::print<String>(&string::utf8(b"SLOTH COUNT AFTER MINT: "));
        debug::print<u64>(&total_minted);

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

    // #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    // // Test mint more than the variant's max supply
    // #[expected_failure (abort_code = 2, location = Self)]
    // fun test_mint_more_than_max_supply(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
    //     let (_creator_addr, _) = common::setup_test(std, creator, minter);
    //     // creator creates a collection
    //     let collection_constructor_ref = create_collection_with_tracker_internal<FixedSupply>(
    //         creator,
    //         string::utf8(b"Collection Description"),
    //         option::some(1000),
    //         string::utf8(b"Collection Name"),
    //         string::utf8(b"Collection Symbol"),
    //         string::utf8(b"Collection URI"),
    //         true,
    //         true, 
    //         true,
    //         true,
    //         true, 
    //         true,
    //         true,
    //         true, 
    //         true,
    //         option::none(),
    //         option::none(),
    //     );

    //     let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        
    //     // Add base type to the tracker
    //     add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
    //     // Add variants to the base type
    //     add_variant_to_type(
    //         creator, 
    //         collection_obj_addr, 
    //         string::utf8(b"Base"), 
    //         string::utf8(b"variant_1"),
    //         2
    //     );

    //     // creator creates a batch of tokens
    //     create_batch_internal<Trait>(
    //         creator,
    //         object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
    //         // types
    //         vector[
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base"),
    //         ],
    //         // uris
    //         vector[
    //             string::utf8(b"Sloth%20Base"),
    //             string::utf8(b"Sloth%20Base"),
    //             string::utf8(b"Sloth%20Base"),
    //             string::utf8(b"Sloth%20Base"),
    //         ],
    //         // variants
    //         vector[
    //             string::utf8(b"variant_1"),
    //             string::utf8(b"variant_1"),
    //             string::utf8(b"variant_1"),
    //             string::utf8(b"variant_1"),
    //         ],
    //         vector[
    //             string::utf8(b""),
    //             string::utf8(b""),
    //             string::utf8(b""),
    //             string::utf8(b""),
    //         ],
    //         4,
    //         option::none(),
    //         option::none(),
    //         vector::empty(),
    //         vector::empty(),
    //         vector::empty()
    //     );
    // }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    /// Test updating the total supply in the tracker
    fun test_update_type_total_supply(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (_creator_addr, _) = common::setup_test(std, creator, minter);
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
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
        
        // assert total supply is 0
        let (max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(max_supply == 0, 1);

        // assert count is 0
        assert!(total_minted == 0, 1);

        // add variants to the base type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"Sloth Base"),
            6
        );

        // create traits
        let _constructor_refs = create_batch_internal<Trait>(
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
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(total_minted == 5, 1);

        // update total supply
        update_variant_total_supply_internal(
            collection_obj_addr, 
            string::utf8(b"Base"),
            string::utf8(b"Sloth Base"),
            10
        );

        let (max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        // debug::print<u64>(&max_supply);
        assert!(max_supply == 10, 1);
        assert!(total_minted == 5, 1);

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
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    // Test update total supply with a new total supply less than the current total supply
    #[expected_failure (abort_code = 3, location = Self)]
    fun test_update_type_total_supply_less_than_current(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (_creator_addr, _) = common::setup_test(std, creator, minter);
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
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
        // Add variant to the base type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"sloth_variant_1"),
            5
        );

        // update total supply
        update_variant_total_supply_internal(collection_obj_addr, string::utf8(b"Base"), string::utf8(b"sloth_variant_1"), 4);
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    /// Test add new type to the tracker
    fun test_add_new_type_to_tracker(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        let (_creator_addr, _) = common::setup_test(std, creator, minter);
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
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
        
        // assert total supply is 0
        let (max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(max_supply == 0, 1);

        // assert count is 0
        assert!(total_minted == 0, 1);

        // add another type
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Body"));

        // add variant to the base type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"base_variant_1"),
            2
        );

        // add variant to the body type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Body"), 
            string::utf8(b"body_variant_1"),
            2
        );

        // add another variant to the body type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Body"), 
            string::utf8(b"body_variant_2"),
            2
        );

        // create traits
        create_batch_internal<Trait>(
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
                string::utf8(b"base_variant_1"),
                string::utf8(b"body_variant_1"),
                string::utf8(b"body_variant_2"),
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
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Base"));
        assert!(total_minted == 1, 1);
        let (_max_supply, total_minted) = type_supply(collection_obj_addr, string::utf8(b"Body"));
        assert!(total_minted == 2, 1);
    }

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    // Test view functions
    fun test_view_functions(std: &signer, creator: &signer, minter: &signer) acquires Tracker {
        common::setup_test(std, creator, minter);
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
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"));
        add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Hat"));
        // Add variants to the base type
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_1"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_2"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Base"), 
            string::utf8(b"variant_3"),
            1
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Hat"), 
            string::utf8(b"hat_variant_1"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Hat"), 
            string::utf8(b"hat_variant_2"),
            2
        );
        add_variant_to_type(
            creator, 
            collection_obj_addr, 
            string::utf8(b"Hat"), 
            string::utf8(b"hat_variant_3"),
            1
        );
        // view functions
        type_supply(collection_obj_addr, string::utf8(b"Base"));
        type_supply(collection_obj_addr, string::utf8(b"Hat"));
        variant_supply(collection_obj_addr, string::utf8(b"Base"), string::utf8(b"variant_1"));
        variant_supply(collection_obj_addr, string::utf8(b"Hat"), string::utf8(b"hat_variant_1"));
        let types = all_types(collection_obj_addr);
        let variants = all_variants_from_type(collection_obj_addr, string::utf8(b"Base"));
        debug::print<vector<String>>(&types);
        debug::print<vector<String>>(&variants);
    }
}