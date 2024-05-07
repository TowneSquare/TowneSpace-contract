/*
*/

module townespace::batch_mint_v2 {

    use aptos_framework::aptos_coin::{AptosCoin as APT};
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_token_objects::collection;
    use aptos_std::simple_map;
    use aptos_std::smart_table::{Self, SmartTable};
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::string_utils;
    use std::type_info;
    use std::vector;
    use composable_token::composable_token::{
        Self, 
        Composable, 
        DA, 
        Trait, 
        Indexed, 
        Collection
    };
    use townespace::common;

    // ------
    // Errors
    // ------

    /// Vector length mismatch
    const ELENGTH_MISMATCH: u64 = 1;
    /// Type not supported
    const ETYPE_NOT_SUPPORTED: u64 = 2;
    /// Insufficient funds
    const EINSUFFICIENT_FUNDS: u64 = 3;
    /// Type not recognized
    const ETYPE_NOT_RECOGNIZED: u64 = 4;

    // ---------
    // Resources
    // ---------

    /// Global storage for the minting metadata
    struct MintInfo has key {
        /// The address of the owner
        owner_addr: address,
        /// The collection associated with the tokens to be minted
        collection: Object<Collection>,
        /// Used for transferring objects
        extend_ref: ExtendRef,
        /// The list of all composables locked up in the contract along with their mint prices
        composable_token_pool: SmartTable<Object<Composable>, u64>,
        /// The list of all traits locked up in the contract along with their mint prices
        trait_pool: SmartTable<Object<Trait>, u64>,
        /// The list of all DAs locked up in the contract along with their mint prices
        da_pool: SmartTable<Object<DA>, u64>,
    }

    // ------
    // Events
    // ------

    #[event]
    struct MintInfoInitialized has drop, store {
        collection: address,
        mint_info_object_address: address,
        owner_addr: address
    }

    #[event]
    struct TokensForMintCreated has drop, store {
        tokens: vector<address>,
    }

    #[event]
    struct TokenMinted has drop, store {
        tokens: vector<address>,
        mint_prices: vector<u64>,
    }

