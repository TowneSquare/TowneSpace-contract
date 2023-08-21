/*
    Module for creating events for the studio.
*/

module townespace::events {
    use std::string::String;



    /// ----------
    /// Structures
    /// ----------
    
    struct CreateTokenCollectionEvent has store, drop {
        name: String,
        symbol: String,
        timestamp: u64,
    }

    struct CreateTraitTokenEvent has store, drop {
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    }

    struct CreateComposableTokenEvent has store, drop {
        collection: String,
        description: String,
        name: String,
        uri: String,
        token_supply: u64,
        // TODO: Add trait vector
        timestamp: u64,
    }

    struct ComposeTokenEvent has store, drop {
        owner: address,
        collection: String,
        token_name: String,
        trait_name: String,
        timestamp: u64,
    }

    struct DecomposeTokenEvent has store, drop {
        owner: address,
        collection: String,
        token_name: String,
        trait_name: String,
        timestamp: u64,
    }

    /// TODO: Add delete/burn tokens events

    /// ---------
    /// Functions 
    /// ---------
    
    /// Collection

    public fun new_create_token_collection_event(
        name: String,
        symbol: String,
        timestamp: u64,
    ): CreateTokenCollectionEvent {
        CreateTokenCollectionEvent {
            name: name,
            symbol: symbol,
            timestamp: timestamp,
        }
    }

    /// Tokens

    public fun new_create_trait_token_event(
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    ): CreateTraitTokenEvent {
        CreateTraitTokenEvent {
            collection: collection,
            description: description,
            name: name,
            uri: uri,
            timestamp: timestamp,
        }
    }

    public fun new_create_composable_token_event(
        collection: String,
        description: String,
        name: String,
        uri: String,
        token_supply: u64,
        timestamp: u64,
    ): CreateComposableTokenEvent {
        CreateComposableTokenEvent {
            collection: collection,
            description: description,
            name: name,
            uri: uri,
            token_supply: token_supply,
            timestamp: timestamp,
        }
    }

    public fun new_compose_token_event(
        owner: address,
        collection: String,
        token_name: String,
        trait_name: String,
        timestamp: u64,
    ): ComposeTokenEvent {
        ComposeTokenEvent {
            owner: owner,
            collection: collection,
            token_name: token_name,
            trait_name: trait_name,
            timestamp: timestamp,
        }
    }

    public fun new_decompose_token_event(
        owner: address,
        collection: String,
        token_name: String,
        trait_name: String,
        timestamp: u64,
    ): DecomposeTokenEvent {
        DecomposeTokenEvent {
            owner: owner,
            collection: collection,
            token_name: token_name,
            trait_name: trait_name,
            timestamp: timestamp,
        }
    }
}