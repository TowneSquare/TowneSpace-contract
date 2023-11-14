#[test_only]
module townespace::core_tests {
    use aptos_framework::account;
    use aptos_framework::fungible_asset::{FungibleStore}; 
    use aptos_framework::object::{Self, Object};
    use aptos_token_objects::collection::{Collection, FixedSupply, UnlimitedSupply};
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use townespace::core::{Self, Composable, Trait};
    use townespace::test_utils;

    const COLLECTION_1_NAME: vector<u8> = b"Hack Singapore 2023 Collection";
    const COLLECTION_2_NAME: vector<u8> = b"Collection 2";

    #[test(std = @0x1, creator = @0x123)]
    // create a collection with unlimited supply
    fun create_unlimited_collection(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
    }

    
    #[test(std = @0x1, creator = @0x123)]
    // create a collection with a fixed supply
    fun create_fixed_collection(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<FixedSupply>(creator, COLLECTION_1_NAME, option::some(100));
    }

    #[test(std = @0x1, creator = @0x123)]
    fun create_composable_token(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
    }

    #[test(std = @0x1, creator = @0x123)]
    fun create_trait_token(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);
    }

    #[test(std = @0x1, creator = @0x123)]
    fun equip_unequip_trait(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        // create collection
        let collection_object = test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        let composable_object = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);
        core::equip_trait_internal(creator, composable_object, trait_object);
        let composable_address = object::object_address(&composable_object);
        let traits = core::borrow_mut_traits(composable_address);
        // assert the trait object is being transferred to the composable object
        assert!(object::is_owner(trait_object, composable_address) == true, 2234);
        // assert traits vector is not empty
        assert!(vector::is_empty<Object<Trait>>(&traits) == false, 3234);
        // assert the trait object is being added to the composable object's traits vector
        assert!(vector::contains(&traits, &trait_object) == true, 4234);
        core::unequip_trait_internal(creator, composable_object, trait_object);
        // assert traits vector is empty
        let traits = core::borrow_mut_traits(composable_address);
        assert!(vector::is_empty<Object<Trait>>(&traits) == true, 3234);
        // assert the token is not in the composable token anymore
        assert!(object::is_owner(trait_object, composable_address) == false, 5234);        
        // assert the trait object is being transferred to the creator
        assert!(object::is_owner(trait_object, signer::address_of(creator)) == true, 5234);
    }

    #[test(std = @0x1, creator = @0x123)]
    // attempt to transfer a composable to a composable; expect failure
    #[expected_failure(abort_code = 10, location = townespace::core)]
    fun fail_transfer_composable_to_composable(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        // create collection
        let collection_object = test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        let composable_object = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        let composable_object2 = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        // send to object address
        let composable_address = object::object_address(&composable_object);
        let composable_address2 = object::object_address(&composable_object2);
        core::transfer_token<Composable>(creator, composable_address2, composable_address);
    }

    #[test(std = @0x1, creator = @0x123)]
    // attempt to transfer a trait to a trait; expect failure
    #[expected_failure(abort_code = 10, location = townespace::core)]
    fun fail_transfer_trait_to_trait(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        // create collection
        let collection_object = test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        let trait_object = test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);
        let trait_object2 = test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);
        // send to object address
        let trait_address = object::object_address(&trait_object);
        let trait_address2 = object::object_address(&trait_object2);
        core::transfer_token<Trait>(creator, trait_address2, trait_address);
    }

    #[test(std = @0x1, creator = @0x123)]
    // equip trait from collection 1 in a composable from collection 2
    fun equip_trait_from_different_collection(std: signer, creator: &signer) {
        test_utils::prepare_for_test(std);
        let collection_object = test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_1_NAME, option::none());
        let collection_object2 = test_utils::create_collection_helper<UnlimitedSupply>(creator, COLLECTION_2_NAME, option::none());
        let composable_object = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(creator, COLLECTION_2_NAME);
        core::equip_trait_internal(creator, composable_object, trait_object);
        // assert the trait object is being transferred to the composable object
        assert!(object::is_owner(trait_object, object::object_address(&composable_object)) == true, 2234);
    }

    #[test(std = @0x1, alice = @0x123, bob = @0x456)]
    // test transfer and equip; alice creates a token, transfers it to bob, and bob tries to equip a trait to it
    fun test_transfer_and_equip(std: signer, alice: &signer, bob: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(alice, COLLECTION_1_NAME, option::none());
        let composable_object = test_utils::create_composable_token_helper(alice, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(alice, COLLECTION_1_NAME);
        let composable_address = object::object_address(&composable_object);
        let trait_address = object::object_address(&trait_object);
        // transfer composable to bob
        core::transfer_token<Composable>(alice, composable_address, signer::address_of(bob));
        // transfer trait to bob
        core::transfer_token<Trait>(alice, trait_address, signer::address_of(bob));
        // equip trait to composable
        core::equip_trait_internal(bob, composable_object, trait_object);
        // assert the trait object is being transferred to the composable object
        assert!(object::is_owner(trait_object, composable_address) == true, 2234);
        // bob creates another trait and equips it to the composable
        test_utils::create_collection_helper<UnlimitedSupply>(bob, COLLECTION_2_NAME, option::none());
        let trait_object2 = test_utils::create_trait_token_helper(bob, COLLECTION_2_NAME);
        core::equip_trait_internal(bob, composable_object, trait_object2);
        // assert traits vector length is 2
        let traits = core::borrow_mut_traits(composable_address);
        assert!(vector::length<Object<Trait>>(&traits) == 2, 3234);
    }

    #[test(std = @0x1, alice = @0x123, bob = @0x456)]
    // equip trait in a composable and transfer it while equipped; should fail
    #[expected_failure(abort_code = 393223, location = aptos_framework::object)]
    fun transfer_equiped_trait(std: signer, alice: &signer, bob: &signer) {
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(alice, COLLECTION_1_NAME, option::none());
        let composable_object = test_utils::create_composable_token_helper(alice, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(alice, COLLECTION_1_NAME);
        let composable_address = object::object_address(&composable_object);
        let trait_address = object::object_address(&trait_object);
        // equip trait to composable
        core::equip_trait_internal(alice, composable_object, trait_object);
        // assert the trait object is being transferred to the composable object
        assert!(object::is_owner(trait_object, composable_address) == true, 2234);
        // transfer composable to bob
        core::transfer_token<Composable>(alice, trait_address, signer::address_of(bob));
    }

    // TODO: test transfer FA to composable (trait as well?)

}