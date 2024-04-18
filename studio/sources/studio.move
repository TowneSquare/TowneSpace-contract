/*
    - This module is a no-code implementation for the composability contract.
    - It is responsible for creating collections, creating tokens,
    and composing and decomposing tokens.
    - It is also responsible for transferring tokens.

    TODO:
        - add a view function to get all active capabilities for a given collection
        - add a view function to get all active capabilities for a given token
        - add events for all entry functions
        - remove redundant entry functions
*/

module townespace::studio {

    use aptos_framework::event;
    use aptos_framework::object::{Self, Object};
    
    use aptos_token_objects::collection;

    use std::option;
    use std::string;
    // use std::signer;
    use std::string::String;
    use std::vector;

    use townespace::composables::{Self, Collection, Composable, Indexed, Named, Trait};

    // ------
    // Events
    // ------

    #[event]
    struct CollectionCreatedEvent has drop, store {
        obj: Object<Collection>,
        type: String,
        created_with_royalty: bool
    }
    fun emit_collection_created_event(
        obj: Object<Collection>, 
        type: String,
        created_with_royalty: bool
    ) {
        event::emit<CollectionCreatedEvent>(
            CollectionCreatedEvent { obj, type, created_with_royalty }
        )
    }

    #[event]
    struct TokenCreatedEvent<phantom T> has drop, store {
        obj: Object<T>,
        type: String,
        naming_style: String,
        created_with_royalty: bool
    }
    fun emit_token_created_event<T>(
        obj: Object<T>,
        type: String,
        naming_style: String,
        created_with_royalty: bool
    ) {
        event::emit<TokenCreatedEvent<T>>(
            TokenCreatedEvent<T> { obj, type, naming_style, created_with_royalty }
        )
    }
    
    // ---------------
    // Entry Functions
    // ---------------
    
    // Create a new collection with fixed supply and royalty on
    public entry fun create_collection_with_fixed_supply_and_royalty(
        signer_ref: &signer,
        description: String,
        max_supply: u64, 
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty_numerator: u64,
        royalty_denominator: u64
    ) {
        let constructor_ref = composables::create_collection<collection::FixedSupply>(
            signer_ref,
            description,
            option::some(max_supply),
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::some(royalty_numerator),
            option::some(royalty_denominator)
        );
        // generate the collection object
        let obj = object::object_from_constructor_ref<Collection>(&constructor_ref);
        // emit creation event
        emit_collection_created_event(
            obj,
            string::utf8(b"fixed supply"),
            true
        );
    }

    // Create a new collection with fixed supply and royalty off.
    // token uri mutibility is enforced to be true to allow composibility
    public entry fun create_collection_with_fixed_supply_and_no_royalty(
        signer_ref: &signer,
        description: String,
        max_supply: u64, 
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool
    ) {
        let constructor_ref = composables::create_collection<collection::FixedSupply>(
            signer_ref,
            description,
            option::some(max_supply),
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            true,  // mutable token uri
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::none(),
            option::none()
        );
        // generate the collection object
        let obj = object::object_from_constructor_ref<Collection>(&constructor_ref);
        // emit creation event
        emit_collection_created_event(
            obj,
            string::utf8(b"fixed supply"),
            false
        );
    }

    // Create a new collection with unlimited supply and royalty on.
    // token uri mutibility is enforced to be true to allow composibility
    public entry fun create_collection_with_unlimited_supply_and_royalty(
        signer_ref: &signer,
        description: String,
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool,
        royalty_numerator: u64,
        royalty_denominator: u64
    ) {
        let constructor_ref = composables::create_collection<collection::UnlimitedSupply>(
            signer_ref,
            description,
            option::none(),
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            true,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::some(royalty_numerator),
            option::some(royalty_denominator)
        );
        // generate the collection object
        let obj = object::object_from_constructor_ref<Collection>(&constructor_ref);
        // emit creation event
        emit_collection_created_event(
            obj,
            string::utf8(b"unlimited supply"),
            true
        );
    }

