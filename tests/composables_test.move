#[test_only]
module townespace::composables_test {

    use aptos_framework::account;
    use aptos_framework::fungible_asset::{Self, FungibleStore}; 
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_token_objects::collection::{FixedSupply, UnlimitedSupply};
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use townespace::composables::{Self, Collection, Composable, Trait};
    use townespace::test_utils;

    const COLLECTION_1_NAME: vector<u8> = b"Collection 1";
    const COLLECTION_2_NAME: vector<u8> = b"Collection 2";

    #[test(std = @0x1, creator = @0x123)]
    // create a collection with unlimited supply
    fun create_collection_with_unlimited_supply(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        let collection_constructor_ref = test_utils::create_collection_helper<UnlimitedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::none()
        );

        let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);
        // TODO: check that the collection is created correctly
        // TODO: check events are emited correctly
    }

    #[test(std = @0x1, creator = @0x123)]
    // create a collection with fixed supply
    fun create_collection_with_fixed_supply(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        let collection_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::some(100)
        );

        let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);
        // TODO: check that the collection is created correctly
        // TODO: check events are emited correctly
    }
}