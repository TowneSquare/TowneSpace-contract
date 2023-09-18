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
        - add transfer functions.
        - add burn functions.
        - add mutators.
        - work on the fungible assets.
*/

module townespace::core {
    use aptos_framework::fungible_asset::{FungibleStore}; 
    use aptos_framework::object::{
        Self, 
        Object
        };
    use aptos_std::type_info;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;
    use aptos_token_objects::property_map;

    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    friend townespace::studio;

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
    // Storage state for composables; aka, the atom/primary of the token
    struct Composable has key {
        name: String,
        traits: vector<Object<Trait>>,
        coins: vector<Object<FungibleStore>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for a trait
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
        uri: String, 
        royalty_numerator: u64,
        royalty_denominator: u64
    ): Object<Collection> {
        let royalty = royalty::create(royalty_numerator, royalty_denominator, signer::address_of(creator_signer));
        if (type_info::type_of<T>() == type_info::type_of<collection::FixedSupply>()) {
            // constructor reference, needed to generate the other references.
            let constructor_ref = collection::create_fixed_collection(
                creator_signer,
                description,
                option::extract(&mut max_supply),
                name,
                // payee address is the creator by default, it can be changed after creation.
                option::some(royalty),
                uri
            );

            // create collection resource and move it to the resource account.
            // Also needed later for indexing.
            let collection_signer = object::generate_signer(&constructor_ref);
            let collection = Collection {
                name: name,
                symbol: symbol,
                type: string::utf8(b"fixed")
            };
            move_to(&collection_signer, collection);
            object::object_from_constructor_ref(&constructor_ref)
        // If type is not recognised, will create a collection with unlimited supply.
        } else {
            let constructor_ref = collection::create_unlimited_collection(
                creator_signer,
                description,
                name,
                option::some(royalty),
                uri
            );
            // create collection resource and move it to the resource account.
            // Also needed later for indexing.
            let collection_signer = object::generate_signer(&constructor_ref);
            let collection = Collection {
                name: name,
                symbol: symbol,
                type: string::utf8(b"unlimited")
            };
            move_to(&collection_signer, collection);
            object::object_from_constructor_ref(&constructor_ref)
        }
    }

    // Create token
    public fun mint_token_internal<T: key>(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        type: String,
        name: String,
        num_type: u64,
        uri: String,
        traits: vector<Object<Trait>>, // if compoosable being minted
        coins: vector<Object<FungibleStore>>,   // if fungible asset being minted
        royalty_numerator: u64,
        royalty_denominator: u64,
        // properties if minted token is trait token
        property_keys: Option<vector<String>>,
        property_types: Option<vector<String>>,
        property_values: Option<vector<vector<u8>>>
    ): Object<T> {
        let token_name = type;
        string::append_utf8(&mut token_name, b" #");
        string::append_utf8(&mut token_name, *string::bytes(&u64_to_string(num_type)));

        let royalty = royalty::create(royalty_numerator, royalty_denominator, signer::address_of(creator_signer));
        let constructor_ref = token::create_named_token(
            creator_signer,
            collection_name,
            description,
            name,
            option::some(royalty), 
            uri
        );

        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let property_mutator_ref = property_map::generate_mutator_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);

        let token_signer = object::generate_signer(&constructor_ref);

        // create refs resource and move it to the resource account.
        let references = References {
            burn_ref: burn_ref,
            extend_ref: extend_ref,
            mutator_ref: mutator_ref,
            property_mutator_ref: property_mutator_ref,
            transfer_ref: transfer_ref
        };
        move_to(&token_signer, references);
        // if type is composable
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable = Composable {
                name: token_name,
                traits: traits,
                coins: coins, 
            };
            move_to(&token_signer, composable);
            // TODO if there are coins.
        // if type is trait
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = Trait {
                type: type,
                name: token_name
            };
            move_to(&token_signer, trait);

