#[test_only]
module townespace::composables_test {

    use aptos_framework::account;
    use aptos_framework::object;
    use aptos_std::debug;
    use aptos_token_objects::collection::{FixedSupply, UnlimitedSupply};
    use std::option;
    use std::signer;
    use std::string;

    use townespace::composables::{Self, Collection, Composable, Trait};
    use townespace::test_utils;

    const COLLECTION_1_NAME: vector<u8> = b"Collection 1";
    const COLLECTION_2_NAME: vector<u8> = b"Collection 2";

    const COMPOSABLE_1_NAME: vector<u8> = b"Composable 1";
    const COMPOSABLE_2_NAME: vector<u8> = b"Composable 2";

    const TRAIT_1_NAME: vector<u8> = b"Trait 1";
    const TRAIT_2_NAME: vector<u8> = b"Trait 2";

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

    #[test(std = @0x1, creator = @0x123)]
    fun create_composable_token(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        let collection_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::some(100)
        );
        let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);
        
        let composable_constructor_ref = test_utils::create_named_composable_token_helper(
            creator,
            COLLECTION_1_NAME, 
            COMPOSABLE_1_NAME
        );

        // let composable_obj = object::object_from_constructor_ref<Composable>(&composable_constructor_ref);
        // TODO: check that the composable is created correctly
        // TODO: check events are emited correctly
    }

    #[test(std = @0x1, creator = @0x123)]
    fun create_trait_token(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        let collection_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::some(100)
        );
        // let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);
        
        let trait_constructor_ref = test_utils::create_named_trait_token_helper(
            creator,
            COLLECTION_1_NAME,
            TRAIT_1_NAME
        );

        // let trait_obj = object::object_from_constructor_ref<Trait>(&trait_constructor_ref);
        // TODO: check that the trait is created correctly
        // TODO: check events are emited correctly
    }

    #[test(std = @0x1, creator = @0x123)]
    fun equip_unequip_trait(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);

        let collection_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::some(100)
        );
        
        let composable_constructor_ref = test_utils::create_named_composable_token_helper(
            creator,
            COLLECTION_1_NAME, 
            COMPOSABLE_1_NAME
        );

        let trait_constructor_ref = test_utils::create_named_trait_token_helper(
            creator,
            COLLECTION_1_NAME,
            TRAIT_1_NAME
        );

        let composable_obj = object::object_from_constructor_ref<Composable>(&composable_constructor_ref);
        let trait_obj = object::object_from_constructor_ref<Trait>(&trait_constructor_ref);
        // let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);

        // equip the trait to the composable
        let uri_after_equipping_trait = string::utf8(b"URI after equipping trait");
        composables::equip_trait(creator, composable_obj, trait_obj, uri_after_equipping_trait);
        // TODO: check that the trait is equipped correctly
        // TODO: check events are emited correctly

        // unequip the trait from the composable  
        let uri_after_unequipping_trait = string::utf8(b"URI after unequipping trait");  
        composables::unequip_trait(creator, composable_obj, trait_obj, uri_after_unequipping_trait);
        // TODO: check that the trait is unequipped correctly
        // TODO: check events are emited correctly
    }

    #[test(std = @0x1, creator = @0x123)]
    // equip trait from collection 1 in a composable from collection 2
    fun equip_trait_from_different_collection(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);

        let collection_1_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_1_NAME, 
            option::some(100)
        );

        let collection_2_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            creator,
            COLLECTION_2_NAME, 
            option::some(100)
        );
        
        let composable_constructor_ref = test_utils::create_named_composable_token_helper(
            creator,
            COLLECTION_2_NAME, 
            COMPOSABLE_1_NAME
        );

        let trait_constructor_ref = test_utils::create_named_trait_token_helper(
            creator,
            COLLECTION_1_NAME,
            TRAIT_1_NAME
        );

        let composable_obj = object::object_from_constructor_ref<Composable>(&composable_constructor_ref);
        let trait_obj = object::object_from_constructor_ref<Trait>(&trait_constructor_ref);
        let collection_1_obj = object::object_from_constructor_ref<Collection>(&collection_1_constructor_ref);
        // let collection_2_obj = object::object_from_constructor_ref<Collection>(&collection_2_constructor_ref);

        // debug::print<address>(&object::owner<Collection>(collection_1_obj));
        // debug::print<address>(&object::owner<Composable>(composable_obj));
        // debug::print<address>(&object::owner<Trait>(trait_obj));

        // equip the trait to the composable
        let uri_after_equipping_trait = string::utf8(b"URI after equipping trait");
        composables::equip_trait(creator, composable_obj, trait_obj, uri_after_equipping_trait);
        // TODO: check that the trait is equipped correctly
        // TODO: check events are emited correctly
    }

    #[test(std = @0x1, alice = @0x123, bob = @0x456)]
    // test transfer and equip; alice creates a token, transfers it to bob, and bob tries to equip a trait to it
    fun transfer_and_equip(std: signer, alice: &signer, bob: &signer) {
        test_utils::prepare_for_test(std);

        let collection_constructor_ref = test_utils::create_collection_helper<FixedSupply>(
            alice,
            COLLECTION_1_NAME, 
            option::some(100)
        );
        
        let composable_constructor_ref = test_utils::create_named_composable_token_helper(
            alice,
            COLLECTION_1_NAME, 
            COMPOSABLE_1_NAME
        );

        let trait_constructor_ref = test_utils::create_named_trait_token_helper(
            alice,
            COLLECTION_1_NAME,
            TRAIT_1_NAME
        );

        let composable_obj = object::object_from_constructor_ref<Composable>(&composable_constructor_ref);
        let trait_obj = object::object_from_constructor_ref<Trait>(&trait_constructor_ref);
        // let collection_obj = object::object_from_constructor_ref<Collection>(&collection_constructor_ref);

        // transfer composable to bob
        let composable_token_addr = object::object_address(&composable_obj);
        let trait_token_addr = object::object_address(&trait_obj);

        composables::transfer_token<Composable>(alice, composable_token_addr, signer::address_of(bob));
        // TODO: check that transfer is successful
        // TODO: check events are emited correctly

        // transfer trait to bob
        composables::transfer_token<Trait>(alice, trait_token_addr, signer::address_of(bob));

        // TODO: check that transfer is successful
        // TODO: check events are emited correctly
        
        // bob equip trait to composable
        let uri_after_equipping_trait = string::utf8(b"URI after equipping trait");
        composables::equip_trait(bob, composable_obj, trait_obj, uri_after_equipping_trait);
        // TODO: check that the trait is equipped correctly
        // TODO: check events are emited correctly
    }

    // TODO: Add more tests

}