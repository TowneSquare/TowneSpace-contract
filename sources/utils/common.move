/*

*/

module townespace::common {

    use aptos_framework::object::{Self, ConstructorRef, ExtendRef};
    use aptos_framework::randomness;
    use aptos_framework::timestamp;

    friend townespace::batch_mint;
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
        // ensure that the size is greater than zero
        assert!(size > 0, 0x1234567);
        let time_now = timestamp::now_microseconds();
        let val_u256 = if (time_now != timestamp::now_microseconds()) {
            // generate a random number
            let random_u256 = randomness::u256_integer();
            // mod by the size
            (random_u256) % (size as u256)
        } else { 
            // generate a random number
            let random_u256 = randomness::u256_integer();
            // mod by the size
            (random_u256) % (size as u256)
        };

        (val_u256 as u64)
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

        // init randomness module for testing
        randomness::initialize(std);

        (creator_address, collector_address)
    }
}