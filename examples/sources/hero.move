/*
    
*/

module examples::hero {
    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_framework::object::{Self, Object};

    use aptos_token_objects::collection;
    use aptos_token_objects::token;

    use townespace::composables::{
        Self, 
        Composable,
        Named,
        Trait
    };

    const ENOT_A_HERO: u64 = 1;
    const ENOT_A_WEAPON: u64 = 2;
    const ENOT_A_GEM: u64 = 3;
    const ENOT_CREATOR: u64 = 4;
    const EINVALID_WEAPON_UNEQUIP: u64 = 5;
    const EINVALID_GEM_UNEQUIP: u64 = 6;
    const EINVALID_TYPE: u64 = 7;

    struct OnChainConfig has key {
        collection: String,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Hero has key {
        composable_obj: Object<Composable>,
        armor: Option<Object<Armor>>,
        gender: String,
        race: String,
        shield: Option<Object<Shield>>,
        weapon: Option<Object<Weapon>>,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Armor has key {
        trait_obj: Object<Trait>,
        defense: u64,
        gem: Option<Object<Gem>>,
        weight: u64,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Gem has key {
        attack_modifier: u64,
        defense_modifier: u64,
        magic_attribute: String,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Shield has key {
        trait_obj: Object<Trait>,
        defense: u64,
        gem: Option<Object<Gem>>,
        weight: u64,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Weapon has key {
        trait_obj: Object<Trait>,
        attack: u64,
        gem: Option<Object<Gem>>,
        weapon_type: String,
        weight: u64,
    }

    fun init_module(account: &signer) {
        let collection = string::utf8(b"Hero Quest!");
        composables::create_collection<collection::UnlimitedSupply>(
            account,
            string::utf8(b"collection description"),
            option::none(),
            collection,
            string::utf8(b"HRQST"), // symbol
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
            option::none(),
        );

        move_to(account, OnChainConfig { collection } );
    }

    // composable: hero
    // traits: armor, shield, weapon
    // simple digital asset: gem

    fun create_hero(
        creator: &signer,
        description: String,
        gender: String,
        name: String,
        race: String,
        uri: String
    ): (Object<Composable>, Object<Hero>) acquires OnChainConfig {
        let on_chain_config = borrow_global<OnChainConfig>(signer::address_of(creator));
        let constructor_ref = composables::create_token<Composable, Named>(
            creator,
            on_chain_config.collection,
            description,
            name,
            string::utf8(b""), // prefix; not used
            string::utf8(b""), // suffix; not used
            uri,
            option::none(), // royalty numerator
            option::none(), // royalty denominator
            vector::empty(),    // properties won't be used
            vector::empty(),
            vector::empty()
        );
        let token_signer = object::generate_signer(&constructor_ref);

        let composable_obj = object::object_from_constructor_ref(&constructor_ref);
        let hero = Hero {
            composable_obj,
            armor: option::none(),
            gender,
            race,
            shield: option::none(),
            weapon: option::none()
        };
        move_to(&token_signer, hero);

        (   
            composable_obj,
            object::address_to_object(signer::address_of(&token_signer))
        )
    }

    public fun create_weapon(
        creator: &signer,
        attack: u64,
        description: String,
        name: String,
        uri: String,
        weapon_type: String,
        weight: u64,
    ): (Object<Trait>, Object<Weapon>) acquires OnChainConfig {
        let on_chain_config = borrow_global<OnChainConfig>(signer::address_of(creator));
        let constructor_ref = composables::create_token<Trait, Named>(
            creator,
            on_chain_config.collection,
            description,
            name,
            string::utf8(b""), // prefix; not used
            string::utf8(b""), // suffix; not used
            uri,
            option::none(), // royalty numerator
            option::none(), // royalty denominator
            vector::empty(),    // properties won't be used
            vector::empty(),
            vector::empty()
        );

        let token_signer = object::generate_signer(&constructor_ref);

        let trait_obj = object::object_from_constructor_ref<Trait>(&constructor_ref);
        let weapon = Weapon {
            trait_obj,
            attack,
            gem: option::none(),
            weapon_type,
            weight,
        };
        move_to(&token_signer, weapon);

        (   
            trait_obj,
            object::address_to_object(signer::address_of(&token_signer))
        )
    }

    public fun create_gem(
        creator: &signer,
        attack_modifier: u64,
        defense_modifier: u64,
        description: String,
        magic_attribute: String,
        name: String,
        uri: String,
    ): Object<Gem> acquires OnChainConfig {
        let on_chain_config = borrow_global<OnChainConfig>(signer::address_of(creator));
        let constructor_ref = token::create_named_token(
            creator,
            on_chain_config.collection,
            description, 
            name, 
            option::none(),
            uri
        );

        let token_signer = object::generate_signer(&constructor_ref);

        let gem = Gem {
            attack_modifier,
            defense_modifier,
            magic_attribute,
        };
        move_to(&token_signer, gem);

        object::address_to_object(signer::address_of(&token_signer))
    }

    // Transfer wrappers

    public fun hero_equip_weapon(
        owner: &signer, 
        hero_obj: Object<Hero>, 
        weapon_obj: Object<Weapon>
    ) acquires Hero, Weapon {
        let hero = borrow_global_mut<Hero>(object::object_address(&hero_obj));
        let weapon = borrow_global_mut<Weapon>(object::object_address(&weapon_obj));
        option::fill(&mut hero.weapon, weapon_obj);
        let uri_after_equipping_weapon = string::utf8(b"hero equipped weapon");
        composables::equip_trait(
            owner, 
            hero.composable_obj, 
            weapon.trait_obj, 
            uri_after_equipping_weapon
        );
    }

    public fun hero_unequip_weapon(
        owner: &signer, 
        hero_obj: Object<Hero>,
        weapon_obj: Object<Weapon>
    ) acquires Hero, Weapon {
        let hero = borrow_global_mut<Hero>(object::object_address(&hero_obj));
        let weapon = borrow_global_mut<Weapon>(object::object_address(&weapon_obj));
        let stored_weapon_obj = option::extract(&mut hero.weapon);
        assert!(stored_weapon_obj == weapon_obj, error::not_found(EINVALID_WEAPON_UNEQUIP));
        let uri_after_unequipping_weapon = string::utf8(b"hero unequipped weapon");
        composables::unequip_trait(
            owner, 
            hero.composable_obj, 
            weapon.trait_obj, 
            uri_after_unequipping_weapon
        );
    }

    public fun weapon_equip_gem(owner: &signer, weapon: Object<Weapon>, gem: Object<Gem>) acquires Weapon {
        let weapon_obj = borrow_global_mut<Weapon>(object::object_address(&weapon));
        option::fill(&mut weapon_obj.gem, gem);
        object::transfer_to_object(owner, gem, weapon);
    }

    public fun weapon_unequip_gem(owner: &signer, weapon: Object<Weapon>, gem: Object<Gem>) acquires Weapon {
        let weapon_obj = borrow_global_mut<Weapon>(object::object_address(&weapon));
        let stored_gem = option::extract(&mut weapon_obj.gem);
        assert!(stored_gem == gem, error::not_found(EINVALID_GEM_UNEQUIP));
        object::transfer(owner, gem, signer::address_of(owner));
    }

}