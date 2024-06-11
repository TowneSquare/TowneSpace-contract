
<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio"></a>

# Module `0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454::studio`



-  [Resource `Tracker`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_Tracker)
-  [Resource `TokenTracker`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokenTracker)
-  [Struct `TrackerInitialized`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TrackerInitialized)
-  [Struct `TypeAdded`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TypeAdded)
-  [Struct `TokensCreated`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokensCreated)
-  [Constants](#@Constants_0)
-  [Function `create_collection_with_tracker`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker)
-  [Function `add_type_to_tracker`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_add_type_to_tracker)
-  [Function `create_batch`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch)
-  [Function `create_batch_composables_with_soulbound_traits`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits)
-  [Function `create_collection_with_tracker_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker_internal)
-  [Function `create_batch_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_internal)
-  [Function `create_batch_composables_with_soulbound_traits_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits_internal)
-  [Function `owned_tokens`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_owned_tokens)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="">0x5fe4421182921f3f4c847bb30127e25138ef463455c5981e7726fa08ce42855e::composable_token</a>;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_Tracker"></a>

## Resource `Tracker`

Global storage to track minting


<pre><code><b>struct</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_Tracker">Tracker</a> <b>has</b> key
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokenTracker"></a>

## Resource `TokenTracker`

Global storage to track token counts per type


<pre><code><b>struct</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokenTracker">TokenTracker</a> <b>has</b> store, key
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TrackerInitialized"></a>

## Struct `TrackerInitialized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TrackerInitialized">TrackerInitialized</a> <b>has</b> drop, store
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TypeAdded"></a>

## Struct `TypeAdded`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TypeAdded">TypeAdded</a> <b>has</b> drop, store
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokensCreated"></a>

## Struct `TokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_TokensCreated">TokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_ELENGTH_MISMATCH"></a>

Token names and count length mismatch


<pre><code><b>const</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 1;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker"></a>

## Function `create_collection_with_tracker`

create a collection and initialize the tracker


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker">create_collection_with_tracker</a>&lt;SupplyType: key&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, mutable_description: bool, mutable_royalty: bool, mutable_uri: bool, mutable_token_description: bool, mutable_token_name: bool, mutable_token_properties: bool, mutable_token_uri: bool, tokens_burnable_by_collection_owner: bool, tokens_freezable_by_collection_owner: bool, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_add_type_to_tracker"></a>

## Function `add_type_to_tracker`

Add a type to the tracker table


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_add_type_to_tracker">add_type_to_tracker</a>(collection_obj_addr: <b>address</b>, type: <a href="_String">string::String</a>, total_supply: u64)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch"></a>

## Function `create_batch`

Create a batch of tokens


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch">create_batch</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, folder_uri: <a href="_String">string::String</a>, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits"></a>

## Function `create_batch_composables_with_soulbound_traits`

Create a batch of composable tokens with soulbound traits


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits">create_batch_composables_with_soulbound_traits</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_description: <a href="_String">string::String</a>, composable_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, folder_uri: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker_internal"></a>

## Function `create_collection_with_tracker_internal`

Helper function for creating a collection and initializing the tracker


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_collection_with_tracker_internal">create_collection_with_tracker_internal</a>&lt;SupplyType: key&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, mutable_description: bool, mutable_royalty: bool, mutable_uri: bool, mutable_token_description: bool, mutable_token_name: bool, mutable_token_properties: bool, mutable_token_uri: bool, tokens_burnable_by_collection_owner: bool, tokens_freezable_by_collection_owner: bool, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;): <a href="_ConstructorRef">object::ConstructorRef</a>
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_internal"></a>

## Function `create_batch_internal`

Helper function for creating a batch of tokens


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_internal">create_batch_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, folder_uri: <a href="_String">string::String</a>, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits_internal"></a>

## Function `create_batch_composables_with_soulbound_traits_internal`

Helper function for creating composable tokens for minting with trait tokens bound to them
Returns the constructor refs of the created composable tokens


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_create_batch_composables_with_soulbound_traits_internal">create_batch_composables_with_soulbound_traits_internal</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_description: <a href="_String">string::String</a>, composable_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, folder_uri: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;): <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_owned_tokens"></a>

## Function `owned_tokens`

Gets a wallet address plus a list of token addresses, and returns only the owned tokens.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio_owned_tokens">owned_tokens</a>(wallet_addr: <b>address</b>, token_addrs: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>