    // Create a new collection with unlimited supply and royalty off.
    // token uri mutibility is enforced to be true to allow composibility
    public entry fun create_collection_with_unlimited_supply_and_no_royalty(
        signer_ref: &signer,
        description: String,
        name: String,
        symbol: String,
        uri: String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        tokens_burnable_by_creator: bool,
        tokens_freezable_by_creator: bool
    ) {
        let constructor_ref = composables::create_collection<collection::UnlimitedSupply>(
            signer_ref,
            description,
            option::none(),
            name,
            symbol,
            uri,
            mutable_description,
            mutable_royalty,
            mutable_uri,
            mutable_token_description,
            mutable_token_name,
            mutable_token_properties,
            true,  // mutable token uri
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::none(),
            option::none()
        );
        // generate the collection object
        let obj = object::object_from_constructor_ref<Collection>(&constructor_ref);
        // emit creation event
        emit_collection_created_event(
            obj,
            string::utf8(b"unlimited supply"),
            false
        );
    }

    // Create a named composable token with no royalty
    public entry fun create_named_composable_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Composable, Named>(
            signer_ref,
            collection,
            description,
            name,
            string::utf8(b""), // won't be used
            string::utf8(b""), // won't be used
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Composable>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Composable>(
            obj,
            string::utf8(b"composable"),
            string::utf8(b"named"),
            false
        );
    }

    // Create a named composable token with royalty
    public entry fun create_named_composable_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Composable, Named>(
            signer_ref,
            collection,
            description,
            name,
            string::utf8(b""), // won't be used
            string::utf8(b""), // won't be used
            uri,
            option::some(royalty_numerator),
            option::some(royalty_denominator),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Composable>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Composable>(
            obj,
            string::utf8(b"composable"),
            string::utf8(b"named"),
            true
        );
    }

    // Create an indexed composable token with royalty 
    public entry fun create_indexed_composable_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Composable, Indexed>(
            signer_ref,
            collection,
            description,
            string::utf8(b""), // won't be used
            string::utf8(b"#"),
            string::utf8(b""),
            uri,
            option::some(royalty_numerator),
            option::some(royalty_denominator),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Composable>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Composable>(
            obj,
            string::utf8(b"composable"),
            string::utf8(b"indexed"),
            true
        );
    }

    // Create an indexed composable token without royalty 
    public entry fun create_indexed_composable_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Composable, Indexed>(
            signer_ref,
            collection,
            description,
            string::utf8(b""), // won't be used
            string::utf8(b"#"),
            string::utf8(b""),
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Composable>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Composable>(
            obj,
            string::utf8(b"composable"),
            string::utf8(b"indexed"),
            false
        );
    }

    // Create a named trait token with no royalty
    public entry fun create_named_trait_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Trait, Named>(
            signer_ref,
            collection,
            description,
            name,
            string::utf8(b""), // won't be used
            string::utf8(b""), // won't be used
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Trait>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Trait>(
            obj,
            string::utf8(b"trait"),
            string::utf8(b"named"),
            false
        );
    }

    // Create a named trait token with royalty
    public entry fun create_named_trait_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Trait, Named>(
            signer_ref,
            collection,
            description,
            name,
            string::utf8(b""), // won't be used
            string::utf8(b""), // won't be used
            uri,
            option::some(royalty_numerator),
            option::some(royalty_denominator),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Trait>(&constructor_ref);
    }

    // Create an indexed trait token with royalty
    public entry fun create_indexed_trait_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Trait, Indexed>(
            signer_ref,
            collection,
            description,
            string::utf8(b""), // won't be used
            string::utf8(b"#"),
            string::utf8(b""),
            uri,
            option::some(royalty_numerator),
            option::some(royalty_denominator),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Trait>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Trait>(
            obj,
            string::utf8(b"trait"),
            string::utf8(b"indexed"),
            true
        );
    }

    // Create an indexed trait token with royalty off
    public entry fun create_indexed_trait_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = composables::create_token<Trait, Indexed>(
            signer_ref,
            collection,
            description,
            string::utf8(b""), // won't be used
            string::utf8(b"#"),
            string::utf8(b""),
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        let obj = object::object_from_constructor_ref<Trait>(&constructor_ref);
        // emit creation event
        emit_token_created_event<Trait>(
            obj,
            string::utf8(b"trait"),
            string::utf8(b"indexed"),
            false
        );
    }

