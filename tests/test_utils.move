/*
    Module containing helper functions needed for unit testing

    TODO:
        - 
*/

#[test_only]
module townespace::test_utils {
    use aptos_framework::object::{Object};
    use aptos_token_objects::collection;
    // use std::error;
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::vector;
    use townespace::core::{Self, Collection, Composable, Trait};
    use townespace::studio;
    use std::features;

    // collection 
    const COLLECTION_DESCRIPTION: vector<u8> =  b"Collection of Hack Singapore 2023 NFTs";
    const COLLECTION_SYMBOL: vector<u8> = b"HSGP23";
    const COLLECTION_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023";

    // composable
    const COMPOSABLE_DESCRIPTION: vector<u8> = b"Composable token for Hack Singapore 2023";
    const COMPOSABLE_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023/composable";

    // trait
    const TRAIT_DESCRIPTION: vector<u8> = b"Trait for Hack Singapore 2023";
    const TRAIT_URI: vector<u8> = b"https://aptosfoundation.org/events/singapore-hackathon-2023/trait";
    const TRAIT_TYPE: vector<u8> = b"Trait type";

    public fun prepare_for_test(std: signer) {
        let feature = features::get_auids();
        features::change_feature_flags(&std, vector[feature], vector[]);
    }

    public fun create_collection_helper<T: key>(
        signer_ref: &signer,
        collection_name: vector<u8>,
        max_supply: Option<u64>, // if the collection is set to haved a fixed supply.
    ): Object<Collection> {
        core::create_collection_internal<T>(
            signer_ref,
            string::utf8(COLLECTION_DESCRIPTION),
            max_supply,
            string::utf8(collection_name),
            string::utf8(COLLECTION_SYMBOL),
            string::utf8(COLLECTION_URI),
            1,
            2,
            false,
            false
        )
    }

    // create a composable
    public fun create_composable_token_helper(signer_ref: &signer, collection_name: vector<u8>): Object<Composable> {
        let type = string::utf8(b"");   // Composable token does not have a type
        core::create_token_internal<Composable>(
            signer_ref,
            string::utf8(collection_name),
            string::utf8(COMPOSABLE_DESCRIPTION),
            string::utf8(COMPOSABLE_URI),
            type,
            vector::empty(),    // no traits
            vector::empty(), // no coins
            // royalty
            1,
            2
        )
    }

    // create a trait
    public fun create_trait_token_helper(signer_ref: &signer, collection_name: vector<u8>): Object<Trait> {
        core::create_token_internal<Trait>(
            signer_ref,
            string::utf8(collection_name),
            string::utf8(TRAIT_DESCRIPTION),
            string::utf8(TRAIT_URI), 
            string::utf8(TRAIT_TYPE),
            vector::empty(),
            vector::empty(),  // no coins
            1,
            2
        )
    }
}