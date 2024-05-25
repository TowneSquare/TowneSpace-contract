/*

*/

module townespace::common {

    use std::bcs;
    use std::hash;
    use std::vector;
    use aptos_std::from_bcs;
    use aptos_framework::object::{Self, ConstructorRef, ExtendRef};
    use aptos_framework::timestamp;
    use aptos_framework::transaction_context;

    friend townespace::random_mint;


    /// Common logic for creating sticky object for the liquid NFTs
    public(friend) inline fun create_sticky_object(
        caller_address: address
    ): (ConstructorRef, ExtendRef, signer, address) {
        let constructor = object::create_sticky_object(caller_address);
        let extend_ref = object::generate_extend_ref(&constructor);
        let object_signer = object::generate_signer(&constructor);
        let object_address = object::address_from_constructor_ref(&constructor);
        (constructor, extend_ref, object_signer, object_address)
    }

    /// Generate a pseudorandom number
    ///
    /// We use AUID to generate a number from the transaction hash and a globally unique
    /// number, which allows us to spin this multiple times in a single transaction.
    ///
    /// We use timestamp to ensure that people can't predict it.
    ///
    public(friend) inline fun pseudorandom_u64(size: u64): u64 {
        let auid = transaction_context::generate_auid_address();
        let bytes = bcs::to_bytes(&auid);
        let time_bytes = bcs::to_bytes(&timestamp::now_microseconds());
        vector::append(&mut bytes, time_bytes);

        // Hash that together, and mod by the expected size
        let hash = hash::sha3_256(bytes);
        let val = from_bcs::to_u256(hash) % (size as u256);
        (val as u64)
    }

    #[test_only]
    use aptos_framework::account::create_account_for_test;
    #[test_only]
    use std::signer;
    #[test_only]
    use aptos_framework::aptos_coin::{Self, AptosCoin as APT};
    #[test_only]
    use aptos_framework::coin;
    #[test_only]
    use aptos_std::math64::pow;

    #[test_only]
    public(friend) fun setup_test(std: &signer, creator: &signer, collector: &signer): (address, address) {
        let (aptos_coin_burn_cap, aptos_coin_mint_cap) = aptos_coin::initialize_for_test(std);
        timestamp::set_time_has_started_for_testing(std);
        let creator_address = signer::address_of(creator);
        let collector_address = signer::address_of(collector);
        create_account_for_test(creator_address);
        create_account_for_test(collector_address);

        coin::register<APT>(creator); 
        coin::register<APT>(collector);

        aptos_coin::mint(std, creator_address, 100 * pow(10, 8));
        aptos_coin::mint(std, collector_address, 100 * pow(10, 8));
        // destroy APT mint and burn caps
        coin::destroy_mint_cap<APT>(aptos_coin_mint_cap);
        coin::destroy_burn_cap<APT>(aptos_coin_burn_cap);

        (creator_address, collector_address)
    }
}