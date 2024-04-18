/*
    Forked from aptos-examples/token-objects to demonstrate the difference
    between using townespace protocol and aptos framework modules directly.
*/

module examples::hero_no_code {
    use aptos_framework::object::{Object};

    use aptos_token_objects::collection;

    use std::bcs;
    use std::option;
    use std::string::{Self, String};

    use townespace::composables;
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
        composables::create_collection<collection::FixedSupply>(
            account,
            string::utf8(b"collection description"),
            option::some(100),
            string::utf8(COLLECTION_NAME),
            string::utf8(b"HRQT"),
            string::utf8(b"collection uri"),
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            option::none(),
            option::none()
        );
    }

    // Create a hero
    entry fun create_hero(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String
    ) {
        composables::create_token<composables::Composable, composables::Indexed>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            vector[
                string::utf8(b"attack"), 
                string::utf8(b"defense")
            ],
            vector[
                string::utf8(b"u64"), 
                string::utf8(b"u64")
            ],
            vector[
                bcs::to_bytes<u64>(&0), 
                bcs::to_bytes<u64>(&0)
            ]
        );
    }

    // Create a weapon
    entry fun create_weapon(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        attack: u64,
        type: String,
        weight: u64
    ) {
        composables::create_token<composables::Trait, composables::Indexed>(
            signer_ref,
            collection,
            description,
            name,
            string::utf8(b"#"),
            string::utf8(b""),
            uri,
            option::none(),
            option::none(),
            vector[
                string::utf8(b"attack"), 
                string::utf8(b"weapon type"), 
                string::utf8(b"weight")
            ],
            vector[
                string::utf8(b"u64"), 
                string::utf8(b"String"), 
                string::utf8(b"u64")
            ],
            vector[
                bcs::to_bytes<u64>(&attack), 
                bcs::to_bytes<String>(&type),
                bcs::to_bytes<u64>(&weight)
            ]
        );
    }

    // Equip a weapon to a hero
    entry fun hero_equip_weapon(
        owner_signer: &signer, 
        hero_obj: Object<composables::Composable>, 
        trait_obj: Object<composables::Trait>,
        new_uri: String
    ) { 
        studio::equip_trait(owner_signer, hero_obj, trait_obj, new_uri);
        // // update hero's attack
        // let (_, hero_attack_val) = property_map::read<composables::Composable>(composable_obj, &string::utf8(b"attack"));
        // let (_, weapon_attack_val) = property_map::read<composables::Trait>(trait_obj, &string::utf8(b"attack"));
        // let new_attack_val = hero_attack_val + weapon_attack_val;
        // property_map::update(
        //     mutator_ref, 
        //     &string::utf8(b"attack"), 
        //     string::utf8(b"u64"), 
        //     new_attack_val
        // );
    }

    // Unequip a weapon from a hero
    entry fun hero_unequip_weapon(
        owner_signer: &signer, 
        hero_obj: Object<composables::Composable>, 
        weapon_obj: Object<composables::Trait>,
        new_uri: String
    ) { 
        studio::unequip_trait(owner_signer, hero_obj, weapon_obj, new_uri);
    }
    
}