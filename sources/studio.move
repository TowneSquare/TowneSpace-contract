/*
    - This module is a no-code implementation for the composability contract.
    - It is responsible for creating collections, creating tokens,
    and composing and decomposing tokens.
    - It is also responsible for transferring tokens.

    TODO:
        - add a view function to get all active capabilities for a given collection
        - add a view function to get all active capabilities for a given token

*/

module townespace::studio {
    use aptos_framework::object;

    use aptos_token_objects::collection;

    use std::option;
    use std::signer;
    use std::string;
    use std::vector;

    use townespace::core;

    // ---------------
    // Entry Functions
    // ---------------
    
    // Create a new collection with fixed supply and royalty on
    public entry fun create_collection_with_fixed_supply_and_royalty(
        signer_ref: &signer,
        description: string::String,
        max_supply: u64, 
        name: string::String,
        symbol: string::String,
        uri: string::String,   
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
        object::object_from_constructor_ref<core::Collection>(&constructor_ref);
    }

    // Create a new collection with fixed supply and royalty off
    public entry fun create_collection_with_fixed_supply_and_royalty_off(
        signer_ref: &signer,
        description: string::String,
        max_supply: u64, 
        name: string::String,
        symbol: string::String,
        uri: string::String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
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
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::none(),
            option::none()
        );
        // generate the collection object
        object::object_from_constructor_ref<core::Collection>(&constructor_ref);
    }

    // Create a new collection with unlimited supply and royalty on
    public entry fun create_collection_with_unlimited_supply_and_royalty(
        signer_ref: &signer,
        description: string::String,
        name: string::String,
        symbol: string::String,
        uri: string::String,   
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
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::some(royalty_numerator),
            option::some(royalty_denominator)
        );
        // generate the collection object
        object::object_from_constructor_ref<core::Collection>(&constructor_ref);
    }

    // Create a new collection with unlimited supply and royalty off
    public entry fun create_collection_with_unlimited_supply_and_royalty_off(
        signer_ref: &signer,
        description: string::String,
        name: string::String,
        symbol: string::String,
        uri: string::String,   
        mutable_description: bool,
        mutable_royalty: bool,
        mutable_uri: bool,
        mutable_token_description: bool,
        mutable_token_name: bool,
        mutable_token_properties: bool,
        mutable_token_uri: bool,
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
            mutable_token_uri,
            tokens_burnable_by_creator,
            tokens_freezable_by_creator,
            option::none(),
            option::none()
        );
        // generate the collection object
        object::object_from_constructor_ref<core::Collection>(&constructor_ref);
    }
}