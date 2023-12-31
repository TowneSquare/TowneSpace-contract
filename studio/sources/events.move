/*
    Module for creating events for the studio.
*/

module townespace::events {
    use aptos_framework::event;
    use aptos_framework::object::{Object};
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    
    use townespace::core::{
        Self, 
        Collection, 
        Composable, 
        Trait
        };
    
    //use std::error;
    //use std::features;
    //use std::option;
    use std::string::{String};

    friend townespace::studio;

    // ------
    // Errors
    // ------

    // -----------------------------
    // Metadata and Helper Functions
    // -----------------------------

    // Collection 
    struct CollectionMetadata has drop, store {
        creator: address,
        description: String,
        name: String,
        uri: String,
        symbol: String
    }

    public fun collection_metadata(
        collection_object: Object<Collection>
        ): CollectionMetadata {
            let creator = collection::creator<Collection>(collection_object);
            let description = collection::description<Collection>(collection_object);
            let name = collection::name<Collection>(collection_object);
            let uri = collection::uri<Collection>(collection_object);
            let symbol = core::get_collection_symbol(collection_object);

            CollectionMetadata {
                creator: creator,
                name: name,
                description: description,
                uri: uri,
                symbol: symbol,
            }
    }

    // Composable Token 
    struct ComposableMetadata has drop, store {
        creator: address,
        collection_name: String,
        description: String,
        name: String,
        uri: String,
        traits: vector<Object<Trait>>,
    }

    
    public fun composable_token_metadata(
        composable_object: Object<Composable>
        ): ComposableMetadata {
            let traits = core::get_traits(composable_object);
            let creator = token::creator<Composable>(composable_object);
            let collection_name = token::collection_name<Composable>(composable_object);
            let description = token::description<Composable>(composable_object);
            let name = token::name<Composable>(composable_object);
            let uri = token::uri<Composable>(composable_object);

            ComposableMetadata {
                creator: creator,
                collection_name: collection_name,
                description: description,
                name: name,
                uri: uri,
                traits: traits,
            }
    }

    // Object Token 
    struct TraitMetadata has drop, store {
        creator: address,
        collection_name: String,
        description: String,
        name: String,
        uri: String
    }

    public fun trait_token_metadata(
        trait_object: Object<Trait>
        ): TraitMetadata {
            let creator = token::creator<Trait>(trait_object);
            let collection_name = token::collection_name<Trait>(trait_object);
            let description = token::description<Trait>(trait_object);
            let name = token::name<Trait>(trait_object);
            let uri = token::uri<Trait>(trait_object);

            TraitMetadata {
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

    #[event]
    // Token Collection Created Event
    struct CollectionCreated has drop, store {
        collection: address,
        collection_metadata: CollectionMetadata
    }
     
    public(friend) fun emit_collection_created_event(
        collection_address: address,
        collection_metadata: CollectionMetadata
    ) {
        event::emit<CollectionCreated>(
            CollectionCreated {
                collection: collection_address,
                collection_metadata: collection_metadata
            }
        );
    }
    // TODO: Token Collection Metadata Updated Event
    // TODO: Token Collection Deleted Event

    #[event]
    // Composable Token 
    struct ComposableMinted has drop, store {
        composable_token: address,
        composable_token_metadata: ComposableMetadata
    }

    public(friend) fun emit_composable_token_minted_event(
        composable_token_address: address,
        composable_token_metadata: ComposableMetadata
    ) {
        event::emit<ComposableMinted>(
            ComposableMinted {
                composable_token: composable_token_address,
                composable_token_metadata: composable_token_metadata
            }
        );
    }

    #[event]
    // Object Token 
    struct TraitMinted has drop, store {
        trait_token_address: address,
        trait_token_metadata: TraitMetadata
    }
    
    public(friend) fun emit_trait_token_minted_event(
        trait_token_address: address,
        trait_token_metadata: TraitMetadata
    ) {
        event::emit<TraitMinted>(
            TraitMinted {
                trait_token_address: trait_token_address,
                trait_token_metadata: trait_token_metadata
            }
        );
    }

    #[event]
    // Object Token Composed Event
    struct CompositionEvent has drop, store {
        composable_token_metadata: ComposableMetadata,
        trait_token_to_compose_metadata: TraitMetadata,
        new_uri: String
    }

    public(friend) fun emit_composition_event(
        composable_token_metadata: ComposableMetadata,
        trait_token_to_compose_metadata: TraitMetadata,
        new_uri: String
    ) {
        event::emit<CompositionEvent>(
            CompositionEvent {
                composable_token_metadata: composable_token_metadata,
                trait_token_to_compose_metadata: trait_token_to_compose_metadata,
                new_uri: new_uri
            }
        );
    }

    #[event]
    // Object Token Decomposed Event
    struct DecompositionEvent has drop, store {
        composable_token_metadata: ComposableMetadata,
        trait_token_to_decompose_metadata: TraitMetadata,
        new_uri: String
    }

    public(friend) fun emit_decomposition_event(
        composable_token_metadata: ComposableMetadata,
        trait_token_to_decompose_metadata: TraitMetadata,
        new_uri: String
    ) {
        event::emit<DecompositionEvent>(
            DecompositionEvent {
                composable_token_metadata: composable_token_metadata,
                trait_token_to_decompose_metadata: trait_token_to_decompose_metadata,
                new_uri: new_uri
            }
        );
    }
    
    #[event]
    // Composable Token Transferred Event
    struct ComposableTransferredEvent has drop, store {
        token_metadata: ComposableMetadata,
        from: address,
        to: address
    }

    public(friend) fun emit_composable_token_transferred_event(
        token_metadata: ComposableMetadata,
        from: address,
        to: address
    ) {
        event::emit<ComposableTransferredEvent>(
            ComposableTransferredEvent {
                token_metadata: token_metadata,
                from: from,
                to: to
            }
        );
    }

    #[event]
    // Object Token Transferred Event
    struct TraitTransferredEvent has drop, store {
        token_metadata: TraitMetadata,
        from: address,
        to: address
    }

    public(friend) fun emit_trait_token_transferred_event(
        token_metadata: TraitMetadata,
        from: address,
        to: address
    ) {
        event::emit<TraitTransferredEvent>(
            TraitTransferredEvent {
                token_metadata: token_metadata,
                from: from,
                to: to
            }
        );
    }

    // TODO: Composable Token Burned Event
    // TODO: Object Token Burned Event
}