module townespace::scripts {
    use std::string::{Self, String};
    use std::vector;
    use townespace::studio;

    public entry fun mint_empty_composable_token(
        creator_signer: &signer, 
        collection_name: String,
        name: String
    ) {
        studio::mint_composable_token(
            creator_signer,
            collection_name,
            string::utf8(b"composable token description"),
            name,
            string::utf8(b"composable token uri"),
            1000,
            vector::empty(),
            vector[string::utf8(b"bool")],
            vector[string::utf8(b"bool")],
            vector[vector[0x01]],
            b"composable token seed"
        )
    }
}