/*
    This module is responsible for migrating the NFTs from 
    the legacy standard to the digital assets standard.

    The migrated NFT can either be a digital asset or a composable.

    It works as follow:
    - User inputs their NFTs address.
    - We check if that NFT is in the legacy standard and owned by the signer.
    - All conditions are met, we take the NFT metadata, mint a new NFT in the digital assets standard and burn the legacy NFT.
    
    Notes: 
        - migrated NFTs will have a universal collection, this is to avoid having to create a new collection for each NFT.
        - Does not work on soulbound tokens.

    TODO: 
        - add royalty support.
        - add support to migrate NFTs to composable.
        - add support to migrate digital assets to composable.
        - add support to batch migrate.
        - add events.
        - first proposed way is owner specific. Make a creator specific way.
*/

module townespace::token_migrate {

    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_token::token as token_v1;
    use aptos_token_objects::collection;
    use aptos_token_objects::token as token_v2;

    use std::option;
    use std::signer;
    use std::string::{Self, String};

    use townespace::resource_manager;

    #[event]
    struct TokenMigratedFromV1toV2 has drop, store {
        old_token_id: token_v1::TokenId,
        new_token_address: address,
    }

    public entry fun init(signer_ref: &signer, uri: String) {
        // assert signer is composable_token
        assert!(signer::address_of(signer_ref) == @townespace, 1);
        // create a collection with unlimited supply
        collection::create_unlimited_collection(
            &resource_manager::resource_signer(),
            string::utf8(b"transform your NFTv1 into NFTv2"),
            string::utf8(b"Migrated NFTs"),
            option::none(),
            uri
        );
    }

    // by owner
    public entry fun from_v1_to_v2_by_owner(signer_ref: &signer, creator_addr: address, collection_name: String, token_name: String, property_version: u64) {
        let (old_token_id, token_addr) = from_v1_to_v2_by_owner_internal(signer_ref, creator_addr, collection_name, token_name, property_version);
        event::emit<TokenMigratedFromV1toV2>(
            TokenMigratedFromV1toV2 {
                old_token_id: old_token_id,
                new_token_address: token_addr
            }
        )
    }

    // by creator
    public entry fun from_v1_to_v2_by_creator(creator_signer_ref: &signer, owner_addr: address, collection_name: String, token_name: String, property_version: u64) {
        let (old_token_id, token_addr) = from_v1_to_v2_by_creator_internal(creator_signer_ref, owner_addr, collection_name, token_name, property_version);
        event::emit<TokenMigratedFromV1toV2>(
            TokenMigratedFromV1toV2 {
                old_token_id: old_token_id,
                new_token_address: token_addr
            }
        )
    }

    fun from_v1_to_v2_by_owner_internal(signer_ref: &signer, creator_addr: address, collection_name: String, token_name: String, property_version: u64): (token_v1::TokenId, address) {
        let signer_addr = signer::address_of(signer_ref);
        // get the token metadata
        let token_id = token_v1::create_token_id_raw(creator_addr, collection_name, token_name, property_version);
        let token_data_id = token_v1::create_token_data_id(creator_addr, collection_name, token_name);
        let token_description = token_v1::get_tokendata_description(token_data_id);
        let token_uri = token_v1::get_tokendata_uri(creator_addr, token_data_id);
        // TODO: if token has royalty, get it

        // mint a new token v2 with the metadata
        let constructor_ref = token_v2::create(
            &resource_manager::resource_signer(), 
            string::utf8(b"Migrated NFTs"),
            token_description,
            token_name,
            option::none(), // TODO: add royalty if applicable
            token_uri
        );
        // transfer it to the signer
        let new_token_obj = object::object_from_constructor_ref<token_v2::Token>(&constructor_ref);
        object::transfer<token_v2::Token>(&resource_manager::resource_signer(), new_token_obj, signer_addr);
        // burn the token v1
        token_v1::burn(signer_ref, creator_addr, collection_name, token_name, property_version, 1);

        (token_id, object::object_address<token_v2::Token>(&new_token_obj))
    }

    fun from_v1_to_v2_by_creator_internal(creator_signer_ref: &signer, owner_addr: address, collection_name: String, token_name: String, property_version: u64): (token_v1::TokenId, address) {
        let creator_addr = signer::address_of(creator_signer_ref);
        // get the token metadata
        let token_id = token_v1::create_token_id_raw(creator_addr, collection_name, token_name, property_version);
        let token_data_id = token_v1::create_token_data_id(creator_addr, collection_name, token_name);
        let token_description = token_v1::get_tokendata_description(token_data_id);
        let token_uri = token_v1::get_tokendata_uri(creator_addr, token_data_id);
        // TODO: if token has royalty, get it
       
        // mint a new token v2 with the metadata
        let constructor_ref = token_v2::create(
            creator_signer_ref, 
            string::utf8(b"Migrated NFTs"),
            token_description,
            token_name,
            option::none(), // TODO: add royalty if applicable
            token_uri
        );
        // transfer it to the owner
        let new_token_obj = object::object_from_constructor_ref<token_v2::Token>(&constructor_ref);
        object::transfer<token_v2::Token>(creator_signer_ref, new_token_obj, owner_addr);
        // burn the token v1
        token_v1::burn_by_creator(creator_signer_ref, owner_addr, collection_name, token_name, property_version, 1);

        (token_id, object::object_address<token_v2::Token>(&new_token_obj))
    }
        

