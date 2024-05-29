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
        descriptions: vector<String>,
        uri_with_index_prefix: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        folder_uri: String,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) {
        assert!(count == vector::length(&descriptions), ELENGTH_MISMATCH);
        assert!(count == vector::length(&uri_with_index_prefix), ELENGTH_MISMATCH);
        assert!(count == vector::length(&name_with_index_prefix), ELENGTH_MISMATCH);
        assert!(count == vector::length(&name_with_index_suffix), ELENGTH_MISMATCH);

        let constructor_refs = create_batch_tokens<T>(
            signer_ref,
            collection,
            descriptions,
            uri_with_index_prefix,
            name_with_index_prefix,
            name_with_index_suffix,
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
        descriptions: vector<String>,
        uri_with_index_prefix: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
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
            let description = *vector::borrow<String>(&descriptions, i);
            let token_index = *option::borrow(&collection::count(collection)) + 1;
            let uri_with_index_prefix = *vector::borrow<String>(&uri_with_index_prefix, i);
            let name_with_index_prefix = *vector::borrow<String>(&name_with_index_prefix, i);
            let name_with_index_suffix = *vector::borrow<String>(&name_with_index_suffix, i);
            // token uri: folder_uri + "/" + "prefix" + "%20" + "%23" + i + ".png"
            let token_uri = folder_uri;
            string::append_utf8(&mut token_uri, b"/");
            string::append(&mut token_uri, uri_with_index_prefix);
            string::append_utf8(&mut token_uri, b"%20");
            string::append_utf8(&mut token_uri, b"%23");    // %23 is the ascii code for #
            string::append(&mut token_uri, string_utils::to_string(&token_index));
            string::append_utf8(&mut token_uri, b".png");
            
            // token name: prefix + # + index + suffix
            let prefix = name_with_index_prefix;
            let suffix = string::utf8(b" ");
            string::append_utf8(&mut prefix, b" #");
            string::append(&mut suffix, name_with_index_suffix);
            let constructor = composable_token::create_token<T, Indexed>(
                signer_ref,
                collection,
                description,
                string::utf8(b""),
                prefix,
                suffix,
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
    #[test_only]
    use composable_token::composable_token::{Trait};

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
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            vector[
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth")
            ],
            vector[
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"),
                string::utf8(b"Cool Sloth"),
                string::utf8(b"Cool Sloth")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b"")
            ],
            string::utf8(b"https://bafybeifnhfsfugbsopnturkkhxsfwws3zhsrlnuv3e4ips4bcl4j6cszrq.ipfs.w3s.link"),
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

        // // create more tokens
        // let constructor_refs2 = create_batch_tokens<Trait>(
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
        //     string::utf8(b"folder_uri"),
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


}