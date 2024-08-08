
<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio"></a>

# Module `0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f::studio`



-  [Resource `Tracker`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Tracker)
-  [Resource `Variant`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Variant)
-  [Struct `TrackerInitialized`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TrackerInitialized)
-  [Struct `TypeAdded`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TypeAdded)
-  [Struct `VariantAdded`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_VariantAdded)
-  [Struct `TokensCreated`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TokensCreated)
-  [Constants](#@Constants_0)
-  [Function `create_collection_with_tracker`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker)
-  [Function `add_type_to_tracker`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_type_to_tracker)
-  [Function `add_variant_to_type`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_variant_to_type)
-  [Function `create_batch`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch)
-  [Function `create_batch_composables_with_soulbound_traits`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits)
-  [Function `update_type_total_supply`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_update_type_total_supply)
-  [Function `create_collection_with_tracker_internal`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker_internal)
-  [Function `create_batch_internal`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_internal)
-  [Function `create_batch_composables_with_soulbound_traits_internal`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits_internal)
-  [Function `owned_tokens`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_owned_tokens)
-  [Function `type_supply`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_type_supply)
-  [Function `variant_supply`](#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_variant_supply)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::smart_table</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="">0x5fe4421182921f3f4c847bb30127e25138ef463455c5981e7726fa08ce42855e::composable_token</a>;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Tracker"></a>

## Resource `Tracker`

Global storage to track minting


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Tracker">Tracker</a> <b>has</b> key
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Variant"></a>

## Resource `Variant`

Variant Data Structure


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_Variant">Variant</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TrackerInitialized"></a>

## Struct `TrackerInitialized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TrackerInitialized">TrackerInitialized</a> <b>has</b> drop, store
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TypeAdded"></a>

## Struct `TypeAdded`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TypeAdded">TypeAdded</a> <b>has</b> drop, store
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_VariantAdded"></a>

## Struct `VariantAdded`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_VariantAdded">VariantAdded</a> <b>has</b> drop, store
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TokensCreated"></a>

## Struct `TokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_TokensCreated">TokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ENOT_OWNER"></a>

The signer is not the collection owner


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ENOT_OWNER">ENOT_OWNER</a>: u64 = 4;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ELENGTH_MISMATCH"></a>

Token names and count length mismatch


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 1;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EMAX_SUPPLY_REACHED"></a>

Token count reached max supply


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EMAX_SUPPLY_REACHED">EMAX_SUPPLY_REACHED</a>: u64 = 2;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ENEW_SUPPLY_LESS_THAN_OLD"></a>

New total supply should be greater than the current total supply


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ENEW_SUPPLY_LESS_THAN_OLD">ENEW_SUPPLY_LESS_THAN_OLD</a>: u64 = 3;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ETYPE_DOES_NOT_EXIST"></a>

The type does not exist in the tracker


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ETYPE_DOES_NOT_EXIST">ETYPE_DOES_NOT_EXIST</a>: u64 = 6;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ETYPE_EXISTS"></a>

The type exists in the tracker


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_ETYPE_EXISTS">ETYPE_EXISTS</a>: u64 = 5;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EVARIANT_DOES_NOT_EXIST"></a>

The variant does not exist in the tracker


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EVARIANT_DOES_NOT_EXIST">EVARIANT_DOES_NOT_EXIST</a>: u64 = 8;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EVARIANT_EXISTS"></a>

The variant exists in the tracker


<pre><code><b>const</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_EVARIANT_EXISTS">EVARIANT_EXISTS</a>: u64 = 7;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker"></a>

## Function `create_collection_with_tracker`

create a collection and initialize the tracker


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker">create_collection_with_tracker</a>&lt;SupplyType: key&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, mutable_description: bool, mutable_royalty: bool, mutable_uri: bool, mutable_token_description: bool, mutable_token_name: bool, mutable_token_properties: bool, mutable_token_uri: bool, tokens_burnable_by_collection_owner: bool, tokens_freezable_by_collection_owner: bool, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_type_to_tracker"></a>

## Function `add_type_to_tracker`

Add a type to the tracker table; callable only by the collection owner


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_type_to_tracker">add_type_to_tracker</a>(signer_ref: &<a href="">signer</a>, collection_obj_addr: <b>address</b>, type_name: <a href="_String">string::String</a>)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_variant_to_type"></a>

## Function `add_variant_to_type`

Add variant to a type in the tracker table; callable only by the collection owner


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_add_variant_to_type">add_variant_to_type</a>(signer_ref: &<a href="">signer</a>, collection_obj_addr: <b>address</b>, type_name: <a href="_String">string::String</a>, variant_name: <a href="_String">string::String</a>, supply: u64)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch"></a>

## Function `create_batch`

Create a batch of tokens


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch">create_batch</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits"></a>

## Function `create_batch_composables_with_soulbound_traits`

Create a batch of composable tokens with soulbound traits


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits">create_batch_composables_with_soulbound_traits</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_update_type_total_supply"></a>

## Function `update_type_total_supply`

Update the total supply in the tracker; callable only by the collection owner


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_update_type_total_supply">update_type_total_supply</a>(signer_ref: &<a href="">signer</a>, collection_obj: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, type_name: <a href="_String">string::String</a>, variant_name: <a href="_String">string::String</a>, new_total_supply: u64)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker_internal"></a>

## Function `create_collection_with_tracker_internal`

Helper function for creating a collection and initializing the tracker


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_collection_with_tracker_internal">create_collection_with_tracker_internal</a>&lt;SupplyType: key&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, mutable_description: bool, mutable_royalty: bool, mutable_uri: bool, mutable_token_description: bool, mutable_token_name: bool, mutable_token_properties: bool, mutable_token_uri: bool, tokens_burnable_by_collection_owner: bool, tokens_freezable_by_collection_owner: bool, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;): <a href="_ConstructorRef">object::ConstructorRef</a>
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_internal"></a>

## Function `create_batch_internal`

Helper function for creating a batch of tokens


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_internal">create_batch_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits_internal"></a>

## Function `create_batch_composables_with_soulbound_traits_internal`

Helper function for creating composable tokens for minting with trait tokens bound to them
Returns the constructor refs of the created composable tokens


<pre><code><b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_create_batch_composables_with_soulbound_traits_internal">create_batch_composables_with_soulbound_traits_internal</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_uri: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;): <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_owned_tokens"></a>

## Function `owned_tokens`

Gets a wallet address plus a list of token addresses, and returns only the owned tokens.


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_owned_tokens">owned_tokens</a>(wallet_addr: <b>address</b>, token_addrs: <a href="">vector</a>&lt;<b>address</b>&gt;): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_type_supply"></a>

## Function `type_supply`

Returns the total supply of a token type and the count of minted tokens of the type; useful for calculating rarity


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_type_supply">type_supply</a>(collection_obj_addr: <b>address</b>, type: <a href="_String">string::String</a>): (u64, u64)
</code></pre>



<a id="0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_variant_supply"></a>

## Function `variant_supply`

Returns the total supply of a token variant and the count of minted tokens of the variant; useful for calculating rarity


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="studio.md#0x326eac5cb552529e610a5d7bdd26bff503782103717bfb6455cfcfd4c1f2c64f_studio_variant_supply">variant_supply</a>(collection_obj_addr: <b>address</b>, type: <a href="_String">string::String</a>, variant: <a href="_String">string::String</a>): (u64, u64)
</code></pre>
