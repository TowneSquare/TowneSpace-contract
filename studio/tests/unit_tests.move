#[test_only]
module townespace::unit_tests {
    use aptos_framework::object::{Object};
    use aptos_token_objects::collection::{UnlimitedSupply};
    use aptos_token_objects::royalty::{Royalty};
    // use std::error;
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::vector;
    use townespace::core::{Self, Collection, Composable, Trait};
    use townespace::studio;
    


    // -----
    // Tests
    // -----

    #[test(creator = @0x123)]
    fun a_create_unlimited_collection(creator: &signer) {
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023");
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

    // TODO: test create a collection with a fixed supply

    #[test(creator = @0x123)]
    fun b_mint_composable_token(creator: &signer) {
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023");
        create_collection_helper<UnlimitedSupply>(
            creator, 
            collection_description, 
            option::none(),
            collection_name, 
            collection_symbol, 
            option::none(),
            collection_uri
            );

        let token_name = string::utf8(b"Composable Token");
        let token_description = string::utf8(b"Composable Token");
        let token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token");
        mint_composable_token_helper(
            creator, 
            collection_name,
            token_description,
            token_name,
            1,
            token_uri, 
            vector::empty()
            );
    }

    #[test(creator = @0x123)]
    fun c_mint_trait_token(creator: &signer) {
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023");
        create_collection_helper<UnlimitedSupply>(
            creator, 
            collection_description, 
            option::none(),
            collection_name, 
            collection_symbol, 
            option::none(),
            collection_uri
            );
        
        let token_name = string::utf8(b"Jacket");
        let token_description = string::utf8(b"Trait Token");
        let token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/jacket");
        let type = string::utf8(b"Clothing"); 
        mint_trait_token_helper(
            creator, 
            collection_name,
            token_description,
            type,
            token_name,
            1,
            token_uri
            );
    }

    #[test(creator = @0x123)]
    fun d_compose_token(creator: &signer) {
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023");

        let composable_token_name = string::utf8(b"Composable Token");
        let composable_token_description = string::utf8(b"Composable Token");
        let composable_token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token");
        
        let token_name = string::utf8(b"Jacket");
        let token_description = string::utf8(b"Trait Token");
        let token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/jacket");
        let type = string::utf8(b"Clothing");
        
        create_collection_helper<UnlimitedSupply>(
            creator, 
            collection_description, 
            option::none(),
            collection_name, 
            collection_symbol, 
            option::none(),
            collection_uri
            );
        
        let composable_object = mint_composable_token_helper(
            creator, 
            collection_name,
            composable_token_description,
            composable_token_name,
            1,
            composable_token_uri,
            vector::empty<Object<Trait>>()
            );
        
        let trait_object = mint_trait_token_helper(
            creator, 
            collection_name,
            token_description,
            type,
            token_name,
            1,
            token_uri
            );

        // let composable_address = object::object_address(&composable_object);

        let updated_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token/jacket");
        
        studio::equip_trait(
            creator,
            composable_object,
            trait_object,
            updated_uri
        );
    }

    #[test(creator = @0x123)]
    fun e_compose_decompose_token(creator: &signer){
        let collection_description = string::utf8(b"Collection of Hack Singapore 2023 NFTs");
        let collection_name = string::utf8(b"Hack Singapore 2023 Collection");
        let collection_symbol = string::utf8(b"HSGP23");
        let collection_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023");
        create_collection_helper<UnlimitedSupply>(
            creator, 
            collection_description, 
            option::none(),
            collection_name, 
            collection_symbol, 
            option::none(),
            collection_uri
            );

        let composable_token_name = string::utf8(b"Composable Token");
        let composable_token_description = string::utf8(b"Composable Token");
        let composable_token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token");
        let traits = vector::empty<Object<Trait>>();
        let composable_object = mint_composable_token_helper(
            creator, 
            collection_name,
            composable_token_description,
            composable_token_name,
            1,
            composable_token_uri,
            traits
            );

        let token_name = string::utf8(b"Jacket");
        let token_description = string::utf8(b"Trait Token");
        let token_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/jacket");
        let type = string::utf8(b"Clothing");
        let trait_object = mint_trait_token_helper(
            creator, 
            collection_name,
            token_description,
            type,
            token_name,
            9,
            token_uri
            );

        let updated_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token/jacket");
        studio::equip_trait(
            creator,
            composable_object,
            trait_object,
            updated_uri
        );

        let decomposed_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/jacket");
        studio::unequip_trait(
            creator,
            composable_object,
            trait_object,
            decomposed_uri
        );
        
    }
    
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
    ): Object<Collection> {
        core::create_collection_internal<T>(
            creator_signer,
            description,
            max_supply,
            name,
            symbol,
            royalty,
            uri
            )
    }

    fun mint_composable_token_helper(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        name: String,
        num_type: u64,
        uri: String, 
        traits: vector<Object<Trait>>
    ): Object<Composable> {
        let type = string::utf8(b"");   // Composable token does not have a type
        core::mint_token_internal<Composable>(
            creator_signer,
            collection_name,
            description,
            type,
            name,
            num_type,
            uri,
            traits,
            vector::empty(), // no coins
            option::none(),
            option::none(),
            option::none()
            )
    }

    fun mint_trait_token_helper(
        creator_signer: &signer,
        collection_name: String,
        description: String,
        type: String,
        name: String,
        num_type: u64,
        uri: String,
    ): Object<Trait> {
        core::mint_token_internal<Trait>(
            creator_signer,
            collection_name,
            description,
            type,
            name,
            num_type,
            uri, 
            vector::empty(),
            vector::empty(),  // no coins
            option::none(),
            option::none(),
            option::none()
            )
    }
}