    #[test_only]
    use std::features;
    #[test_only]
    use std::bcs;
    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::account;

    #[test_only]
    public fun collection_name(): String {
        string::utf8(b"test collection")
    }

    #[test_only]
    public fun token_name(): String {
        string::utf8(b"test token")
    }

    #[test_only]
    public fun create_collection_and_token(
        creator: &signer,
        amount: u64,
        collection_max: u64,
        token_max: u64,
        property_keys: vector<String>,
        property_values: vector<vector<u8>>,
        property_types: vector<String>,
        collection_mutate_setting: vector<bool>,
        token_mutate_setting: vector<bool>,
    ): token_v1::TokenId {
        let mutate_setting = collection_mutate_setting;

        token_v1::create_collection(
            creator,
            collection_name(),
            string::utf8(b"Collection: Hello, World"),
            string::utf8(b"https://aptos.dev"),
            collection_max,
            mutate_setting
        );

        let default_keys = if (vector::length<String>(&property_keys) == 0) { vector<String>[string::utf8(b"attack"), string::utf8(b"num_of_use")] } else { property_keys };
        let default_vals = if (vector::length<vector<u8>>(&property_values) == 0) { vector<vector<u8>>[bcs::to_bytes<u64>(&10), bcs::to_bytes<u64>(&5)] } else { property_values };
        let default_types = if (vector::length<String>(&property_types) == 0) { vector<String>[string::utf8(b"u64"), string::utf8(b"u64")] } else { property_types };
        let mutate_setting = token_mutate_setting;
        token_v1::create_token_script(
            creator,
            collection_name(),
            token_name(),
            string::utf8(b"Hello, Token"),
            amount,
            token_max,
            string::utf8(b"https://aptos.dev"),
            signer::address_of(creator),
            100,
            2,
            mutate_setting,
            default_keys,
            default_vals,
            default_types,
        );
        token_v1::create_token_id_raw(signer::address_of(creator), collection_name(), token_name(), 0)
    }

    #[test_only]
    public fun init_test(signer_ref: &signer, uri: String) {
        resource_manager::initialize(signer_ref);
        init(signer_ref, uri);
    }

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";
    const BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";

    #[test(std = @0x1, ts = @townespace, creator = @0x456, alice = @0x123)]
    // test migration of a token v1 to v2
    fun test_migration(
        std: &signer,
        alice: &signer,
        ts: &signer,
        creator: &signer,
    ) {
        // auid and events
        // features::change_feature_flags(std, vector[23, 26], vector[]);
        account::create_account_for_test(signer::address_of(ts));
        init_test(ts, string::utf8(b"test uri"));
        account::create_account_for_test(signer::address_of(alice));
        account::create_account_for_test(signer::address_of(creator));
        // create token v1
        let token_id = create_collection_and_token(
            creator,
            2,
            4,
            4,
            vector<String>[string::utf8(BURNABLE_BY_CREATOR), string::utf8(BURNABLE_BY_OWNER)],
            vector<vector<u8>>[bcs::to_bytes<bool>(&true), bcs::to_bytes<bool>(&true)],
            vector<String>[string::utf8(b"bool"), string::utf8(b"bool")],
            vector<bool>[false, false, false],
            vector<bool>[false, false, false, false, false],
        );
        assert!(token_v1::balance_of(signer::address_of(creator), token_id) == 2, 1);
        token_v1::opt_in_direct_transfer(alice, true);
        token_v1::initialize_token_store(alice);
        // token_v1::transfer_with_opt_in(creator, signer::address_of(creator), collection_name(),token_name(), 1, signer::address_of(alice), 1);
        // let token = token_v1::withdraw_token(alice, token_id, 1);
        // token_v1::direct_deposit_with_opt_in(signer::address_of(alice), token);
        token_v1::transfer(creator, token_id, signer::address_of(alice), 1);
        // migrate it to v2
        let (_, token_v2_addr) = from_v1_to_v2_by_owner_internal(alice, signer::address_of(creator), collection_name(), token_name(), 0);
        // assert token v1 is burned
        assert!(token_v1::balance_of(signer::address_of(alice), token_id) == 0, 2);
        // TODO: explore more explicit way to check if token is burned
        // assert token v2 is minted
        // assert!(object::object_exists<token_v2::Token>(&token_v2_addr), 3);
        assert!(object::is_object(token_v2_addr), 3);
    }
}