            // Add properties to property map
            if (
                option::is_some(&property_keys) 
                && option::is_some(&property_types) 
                && option::is_some(&property_values) == true
                ){
                    let (
                    unwrapped_property_keys,
                    unwrapped_property_types,
                    unwrapped_property_values
                    ) = (
                        option::extract(&mut property_keys),
                        option::extract(&mut property_types),
                        option::extract(&mut property_values)
                        );
                    let properties = property_map::prepare_input(
                        unwrapped_property_keys,
                        unwrapped_property_types,
                        unwrapped_property_values
                        );
                    property_map::init(&constructor_ref, properties);
                }
        } else {
            // if type is neither composable nor trait.
            assert!(false, E_TYPE_NOT_RECOGNIZED);
        }; 
        object::object_from_constructor_ref(&constructor_ref)
    }   

    // Compose trait to a composable token
    public(friend) fun equip_trait_internal(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable 
        let composable_resource = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        // Add the object to the end of the vector
        vector::push_back<Object<Trait>>(&mut composable_resource.traits, trait_object);
        // Assert ungated transfer enabled for the object token.
        assert!(object::ungated_transfer_allowed(trait_object) == true, E_UNGATED_TRANSFER_DISABLED);
        // Transfer
        object::transfer_to_object(owner_signer, trait_object, composable_object);
        // Disable ungated transfer for trait object
        object::disable_ungated_transfer(&trait_references.transfer_ref);
    }

    // Decompose a trait from a composable token. Tests panic.
    public(friend) fun unequip_trait_internal(
        owner_signer: &signer,
        composable_object: Object<Composable>,
        trait_object: Object<Trait>
    ) acquires Composable, References {
        // Composable
        let composable_resource = borrow_global_mut<Composable>(object::object_address(&composable_object));
        // Trait
        let trait_references = borrow_global_mut<References>(object::object_address(&trait_object));
        let (trait_exists, index) = vector::index_of(&composable_resource.traits, &trait_object);
        assert!(trait_exists == true, 10);
        // Enable ungated transfer for trait object
        object::enable_ungated_transfer(&trait_references.transfer_ref);
        // Transfer trait object to owner
        object::transfer(owner_signer, trait_object, signer::address_of(owner_signer));
        // Remove the object from the vector
        vector::remove(&mut composable_resource.traits, index);
    }

    // TODO: convert trait to composable

    // ---------
    // Accessors
    // ---------

    // --------------
    // View Functions
    // --------------
    inline fun borrow<T: key>(
        object: Object<T>
        ): &T acquires Collection, Composable, Trait {
            let object_address = object::object_address(&object);
            assert!(
                exists<T>(object_address),
                89,
            );
            borrow_global<T>(object_address)
    }

    // collection
    #[view]
    public fun get_collection_name(
        collection_object: Object<Collection>
    ): String acquires Collection {
        borrow<Collection>(collection_object).name
    }

    #[view]
    public fun get_collection_symbol(
        collection_object: Object<Collection>
    ): String acquires Collection {
        borrow<Collection>(collection_object).symbol
    }

    #[view]
    public fun get_traits(
        composable_object: Object<Composable>
    ): vector<Object<Trait>> acquires Composable {
        borrow<Composable>(composable_object).traits  
    }

    // --------
    // Mutators
    // --------

    // Change uri
    public(friend) fun update_uri_internal(
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

    #[test_only]
    use aptos_token_objects::collection::{/*FixedSupply, */UnlimitedSupply};

    #[test(creator = @0x123)]
    fun test(creator: &signer) acquires Composable, References {
        create_collection_internal<UnlimitedSupply>(
            creator,
            string::utf8(b"test"), 
            option::none(), 
            string::utf8(b"test"), 
            string::utf8(b"test"),
            string::utf8(b"test"), 
            1,
            2
            );
        let composable_object = mint_token_internal<Composable>(
            creator,
            string::utf8(b"test"),
            string::utf8(b"test"),
            string::utf8(b"test"),
            string::utf8(b"composable token"),
            1,
            string::utf8(b"test"),
            vector::empty(),
            vector::empty(),    // no coins  
            1,
            2,
            option::none(),
            option::none(),
            option::none()
        );
        let trait_object = mint_token_internal<Trait>(
            creator,
            string::utf8(b"test"),
            string::utf8(b"test"),
            string::utf8(b"test"),
            string::utf8(b"trait token"),
            2,
            string::utf8(b"test"),
            vector::empty(),
            vector::empty(),    // no coins
            1,
            2,
            option::none(),
            option::none(),
            option::none()
        );
        equip_trait_internal(creator, composable_object, trait_object);
        let composable_address = object::object_address(&composable_object);
        let composable_resource = borrow_global_mut<Composable>(composable_address);
        // assert the trait object is being transferred to the composable object
        assert!(object::is_owner(trait_object, composable_address) == true, 2234);
        // assert traits vector is not empty
        assert!(vector::is_empty<Object<Trait>>(&composable_resource.traits) == false, 3234);
        // assert the trait object is being added to the composable object's traits vector
        assert!(vector::contains(&composable_resource.traits, &trait_object) == true, 4234);
        unequip_trait_internal(creator, composable_object, trait_object);
        // assert the token is not in the composable token anymore
        assert!(object::is_owner(trait_object, composable_address) == false, 5234);        
        // assert the trait object is being transferred to the creator
        assert!(object::is_owner(trait_object, signer::address_of(creator)) == true, 5234);
    }


}