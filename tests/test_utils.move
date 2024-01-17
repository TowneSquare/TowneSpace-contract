/*
    Module containing helper functions needed for unit testing

    TODO:
        - 
*/

#[test_only]
module townespace::test_utils {

    use aptos_framework::account;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin;
    use aptos_framework::managed_coin;
    use aptos_framework::object::{Self, Object};
    use aptos_std::smart_table;
    use aptos_token_objects::collection;
    // use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::type_info;
    use std::vector;
    use townespace::composables::{Self, Collection, Composable, Trait, Named, Indexed};
    use std::features;

    // collection 
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

    public fun prepare_for_test(std: signer) {
        // auid and events
        features::change_feature_flags(&std, vector[23, 26], vector[]);
    }

    public fun prepare_for_mint_test(std: signer, user_a: &signer, user_b: &signer) {
        features::change_feature_flags(&std, vector[23, 26], vector[]);
        prepare_account_for_test(&std, user_a, user_b);
    }

    fun prepare_account_for_test(aptos_framework: &signer, user_a: &signer, user_b: &signer) {
        account::create_account_for_test(signer::address_of(aptos_framework));
        account::create_account_for_test(signer::address_of(user_a));
        account::create_account_for_test(signer::address_of(user_b));
        // register aptos coin and mint some APT to be able to pay for the fee of generate_coin
        managed_coin::register<AptosCoin>(aptos_framework);
        managed_coin::register<AptosCoin>(user_a);
        managed_coin::register<AptosCoin>(user_b);
        let (aptos_coin_burn_cap, aptos_coin_mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        // mint APT to be able to pay for the fee of generate_coin
        aptos_coin::mint(aptos_framework, signer::address_of(user_a), 1000000000);
        aptos_coin::mint(aptos_framework, signer::address_of(user_b), 1000000000);

        // destroy APT mint and burn caps
        coin::destroy_mint_cap<AptosCoin>(aptos_coin_mint_cap);
        coin::destroy_burn_cap<AptosCoin>(aptos_coin_burn_cap);
    }

    public fun create_collection_helper<T: key>(
        signer_ref: &signer,
        collection_name: vector<u8>,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
    ): object::ConstructorRef {
        if (type_info::type_of<T>() == type_info::type_of<collection::UnlimitedSupply>()) {
            composables::create_collection<collection::UnlimitedSupply>(
                signer_ref,
                string::utf8(COLLECTION_DESCRIPTION),
                option::none(), 
                string::utf8(collection_name),
                string::utf8(COLLECTION_SYMBOL),
                string::utf8(COLLECTION_URI),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                option::some(1),
                option::some(2),
            )
        } else if (type_info::type_of<T>() == type_info::type_of<collection::FixedSupply>()) {
            composables::create_collection<collection::FixedSupply>(
                signer_ref,
                string::utf8(COLLECTION_DESCRIPTION),
                max_supply, 
                string::utf8(collection_name),
                string::utf8(COLLECTION_SYMBOL),
                string::utf8(COLLECTION_URI),
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                option::some(1),
                option::some(2),
            )
        } else {
            abort 1
        }
    }

    // create a composable
    public fun create_named_composable_token_helper(signer_ref: &signer, collection_name: vector<u8>, composable_name: vector<u8>): object::ConstructorRef {
        // let type = string::utf8(b"");   // Composable token does not have a type
        composables::create_token<Composable, Named>(
            signer_ref,
            string::utf8(collection_name),
            string::utf8(COMPOSABLE_DESCRIPTION),
            string::utf8(composable_name),
            string::utf8(b""),
            string::utf8(b""),
            string::utf8(COMPOSABLE_URI),
            option::some(1),
            option::some(2),
            vector::empty(),
            vector::empty(),
            vector::empty(),
        )
    }

    // create a trait
    public fun create_named_trait_token_helper(signer_ref: &signer, collection_name: vector<u8>, trait_name: vector<u8>): object::ConstructorRef {
        composables::create_token<Trait, Named>(
            signer_ref,
            string::utf8(collection_name),
            string::utf8(TRAIT_DESCRIPTION),
            string::utf8(trait_name),
            string::utf8(b""),
            string::utf8(b""),
            string::utf8(TRAIT_URI),
            option::some(1),
            option::some(2),
            vector::empty(),
            vector::empty(),
            vector::empty(),
        )
    }

    // TODO: create fungible asset
    public fun create_fungible_asset(){}
}