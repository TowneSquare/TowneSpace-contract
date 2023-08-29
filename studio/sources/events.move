/*
    Module for creating events for the studio.
*/

module townespace::events {
    use aptos_framework::event;
    use aptos_framework::object::{Object};
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::collection;
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;
    
    use townespace::core::{
        Self, 
        TokenCollection, 
        ComposableToken, 
        ObjectToken
        };
    
    //use std::error;
    //use std::features;
    use std::option;
    use std::string::{String};

    friend townespace::studio;

    // ------
    // Errors
    // ------

    // ---------
    // Constants
    // ---------

    // ---------------------
    // Initializer Functions
    // ---------------------

    // -----------------------------
    // Metadata and Helper Functions
    // -----------------------------

    // Collection 
    struct TokenCollectionMetadata has drop, store {
        creator: address,
        description: String,
        name: String,
        uri: String,
        symbol: String
    }

    public fun token_collection_metadata(
        token_collection_object: Object<TokenCollection>
        ): TokenCollectionMetadata {
            let collection_object = core::get_collection(token_collection_object);
            let creator = collection::creator<aptos_token::AptosCollection>(collection_object);
            let description = collection::description<aptos_token::AptosCollection>(collection_object);
            let name = collection::name<aptos_token::AptosCollection>(collection_object);
            let uri = collection::uri<aptos_token::AptosCollection>(collection_object);
            let symbol = core::get_collection_symbol(token_collection_object);

            TokenCollectionMetadata {
                creator: creator,
                name: name,
                description: description,
                uri: uri,
                symbol: symbol,
            }
    }

    // Composable Token 
    struct ComposableTokenMetadata has drop, store {
        creator: address,
        collection_name: String,
        description: String,
        name: String,
        uri: String,
        total_supply: u64,
        object_tokens: vector<Object<ObjectToken>>,
    }

    public fun composable_token_metadata(
        composable_token_object: Object<ComposableToken>
        ): ComposableTokenMetadata {
            let token_object = core::get_composable_token(composable_token_object);
            let object_tokens = core::get_object_token_vector(composable_token_object);
            let creator = token::creator<aptos_token::AptosToken>(token_object);
            let collection_name = token::collection_name<aptos_token::AptosToken>(token_object);
            let description = token::description<aptos_token::AptosToken>(token_object);
            let name = token::name<aptos_token::AptosToken>(token_object);
            let uri = token::uri<aptos_token::AptosToken>(token_object);
            let total_supply = core::get_supply(composable_token_object);

            ComposableTokenMetadata {
                creator: creator,
                collection_name: collection_name,
                description: description,
                name: name,
                uri: uri,
                total_supply: total_supply,
                object_tokens: object_tokens,
            }
    }

    // Object Token 
    struct ObjectTokenMetadata has drop, store {
        creator: address,
        collection_name: String,
        description: String,
        name: String,
        uri: String
    }

    public fun object_token_metadata(
        object_token_object: Object<ObjectToken>
        ): ObjectTokenMetadata {
            let token_object = core::get_object_token(object_token_object);
            let creator = token::creator<aptos_token::AptosToken>(token_object);
            let collection_name = token::collection_name<aptos_token::AptosToken>(token_object);
            let description = token::description<aptos_token::AptosToken>(token_object);
            let name = token::name<aptos_token::AptosToken>(token_object);
            let uri = token::uri<aptos_token::AptosToken>(token_object);

            ObjectTokenMetadata {
                creator: creator,
                collection_name: collection_name,
                description: description,
                name: name,
                uri: uri
            }
    }

    // ------
    // Events
    // ------

    // Collection 

    // Token Collection Created Event
    struct TokenCollectionCreated has drop, store {
        token_collection: address,
        token_collection_metadata: TokenCollectionMetadata
    }

    public(friend) fun emit_token_collection_created_event(
        token_collection_address: address,
        token_collection_metadata: TokenCollectionMetadata
    ) {
        event::emit<TokenCollectionCreated>(TokenCollectionCreated {
            token_collection: token_collection_address,
            token_collection_metadata: token_collection_metadata
        });
    }
    // TODO: Token Collection Metadata Updated Event
    // TODO: Token Collection Deleted Event

    // Composable Token 
    struct ComposableTokenMinted has drop, store {
        composable_token: address,
        composable_token_metadata: ComposableTokenMetadata
    }

    public(friend) fun emit_composable_token_minted_event(
        composable_token_address: address,
        composable_token_metadata: ComposableTokenMetadata
    ) {
        event::emit<ComposableTokenMinted>(ComposableTokenMinted {
            composable_token: composable_token_address,
            composable_token_metadata: composable_token_metadata
        });
    }
    // TODO: Composable Token Metadata Updated Event
    // TODO: Composable Token Burned Event
    // TODO: Composable Token Transferred Event
    

    // Object Token 
    struct ObjectTokenMinted has drop, store {
        object_token_address: address,
        object_token_metadata: ObjectTokenMetadata
    }
    
    public(friend) fun emit_object_token_minted_event(
        object_token_address: address,
        object_token_metadata: ObjectTokenMetadata
    ) {
        event::emit<ObjectTokenMinted>(ObjectTokenMinted {
            object_token_address: object_token_address,
            object_token_metadata: object_token_metadata
        });
    }
    // TODO: Object Token Metadata Updated Event
    // TODO: Object Token Burned Event
    // TODO: Object Token Transferred Event
    // TODO: Object Token Composed Event
    // TODO: Object Token Decomposed Event
    
}