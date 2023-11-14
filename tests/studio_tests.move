#[test_only]
module townespace::studio_tests {
    use aptos_framework::account;
    use aptos_framework::object::{Object};
    use aptos_token_objects::collection::{FixedSupply, UnlimitedSupply};
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use townespace::core::{Self, Collection, Composable, Trait};
    use townespace::studio;
    use townespace::test_utils;

    const COLLECTION_1_NAME: vector<u8> = b"Hack Singapore 2023 Collection";
    const COLLECTION_2_NAME: vector<u8> = b"Collection 2";

    #[test(std = @0x1, creator = @0x123)]
    fun compose_token(std: signer, creator: &signer) { 
        test_utils::prepare_for_test(std);       
        test_utils::create_collection_helper<UnlimitedSupply>(
            creator, 
            COLLECTION_1_NAME,
            option::none()
        );
        let composable_object = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);

        // let composable_address = object::object_address(&composable_object);

        let updated_uri = string::utf8(b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable-token/jacket");
        
        studio::equip_trait(
            creator,
            composable_object,
            trait_object,
            updated_uri
        );
    }

    #[test(std = @0x1, creator = @0x123)]
    fun compose_decompose_token(std: signer, creator: &signer){
        test_utils::prepare_for_test(std);
        test_utils::create_collection_helper<UnlimitedSupply>(
            creator, 
            COLLECTION_1_NAME,
            option::none()
        );

        let composable_object = test_utils::create_composable_token_helper(creator, COLLECTION_1_NAME);
        let trait_object = test_utils::create_trait_token_helper(creator, COLLECTION_1_NAME);

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
}