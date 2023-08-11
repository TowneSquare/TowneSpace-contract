module townesquare::studio_events {
    use std::string::String;
    use townesquare::studio_core;

    struct CreateTokenCollectionEvent has store, drop {
        name: String,
        symbol: String,
        timestamp: u64,
    }

    struct CreatePlainTokenEvent has store, drop {
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    }

    struct CreateDynamicTokenEvent has store, drop {
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    }

    struct CreateComposedTokenEvent has store, drop {
        // TODO
    }

    struct CombineTokenEvent has store, drop {
        owner: address,
        collection: String,
        token_name: String,
        object_name: String,
        timestamp: u64,
    }

    struct UncombineTokenEvent has store, drop {
        owner: address,
        collection: String,
        token_name: String,
        object_name: String,
        timestamp: u64,
    }

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

    public fun new_create_plain_token_event(
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    ): CreatePlainTokenEvent {
        CreatePlainTokenEvent {
            collection: collection,
            description: description,
            name: name,
            uri: uri,
            timestamp: timestamp,
        }
    }

    public fun new_create_dynamic_token_event(
        collection: String,
        description: String,
        name: String,
        uri: String,
        timestamp: u64,
    ): CreateDynamicTokenEvent {
        CreateDynamicTokenEvent {
            collection: collection,
            description: description,
            name: name,
            uri: uri,
            timestamp: timestamp,
        }
    }

    public fun new_create_composed_token_event(
        // TODO: 
    ): CreateComposedTokenEvent {

    }

    public fun new_combine_token_event(
        owner: address,
        collection: String,
        token_name: String,
        object_name: String,
        timestamp: u64,
    ): CombineTokenEvent {
        CombineTokenEvent {
            owner: owner,
            collection: collection,
            token_name: token_name,
            object_name: object_name,
            timestamp: timestamp,
        }
    }

    public fun new_uncombine_token_event(
        owner: address,
        collection: String,
        token_name: String,
        object_name: String,
        timestamp: u64,
    ): UncombineTokenEvent {
        UncombineTokenEvent {
            owner: owner,
            collection: collection,
            token_name: token_name,
            object_name: object_name,
            timestamp: timestamp,
        }
    }
}