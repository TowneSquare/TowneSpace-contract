#[test_only]
module townespace::unit_tests {
    use aptos_framework::account;
    use aptos_framework::object::{Object};
    use aptos_token_objects::aptos_token::{AptosCollection, AptosToken};
    //use std::error;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use townespace::core::{Self, TokenCollection, ComposableToken, ObjectToken};

    #[test(creator = @0x123)]
    fun a_create_collection_and_mint_tokens(creator: &signer) {
        let collection_name = string::utf8(b"collection name");
        let collection_symbol = string::utf8(b"collection symbol");
        let composable_token_name = string::utf8(b"composable token name");
        let object_token_name = string::utf8(b"object token name");
        let object_token_seed = b"object token seed";
        create_token_collection_helper(creator, collection_name, collection_symbol, true);
        let (composable_token_object, _) = mint_composable_token_helper(creator, collection_name, composable_token_name);
        mint_object_token_helper(creator, collection_name, object_token_name, composable_token_object, object_token_seed);
    }


    #[test(creator = @0x123)]
    fun b_compose_token(creator: &signer) {
        let collection_name = string::utf8(b"collection name");
        let collection_symbol = string::utf8(b"collection symbol");
        let composable_token_name = string::utf8(b"composable token name");
        let object_token_name = string::utf8(b"object token name");
        let object_token_seed = b"object token seed";
        create_token_collection_helper(creator, collection_name, collection_symbol, true);
        let (composable_token_object, _) = mint_composable_token_helper(creator, collection_name, composable_token_name);
        let (object_token_object, _) = mint_object_token_helper(creator, collection_name, object_token_name, composable_token_object, object_token_seed);
        core::compose_object(creator, composable_token_object, object_token_object);
    }

    #[test(creator = @0x123)]
    fun c_compose_decompose_token(creator: &signer) {
        let collection_name = string::utf8(b"collection name");
        let collection_symbol = string::utf8(b"collection symbol");
        let composable_token_name = string::utf8(b"composable token name");
        let object_token_name = string::utf8(b"object token name");
        let object_token_seed = b"object token seed";
        create_token_collection_helper(creator, collection_name, collection_symbol, true);
        let (composable_token_object, _) = mint_composable_token_helper(creator, collection_name, composable_token_name);
        let (object_token_object, _) = mint_object_token_helper(creator, collection_name, object_token_name, composable_token_object, object_token_seed);
        core::compose_object(creator, composable_token_object, object_token_object);
        // TODO: asserts
        let new_uri = string::utf8(b"new uri"); // User should not prompt this/ In most cases
        core::decompose_object(creator, composable_token_object, object_token_object, new_uri);
        // TODO: asserts
    }

    // TODO: test decompose entire token
    #[test(creator = @0x123)]
    fun d_decompose_entire_token(creator: &signer) {
        let collection_name = string::utf8(b"collection name");
        let collection_symbol = string::utf8(b"collection symbol");
        let composable_token_name = string::utf8(b"composable token name");
        let object_token_name_one = string::utf8(b"object token name one");
        let object_token_name_two = string::utf8(b"object token name two");
        let object_token_name_three = string::utf8(b"object token name three");
        let object_token_one_seed = b"object token one seed";
        let object_token_two_seed = b"object token two seed";
        let object_token_three_seed = b"object token three seed";
        create_token_collection_helper(creator, collection_name, collection_symbol, true);
        let (composable_token_object, _) = mint_composable_token_helper(creator, collection_name, composable_token_name);
        let (object_token_object_one, _) = mint_object_token_helper(creator, collection_name, object_token_name_one, composable_token_object, object_token_one_seed);
        let (object_token_object_two, _) = mint_object_token_helper(creator, collection_name, object_token_name_two, composable_token_object, object_token_two_seed);
        let (object_token_object_three, _) = mint_object_token_helper(creator, collection_name, object_token_name_three, composable_token_object, object_token_three_seed);
        core::compose_object(creator, composable_token_object, object_token_object_one);
        core::compose_object(creator, composable_token_object, object_token_object_two);
        core::compose_object(creator, composable_token_object, object_token_object_three);
        // TODO: asserts
        let new_uri = string::utf8(b"new uri"); // User should not prompt this/ In most cases
        core::decompose_entire_token(creator, composable_token_object, new_uri);
    }

    // TODO: test token supply

    // TODO: test transfer function

    fun create_token_collection_helper(
        creator: &signer,
        name: String,
        symbol: String,
        flag: bool,
    ): (Object<TokenCollection>, Object<AptosCollection>) {
        let creator_address = signer::address_of(creator);
        account::create_account_for_test(creator_address);
        core::create_token_collection_internal(
            creator,
            string::utf8(b"collection description"),
            100,
            name,
            symbol,
            string::utf8(b"collection uri"),
            flag,
            flag,
            flag,
            flag,
            flag,
            flag,
            true,
            flag,
            flag,
            1,
            100,
            b"token collection seed"
        )
    }

    fun mint_composable_token_helper(
        creator: &signer,
        collection_name: String,
        token_name: String,
    ): (Object<ComposableToken>, Object<AptosToken>) {

        core::mint_composable_token_internal(
            creator,
            collection_name,
            string::utf8(b"composable token description"),
            token_name,
            string::utf8(b"composable token uri"),
            100,
            vector::empty(),
            vector[string::utf8(b"bool")],
            vector[string::utf8(b"bool")],
            vector[vector[0x01]],
            b"composable token seed"
        )
    }

    fun mint_object_token_helper(
        creator: &signer,
        collection_name: String,
        token_name: String,
        composable_token_object: Object<ComposableToken>,
        seed: vector<u8>
        ): (Object<ObjectToken>, Object<AptosToken>) {

        core::mint_object_token_internal(
            creator,
            collection_name,
            string::utf8(b"object token description"),
            token_name,
            string::utf8(b"object token uri"),
            vector[string::utf8(b"bool")],
            vector[string::utf8(b"bool")],
            vector[vector[0x01]],
            composable_token_object,
            seed
        )
    }

    // TODO: test entry functions; test minting, burning
    
}