
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::events`



-  [Struct `CollectionMetadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionMetadata)
-  [Struct `ComposableMetadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata)
-  [Struct `TraitMetadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata)
-  [Struct `CollectionCreated`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionCreated)
-  [Struct `ComposableMinted`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMinted)
-  [Struct `TraitMinted`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMinted)
-  [Struct `CompositionEvent`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CompositionEvent)
-  [Struct `DecompositionEvent`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_DecompositionEvent)
-  [Struct `ComposableTransferredEvent`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableTransferredEvent)
-  [Struct `TraitTransferredEvent`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitTransferredEvent)
-  [Struct `UriUpdatedEvent`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_UriUpdatedEvent)
-  [Function `collection_metadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_collection_metadata)
-  [Function `composable_token_metadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_composable_token_metadata)
-  [Function `trait_token_metadata`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_trait_token_metadata)
-  [Function `emit_collection_created_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_collection_created_event)
-  [Function `emit_composable_token_created_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_created_event)
-  [Function `emit_trait_token_created_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_created_event)
-  [Function `emit_composition_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composition_event)
-  [Function `emit_decomposition_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_decomposition_event)
-  [Function `emit_composable_token_transferred_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_transferred_event)
-  [Function `emit_trait_token_transferred_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_transferred_event)
-  [Function `emit_uri_updated_event`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_uri_updated_event)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::core</a>;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionMetadata"></a>

## Struct `CollectionMetadata`

------
Errors
------
-----------------------------
Metadata and Helper Functions
-----------------------------
Collection


<pre><code><b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionMetadata">CollectionMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata"></a>

## Struct `ComposableMetadata`

Composable Token


<pre><code><b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">ComposableMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata"></a>

## Struct `TraitMetadata`

Object Token


<pre><code><b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">TraitMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionCreated"></a>

## Struct `CollectionCreated`

Token Collection Created Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionCreated">CollectionCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMinted"></a>

## Struct `ComposableMinted`

Composable Token


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMinted">ComposableMinted</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMinted"></a>

## Struct `TraitMinted`

Object Token


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMinted">TraitMinted</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CompositionEvent"></a>

## Struct `CompositionEvent`

Object Token Composed Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CompositionEvent">CompositionEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_DecompositionEvent"></a>

## Struct `DecompositionEvent`

Object Token Decomposed Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_DecompositionEvent">DecompositionEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableTransferredEvent"></a>

## Struct `ComposableTransferredEvent`

Composable Token Transferred Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableTransferredEvent">ComposableTransferredEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitTransferredEvent"></a>

## Struct `TraitTransferredEvent`

Object Token Transferred Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitTransferredEvent">TraitTransferredEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_UriUpdatedEvent"></a>

## Struct `UriUpdatedEvent`

uri Updated Event


<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_UriUpdatedEvent">UriUpdatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_collection_metadata"></a>

## Function `collection_metadata`



<pre><code><b>public</b> <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_collection_metadata">collection_metadata</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection">core::Collection</a>&gt;): <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionMetadata">events::CollectionMetadata</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_composable_token_metadata"></a>

## Function `composable_token_metadata`



<pre><code><b>public</b> <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_composable_token_metadata">composable_token_metadata</a>(composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;): <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">events::ComposableMetadata</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_trait_token_metadata"></a>

## Function `trait_token_metadata`



<pre><code><b>public</b> <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_trait_token_metadata">trait_token_metadata</a>(trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;): <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">events::TraitMetadata</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_collection_created_event"></a>

## Function `emit_collection_created_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_collection_created_event">emit_collection_created_event</a>(collection_address: <b>address</b>, collection_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_CollectionMetadata">events::CollectionMetadata</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_created_event"></a>

## Function `emit_composable_token_created_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_created_event">emit_composable_token_created_event</a>(composable_token_address: <b>address</b>, composable_token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">events::ComposableMetadata</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_created_event"></a>

## Function `emit_trait_token_created_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_created_event">emit_trait_token_created_event</a>(trait_token_address: <b>address</b>, trait_token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">events::TraitMetadata</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composition_event"></a>

## Function `emit_composition_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composition_event">emit_composition_event</a>(composable_token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">events::ComposableMetadata</a>, trait_token_to_compose_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">events::TraitMetadata</a>, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_decomposition_event"></a>

## Function `emit_decomposition_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_decomposition_event">emit_decomposition_event</a>(composable_token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">events::ComposableMetadata</a>, trait_token_to_decompose_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">events::TraitMetadata</a>, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_transferred_event"></a>

## Function `emit_composable_token_transferred_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_composable_token_transferred_event">emit_composable_token_transferred_event</a>(token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_ComposableMetadata">events::ComposableMetadata</a>, from: <b>address</b>, <b>to</b>: <b>address</b>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_transferred_event"></a>

## Function `emit_trait_token_transferred_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_trait_token_transferred_event">emit_trait_token_transferred_event</a>(token_metadata: <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_TraitMetadata">events::TraitMetadata</a>, from: <b>address</b>, <b>to</b>: <b>address</b>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_uri_updated_event"></a>

## Function `emit_uri_updated_event`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events_emit_uri_updated_event">emit_uri_updated_event</a>(composable_token_addr: <b>address</b>, new_uri: <a href="_String">string::String</a>)
</code></pre>
