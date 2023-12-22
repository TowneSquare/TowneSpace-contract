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
*/

module townespace::migrate {

    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_token::token as token_v1;
    use aptos_token_objects::collection;
    use aptos_token_objects::token as token_v2;

    use std::option;
    use std::signer;
    use std::string::{Self, String};

    use townespace::errors;
    use townespace::mint;
    use townespace::resource_manager;
    use townespace::studio;

    #[event]
    struct TokenMigratedFromV1toV2 has drop, store {
        old_token_id: token_v1::TokenId,
        // new_token_metadata: token_v2::Token,
    }

    fun emit_token_migrated_from_v1_to_v2_event(token_id: token_v1::TokenId) {
        event::emit<TokenMigratedFromV1toV2>(
            TokenMigratedFromV1toV2 {
                old_token_id: token_id
            }
        )
    }

    public entry fun init(signer_ref: &signer, uri: String) {
        // assert signer is townespace
        assert!(signer::address_of(signer_ref) == @townespace, errors::not_townespace());
        // create a collection with unlimited supply
        collection::create_unlimited_collection(
            &resource_manager::get_signer(),
            string::utf8(b"transform your NFTv1 into NFTv2"),
            string::utf8(b"Migrated NFTs"),
            option::none(),
            uri
        );
    }

    public entry fun from_v1_to_v2(signer_ref: &signer, creator: address, collection_name: String, token_name: String, property_version: u64) {
        let signer_addr = signer::address_of(signer_ref);
        // get the token metadata
        let token_id = token_v1::create_token_id_raw(creator, collection_name, token_name, property_version);
        let (creator_addr, collection_name, token_name, property_version) = token_v1::get_token_id_fields(&token_id);
        let token_data_id = token_v1::create_token_data_id(signer_addr, collection_name, token_name);
        let token_description = token_v1::get_tokendata_description(token_data_id);
        let token_uri = token_v1::get_tokendata_uri(creator_addr, token_data_id);
        // TODO: if token has royalty, get it

        // mint a new token v2 with the metadata
        let constructor_ref = token_v2::create(
            &resource_manager::get_signer(), 
            string::utf8(b"Migrated NFTs"),
            token_description,
            token_name,
            option::none(), // TODO: add royalty if applicable
            token_uri
        );
        // transfer it to the signer
        let new_token_addr = object::object_from_constructor_ref<token_v2::Token>(&constructor_ref);
        object::transfer<token_v2::Token>(&resource_manager::get_signer(), new_token_addr, signer_addr);
        // burn the token v1
        token_v1::burn(signer_ref, creator_addr, collection_name, token_name, property_version, 1);
        
        emit_token_migrated_from_v1_to_v2_event(token_id);
    }

    #[test_only]
    public fun init_test(signer_ref: &signer, uri: string) {
        init(signer_ref, uri);
    }

    // #[test]
    // // test migration of a token v1 to v2
    // fun test_migration(signer_ref: &signer) {
    //     // create token v1
    //     // migrate it to v2
    //     from_v1_to_v2(signer_ref, token);
    //     // assert token v1 is burned
    //     // assert token v2 is minted
    // }
}