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
        - add burn functions.
        - add mutators.
        - add view functions to see collection details.
        - FA: only composables can hold FA (for now).
        - Implement royalties better, check framwork modules.
        - Recover burned tokens?
*/

module townespace::core {
    use aptos_framework::fungible_asset::{Self, FungibleStore}; 
    use aptos_framework::object::{Self, Object, TransferRef};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::type_info;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;

    // use std::error;
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
    const E_TOKEN_NOT_BURNABLE: u64 = 3;

    // ---------
    // Resources
    // ---------
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for collections
    struct Collection has key {
        name: String,
        symbol: String
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for composables; aka, the atom/primary of the token
    struct Composable has key {
        traits: vector<Object<Trait>>,
        coins: SmartTable<String, Object<FungibleStore>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for traits
    struct Trait has key {
        index: u64, // index from the vector
        type: String,
        coins: SmartTable<String, Object<FungibleStore>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for token references
    struct References has key {
        burn_ref: token::BurnRef,
        extend_ref: object::ExtendRef,
        mutator_ref: token::MutatorRef,
        transfer_ref: object::TransferRef
    }

    // ------------------   
    // Internal Functions
    // ------------------

    // Create a collection
    public fun create_collection_internal<T>(
        signer_ref: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        uri: String, 
        royalty_numerator: u64,
        royalty_denominator: u64,
        // whether tokens can be burned or not.
        is_burnable: bool,
        // whether Trait description and uri can be mutated or not.
        is_mutable: bool
    ): Object<Collection> {
        let royalty = royalty::create(royalty_numerator, royalty_denominator, signer::address_of(signer_ref));
        if (type_info::type_of<T>() == type_info::type_of<collection::FixedSupply>()) {
            // constructor reference, needed to generate the other references.
            let constructor_ref = collection::create_fixed_collection(
                signer_ref,
                description,
                option::extract(&mut max_supply),
                name,
                // payee address is the creator by default, it can be changed after creation.
                option::some(royalty),
                uri
            );

            move_to(
                &object::generate_signer(&constructor_ref), 
                Collection {
                    name,
                    symbol
                }
            );

            object::object_from_constructor_ref(&constructor_ref)
        // If type is not recognised, will create a collection with unlimited supply.
        } else {
            let constructor_ref = collection::create_unlimited_collection(
                signer_ref,
                description,
                name,
                option::none(),
                uri
            );
            
            move_to(
                &object::generate_signer(&constructor_ref), 
                Collection {
                    name,
                    symbol
                }
            );

            object::object_from_constructor_ref(&constructor_ref)
        }
    }

    // TODO
    // fun init_ref(): Option<>{}

    // Create tokens
    public fun create_token_internal<T: key>(
        signer_ref: &signer,
        collection_name: String,
        description: String,
        uri: String,
        type: String,   // should be option?
        traits: vector<Object<Trait>>, 
        coins: SmartTable<String, Object<FungibleStore>>,   
        royalty_numerator: u64,
        royalty_denominator: u64
    ): Object<T> {
        // type should either be composable or traits
        assert!(
            type_info::type_of<T>() == type_info::type_of<Composable>() || type_info::type_of<T>() == type_info::type_of<Trait>(), 
            E_TYPE_NOT_RECOGNIZED
        );
        // if inputted royalty is 0, set option to none.
        let royalty = royalty::create(royalty_numerator, royalty_denominator, signer::address_of(signer_ref));
        let constructor_ref = token::create_numbered_token(
            signer_ref,
            collection_name,
            description,
            string::utf8(b"#"),
            string::utf8(b""),
            option::some(royalty), 
            uri
        );

        // Generate references
        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);

        // Generate token signer; needed to store references
        let token_signer = object::generate_signer(&constructor_ref);

        // if type is composable
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            move_to(
                &token_signer, 
                Composable {
                    traits,
                    coins
                }
            );
        // if type is trait
        } else {
            move_to(
                &token_signer,
                Trait {
                    index: vector::length(&traits),
                    type,
                    coins
                } 
            );
        };
        
        // move resource under the token signer.
        move_to(
            &token_signer, 
            References {
                burn_ref: burn_ref,
                extend_ref: extend_ref,
                mutator_ref: mutator_ref,
                transfer_ref: transfer_ref
            }
        );

        object::object_from_constructor_ref(&constructor_ref)
    }   

    // Compose trait to a composable token
    public(friend) fun equip_trait_internal(
        signer_ref: &signer,
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
        object::transfer_to_object(signer_ref, trait_object, composable_object);
        // Disable ungated transfer for trait object
        object::disable_ungated_transfer(&trait_references.transfer_ref);
    }

    // Transfer fungible asset of type T to a token (only composable for now)
    public(friend) fun transfer_fungible_assets<T: key>(
        sender: &signer,
        from: Object<T>,
        to: Object<T>,
        amount: u64,
    ){
        // check if from exists in coins and return index
        // get the element from coins given the index
        // transfer fa
    }

    // TODO: Decompose Fungible asset to a composable token

    // Decompose a trait from a composable token. Tests panic.
    public(friend) fun unequip_trait_internal(
        signer_ref: &signer,
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
        object::transfer(signer_ref, trait_object, signer::address_of(signer_ref));
        // Remove the object from the vector
        vector::remove(&mut composable_resource.traits, index);
    }

    // transfer function; from user to user.
    public(friend) fun transfer_token<T: key>(
        signer_ref: &signer,
        token_address: address,
        new_owner: address
    ) {
        // assert new owner is not a token; check if it exists in Composable or Trait or TokenV2
        assert!(object::is_object(new_owner) == false, 10); // might be wrong
        object::transfer<T>(
            signer_ref,
            object::address_to_object<T>(token_address),
            new_owner
        )
        // TODO: emit transfer events
    }
    // TODO: Transfer with fee.

