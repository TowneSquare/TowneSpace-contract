/*
    Minter module for creating collections and NFTs powered by the digital asset standard.
*/

module townespace::mint {

    use aptos_framework::aptos_coin::{AptosCoin as APT};
    use aptos_framework::coin;
    use aptos_framework::object;

    use aptos_std::type_info;

    use aptos_token_objects::collection::{FixedSupply, UnlimitedSupply};
    use aptos_token_objects::token::{Self, Token as TokenV2};

    use std::option;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use townespace::core::{Self, Composable, Trait};
    use townespace::errors;
    use townespace::events;
    use townespace::resource_manager;

    public entry fun initialize(signer_ref: &signer) {
        // assert that the signer is the owner of the module
        assert!(signer::address_of(signer_ref) == @townespace, errors::not_townespace());
        // init resource
        resource_manager::initialize(signer_ref);
    }

    // -------------------------
    // Creator related functions
    // -------------------------

    // create a new collection given metadata and a total number of supply (if it's a fixed supply collection).
    public entry fun create_fixed_supply_collection(
        creator_signer: &signer,
        description: String,
        max_supply: u64, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        is_burnable: bool,
        is_mutable: bool
    ) {
        let collection_obj = core::create_collection_internal<FixedSupply>(
            creator_signer,
            description,
            option::some(max_supply),
            name,
            symbol,
            uri,
            royalty_numerator,
            royalty_denominator,
            is_burnable,
            is_mutable
        );

        events::emit_collection_created_event(
            signer::address_of(creator_signer),
            events::collection_metadata(collection_obj)
        );
    }

    public entry fun create_unlimited_supply_collection(
        creator_signer: &signer,
        description: String,
        name: String,
        symbol: String,
        uri: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
        is_burnable: bool,
        is_mutable: bool
    ) {
        let collection_obj = core::create_collection_internal<UnlimitedSupply>(
            creator_signer,
            description,
            option::none<u64>(),
            name,
            symbol,
            uri,
            royalty_numerator,
            royalty_denominator,
            is_burnable,
            is_mutable
        );

        events::emit_collection_created_event(
            signer::address_of(creator_signer),
            events::collection_metadata(collection_obj)
        );
    }

    // mint NFTs given a metadata and a number of tokens to mint; can either mint traits or composables.
    public entry fun create_composable_tokens(
        creator_signer: &signer,
        collection_name: String,
        number_of_tokens_to_mint: u64,
        description: String,
        uri: String,  
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ) {
        let escrow_addr = resource_manager::get_resource_address();
        let i = 0;
        while (i < number_of_tokens_to_mint) {
            let token_object = core::create_token_internal<Composable>(
                creator_signer,
                collection_name,
                description,
                uri, 
                string::utf8(b""),
                vector::empty(),
                base_mint_price,
                royalty_numerator,
                royalty_denominator
            );

            let obj_addr = object::object_address<Composable>(&token_object);
        
            events::emit_composable_token_created_event(
                signer::address_of(creator_signer),
                events::composable_token_metadata(token_object)
            );

            core::transfer_token<Composable>(creator_signer, obj_addr, escrow_addr);

            i = i + 1;
        }   
    }

    public entry fun create_trait_tokens(
        creator_signer: &signer,
        collection_name: String,
        number_of_tokens_to_mint: u64,
        description: String,
        type: String,
        uri: String,
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ) {
        let escrow_addr = resource_manager::get_resource_address();
        let i = 0;
        while (i < number_of_tokens_to_mint) {
            let token_object = core::create_token_internal<Trait>(
                creator_signer,
                collection_name,
                description,
                uri, 
                type,
                vector::empty(),
                base_mint_price,
                royalty_numerator,
                royalty_denominator
            );

            let obj_addr = object::object_address<Trait>(&token_object);
        
            events::emit_trait_token_created_event(
                signer::address_of(creator_signer),
                events::trait_token_metadata(token_object)
            );

            // transfer to the resource account
            core::transfer_token<Trait>(creator_signer, obj_addr, escrow_addr);

            i = i + 1;
        }
    }

    // ------------------------
    // Minter related functions
    // ------------------------

    // Assuming an NFT is already creater and transfers it to the minter/caller
    public entry fun mint_token<Type: key>(signer_ref: &signer, token_addr: address) {
        let signer_addr = signer::address_of(signer_ref);
        let creator_addr = get_creator_addr_from_token_addr(token_addr);
        assert!(
            type_info::type_of<Type>() == type_info::type_of<Composable>() || type_info::type_of<Type>() == type_info::type_of<Trait>(), 
            errors::type_not_recognized()
        );
        // get mint price
        let mint_price = core::get_base_mint_price<Type>(token_addr);
        assert!(coin::balance<APT>(signer_addr) >= mint_price, errors::insufficient_funds());
        // transfer composable from resource acc to the minter
        let resource_signer = &resource_manager::get_signer();
        core::transfer_token<Type>(resource_signer, token_addr, signer_addr);
        // transfer mint price to creator
        coin::transfer<APT>(signer_ref, creator_addr, mint_price);
    }

    // ----------------
    // Helper functions
    // ----------------

    inline fun get_creator_addr_from_token_addr(token_addr: address): address {
        let token_obj = object::address_to_object<TokenV2>(token_addr);
        token::creator<TokenV2>(token_obj)
    }

    #[test_only]
    public fun init_test(signer_ref: &signer) {
        // assert that the signer is the owner of the module
        assert!(signer::address_of(signer_ref) == @townespace, errors::not_townespace());
        // init resource
        resource_manager::initialize(signer_ref);
    }

    #[test_only]
    public fun create_composables_and_return_addresses_test(
        creator_signer: &signer,
        collection_name: String,
        number_of_tokens_to_mint: u64,
        description: String,
        uri: String,
        base_mint_price: u64,
        royalty_numerator: u64,
        royalty_denominator: u64
    ): vector<address> {
        let created_composables = vector::empty<address>();
        let escrow_addr = resource_manager::get_resource_address();
        let i = 0;
        while (i < number_of_tokens_to_mint) {
            let token_object = core::create_token_internal<Composable>(
                creator_signer,
                collection_name,
                description,
                uri, 
                string::utf8(b""),
                vector::empty(),
                base_mint_price,
                royalty_numerator,
                royalty_denominator
            );

            let obj_addr = object::object_address<Composable>(&token_object);
            core::transfer_token<Composable>(creator_signer, obj_addr, escrow_addr);
            i = i + 1;

            vector::push_back(&mut created_composables, obj_addr);
        };
        
        // return the addresses of the created composables
        created_composables
    }
}