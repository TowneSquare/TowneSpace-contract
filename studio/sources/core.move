/*
    - This contract represents the core of the studio.
    - Allows to create collections and mint tokens.
    - Leverages aptos_token_objects.
    - All functions are internals and has limited visibility (check NOTES).
    - A user can create the following:
        - Collections using aptos_token_objects/collection.move
        - Trait token: A token V2 that represents a trait.
        - Composable token (cNFT): A token V2 that can hold Trait tokens.
        - Fungible assets: future work :)
    TODOs:
        - fix unequip_trait_internal.
        - optimise the code: add inline functions (accessors).
        - add transfer functions.
        - add burn functions.
        - add mutators.
        - work on the fungible assets.

    NOTES:
    - for the sake of testing, all functions are set to be public.
    They should be set to internal once the testing is done (public(friend)).
*/

module townespace::core {
    use aptos_framework::fungible_asset::{FungibleStore}; 
    use aptos_framework::object::{
        Self, 
        Object, 
        ConstructorRef
        };
    use aptos_std::type_info;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty::{Royalty};
    use aptos_token_objects::token;
    use aptos_token_objects::property_map;

    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    // friend townespace::studio;
    // friend townespace::unit_tests;

    // ------
    // errors
    // ------
    const E_TYPE_NOT_RECOGNIZED: u64 = 1;
    const E_UNGATED_TRANSFER_DISABLED: u64 = 2;

    // ---------
    // Resources
    // ---------
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for collections
    struct Collection has key {
        name: String,
        // Collection symbol.
        symbol: String,
        type: String
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for composables; aka, the atoms/primaries of the token
    struct Composable has key {
        name: String,
        traits: vector<Object<Trait>>,
        coins: vector<Object<FungibleStore>>    // tbd
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
        transfer_ref: object::TransferRef
    }

    // ------------------   
    // Internal Functions
    // ------------------

    // Create a collection
    public fun create_collection_internal<T>(
        creator_signer: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        royalty: Option<Royalty>,   // TODO get the same in core.move
        uri: String, 
    ): ConstructorRef {
        if (type_info::type_of<T>() == type_info::type_of<collection::FixedSupply>()) {
            // constructor reference, needed to generate the other references.
            let constructor_ref = collection::create_fixed_collection(
                creator_signer,
                description,
                option::extract(&mut max_supply),
                name,
                royalty,
                uri
            );

            // create collection resource and move it to the resource account.
            // Also needed later for indexing.
            let collection_signer = object::generate_signer(&constructor_ref);
            let new_collection = Collection {
                name: name,
                symbol: symbol,
                type: string::utf8(b"fixed")
            };
            move_to(&collection_signer, new_collection);
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

            // create collection resource and move it to the resource account.
            // Also needed later for indexing.
            let collection_signer = object::generate_signer(&constructor_ref);
            let new_collection = Collection {
                name: name,
                symbol: symbol,
                type: string::utf8(b"unlimited")
            };
            move_to(&collection_signer, new_collection);
            constructor_ref
        }
    }

    // Create token
    public fun mint_token_internal<T>(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        type: String,
        name: String,
        num_type: u64,
        uri: String,
        traits: vector<Object<Trait>>, // if compoosable being minted
        property_keys: Option<vector<String>>,
        property_types: Option<vector<String>>,
        property_values: Option<vector<vector<u8>>>
    ): ConstructorRef {
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

        // create refs resource and move it to the resource account.
        let new_references = References {
            burn_ref: burn_ref,
            extend_ref: extend_ref,
            mutator_ref: mutator_ref,
            property_mutator_ref: property_mutator_ref,
            transfer_ref: transfer_ref
        };
        move_to(&token_signer, new_references);

        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            // if there are no traits or coins.
            let new_composable = Composable {
                name: token_name,
                traits: traits,
                coins: vector::empty(), // empty for now
            };
            move_to(&token_signer, new_composable);
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let new_trait = Trait {
                type: type,
                name: token_name,
            };
            move_to(&token_signer, new_trait);

            // Add properties to property map
            if (
                option::is_some(&property_keys) 
                && option::is_some(&property_types) 
                && option::is_some(&property_values) == true
                ){
                    let (
                    unrwaped_property_keys,
                    unrwaped_property_types,
                    unrwaped_property_values
                    ) = (
                        option::extract(&mut property_keys),
                        option::extract(&mut property_types),
                        option::extract(&mut property_values)
                        );
                    let properties = property_map::prepare_input(
                        unrwaped_property_keys,
                        unrwaped_property_types,
                        unrwaped_property_values
                        );
                    property_map::init(&constructor_ref, properties);
                }
        } else {
            // if type is neither composable nor trait.
            assert!(false, E_TYPE_NOT_RECOGNIZED);
        }; 
        constructor_ref
    }   

    // Compose trait to a composable token
    public fun equip_trait_internal(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable 
        let composable_resource = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        // index = vector length
        let traits = composable_resource.traits;
        let index = vector::length(&traits);
        // Add the object to the vector
        vector::insert<Object<Trait>>(&mut traits, index, trait_object);
        // Assert ungated transfer enabled for the object token.
        assert!(object::ungated_transfer_allowed(trait_object) == true, E_UNGATED_TRANSFER_DISABLED);
        // Transfer
        object::transfer_to_object(owner_signer, trait_object, composable_object);
        // Disable ungated transfer for trait object
        object::disable_ungated_transfer(&trait_references.transfer_ref);
    }

    // Decompose a trait from a composable token. Tests panic.
    public fun unequip_trait_internal(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable
        let composable_resource = borrow_global_mut<Composable>(object::object_address(&composable_object));
        let traits_vector = composable_resource.traits;
        // Trait
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        let (trait_exists, index) = vector::index_of(&traits_vector, &trait_object);
        assert!(trait_exists == true, 10);
        // Enable ungated transfer for trait object
        object::enable_ungated_transfer(&trait_references.transfer_ref);
        // Transfer trait object to owner
        object::transfer(owner_signer, trait_object, signer::address_of(owner_signer));
        // Remove the object from the vector
        vector::remove(&mut traits_vector, index);
    }

    // ---------
    // Accessors
    // ---------

    // --------------
    // View Functions
    // --------------

    // --------
    // Mutators
    // --------

    // Change uri
    public fun update_uri_internal(
        composable_object_address: address,
        new_uri: String
    ) acquires References {
        let references = borrow_global_mut<References>(composable_object_address);
        let mutator_reference = &references.mutator_ref;
        token::set_uri(mutator_reference, new_uri);
    }

    // type casting; cloned from dynamic_aptoads.move
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

}