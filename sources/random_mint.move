/*

    TODO: 
        - smart tables holding the tokens to mint must have size pre-defined?
        - create tokens ready for mint can be the same as in unveil
        - refactor module name; must be more accurate
        - Add a global storage for the tracking tokens supply per type
        - Handle when the caller wants to mint more than it is available
*/

module townespace::random_mint {

    use aptos_framework::aptos_coin::{AptosCoin as APT};
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_std::simple_map;
    use aptos_std::smart_table::{Self, SmartTable};
    use composable_token::composable_token::{
        Self, 
        Composable,
        Collection
    };
    use std::option::{Option};
    use std::signer;
    use std::string::{String};
    use std::vector;
    use townespace::studio;
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
        token_pool: SmartTable<address, u64>,
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
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        vec_mint_price: vector<u64>,
        token_count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) { 
        let (token_addrs, mint_info_object_address, _) = create_tokens_for_mint_internal<T>(
            signer_ref,
            collection,
            description,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            vec_mint_price,
            token_count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values
        );

        // emit events
        event::emit(
            MintInfoInitialized {
                collection: object::object_address(&collection),
                mint_info_object_address,
                owner_addr: signer::address_of(signer_ref)
            }
        );

        event::emit(TokensForMintCreated { tokens: token_addrs });
    }

    #[lint::allow_unsafe_randomness]
    /// Entry Function to mint tokens
    public entry fun mint_tokens<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        count: u64
    ) acquires MintInfo {
        let (minted_tokens, mint_prices, _) = mint_batch_tokens<T>(signer_ref, mint_info_obj_addr, count);
        event::emit(TokenMinted { tokens: minted_tokens, mint_prices });
    }

    /// Entry function for adding more tokens for minting
    public entry fun add_tokens_for_mint<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        mint_info_obj_addr: address,
        description: String,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        vec_mint_price: vector<u64>,
        token_count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ) acquires MintInfo {
        add_tokens_for_mint_internal<T>(
            signer_ref,
            collection,
            mint_info_obj_addr,
            description,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            vec_mint_price,
            token_count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values
        );
    }
    

    // ----------------
    // Helper functions
    // ----------------

    /// Helper function for creating tokens for minting
    public fun create_tokens_for_mint_internal<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        vec_mint_price: vector<u64>,
        token_count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): (vector<address>, address, vector<object::ConstructorRef>) {

        // Build the object to hold the liquid token
        // This must be a sticky object (a non-deleteable object) to be fungible
        let (
            _, 
            extend_ref, 
            object_signer, 
            obj_addr
        ) = common::create_sticky_object(signer::address_of(signer_ref));
        // create tokens
        let constructor_refs = create_tokens_internal<T>(
            signer_ref,
            collection,
            description,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            token_count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
        );

        let token_addrs = vector::empty<address>();
        
        for (i in 0..vector::length(&constructor_refs)) {
            // transfer
            composable_token::transfer_token<T>(
                signer_ref,
                object::object_from_constructor_ref(vector::borrow(&constructor_refs, i)),
                obj_addr
            );
            vector::push_back(
                &mut token_addrs, 
                object::address_from_constructor_ref(vector::borrow(&constructor_refs, i))
            );
        };
        
        let token_pool = smart_table::new<address, u64>();
        // add tokens and mint_price to the token_pool
        smart_table::add_all(&mut token_pool, token_addrs, vec_mint_price);
        // Add the Metadata
        move_to(
            &object_signer, 
                MintInfo {
                    owner_addr: signer::address_of(signer_ref),
                    collection, 
                    extend_ref, 
                    token_pool,
                }
        );
        // tokens addresses, object address holding the mint info and constructor refs for the tokens
        (token_addrs, obj_addr, constructor_refs)
    }

    /// Helper function to create tokens without a mint pool
    fun create_tokens_without_mint_pool<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): (vector<Object<T>>, vector<address>, vector<object::ConstructorRef>) {

        // mint the tokens
        let constructor_refs = create_tokens_internal<T>(
            signer_ref,
            collection,
            description,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
        );

        let token_objs = vector::empty<Object<T>>();
        let token_addrs = vector::empty<address>();

        for (i in 0..count) {
            vector::push_back(
                &mut token_objs, 
                object::object_from_constructor_ref(vector::borrow(&constructor_refs, i))
            );
            vector::push_back(
                &mut token_addrs, 
                object::address_from_constructor_ref(vector::borrow(&constructor_refs, i))
            );
        };

        (token_objs, token_addrs, constructor_refs)
    }

    /// Helper function to create tokens
    fun create_tokens_internal<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        description: String,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): vector<object::ConstructorRef> {
        // mint the tokens and return their constructor refs
        let descriptions = vector::empty<String>();
        for (i in 0..count) { vector::push_back(&mut descriptions, description) };
        studio::create_batch_internal<T>(
            signer_ref,
            collection,
            descriptions,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
        )
    }

    /// Gets Keys from a smart table and returns a new smart table with with the pair <u64, address> and u64 is the index
    fun indexed_tokens (
        smart_table: &SmartTable<address, u64>
    ): SmartTable<u64, address> {
        let indexed_tokens = smart_table::new<u64, address>();
        // create a simple map from the input smart table
        let simple_map = smart_table::to_simple_map(smart_table);
        // create a vector of keys
        let token_addrs = simple_map::keys(&simple_map);
        for (i in 0..smart_table::length(smart_table)) {
            // add the pair "i, tokens(i)" to the indexed_tokens
            let token_addr = *vector::borrow(&token_addrs, i);
            smart_table::add(&mut indexed_tokens, i, token_addr);
        };

        indexed_tokens
    }
    

    /// Helper function for getting the mint_price of a token
    inline fun mint_price(
        mint_info_obj_addr: address,
        token: address
    ): u64 acquires MintInfo {
        let mint_info = borrow_global<MintInfo>(mint_info_obj_addr);
        *smart_table::borrow<address, u64>(&mint_info.token_pool, token)
    }

    /// Helper function for getting a random token from a smart table
    inline fun random_token(
        mint_info_obj_addr: address
    ): (address, u64) {
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        let pool = indexed_tokens(&mint_info.token_pool);
        let i = common::pseudorandom_u64(smart_table::length<u64, address>(&pool));
        let token_addr = *smart_table::borrow<u64, address>(&pool, i);
        smart_table::destroy(pool);

        (token_addr, i)
    }

    /// Helper function for getting a token at a given index
    inline fun token_at_index(
        mint_info_obj_addr: address,
        index: u64
    ): address {
        let mint_info = borrow_global<MintInfo>(mint_info_obj_addr);
        let pool = indexed_tokens(&mint_info.token_pool);
        let token_addr = *smart_table::borrow<u64, address>(&pool, index);
        smart_table::destroy(pool);
        token_addr
    }

    #[lint::allow_unsafe_randomness]
    /// Helper function for minting a token
    /// Returns the address of the minted token and the mint price
    public fun mint_token<T: key>(signer_ref: &signer, mint_info_obj_addr: address): (address, u64, u64) acquires MintInfo {
        let signer_addr = signer::address_of(signer_ref);
        // remove the token from the mint info
        // get random token from the token_pool
        let (token_addr, index) = random_token(mint_info_obj_addr);
        // get mint price
        let mint_price = mint_price(mint_info_obj_addr, token_addr);
        assert!(coin::balance<APT>(signer_addr) >= mint_price, EINSUFFICIENT_FUNDS);
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        smart_table::remove(&mut mint_info.token_pool, token_addr);

        // transfer composable from resource acc to the minter
        let mint_info = borrow_global<MintInfo>(mint_info_obj_addr);
        let obj_signer = object::generate_signer_for_extending(&mint_info.extend_ref);
        object::transfer_call(&obj_signer, token_addr, signer_addr);
        // transfer mint price to the launchpad creator
        coin::transfer<APT>(signer_ref, mint_info.owner_addr, mint_price);

        (token_addr, mint_price, index)
    }

    /// Helper function to mint a token at a given index
    public fun mint_token_at_index<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        index: u64
    ): (address, u64) acquires MintInfo {
        let signer_addr = signer::address_of(signer_ref);
        let token_addr = token_at_index(mint_info_obj_addr, index);
        let mint_price = mint_price(mint_info_obj_addr, token_addr);
        assert!(coin::balance<APT>(signer_addr) >= mint_price, EINSUFFICIENT_FUNDS);
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        smart_table::remove(&mut mint_info.token_pool, token_addr);

        // transfer composable from resource acc to the minter
        let obj_signer = object::generate_signer_for_extending(&mint_info.extend_ref);
        object::transfer_call(&obj_signer, token_addr, signer_addr);
        // transfer mint price to the launchpad creator
        coin::transfer<APT>(signer_ref, mint_info.owner_addr, mint_price);

        (token_addr, mint_price)
    }

    #[lint::allow_unsafe_randomness]
    /// Helper function for minting a batch of tokens
    public fun mint_batch_tokens<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        count: u64
    ): (vector<address>, vector<u64>, vector<u64>) acquires MintInfo {
        let minted_tokens = vector::empty<address>();
        let mint_prices = vector::empty<u64>();
        let indices = vector::empty<u64>();
        for (i in 0..count) {
            let (token_addr, mint_price, index) = mint_token<T>(signer_ref, mint_info_obj_addr);
            vector::push_back(&mut minted_tokens, token_addr);
            vector::push_back(&mut mint_prices, mint_price);
            vector::push_back(&mut indices, index);
        };

        (minted_tokens, mint_prices, indices)
    }

    /// Helper function to mint a batch of tokens at given indices
    public fun mint_batch_tokens_at_indices<T: key>(
        signer_ref: &signer,
        mint_info_obj_addr: address,
        indices: vector<u64>
    ): (vector<address>, vector<u64>) acquires MintInfo {
        let minted_tokens = vector::empty<address>();
        let mint_prices = vector::empty<u64>();
        for (i in 0..vector::length(&indices)) {
            let (token_addr, mint_price) = mint_token_at_index<T>(signer_ref, mint_info_obj_addr, *vector::borrow(&indices, i));
            vector::push_back(&mut minted_tokens, token_addr);
            vector::push_back(&mut mint_prices, mint_price);
        };

        (minted_tokens, mint_prices)
    }

    /// Helper function to create more tokens and add them to the mint_info
    public fun add_tokens_for_mint_internal<T: key>(
        signer_ref: &signer,
        collection: Object<Collection>,
        mint_info_obj_addr: address,
        description: String,
        uri: vector<String>,
        name_with_index_prefix: vector<String>,
        name_with_index_suffix: vector<String>,
        vec_mint_price: vector<u64>,
        token_count: u64,
        royalty_numerator: Option<u64>,
        royalty_denominator: Option<u64>,
        property_keys: vector<String>,
        property_types: vector<String>,
        property_values: vector<vector<u8>>,
    ): (vector<address>, vector<object::ConstructorRef>) acquires MintInfo {
        // creates tokens
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        // create tokens
        let constructor_refs = create_tokens_internal<Composable>(
            signer_ref,
            collection,
            description,
            uri,
            name_with_index_prefix,
            name_with_index_suffix,
            token_count,
            royalty_numerator,
            royalty_denominator,
            property_keys,
            property_types,
            property_values,
        );
        let token_addrs = vector::empty<address>();
        for (i in 0..vector::length(&constructor_refs)) {
            // transfer
            let token_addr = object::address_from_constructor_ref(vector::borrow(&constructor_refs, i));
            object::transfer_call(signer_ref, token_addr, mint_info_obj_addr);
            vector::push_back(&mut token_addrs, token_addr);
        };
        // add tokens and mint_price to the token_pool
        smart_table::add_all(&mut mint_info.token_pool, token_addrs, vec_mint_price);

        (token_addrs, constructor_refs)
    } 
    
    
    // --------------
    // View Functions
    // --------------
   
    #[view]
    /// Get a list of tokens available for minting
    public fun tokens_for_mint<T: key>(
        mint_info_obj_addr: address
    ): vector<address> acquires MintInfo {
        let token_addrs = vector::empty<address>();
        let mint_info = borrow_global_mut<MintInfo>(mint_info_obj_addr);
        let token_pool = indexed_tokens(&mint_info.token_pool);
        for (i in 0..smart_table::length<u64, address>(&token_pool)) {
            let token_addr = *smart_table::borrow<u64, address>(&token_pool, i);
            vector::push_back(&mut token_addrs, token_addr);
        };
        smart_table::destroy(token_pool);
        token_addrs
    }
    

    // ------------
    // Unit Testing
    // ------------

    #[test_only]
    use std::debug;
    #[test_only]
    use std::string;
    #[test_only]
    use std::option;
    #[test_only]
    use aptos_token_objects::collection::{FixedSupply};
    #[test_only]
    use aptos_token_objects::token;
    #[test_only]
    use aptos_framework::randomness;
    #[test_only]
    const URI_PREFIX: vector<u8> = b"Token%20Name%20Prefix%20";
    #[test_only]
    const PREFIX: vector<u8> = b"Prefix #"; 
    #[test_only]
    const SUFFIX : vector<u8> = b" Suffix";

    #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    fun test_e2e(std: &signer, creator: &signer, minter: &signer) acquires MintInfo {
        let input_mint_price = 1000;

        let (creator_addr, minter_addr) = common::setup_test(std, creator, minter);
        let creator_balance_before_mint = coin::balance<APT>(signer::address_of(creator));
        // init randomness
        randomness::initialize_for_testing(std);
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        // creator creates a collection
        let collection_constructor_ref = studio::create_collection_with_tracker_internal<FixedSupply>(
            creator,
            string::utf8(b"Collection Description"),
            option::some(1000),
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

        // Add base type to the tracker
        let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
        studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Base"), 25);
        studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Body"), 25);
        studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Sloth"), 25);

        // creator creates tokens for minting
        let (token_addrs, mint_info_object_address, composable_constructor_refs) = create_tokens_for_mint_internal<Composable>(
            creator,
            object::object_from_constructor_ref(&collection_constructor_ref),
            string::utf8(b"Sloth"),
            vector[
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base"),
                string::utf8(b"Base")
            ],
            vector[
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth"),
                string::utf8(b"Cool%20Sloth")
            ],
            vector[
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"),
                string::utf8(b"Cool Sloth")
            ],
            vector[1000, 1000, 1000, 1000],
            4,
            option::none(),
            option::none(),
            vector[],
            vector[],
            vector[]
        );

        // minter mints tokens
        let (minted_tokens, _, _) = mint_batch_tokens<Composable>(minter, mint_info_object_address, 4);

        // assert the owner is the minter
        let token_0 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 0));
        let token_1 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 1));
        let token_2 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 2));
        let token_3 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 3));

        assert!(object::is_owner(token_0, minter_addr), 1);
        assert!(object::is_owner(token_1, minter_addr), 1);
        assert!(object::is_owner(token_2, minter_addr), 1);
        assert!(object::is_owner(token_3, minter_addr), 1);

        // assert the mint price is sent to the owner
        let creator_balance_after_mint = creator_balance_before_mint + (input_mint_price * 4);
        // debug::print<u64>(&coin::balance<APT>(creator_addr));
        assert!(coin::balance<APT>(creator_addr) == creator_balance_after_mint, 2);

        // // get one token and print its name and uri
        // debug::print<String>(&token::name<Composable>(token_0));
        // debug::print<String>(&token::name<Composable>(token_1));
        // debug::print<String>(&token::name<Composable>(token_2));
        // debug::print<String>(&token::name<Composable>(token_3));

        // debug::print<String>(&token::uri<Composable>(token_0));
        // debug::print<String>(&token::uri<Composable>(token_1));
        // debug::print<String>(&token::uri<Composable>(token_2));
        // debug::print<String>(&token::uri<Composable>(token_3));

        // create more tokens for minting
        add_tokens_for_mint_internal<Composable>(
            creator,
            object::object_from_constructor_ref(&collection_constructor_ref),
            mint_info_object_address,
            string::utf8(b"Sloth"),
            vector[
                string::utf8(b"Cool%20Sloth%201"),
                string::utf8(b"Cool%20Sloth%202"),
                string::utf8(b"Cool%20Sloth%203"),
                string::utf8(b"Cool%20Sloth%204")
            ],
            vector[
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"),
                string::utf8(b"Cool Sloth")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b"")
            ],
            vector[1000, 1000, 1000, 1000],
            
            4,
            option::none(),
            option::none(),
            vector[],
            vector[],
            vector[]
        );

        // mint the newly created tokens
        let (minted_tokens, _, _) = mint_batch_tokens<Composable>(minter, mint_info_object_address, 4);

        // assert the owner is the minter
        let token_4 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 0));
        let token_5 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 1));
        let token_6 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 2));
        let token_7 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 3));

        assert!(object::is_owner(token_4, minter_addr), 3);
        assert!(object::is_owner(token_5, minter_addr), 3);
        assert!(object::is_owner(token_6, minter_addr), 3);
        assert!(object::is_owner(token_7, minter_addr), 3);

        // assert the mint price is sent to the owner
        let creator_balance_after_mint = creator_balance_after_mint + (input_mint_price * 4);
        assert!(coin::balance<APT>(creator_addr) == creator_balance_after_mint, 4);

        // get one token and print its name and uri
        debug::print<String>(&string::utf8(b"COMPOSABLES NAMES:"));
        debug::print<String>(&token::name<Composable>(token_4));
        debug::print<String>(&token::name<Composable>(token_5));
        debug::print<String>(&token::name<Composable>(token_6));
        debug::print<String>(&token::name<Composable>(token_7));

        debug::print<String>(&string::utf8(b"COMPOSABLES URIS:"));
        debug::print<String>(&token::uri<Composable>(token_4));
        debug::print<String>(&token::uri<Composable>(token_5));
        debug::print<String>(&token::uri<Composable>(token_6));
        debug::print<String>(&token::uri<Composable>(token_7));

        // add more tokens for minting
        add_tokens_for_mint_internal<Composable>(
            creator,
            object::object_from_constructor_ref(&collection_constructor_ref),
            mint_info_object_address,
            string::utf8(b"Sloth"),
            vector[
                string::utf8(b"Cool%20Sloth%205"),
                string::utf8(b"Cool%20Sloth%206"),
                string::utf8(b"Cool%20Sloth%207"),
                string::utf8(b"Cool%20Sloth%208")
            ],
            vector[
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"), 
                string::utf8(b"Cool Sloth"),
                string::utf8(b"Cool Sloth")
            ],
            vector[
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b""),
                string::utf8(b"")
            ],
            vector[1000, 1000, 1000, 1000],
            
            4,
            option::none(),
            option::none(),
            vector[],
            vector[],
            vector[]
        );

        // mint one token at index 0
        // debug::print<u64>(&vector::length(&tokens_for_mint<Composable>(mint_info_object_address)));
        // let indices = vector<u64>[];
        // for (i in 0..vector::length(&tokens_for_mint<Composable>(mint_info_object_address))) {
        //     let token = vector::borrow(&tokens_for_mint<Composable>(mint_info_object_address), i);
        //     let (_, index) = vector::index_of(&tokens_for_mint<Composable>(mint_info_object_address), token);
        //     vector::push_back(&mut indices, index);
        // };
        // debug::print<String>(&string::utf8(b"INDICES:"));
        // debug::print<vector<u64>>(&indices);

        // let mint_info = borrow_global<MintInfo>(mint_info_object_address);
        // let pool = indexed_tokens(&mint_info.token_pool);
        // debug::print<SimpleMap<u64, address>>(&smart_table::to_simple_map(&pool));

        let (minted_token_one, _) = mint_token_at_index<Composable>(minter, mint_info_object_address, 3);
        let (minted_token_two, _) = mint_token_at_index<Composable>(minter, mint_info_object_address, 2);
        let (minted_token_three, _) = mint_token_at_index<Composable>(minter, mint_info_object_address, 1);
        let (minted_token_four, _) = mint_token_at_index<Composable>(minter, mint_info_object_address, 0);

        debug::print<String>(&string::utf8(b"COMPOSABLE ADDRs minted given indices:"));
        debug::print<address>(&minted_token_one);

        // smart_table::destroy(pool);
    }

    // #[test_only]
    // const TRAIT_URI_PREFIX: vector<u8> = b"Trait%20Name%20Prefix%20";
    // #[test_only]
    // const TRAIT_PREFIX: vector<u8> = b"Trait Prefix #";
    // #[test_only]
    // const TRAIT_SUFFIX : vector<u8> = b" Trait Suffix";
    // #[test(std = @0x1, creator = @0x111, minter = @0x222)]
    // /// Test the minting of composable tokens with soulbound traits
    // fun test_composable_tokens_with_soulbound_traits(std: &signer, creator: &signer, minter: &signer) acquires MintInfo {
    //     let input_mint_price = 1000;

    //     let (creator_addr, minter_addr) = common::setup_test(std, creator, minter);
    //     let creator_balance_before_mint = coin::balance<APT>(signer::address_of(creator));

    //     // creator creates a collection
    //     let collection_constructor_ref = studio::create_collection_with_tracker_internal<FixedSupply>(
    //         creator,
    //         string::utf8(b"Collection Description"),
    //         option::some(1000),
    //         string::utf8(b"Collection Name"),
    //         string::utf8(b"Collection Symbol"),
    //         string::utf8(b"Collection URI"),
    //         true,
    //         true, 
    //         true,
    //         true,
    //         true, 
    //         true,
    //         true,
    //         true, 
    //         true,
    //         option::none(),
    //         option::none(),
    //     );

    //     // Add base type to the tracker
    //     let collection_obj_addr = object::address_from_constructor_ref(&collection_constructor_ref);
    //     studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Trait"), 20);
    //     studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Composable"), 20);
    //     studio::add_type_to_tracker(creator, collection_obj_addr, string::utf8(b"Trait"), 20);

    //     // creator creates composable tokens with soulbound traits
    //     let (composable_token_addrsesses, trait_token_addrsesses, mint_info_obj_addr, _) = create_composable_tokens_with_soulbound_traits_for_mint_internal(
    //         creator,
    //         object::object_from_constructor_ref(&collection_constructor_ref),
    //         string::utf8(b"Description"),
    //         // trait token related fields
    //         vector[
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait")
    //         ],
    //         vector[
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait")
    //         ],
    //         vector[
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait"),
    //             string::utf8(b"Trait")
    //         ],
    //         vector[],
    //         vector[],
    //         vector[],
    //         // composable token related fields
    //         vector[
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable")
    //         ],
    //         vector[
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable")
    //         ],
    //         vector[
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable"),
    //             string::utf8(b"Composable")
    //         ],
    //         vector[],
    //         vector[],
    //         vector[],
    //         // common
    //         4,
    //         
    //         option::some(1),
    //         option::some(2),
    //         vector[1000, 1000, 1000, 1000],
    //     );

    //     // assert trait tokens are soulbound to the composable tokens
    //     let trait_token_0 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 0));
    //     let trait_token_1 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 1));
    //     let trait_token_2 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 2));
    //     let trait_token_3 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 3));

    //     let composable_token_0 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 0));
    //     let composable_token_1 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 1));
    //     let composable_token_2 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 2));
    //     let composable_token_3 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 3));

    //     assert!(object::is_owner(trait_token_0, *vector::borrow(&composable_token_addrsesses, 0)), 1);
    //     assert!(object::is_owner(trait_token_1, *vector::borrow(&composable_token_addrsesses, 1)), 1);
    //     assert!(object::is_owner(trait_token_2, *vector::borrow(&composable_token_addrsesses, 2)), 1);
    //     assert!(object::is_owner(trait_token_3, *vector::borrow(&composable_token_addrsesses, 3)), 1);

    //     // minter mints tokens
    //     let (minted_tokens, _) = mint_batch_tokens<Composable>(minter, mint_info_obj_addr, 4);

    //     // assert the owner is the minter
    //     let token_0 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 0));
    //     let token_1 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 1));
    //     let token_2 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 2));
    //     let token_3 = object::address_to_object<Composable>(*vector::borrow(&minted_tokens, 3));
    //     assert!(object::is_owner(token_0, minter_addr), 1);
    //     assert!(object::is_owner(token_1, minter_addr), 1);
    //     assert!(object::is_owner(token_2, minter_addr), 1);
    //     assert!(object::is_owner(token_3, minter_addr), 1);

    //     // assert the mint price is sent to the owner
    //     let creator_balance_after_mint = creator_balance_before_mint + (input_mint_price * 4);
    //     assert!(coin::balance<APT>(creator_addr) == creator_balance_after_mint, 2);

    //     // get tokens and print their names 
    //     debug::print<String>(&token::name<Trait>(trait_token_0));
    //     debug::print<String>(&token::name<Trait>(trait_token_1));
    //     debug::print<String>(&token::name<Trait>(trait_token_2));
    //     debug::print<String>(&token::name<Trait>(trait_token_3));

    //     debug::print<String>(&token::name<Composable>(composable_token_0));
    //     debug::print<String>(&token::name<Composable>(composable_token_1));
    //     debug::print<String>(&token::name<Composable>(composable_token_2));
    //     debug::print<String>(&token::name<Composable>(composable_token_3));

    //     // print uris
    //     debug::print<String>(&token::uri<Trait>(trait_token_0));
    //     debug::print<String>(&token::uri<Trait>(trait_token_1));
    //     debug::print<String>(&token::uri<Trait>(trait_token_2));
    //     debug::print<String>(&token::uri<Trait>(trait_token_3));

    //     debug::print<String>(&token::uri<Composable>(composable_token_0));
    //     debug::print<String>(&token::uri<Composable>(composable_token_1));
    //     debug::print<String>(&token::uri<Composable>(composable_token_2));
    //     debug::print<String>(&token::uri<Composable>(composable_token_3));

    //     // create more tokens for minting
    //     add_tokens_for_mint_internal<Composable>(
    //         creator,
    //         object::object_from_constructor_ref(&collection_constructor_ref),
    //         mint_info_obj_addr,
    //         string::utf8(b"Description"),
    //         vector[
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base"),
    //             string::utf8(b"Base")
    //         ],
    //         vector[
    //             string::utf8(b"Cool%20Sloth"),
    //             string::utf8(b"Cool%20Sloth"),
    //             string::utf8(b"Cool%20Sloth"),
    //             string::utf8(b"Cool%20Sloth")
    //         ],
    //         vector[
    //             string::utf8(b"Cool Sloth"), 
    //             string::utf8(b"Cool Sloth"), 
    //             string::utf8(b"Cool Sloth"),
    //             string::utf8(b"Cool Sloth")
    //         ],
    //         vector[1000, 1000, 1000, 1000],
    //         4,
    //         option::none(),
    //         option::none(),
    //         vector[],
    //         vector[],
    //         vector[]
    //     );

    //     // mint the newly created tokens
    //     let (minted_tokens, _) = mint_batch_tokens<Composable>(minter, mint_info_obj_addr, 4);

    //     // assert the traits are soulbound to the composable tokens
    //     let trait_token_4 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 0));
    //     let trait_token_5 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 1));
    //     let trait_token_6 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 2));
    //     let trait_token_7 = object::address_to_object<Trait>(*vector::borrow(&trait_token_addrsesses, 3));

    //     let composable_token_4 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 0));
    //     let composable_token_5 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 1));
    //     let composable_token_6 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 2));
    //     let composable_token_7 = object::address_to_object<Composable>(*vector::borrow(&composable_token_addrsesses, 3));

    //     assert!(object::is_owner(trait_token_4, *vector::borrow(&composable_token_addrsesses, 0)), 2);
    //     assert!(object::is_owner(trait_token_5, *vector::borrow(&composable_token_addrsesses, 1)), 2);
    //     assert!(object::is_owner(trait_token_6, *vector::borrow(&composable_token_addrsesses, 2)), 2);
    //     assert!(object::is_owner(trait_token_7, *vector::borrow(&composable_token_addrsesses, 3)), 2);

    //     // assert the owner is the minter
    //     assert!(object::is_owner(composable_token_4, minter_addr), 3);
    //     assert!(object::is_owner(composable_token_5, minter_addr), 3);
    //     assert!(object::is_owner(composable_token_6, minter_addr), 3);
    //     assert!(object::is_owner(composable_token_7, minter_addr), 3);

    //     // assert the mint price is sent to the owner
    //     let creator_balance_after_mint = creator_balance_after_mint + (input_mint_price * 4);
    //     assert!(coin::balance<APT>(creator_addr) == creator_balance_after_mint, 4);

    //     // get one token and print its name and uri
    //     debug::print<String>(&token::name<Composable>(composable_token_4));
    //     debug::print<String>(&token::name<Composable>(composable_token_5));
    //     debug::print<String>(&token::name<Composable>(composable_token_6));
    //     debug::print<String>(&token::name<Composable>(composable_token_7));
    // }
}