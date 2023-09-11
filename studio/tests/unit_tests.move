#[test_only]
module townespace::unit_tests {
    // use aptos_framework::object;
    use aptos_token_objects::collection::{UnlimitedSupply};
    use aptos_token_objects::royalty::{Royalty};
    // use std::error;
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use townespace::studio;
    


    // -----
    // Tests
    // -----

    #[test(creator = @0x123)]
    fun a_create_unlimited_collection(creator: &signer) {
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://hacksgp23.com");
        create_collection_helper<UnlimitedSupply>(
            creator, 
            collection_description, 
            option::none(),
            collection_name, 
            collection_symbol, 
            option::none(),
            collection_uri
            );
    }

    // #[test(creator = @0x123)]
    // fun b_mint_composable_token(creator: &signer) {
    //     let token_name = string::utf8(b"Composable Token");
    //     // mint_token_helper<ComposableToken>(creator, token_name);
    // }

    // #[test(creator = @0x123)]
    // fun c_mint_trait_token(creator: &signer) {
    //     let token_name = string::utf8(b"Object Token");
    //     // mint_token_helper<ObjectToken>(creator, token_name);
    // }

    // #[test(creator = @0x123)]
    // fun b_compose_token(creator: &signer) {
        
    // }

    // #[test(creator = @0x123)]
    // fun c_decompose_token(creator: &signer) {
        
    // }

    // -------
    // Helpers
    // -------

    fun create_collection_helper<T: key>(
        creator_signer: &signer,
        description: String,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
        name: String,
        symbol: String,
        royalty: Option<Royalty>,   // TODO get the same in core.move
        uri: String
    ) {
        studio::create_collection<T>(
            creator_signer,
            description,
            max_supply,
            name,
            symbol,
            royalty,
            uri
            );
    }

    fun mint_token_helper<T: key>(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        type: String,
        name: String,
        num_type: u64,
        uri: String
    ) {
        studio::mint_token<T>(
            creator_signer,
            collection_name,
            description,
            type,
            name,
            num_type,
            uri
            );
    }
}