    /// Entry Function to create tokens for minting
    public entry fun create_tokens_for_mint<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        token_count: u64,
        folder_uri: String,
        mint_price: vector<u64>
    ) { 
        let (tokens, mint_info_obj) = create_tokens_for_mint_internal<T>(
            signer_ref,
            collection,
            description,
            name,
            name_with_index_prefix,
            name_with_index_suffix,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
            folder_uri,
            token_count,
            mint_price
        );

        // emit events
        event::emit(
            MintInfoInitialized {
                collection: object::object_address(&collection),
                mint_info_object_address: object::object_address(&mint_info_obj),
                owner_addr: signer::address_of(signer_ref)
            }
        );

        event::emit(TokensForMintCreated { tokens });
    }

    /// Entry Function to mint tokens
    public entry fun mint_tokens<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        count: u64
    ) acquires MintInfo {
        let (minted_tokens, mint_prices) = mint_batch_tokens<T>(signer_ref, mint_info_obj_addr, count);
        event::emit(TokenMinted { tokens: minted_tokens, mint_prices });
    }
    

    // ----------------
    // Helper functions
    // ----------------

    /// Helper function for creating tokens for minting
    public inline fun create_tokens_for_mint_internal<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        folder_uri: String,
        token_count: u64,
        mint_price: vector<u64>
    ): (vector<address>, Object<MintInfo>) {
        // assert token_count is matched with mint_price
        assert!(vector::length(&mint_price) == token_count, ELENGTH_MISMATCH);

        // Build the object to hold the liquid token
        // This must be a sticky object (a non-deleteable object) to be fungible
        let (
            _, 
            extend_ref, 
            object_signer, 
            obj_addr
        ) = common::create_sticky_object(signer::address_of(signer_ref));
        let tokens_addr = if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            // create tokens
            let (tokens, tokens_addr) = create_tokens_internal<Composable>(
                signer_ref,
                obj_addr,
                collection,
                description,
                name,
                name_with_index_prefix,
                name_with_index_suffix,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values,
                folder_uri,
                token_count,
            );
            let composable_token_pool = smart_table::new<Object<Composable>, u64>();
            // add tokens and mint_price to the composable_token_pool
            smart_table::add_all(&mut composable_token_pool, tokens, mint_price);
            // Add the Metadata
            move_to(
                &object_signer, 
                    MintInfo {
                        owner_addr: signer::address_of(signer_ref),
                        collection, 
                        extend_ref, 
                        composable_token_pool,
                        trait_pool: smart_table::new<Object<Trait>, u64>(),
                        da_pool: smart_table::new<Object<DA>, u64>()
                    }
            );

            tokens_addr
        
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let (tokens, tokens_addr) = create_tokens_internal<Trait>(
                signer_ref,
                obj_addr,
                collection,
                description,
                name,
                name_with_index_prefix,
                name_with_index_suffix,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values,
                folder_uri,
                token_count
            );
            let trait_pool = smart_table::new();
            // add tokens and mint_price to the trait_pool
            smart_table::add_all(&mut trait_pool, tokens, mint_price);
            // Add the Metadata
            move_to(
                &object_signer, 
                    MintInfo {
                        owner_addr: signer::address_of(signer_ref),
                        collection, 
                        extend_ref, 
                        composable_token_pool: smart_table::new<Object<Composable>, u64>(),
                        trait_pool,
                        da_pool: smart_table::new<Object<DA>, u64>()
                    }
            );

            tokens_addr
        } else {
            let da_pool = smart_table::new<Object<DA>, u64>();
            let (tokens, tokens_addr) = create_tokens_internal<DA>(
                signer_ref,
                obj_addr,
                collection,
                description,
                name,
                name_with_index_prefix,
                name_with_index_suffix,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values,
                folder_uri,
                token_count
            );
            // add tokens and mint_price to the da_pool
            smart_table::add_all(&mut da_pool, tokens, mint_price);
            // Add the Metadata
            move_to(
                &object_signer, 
                    MintInfo {
                        owner_addr: signer::address_of(signer_ref),
                        collection, 
                        extend_ref, 
                        composable_token_pool: smart_table::new<Object<Composable>, u64>(),
                        trait_pool: smart_table::new<Object<Trait>, u64>(),
                        da_pool
                    }
            );

            tokens_addr
        };
        // tokens objects, tokens addresses, object address holding the mint info
        (tokens_addr, object::address_to_object(obj_addr))
    }

    /// Helper function for creating tokens
    inline fun create_tokens_internal<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        collection: Object<Collection>,
        description: String,
        name: String,
        name_with_index_prefix: String,
        name_with_index_suffix: String,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
        folder_uri: String,
        token_count: u64,
    ): (vector<Object<T>>, vector<address>) {
        let tokens = vector::empty<Object<T>>();
        let tokens_addr = vector::empty();

        // mint tokens
        let first_index = 1 + *option::borrow(&collection::count(collection));
        let last_index = first_index + token_count;
        for (i in first_index..last_index) {
            let token_uri = folder_uri;
            // folder_uri + "/" + i + ".png"
            string::append_utf8(&mut token_uri, b"/");
            string::append(&mut token_uri, string_utils::to_string(&i));
            string::append_utf8(&mut token_uri, b".png");

            let (constructor) = composable_token::create_token<T, Indexed>(
                signer_ref,
                collection,
                description,
                name,
                name_with_index_prefix,
                name_with_index_suffix,
                token_uri,
                royalty_numerator,
                royalty_denominator,
                property_keys,
                property_types,
                property_values
            );

            vector::push_back(&mut tokens, object::object_from_constructor_ref<T>(&constructor));
            vector::push_back(&mut tokens_addr, object::address_from_constructor_ref(&constructor));

            // transfer the token to mint info object
            composable_token::transfer_token<T>(
                signer_ref,
                object::object_from_constructor_ref(&constructor), 
                mint_info_obj_addr
            );
        };

        (tokens, tokens_addr)
    }

    /// Gets Keys from a smart table and returns a new smart table with with the pair <u64, address> and u64 is the index
    inline fun indexed_tokens<T: key> (
        smart_table: &SmartTable<Object<T>, u64>
    ): SmartTable<u64, address> {
        let indexed_tokens = smart_table::new<u64, address>();
        // create a simple map from the input smart table
        let simple_map = smart_table::to_simple_map(smart_table);
        // create a vector of keys
        let tokens = simple_map::keys(&simple_map);
        for (i in 0..smart_table::length(smart_table)) {
            // add the pair "i, tokens(i)" to the indexed_tokens
            let token_addr = object::object_address(vector::borrow(&tokens, i));
            smart_table::add(&mut indexed_tokens, i, token_addr);
        };

        indexed_tokens
    }
    

    /// Helper function for getting the mint_price of a token
    inline fun mint_price<T: key>(
        mint_info: &mut MintInfo,
        mint_info_obj_addr: address,
        token: Object<T>
    ): u64 acquires MintInfo {
        if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            let composable_token = object::convert<T, Composable>(token);
            *smart_table::borrow<Object<Composable>, u64>(&mint_info.composable_token_pool, composable_token)
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            let trait = object::convert<T, Trait>(token);
            *smart_table::borrow<Object<Trait>, u64>(&mint_info.trait_pool, trait)
        } else {
            let da = object::convert<T, DA>(token);
            *smart_table::borrow<Object<DA>, u64>(&mint_info.da_pool, da)
        }
    }

    /// Helper function for minting a token
    /// Returns the address of the minted token and the mint price
    public inline fun mint_token<T: key>(signer_ref: &signer, mint_info_obj_addr: address): (address, u64) acquires MintInfo {
        let signer_addr = signer::address_of(signer_ref);
        assert!(
            type_info::type_of<T>() == type_info::type_of<Composable>()
            || type_info::type_of<T>() == type_info::type_of<Trait>()
            || type_info::type_of<T>() == type_info::type_of<DA>(), 
            ETYPE_NOT_RECOGNIZED
        );
        // remove the token from the mint info
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        let (token_addr, mint_price) = if (type_info::type_of<T>() == type_info::type_of<Composable>()) {
            // get random token from the composable_token_pool
            let pool = indexed_tokens<Composable>(&mint_info.composable_token_pool);
            let i = common::pseudorandom_u64(smart_table::length<u64, address>(&pool));
            let token_addr = *smart_table::borrow<u64, address>(&pool, i);
            let composable = object::convert<T, Composable>(object::address_to_object(token_addr));
            smart_table::destroy(pool);
            // get mint price
            let mint_price = mint_price<Composable>(mint_info, mint_info_obj_addr, object::address_to_object<Composable>(token_addr));
            assert!(coin::balance<APT>(signer_addr) >= mint_price, EINSUFFICIENT_FUNDS);
            (token_addr, smart_table::remove(&mut mint_info.composable_token_pool, composable))
        } else if (type_info::type_of<T>() == type_info::type_of<Trait>()) {
            // get random token from the trait_pool
            let pool = indexed_tokens<Trait>(&mint_info.trait_pool);
            let i = common::pseudorandom_u64(smart_table::length<u64, address>(&pool));
            let token_addr = *smart_table::borrow<u64, address>(&pool, i);
            let trait = object::convert<T, Trait>(object::address_to_object(token_addr));
            smart_table::destroy(pool);
            // get mint price
            let mint_price = mint_price<Trait>(mint_info, mint_info_obj_addr, object::address_to_object<Trait>(token_addr));
            assert!(coin::balance<APT>(signer_addr) >= mint_price, EINSUFFICIENT_FUNDS);
            (token_addr, smart_table::remove(&mut mint_info.trait_pool, trait))
        } else {
            // get random token from the da_pool
            let pool = indexed_tokens<DA>(&mint_info.da_pool);
            let i = common::pseudorandom_u64(smart_table::length<u64, address>(&pool));
            let token_addr = *smart_table::borrow<u64, address>(&pool, i);
            let da = object::convert<T, DA>(object::address_to_object(token_addr));
            smart_table::destroy(pool);
            // get mint price
            let mint_price = mint_price<DA>(mint_info, mint_info_obj_addr, object::address_to_object<DA>(token_addr));
            assert!(coin::balance<APT>(signer_addr) >= mint_price, EINSUFFICIENT_FUNDS);
            (token_addr, smart_table::remove(&mut mint_info.da_pool, da))
        };
        // transfer composable from resource acc to the minter
        let obj_signer = object::generate_signer_for_extending(&mint_info.extend_ref);
        composable_token::transfer_token<T>(
            &obj_signer, 
            object::address_to_object(token_addr), 
            signer_addr
        );
        // transfer mint price to the launchpad creator
        coin::transfer<APT>(signer_ref, mint_info.owner_addr, mint_price);

        (token_addr, mint_price)
    }

    /// Helper function for minting a batch of tokens
    public inline fun mint_batch_tokens<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        count: u64
    ): (vector<address>, vector<u64>) acquires MintInfo {
        let minted_tokens = vector::empty<address>();
        let mint_prices = vector::empty<u64>();
        for (i in 0..count) {
            let (token_addr, mint_price) = mint_token<T>(signer_ref, mint_info_obj_addr);
            vector::push_back(&mut minted_tokens, token_addr);
            vector::push_back(&mut mint_prices, mint_price);
        };

        (minted_tokens, mint_prices)
    }

    /// TODO: add tokens to the mint info
    

    // ------------
    // Unit Testing
    // ------------

    #[test_only]
    use std::debug;
    #[test_only]
    use aptos_token_objects::collection::{FixedSupply};

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    fun test_nft_e2e(std: &signer, creator: &signer, minter: &signer) acquires MintInfo {
        let input_mint_price = 1000;

        let (creator_addr, minter_addr) = common::setup_test(std, creator, minter);
        let creator_balance_before_mint = coin::balance<APT>(signer::address_of(creator));
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        // creator creates a collection
        let collection_constructor_ref = composable_token::create_collection<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(100),
            string::utf8(b"Collection Name"),
            string::utf8(b"Collection Symbol"),
            string::utf8(b"Collection URI"),
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

        // creator creates tokens for minting
        let (tokens, mint_info_obj) = create_tokens_for_mint_internal<Composable>(
            creator,
            object::object_from_constructor_ref(&collection_constructor_ref),
            string::utf8(b"Description"),
            string::utf8(b"Name"),
            string::utf8(b"Name with Index Prefix"),
            string::utf8(b"Name with Index Suffix"),
            option::none(),
            option::none(),
            vector[],
            vector[],
            vector[],
            string::utf8(b"Folder URI"),
            4,
            vector[input_mint_price, input_mint_price, input_mint_price, input_mint_price]
        );

        // minter mints tokens
        let (minted_tokens, mint_prices) = mint_batch_tokens<Composable>(minter, object::object_address(&mint_info_obj), 4);


        // assert the owner is the minter
        let token = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 0));
        assert!(object::is_owner(token, minter_addr), 1);
        // assert the mint price is sent to the owner
        let creator_balance_after_mint = creator_balance_before_mint + (input_mint_price * 4);
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        assert!(coin::balance<APT>(creator_addr) == creator_balance_after_mint, 2);
    }
}