    // burn a token
    // TODO: needs to be tested
    public(friend) fun burn_token<T: key>(
        token_object: Object<T>
    ) acquires Composable, Trait, References {
        // assert!
        // Burn tokens and delete references
        let token_object_address = object::object_address(&token_object);
        // assert object is either composable or trait
        assert!(
            exists<Composable>(token_object_address) 
            || exists<Trait>(token_object_address), 
            2
            );
        // get references
        let references_resource = borrow_global<References>(token_object_address);
        move references_resource;
        // delete references
        let refrences = move_from<References>(token_object_address);
        let References {
            burn_ref,
            extend_ref: _,
            mutator_ref: _,
            transfer_ref: _
        } = refrences;
        // if type is composable
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            // TODO: decompose; send traits back to owner
            // destroy coins table
            smart_table::destroy(borrow_global_mut<Composable>(token_object_address).coins);
            // get composable resource
            let composable_resource = borrow_global_mut<Composable>(token_object_address);
            move composable_resource;
            // delete resources
            let composable = move_from<Composable>(token_object_address);
            let Composable {
                traits: _,
                coins: _
            } = composable;
            // burn token
            token::burn(burn_ref);
            // TODO: emit composable burn event
        // if type is trait
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            // destroy coins table
            smart_table::destroy(borrow_global_mut<Trait>(token_object_address).coins);
            // get trait resource
            let trait_resource = borrow_global<Trait>(token_object_address);
            move trait_resource;
            let trait = move_from<Trait>(token_object_address);
            let Trait {
                index: _,
                type: _,
                coins: _
            } = trait;
            // burn token
            token::burn(burn_ref);
            // TODO: emit trait burn event
        } else {
            // if type is neither composable nor trait.
            assert!(false, E_TYPE_NOT_RECOGNIZED);
        }
    }

    // TODO: create store; this will create and object, from the constructor ref and its signer, create and returns a fungible store.
    fun create_store<FA: key>(signer_ref: &signer, metadata: Object<FA>): (Object<FungibleStore>, TransferRef) {
        // create object
        let constructor_ref = object::create_object(signer::address_of(signer_ref));
        // create fungible store, its transfer_ref, and return both
        (fungible_asset::create_store<FA>(&constructor_ref, metadata), object::generate_transfer_ref(&constructor_ref))
    }

    // TODO: add store to a T; 
    // if T is a token, send the object to the composable and update coins smart table <<FA>, FungibleStore<FA>>._
    // if T is a user? how to kmoe if the input is an account or object?
    fun add_store<FA: key, Token: key>(
        signer_ref: &signer, 
        token_obj: Object<Token>,
        fungible_store_obj: Object<FungibleStore>,
        fungible_store_transfer_ref: TransferRef
    ) acquires Composable, Trait {
        // TODO: assert destination is a token or user (account or object)

        let token_obj_addr = object::object_address(&token_obj);
        // based on type
        if (type_info::type_of<Token>() == type_info::type_of<Composable>()) {
            // transfer the fungible object to the composable
            object::transfer_to_object(signer_ref, fungible_store_obj, token_obj);
            // Disable ungated transfer for the fungible object
            object::disable_ungated_transfer(&fungible_store_transfer_ref);
            // update the coins smart table
            smart_table::add(
                &mut borrow_global_mut<Composable>(token_obj_addr).coins,
                type_info::type_name<FA>(),
                fungible_store_obj
            );
        } else if (type_info::type_of<Token>() == type_info::type_of<Trait>()) {
            // transfer the fungible object to the trait and disable ungated transfer
            object::transfer_to_object(signer_ref, fungible_store_obj, token_obj);
            // Disable ungated transfer for the fungible object
            object::disable_ungated_transfer(&fungible_store_transfer_ref);
            // update the coins smart table
            smart_table::add(
                &mut borrow_global_mut<Trait>(token_obj_addr).coins,
                type_info::type_name<FA>(),
                fungible_store_obj
            );
        } else {
            // if user (account not object)
        }
    }

    // transfer fa to a token
    // TODO: add Trait compotability
    public(friend) fun transfer_fa_to_token<FA: key, Token: key>(
        signer_ref: &signer,
        from: Object<FungibleStore>,
        token_obj: Object<Token>,
        amount: u64
    ) acquires Composable {
        let token_obj_addr = object::object_address(&token_obj);
        
        // check if store for FA exists in the token
        // get the store
        let fa_store = *smart_table::borrow(&borrow_global<Composable>(token_obj_addr).coins, type_info::type_name<FA>());
        // transfer 
        fungible_asset::transfer(signer_ref, from, fa_store, amount);
    }

    // TODO: store exists in a composable token?

    // ---------
    // Accessors
    // ---------

    // --------------
    // View Functions
    // --------------

    // collection
    #[view]
    public fun get_collection_name(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).name
    }

    #[view]
    public fun get_collection_symbol(collection_object: Object<Collection>): String acquires Collection {
        let object_address = object::object_address(&collection_object);
        borrow_global<Collection>(object_address).symbol
    }

    #[view]
    public fun get_traits(composable_object: Object<Composable>): vector<Object<Trait>> acquires Composable {
        let object_address = object::object_address(&composable_object);
        borrow_global<Composable>(object_address).traits  
    }

    #[view]
    public fun borrow_mut_traits(composable_address: address): vector<Object<Trait>> acquires Composable {
        borrow_global_mut<Composable>(composable_address).traits
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
    friend townespace::studio_tests; 
    #[test_only]
    friend townespace::test_utils; 
    #[test_only]  
    friend townespace::core_tests;
    
}