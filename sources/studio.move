/*
    - This module is a no-code implementation for the composability contract.
    - It is responsible for creating collections, creating tokens,
    and composing and decomposing tokens.
    - It is also responsible for transferring tokens.

    TODO:
        - use composable-token
*/

module townespace::studio {

    use aptos_framework::event;
    use aptos_framework::object::{Self, Object};
    use aptos_token_objects::collection;
    use composable_token::composable_token::{Self, Collection, Indexed};
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::string_utils;
    use std::vector;

    // ------
    // Events
    // ------

    #[event]
    struct TokensCreated has drop, store {
        tokens_addr: vector<address>
    }

    /// Mint a batch of tokens
    entry fun mint_tokens<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        token_count: u64,
        folder_uri: String
    ) { 
        let (_, tokens_addr) = create_tokens<T>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
            folder_uri,
            token_count
        );

        event::emit( TokensCreated { tokens_addr } );
    }
    
    inline fun create_tokens<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        folder_uri: String,
        token_count: u64
    ): (vector<Object<T>>, vector<address>) {
        let tokens = vector::empty<Object<T>>();
        let tokens_addr = vector::empty();
        
        // mint tokens
        let first_index = 1 + *option::borrow(&collection::count(collection));
        let last_index = first_index + token_count;
        for (i in first_index..last_index) {
            let token_uri = folder_uri;
            // folder_uri + "/" + i + ".png"
            string::append_utf8(&mut token_uri, b"/");
            string::append(&mut token_uri, string_utils::to_string(&i));
            string::append_utf8(&mut token_uri, b".png");

            let (constructor) = composable_token::create_token<T, Indexed>(
                signer_ref,
                collection,
                description,
                name,
                name_with_index_prefix,
                name_with_index_suffix,
                token_uri,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values
            );

            vector::push_back(&mut tokens, object::object_from_constructor_ref<T>(&constructor));
            vector::push_back(&mut tokens_addr, object::address_from_constructor_ref(&constructor));
        };

        (tokens, tokens_addr)
    }
}