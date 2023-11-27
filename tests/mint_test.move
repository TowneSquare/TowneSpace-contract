/*
    Module containing helper functions needed for unit testing
*/

#[test_only]
module townespace::mint_test {
    use aptos_framework::account;
    use aptos_framework::object::{Self, Object};
    use aptos_token_objects::collection::{FixedSupply, UnlimitedSupply};
    use aptos_token_objects::token::{Token};
    use aptos_std::debug;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use townespace::core::{Self, Collection, Composable, Trait};
    use townespace::resource_manager;
    use townespace::mint;
    use townespace::studio;
    use townespace::test_utils;

    // collection 
    const COLLECTION_1_NAME: vector<u8> = b"Collection 1";
    const COLLECTION_2_NAME: vector<u8> = b"Collection 2";
    const COLLECTION_DESCRIPTION: vector<u8> =  b"Collection of Hack Singapore 2023 NFTs";
    const COLLECTION_SYMBOL: vector<u8> = b"HSGP23";
    const COLLECTION_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023";

    // composable
    const COMPOSABLE_DESCRIPTION: vector<u8> = b"Composable token for Hack Singapore 2023";
    const COMPOSABLE_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable";

    // trait
    const TRAIT_DESCRIPTION: vector<u8> = b"Trait for Hack Singapore 2023";
    const TRAIT_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023/trait";
    const TRAIT_TYPE: vector<u8> = b"Trait type";

    #[test(std = @0x1, townespace = @townespace, creator = @0x123, minter = @0x456)]
    public fun create_tokens(std: signer, townespace: &signer, creator: &signer, minter: &signer) {
        test_utils::prepare_for_mint_test(std, creator, minter);
        mint::init_test(townespace);

        // creator creates a collection
        mint::create_fixed_supply_collection(
            creator,
            string::utf8(COLLECTION_DESCRIPTION),
            1000,
            string::utf8(COLLECTION_1_NAME),
            string::utf8(COLLECTION_SYMBOL),
            string::utf8(COLLECTION_URI),
            1,
            2,
            false,
            false
        );

        // creator creates tokens to mint
        mint::create_composable_tokens(
            creator,
            string::utf8(COLLECTION_1_NAME),
            100,    // nbr of tokens to mint
            string::utf8(COMPOSABLE_DESCRIPTION),
            string::utf8(COMPOSABLE_URI),
            100000000,
            1,
            2
        );

        mint::create_trait_tokens(
            creator,
            string::utf8(COLLECTION_1_NAME),
            100,    // nbr of tokens to mint
            string::utf8(TRAIT_DESCRIPTION),
            string::utf8(TRAIT_URI),
            string::utf8(TRAIT_TYPE),
            100000000,
            1,
            2
        );
    }

    #[test(std = @0x1, townespace = @townespace, creator = @0x123, minter = @0x456)]
    public fun mint_tokens(std: signer, townespace: &signer, creator: &signer, minter: &signer) {
        test_utils::prepare_for_mint_test(std, creator, minter);
        mint::init_test(townespace);

        // creator creates a collection
        mint::create_fixed_supply_collection(
            creator,
            string::utf8(COLLECTION_DESCRIPTION),
            1000,
            string::utf8(COLLECTION_1_NAME),
            string::utf8(COLLECTION_SYMBOL),
            string::utf8(COLLECTION_URI),
            1,
            2,
            false,
            false
        );  

        // creator creates tokens to mint
        let composables_addresses = mint::create_composables_and_return_addresses_test(
            creator,
            string::utf8(COLLECTION_1_NAME),
            100,    // nbr of tokens to mint
            string::utf8(COMPOSABLE_DESCRIPTION),
            string::utf8(COMPOSABLE_URI),
            10000,
            1,
            2
        );

        // assert composable addresses vector length is 100
        debug::print<u64>(&vector::length<address>(&composables_addresses));
        assert!(vector::length<address>(&composables_addresses) == 100, 111);

        // randomly pick any token from the vector
        let token_to_mint = *vector::borrow<address>(&composables_addresses, 0);

        // minter mints it
        mint::mint_token<Composable>(minter, token_to_mint);
        let token_obj = object::address_to_object<Composable>(token_to_mint);
        assert!(object::is_owner<Composable>(token_obj, @0x456), 1);
    }
}