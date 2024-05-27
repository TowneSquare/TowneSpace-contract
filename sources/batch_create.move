/*

    TODO:
*/

module townespace::batch_create {

    use aptos_framework::event;
    use aptos_framework::object::{Self, ConstructorRef, Object};
    use aptos_token_objects::collection;
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::string_utils;
    use std::vector;
    use composable_token::composable_token::{Self, Indexed, Collection};

    // ------
    // Errors
    // ------

    /// Token names and count length mismatch
    const ELENGTH_MISMATCH: u64 = 1;

    // ------
    // Events
    // ------

    #[event]
    struct TokensCreated has drop, store { addresses: vector<address> }

    // ---------------
    // Entry Functions
    // ---------------

    /// Create a batch of tokens
    public entry fun create_batch<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        names: vector<String>,
        folder_uri: String,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) {
        assert!(count == vector::length(&names), ELENGTH_MISMATCH);
        let constructor_refs = create_batch_tokens<T>(
            signer_ref,
            collection,
            description,
            names,
            folder_uri,
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

    // -------
    // Helpers
    // -------

    /// Helper function for creating a batch of tokens
    public fun create_batch_tokens<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        names: vector<String>,
        folder_uri: String,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): vector<ConstructorRef> {
        let constructor_refs = vector::empty<ConstructorRef>();
        for (i in 0..count) {
            let token_index = *option::borrow(&collection::count(collection)) + 1;
            let token_uri = folder_uri;
            // token uri: folder_uri + "/" + "prefix" + "%23" + i + ".png"
            string::append_utf8(&mut token_uri, b"/");
            let name = *vector::borrow<String>(&names, i);
            let prefix = *vector::borrow<String>(&names, i);
            string::append(&mut token_uri, name);
            string::append_utf8(&mut token_uri, b"%23");    // %23 is the ascii code for #
            string::append(&mut token_uri, string_utils::to_string(&token_index));
            string::append_utf8(&mut token_uri, b".png");
            
            let constructor = composable_token::create_token<T, Indexed>(
                signer_ref,
                collection,
                description,
                name,
                prefix,
                string::utf8(b""),
                token_uri,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values
            );

            vector::push_back(&mut constructor_refs, constructor);
        };

        constructor_refs
    }

    // ------------
    // Unit Testing
    // ------------

    #[test_only]
    use std::debug;
    #[test_only]
    use aptos_token_objects::collection::{FixedSupply};
    #[test_only]
    use aptos_token_objects::token;
    #[test_only]
    use townespace::common;

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    fun test_e2e(std: &signer, creator: &signer, minter: &signer) {
        let input_mint_price = 1000;

        let (creator_addr, _) = common::setup_test(std, creator, minter);
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        // creator creates a collection
        let collection_constructor_ref = composable_token::create_collection<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(100),
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

    
        // creator creates a batch of tokens
        let constructor_refs = create_batch_tokens<Trait>(
            creator,
            object::object_from_constructor_ref<Collection>(&collection_constructor_ref),
            string::utf8(b"Token Description"),
            vector[
                string::utf8(b"token_cat"), 
                string::utf8(b"token_dog"), 
                string::utf8(b"token_horse"),
                string::utf8(b"token_bird"),
                string::utf8(b"token_fish")
            ],
            string::utf8(b"folder_uri"),
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

        debug::print<String>(&token1_name);
        debug::print<String>(&token2_name);
        debug::print<String>(&token3_name);
        debug::print<String>(&token4_name);
        debug::print<String>(&token5_name);

        debug::print<String>(&token1_uri);
        debug::print<String>(&token2_uri);
        debug::print<String>(&token3_uri);
        debug::print<String>(&token4_uri);
        debug::print<String>(&token5_uri);
    }


}