
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::core`



-  [Resource `Collection`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection)
-  [Resource `Composable`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable)
-  [Resource `Trait`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait)
-  [Resource `References`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_References)
-  [Function `create_collection_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_collection_internal)
-  [Function `create_token_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_token_internal)
-  [Function `equip_trait_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_trait_internal)
-  [Function `equip_fa_to_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_fa_to_token)
-  [Function `unequip_fa_from_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_fa_from_token)
-  [Function `unequip_trait_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_trait_internal)
-  [Function `transfer_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_token)
-  [Function `transfer_fa`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_fa)
-  [Function `burn_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_burn_token)
-  [Function `get_collection_name`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_name)
-  [Function `get_collection_symbol`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_symbol)
-  [Function `get_base_mint_price`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_base_mint_price)
-  [Function `get_traits`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_traits)
-  [Function `get_trait_type`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_trait_type)
-  [Function `borrow_mut_traits`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_borrow_mut_traits)
-  [Function `set_token_name_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_set_token_name_internal)
-  [Function `update_uri_internal`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_update_uri_internal)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::royalty</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::errors</a>;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection"></a>

## Resource `Collection`

Storage state for collections


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection">Collection</a> <b>has</b> key
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable"></a>

## Resource `Composable`

Storage state for composables; aka, the atom/primary of the token


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">Composable</a> <b>has</b> key
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait"></a>

## Resource `Trait`

Storage state for traits


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">Trait</a> <b>has</b> key
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_References"></a>

## Resource `References`

Storage state for token references


<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_References">References</a> <b>has</b> key
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_collection_internal"></a>

## Function `create_collection_internal`

------------------
Internal Functions
------------------
Create a collection


<pre><code><b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_collection_internal">create_collection_internal</a>&lt;T&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64, is_burnable: bool, is_mutable: bool): <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection">core::Collection</a>&gt;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_token_internal"></a>

## Function `create_token_internal`

TODO
fun init_ref(): Option<>{}
Create tokens


<pre><code><b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_create_token_internal">create_token_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, description: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, type: <a href="_String">string::String</a>, traits: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;&gt;, base_mint_price: u64, royalty_numerator: u64, royalty_denominator: u64): <a href="_Object">object::Object</a>&lt;T&gt;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_trait_internal"></a>

## Function `equip_trait_internal`

Compose trait to a composable token


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_trait_internal">equip_trait_internal</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_fa_to_token"></a>

## Function `equip_fa_to_token`

equip fa; transfer fa to a token; token can be either composable or trait


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_equip_fa_to_token">equip_fa_to_token</a>&lt;FA: key, Token: key&gt;(signer_ref: &<a href="">signer</a>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, token_obj: <a href="_Object">object::Object</a>&lt;Token&gt;, amount: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_fa_from_token"></a>

## Function `unequip_fa_from_token`

uequip fa; transfer fa from a token to the owner


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_fa_from_token">unequip_fa_from_token</a>&lt;FA: key, Token: key&gt;(signer_ref: &<a href="">signer</a>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, token_obj: <a href="_Object">object::Object</a>&lt;Token&gt;, amount: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_trait_internal"></a>

## Function `unequip_trait_internal`

Decompose a trait from a composable token. Tests panic.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_unequip_trait_internal">unequip_trait_internal</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_token"></a>

## Function `transfer_token`

transfer digital assets; from user to user.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_token">transfer_token</a>&lt;Token: key&gt;(signer_ref: &<a href="">signer</a>, token_address: <b>address</b>, new_owner: <b>address</b>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_fa"></a>

## Function `transfer_fa`

transfer fa from user to user.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_transfer_fa">transfer_fa</a>&lt;FA: key&gt;(signer_ref: &<a href="">signer</a>, recipient: <b>address</b>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, amount: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_burn_token"></a>

## Function `burn_token`

burn a token


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_burn_token">burn_token</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, token_object: <a href="_Object">object::Object</a>&lt;T&gt;)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_name"></a>

## Function `get_collection_name`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_name">get_collection_name</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection">core::Collection</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_symbol"></a>

## Function `get_collection_symbol`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_collection_symbol">get_collection_symbol</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Collection">core::Collection</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_base_mint_price"></a>

## Function `get_base_mint_price`

get mint price of a token


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_base_mint_price">get_base_mint_price</a>&lt;T: key&gt;(object_address: <b>address</b>): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_traits"></a>

## Function `get_traits`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_traits">get_traits</a>(composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;): <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;&gt;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_trait_type"></a>

## Function `get_trait_type`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_get_trait_type">get_trait_type</a>(trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_borrow_mut_traits"></a>

## Function `borrow_mut_traits`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_borrow_mut_traits">borrow_mut_traits</a>(composable_address: <b>address</b>): <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;&gt;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_set_token_name_internal"></a>

## Function `set_token_name_internal`

--------
Mutators
--------
Change token name


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_set_token_name_internal">set_token_name_internal</a>(signer_ref: &<a href="">signer</a>, token_object_address: <b>address</b>, new_name: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_update_uri_internal"></a>

## Function `update_uri_internal`

Change uri


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_update_uri_internal">update_uri_internal</a>(composable_object_address: <b>address</b>, new_uri: <a href="_String">string::String</a>)
</code></pre>
