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
        - add mutators.
        - add view functions to see collection details.
        - FA: only composables can hold FA (for now).
        - Implement royalties better, check framwork modules.
        - refactor: tokens -> digital assets | fa -> fungible asset (remains the same)
        - naming related: name should follow the nft type
            e.g: type # index
        - soulbound FA: not transferable but burnable. 
*/

module townespace::core {
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use aptos_std::type_info;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token::{Self, Token as TokenV2};

    // use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    friend townespace::mint;
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
        traits: vector<Object<Trait>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Storage state for traits
    struct Trait has key {
        index: u64, // index from the vector
        type: String
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
    // TODO: if royalties option::some == true, init royalty. Not otherwise.
    public fun create_collection_internal<T>(
        signer_ref: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        uri: String,    
        // TODO: make royalties optional
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
                    traits
                }
            );
        // if type is trait
        } else {
            move_to(
                &token_signer,
                Trait {
                    index: vector::length(&traits),
                    type,
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

    // equip fa; transfer fa to a token; token can be either composable or trait
    public(friend) fun equip_fa_to_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) {
        let token_obj_addr = object::object_address(&token_obj);
        // assert Token is either composable or trait
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            E_TYPE_NOT_RECOGNIZED
        );
        // transfer 
        primary_fungible_store::transfer(signer_ref, fa, token_obj_addr, amount);
    }

    // uequip fa; transfer fa from a token to the owner
    public(friend) fun unequip_fa_from_token<FA: key, Token: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<Token>,
        amount: u64
    ) {
        let token_obj_addr = object::object_address(&token_obj);
        // assert Token is either composable or trait
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            E_TYPE_NOT_RECOGNIZED
        );
        // transfer 
        primary_fungible_store::transfer(signer_ref, fa, signer::address_of(signer_ref), amount);
    }

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

    // transfer digital assets; from user to user.
    public(friend) fun transfer_token<Token: key>(
        signer_ref: &signer,
        token_address: address,
        new_owner: address
    ) {
        // assert Token is either composable, trait or FA
        assert!(
            type_info::type_of<Token>() == type_info::type_of<Composable>() 
            || type_info::type_of<Token>() == type_info::type_of<Trait>(), 
            E_TYPE_NOT_RECOGNIZED
        );

        // assert new owner is not a token
        assert!(!object::is_object(new_owner), 10);

        // transfer
        // TODO: should use transfer ref and object instead of token address?
        object::transfer<TokenV2>(signer_ref, object::address_to_object(token_address), new_owner)
    }

    // transfer fa from user to user.
    public(friend) fun transfer_fa<FA: key>(
        signer_ref: &signer,
        recipient: address,
        fa: Object<FA>,
        amount: u64
    ) {
        assert!(!object::is_object(recipient), 10);
        primary_fungible_store::transfer<FA>(signer_ref, fa, recipient, amount)
    }

    // burn a token
    public(friend) fun burn_token<T: key>(signer_ref: &signer, token_object: Object<T>) {
        assert!(object::owns<T>(token_object, signer::address_of(signer_ref)), 10);
        // Burn tokens and delete references
        let token_object_address = object::object_address(&token_object);
        // assert object is either composable or trait
        assert!(exists<Composable>(token_object_address) || exists<Trait>(token_object_address), 2);
        // if type is composable
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            // TODO: decompose; send traits back to owner
            object::burn<T>(signer_ref, token_object);
        // if type is trait
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            // get trait resource
            object::burn<T>(signer_ref, token_object);
        } else { assert!(false, E_TYPE_NOT_RECOGNIZED); };
    }

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

    public(friend) fun borrow_mut_traits(composable_address: address): vector<Object<Trait>> acquires Composable {
        borrow_global_mut<Composable>(composable_address).traits
    }

    // --------
    // Mutators
    // --------

    // Change token name
    public(friend) fun set_token_name_internal(
        signer_ref: &signer,
        token_object_address: address,
        new_name: String
    ) acquires References {
        assert!(object::is_owner<TokenV2>(object::address_to_object(token_object_address), signer::address_of(signer_ref)), 10);
        let references = borrow_global_mut<References>(token_object_address);
        let mutator_reference = &references.mutator_ref;
        token::set_name(mutator_reference, new_name);
    }

    // Change uri
    public(friend) fun update_uri_internal(
        composable_object_address: address,
        new_uri: String
    ) acquires References {
        let references = borrow_global_mut<References>(composable_object_address);
        let mutator_reference = &references.mutator_ref;
        token::set_uri(mutator_reference, new_uri);
    } 

    #[test_only]
    friend townespace::studio_tests; 
    #[test_only]
    friend townespace::test_utils; 
    #[test_only]  
    friend townespace::core_tests;
    
}