    // Burn a token
    public entry fun burn_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        composables::burn_token<T>(signer_ref, token_obj);
    }

    // Freeze a token
    public entry fun freeze_transfer<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        composables::freeze_transfer<T>(signer_ref, token_obj);
    }

    // Unfreeze a token
    public entry fun unfreeze_transfer<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        composables::unfreeze_transfer<T>(signer_ref, token_obj);
    }

    // Equip trait to a composable
    public entry fun equip_trait(
        owner: &signer,
        composable_obj: Object<Composable>,
        trait_obj: Object<Trait>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) { 
        composables::equip_trait(owner, composable_obj, trait_obj, new_uri);
    }

    // Equip fungible asset to a trait or composable
    public entry fun equip_fungible_asset<FA: key, TokenType: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<TokenType>,
        amount: u64
    ) {
        composables::equip_fa_to_token<FA, TokenType>(signer_ref, fa, token_obj, amount);
    }

    // Unequip trait from a composable
    public entry fun unequip_trait(
        owner: &signer,
        composable_obj: Object<Composable>,
        trait_obj: Object<Trait>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        composables::unequip_trait(owner, composable_obj, trait_obj, new_uri);
    }

    // Unequip fungible asset from a trait or composable
    public entry fun unequip_fungible_asset<FA: key, TokenType: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<TokenType>,
        amount: u64
    ) {
        composables::unequip_fa_from_token<FA, TokenType>(signer_ref, fa, token_obj, amount);
    }

    // Decompose an entire composable token
    // TODO: should be tested
    public entry fun decompose_entire_composable_token(
        owner: &signer,
        composable_obj: Object<Composable>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        // iterate through the vector and unequip traits
        let traits = composables::get_traits_from_composable(composable_obj);
        let i = 0;
        // TODO: can be optimized
        while (i < vector::length<Object<Trait>>(&traits)) {
            let trait_obj = *vector::borrow(&traits, i);
            composables::unequip_trait(owner, composable_obj, trait_obj, new_uri);
            i = i + 1;
        };
    }

    // Directly transfer a token to a user.
    public entry fun transfer_digital_asset<T: key>(
        owner: &signer, 
        token_address: address,
        new_owner_address: address,
    ) {
        composables::transfer_token<T>(owner, token_address, new_owner_address);
    }

    // Directly transfer a token to a user.
    public entry fun transfer_fungible_asset<FA: key>(
        signer_ref: &signer,
        recipient: address,
        fa: Object<FA>,
        amount: u64
    ) {
        composables::transfer_fa<FA>(signer_ref, recipient, fa, amount);
    }

    // --------
    // Mutators
    // --------

    // set token name
    public entry fun set_token_name<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        new_name: String
    ) {
        composables::set_name<T>(signer_ref, token_obj, new_name);
    }

    // set token description
    public entry fun set_token_description<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        new_description: String
    ) {
        composables::set_description<T>(signer_ref, token_obj, new_description);
    }

    // set trait token uri
    public entry fun set_trait_token_uri(
        signer_ref: &signer,
        trait_obj: Object<Trait>,
        new_uri: String
    ) {
        composables::set_trait_uri(signer_ref, trait_obj, new_uri);
    }

    // add a property to a token
    public entry fun add_property_to_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        type: String,
        value: vector<u8>
    ) {
        composables::add_property<T>(signer_ref, token_obj, key, type, value);
    }

    // add a typed property to a token
    public entry fun add_typed_property_to_token<T: key, V: drop>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        value: V
    ) {
        composables::add_typed_property<T, V>(signer_ref, token_obj, key, value);
    }

    // update a property from a token
    public entry fun update_property_from_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        value: vector<u8>
    ) {
        composables::update_property<T>(signer_ref, token_obj, key, value);
    }

    // remove a property from a token
    public entry fun remove_property_from_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String
    ) {
        composables::remove_property<T>(signer_ref, token_obj, key);
    }
}