/*
    TODO: Forked from: 
    TODO: Add a description of the module here.
    TODOs:
        - functions to create/mint.
        - add property map to token (maybe use aptos_token as a reference).
        - set uri function.
        - colection mutators: royalty mutator.
        - add comments.
*/

module townespace::core {
    use aptos_framework::fungible_asset::{FungibleAsset}; 
    use aptos_framework::object::{
        Self, 
        Object, 
        ConstructorRef, 
        DeleteRef, 
        ExtendRef,
        TransferRef
        };
    use aptos_std::string_utils;
    use aptos_std::type_info;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty::{Royalty};
    use aptos_token_objects::token;
    use aptos_token_objects::property_map;
   

    use std::error;
    use std::features;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    // ------
    // errors
    // ------
    const E_TYPE_NOT_RECOCNIZED: u64 = 1;

    // ---------
    // Resources
    // ---------

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for collections
    struct Collection has key {
        name: String,
        symbol: String,
        type: String
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for composables; aka, the atoms/primaries of the token
    struct Composable has key {
        name: String,
        traits: Option<vector<Object<Trait>>>,
        coins: Option<Object<FungibleAsset>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for traits; aka, the additional tokens
    struct Trait has key {
        type: String,
        name: String,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for token references
    struct References has key {
        burn_ref: token::BurnRef, // TODO: should be optional
        extend_ref: object::ExtendRef,
        mutator_ref: token::MutatorRef, // TODO: should be optional
        property_mutator_ref: property_map::MutatorRef, 
        transfer_ref: object::TransferRef,
    }

    // ------------------   
    // Internal Functions
    // ------------------

    // Create a collection
    fun create_collection<T>(
        creator_signer: &signer,
        description: String,
        supply_type: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        royalty: Option<Royalty>,   // TODO get the same in core.move
        uri: String
    ): ConstructorRef {
        if (type_info::type_of<T>() == type_info::type_of<collection::FixedSupply>()) {
            let constructor_ref = collection::create_fixed_collection(
                creator_signer,
                description,
                option::extract(&mut max_supply),
                name,
                royalty,
                uri
            );

            let collection_signer = object::generate_signer(&constructor_ref);
            move_to(
                &collection_signer,
                Collection {
                    name: name,
                    symbol: symbol,
                    type: string::utf8(b"fixed")
                }
            );
            constructor_ref
        // If type is not recognised, will create a collection with unlimited supply.
        } else {
            let constructor_ref = collection::create_unlimited_collection(
                creator_signer,
                description,
                name,
                royalty,
                uri
            );

            let collection_signer = object::generate_signer(&constructor_ref);
            move_to(
                &collection_signer,
                Collection {
                    name: name,
                    symbol: symbol,
                    type: string::utf8(b"unlimited")
                }
            );
            constructor_ref
        }
    }

    // Create token
    fun create_token<T>(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        type: String,
        name: String,
        num_type: u64,
        uri: String
    ): ConstructorRef acquires Collection {
        let token_name = type;
        string::append_utf8(&mut token_name, b" #");
        string::append_utf8(&mut token_name, *string::bytes(&u64_to_string(num_type)));

        let constructor_ref = token::create_named_token(
            creator_signer,
            collection_name,
            description,
            name,
            option::none(), // TODO: add royalty
            uri
        );

        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let property_mutator_ref = property_map::generate_mutator_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);

        let token_signer = object::generate_signer(&constructor_ref);

        move_to(
            &token_signer,
            References {
                burn_ref: burn_ref,
                extend_ref: extend_ref,
                mutator_ref: mutator_ref,
                property_mutator_ref: property_mutator_ref,
                transfer_ref: transfer_ref
            }
        );

        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            move_to(
                &token_signer,
                Composable {
                    name: token_name,
                    traits: option::none(),
                    coins: option::none(),
                }
            ); 
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            move_to(
                &token_signer,
                Trait {
                    type: type,
                    name: token_name
                }
            );
        } else {
            assert!(false, E_TYPE_NOT_RECOCNIZED);
        }; 

        constructor_ref
    }   

    // Compose trait to a composable token
    public(friend) fun equip_trait(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, Trait, References {
        // Composable 
        let composable = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait = borrow_global_mut<Trait>(object::object_address(&trait_object));
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        // index = vector length
        let traits = option::extract(&mut composable.traits);
        let index = vector::length(&traits);
        // Assert ungated transfer enabled for the object token.
        assert!(object::ungated_transfer_allowed(trait_object) == true, 10);
        // Transfer
        object::transfer_to_object(owner_signer, trait_object, composable_object);
        // Disable ungated transfer for trait object
        object::disable_ungated_transfer(&trait_references.transfer_ref);
        // Add the object to the vector
        vector::insert<Object<Trait>>(&mut traits, index, trait_object);
    }

    // TODO: Decompose
    public(friend) fun unequip_trait(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, Trait, References {
        // Composable 
        let composable_address = object::object_address(&composable_object);
        let composable = borrow_global_mut<Composable>(composable_address);
        // Trait
        let trait_address = object::object_address(&trait_object);
        let trait = borrow_global_mut<Trait>(trait_address);
        let trait_references = borrow_global_mut<References>(trait_address);
        // get the index "i" of the object. Needed for removing the trait from vector. (pattern matching)
        let (_, index) = vector::index_of(&composable_token.object_tokens, &object_token_object);
        // assert the object exists in the composable token address
        assert!(object::is_owner(object_token_object, composable_address), 8);
        // assert the object aptos token exists in the composable aptos token address
        assert!(object::is_owner(object_aptos_token_object, composable_aptos_token_address), 9);
        // Enable ungated transfer for trait object
        object::enable_ungated_transfer(&trait_references.transfer_ref);
        // Transfer
        object::transfer(owner_signer, trait_object, signer::address_of(owner_signer));
        // Add the object to the vector
        vector::remove<Object<Trait>>(&mut traits, index, index);
    }

    // TODO: Transfer

    // TODO: Burn

    // ---------
    // Accessors
    // ---------

    // --------------
    // View Functions
    // --------------

    // --------
    // Mutators
    // --------
    fun u64_to_string(value: u64): String {
      if (value == 0) {
         return string::utf8(b"0")
      };
      let buffer = vector::empty<u8>();
      while (value != 0) {
         vector::push_back(&mut buffer, ((48 + value % 10) as u8));
         value = value / 10;
      };
      vector::reverse(&mut buffer);
      string::utf8(buffer)
   }

    // TODO: add properties to property map

}