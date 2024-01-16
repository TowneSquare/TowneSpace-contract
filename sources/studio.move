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
    use aptos_framework::object::{Self, Object};
    
    use aptos_token_objects::collection;

    use std::option;
    // use std::signer;
    use std::string::String;
    use std::vector;

    use townespace::core::{Self, Collection, Composable, Indexed, Named, Trait};

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
        let constructor_ref = core::create_collection<collection::FixedSupply>(
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
        object::object_from_constructor_ref<Collection>(&constructor_ref);
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
        let constructor_ref = core::create_collection<collection::FixedSupply>(
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
        object::object_from_constructor_ref<Collection>(&constructor_ref);
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
        let constructor_ref = core::create_collection<collection::UnlimitedSupply>(
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
        object::object_from_constructor_ref<Collection>(&constructor_ref);
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
        let constructor_ref = core::create_collection<collection::UnlimitedSupply>(
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
        object::object_from_constructor_ref<Collection>(&constructor_ref);
    }

    // Create a named composable token with no royalty
    public entry fun create_named_composable_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Composable, Named>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Composable>(&constructor_ref);
    }

    // Create a named composable token with royalty off
    public entry fun create_named_composable_token_with_royalty_off(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Composable, Named>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Composable>(&constructor_ref);
    }

    // Create an indexed composable token with royalty 
    public entry fun create_indexed_composable_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Composable, Indexed>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::some(royalty_numerator),
            option::some(royalty_denominator),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Composable>(&constructor_ref);
    }

    // Create an indexed composable token with royalty off
    public entry fun create_indexed_composable_token_with_royalty_off(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Composable, Indexed>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Composable>(&constructor_ref);
    }

    // Create a named trait token with no royalty
    public entry fun create_named_trait_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Trait, Named>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Trait>(&constructor_ref);
    }

    // Create a named trait token with royalty
    public entry fun create_named_trait_token_with_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Trait, Named>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
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
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Trait, Indexed>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
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

    // Create an indexed trait token with royalty off
    public entry fun create_indexed_trait_token_with_no_royalty(
        signer_ref: &signer,
        collection: String,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        uri: String,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>
    ) {
        let constructor_ref = core::create_token<Trait, Indexed>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            uri,
            option::none(),
            option::none(),
            property_keys,
            property_types,
            property_values
        );
        // generate the token object
        object::object_from_constructor_ref<Trait>(&constructor_ref);
    }

    // Burn a token
    public entry fun burn_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        core::burn_token<T>(signer_ref, token_obj);
    }

    // Freeze a token
    public entry fun freeze_transfer<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        core::freeze_transfer<T>(signer_ref, token_obj);
    }

    // Unfreeze a token
    public entry fun unfreeze_transfer<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>
    ) {
        core::unfreeze_transfer<T>(signer_ref, token_obj);
    }

    // Equip trait to a composable
    public entry fun equip_trait(
        owner: &signer,
        composable_obj: Object<Composable>,
        trait_obj: Object<Trait>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) { 
        core::equip_trait_internal(owner, composable_obj, trait_obj, new_uri);
    }

    // Equip fungible asset to a trait or composable
    public entry fun equip_fungible_asset<FA: key, TokenType: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<TokenType>,
        amount: u64
    ) {
        core::equip_fa_to_token<FA, TokenType>(signer_ref, fa, token_obj, amount);
    }

    // Unequip trait from a composable
    public entry fun unequip_trait(
        owner: &signer,
        composable_obj: Object<Composable>,
        trait_obj: Object<Trait>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        core::unequip_trait_internal(owner, composable_obj, trait_obj, new_uri);
    }

    // Unequip fungible asset from a trait or composable
    public entry fun unequip_fungible_asset<FA: key, TokenType: key>(
        signer_ref: &signer,
        fa: Object<FA>,
        token_obj: Object<TokenType>,
        amount: u64
    ) {
        core::unequip_fa_from_token<FA, TokenType>(signer_ref, fa, token_obj, amount);
    }

    // Decompose an entire composable token
    // TODO: should be tested
    public entry fun decompose_entire_token(
        owner: &signer,
        composable_obj: Object<Composable>,
        new_uri: String // User should not prompt this! It should be generated by the studio.
    ) {
        // iterate through the vector and unequip traits
        let traits = core::get_traits_from_composable(composable_obj);
        let i = 0;
        // TODO: can be optimized
        while (i < vector::length<Object<Trait>>(&traits)) {
            let trait_obj = *vector::borrow(&traits, i);
            core::unequip_trait_internal(owner, composable_obj, trait_obj, new_uri);
            i = i + 1;
        };
    }

    // Directly transfer a token to a user.
    public entry fun transfer_digital_asset<T: key>(
        owner: &signer, 
        token_address: address,
        new_owner_address: address,
    ) {
        core::transfer_token<T>(owner, token_address, new_owner_address);
    }

    // Directly transfer a token to a user.
    public entry fun transfer_fungible_asset<FA: key>(
        signer_ref: &signer,
        recipient: address,
        fa: Object<FA>,
        amount: u64
    ) {
        core::transfer_fa<FA>(signer_ref, recipient, fa, amount);
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
        core::set_name<T>(signer_ref, token_obj, new_name);
    }

    // set token description
    public entry fun set_token_description<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        new_description: String
    ) {
        core::set_description<T>(signer_ref, token_obj, new_description);
    }

    // set trait token uri
    public entry fun set_trait_token_uri(
        signer_ref: &signer,
        trait_obj: Object<Trait>,
        new_uri: String
    ) {
        core::set_trait_uri(signer_ref, trait_obj, new_uri);
    }

    // add a property to a token
    public entry fun add_property_to_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        type: String,
        value: vector<u8>
    ) {
        core::add_property<T>(signer_ref, token_obj, key, type, value);
    }

    // add a typed property to a token
    public entry fun add_typed_property_to_token<T: key, V: drop>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        value: V
    ) {
        core::add_typed_property<T, V>(signer_ref, token_obj, key, value);
    }

    // update a property from a token
    public entry fun update_property_from_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String,
        value: vector<u8>
    ) {
        core::update_property<T>(signer_ref, token_obj, key, value);
    }

    // remove a property from a token
    public entry fun remove_property_from_token<T: key>(
        signer_ref: &signer,
        token_obj: Object<T>,
        key: String
    ) {
        core::remove_property<T>(signer_ref, token_obj, key);
    }
}