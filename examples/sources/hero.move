/*
    Forked from aptos-examples/token-objects to demonstrate the difference
    between using townespace protocol and aptos framework modules directly.
*/

module examples::hero {
    use aptos_framework::object::{Self, ConstructorRef, Object};

    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_std::string_utils;

    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use townespace::core;
    use townespace::mint; 
    use townespace::studio;

    const ENOT_A_HERO: u64 = 1;
    const ENOT_A_WEAPON: u64 = 2;
    const ENOT_A_GEM: u64 = 3;
    const ENOT_CREATOR: u64 = 4;
    const EINVALID_WEAPON_UNEQUIP: u64 = 5;
    const EINVALID_GEM_UNEQUIP: u64 = 6;
    const EINVALID_TYPE: u64 = 7;

    const COLLECTION_NAME: vector<u8> = b"Hero Quest!";

    fun init_module(account: &signer) {
        mint::create_unlimited_supply_collection(
            account,
            string::utf8(b"collection description"),
            string::utf8(COLLECTION_NAME),
            string::utf8(b"HRQT"),
            string::utf8(b"collection uri"),
            1,
            2,
            false,
            false
        );
    }

    public fun create_hero(
        signer_ref: &signer,
        collection_name: String,
        description: String,
        uri: String, 
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ): Object<core::Composable>  {
        core::create_token_internal<core::Composable>(
            signer_ref,
            string::utf8(COLLECTION_NAME),
            description,
            uri,
            string::utf8(b"Type - no need as we're minting a composable"),
            vector::empty(),
            base_mint_price,
            royalty_numerator,
            royalty_denominator
        )
    }

    public fun create_weapon(
        signer_ref: &signer,
        collection_name: String,
        description: String,
        uri: String,
        weapon_type: String,
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ): Object<core::Trait> {
        // create the trait object, this will be the weapon token
        let trait_obj = core::create_token_internal<core::Trait>(
            signer_ref,
            string::utf8(COLLECTION_NAME),
            description,
            uri,
            weapon_type,
            vector::empty(),
            base_mint_price,
            royalty_numerator,
            royalty_denominator
        );

        trait_obj
    }

    // Transfer wrappers 

    public fun hero_equip_weapon(
        owner_signer: &signer, 
        hero_obj: Object<core::Composable>, 
        trait_obj: Object<core::Trait>,
        new_uri: String
    ) { 
        studio::equip_trait(owner_signer, hero_obj, trait_obj, new_uri);
    }

    public fun hero_unequip_weapon(
        owner_signer: &signer, 
        hero_obj: Object<core::Composable>, 
        weapon_obj: Object<core::Trait>,
        new_uri: String
    ) { 
        studio::unequip_trait(owner_signer, hero_obj, weapon_obj, new_uri);
    }

    // Entry functions

    entry fun mint_hero(
        signer_ref: &signer,
        description: String,
        uri: String, 
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ) {
        create_hero(
            signer_ref,
            string::utf8(COLLECTION_NAME),
            description,
            uri,
            base_mint_price,
            royalty_numerator,
            royalty_denominator
        );
    }
}