
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::studio`



-  [Function `create_collection`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_collection)
-  [Function `create_composable_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_composable_token)
-  [Function `create_trait_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_trait_token)
-  [Function `burn_composable_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_composable_token)
-  [Function `burn_trait_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_trait_token)
-  [Function `equip_trait`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_equip_trait)
-  [Function `unequip_trait`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_unequip_trait)
-  [Function `decompose_entire_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_decompose_entire_token)
-  [Function `transfer_digital_asset`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_digital_asset)
-  [Function `transfer_fungible_asset`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_fungible_asset)
-  [Function `set_token_name`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_set_token_name)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::core</a>;
<b>use</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::events</a>;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_collection"></a>

## Function `create_collection`

---------------
Entry Functions
---------------
Create a new collection


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_collection">create_collection</a>&lt;T: key&gt;(creator_signer: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64, is_burnable: bool, is_mutable: bool)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_composable_token"></a>

## Function `create_composable_token`

create a composable token


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_composable_token">create_composable_token</a>(creator_signer: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, description: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, base_mint_price: u64, traits: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;&gt;, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_trait_token"></a>

## Function `create_trait_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_create_trait_token">create_trait_token</a>(creator_signer: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, description: <a href="_String">string::String</a>, type: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, base_mint_price: u64, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_composable_token"></a>

## Function `burn_composable_token`

Burn token


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_composable_token">burn_composable_token</a>(signer_ref: &<a href="">signer</a>, token_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_trait_token"></a>

## Function `burn_trait_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_burn_trait_token">burn_trait_token</a>(signer_ref: &<a href="">signer</a>, token_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_equip_trait"></a>

## Function `equip_trait`

Compose one object


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_equip_trait">equip_trait</a>(owner_signer: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_unequip_trait"></a>

## Function `unequip_trait`

Decompose one object


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_unequip_trait">unequip_trait</a>(owner_signer: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Trait">core::Trait</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_decompose_entire_token"></a>

## Function `decompose_entire_token`

Decompose an entire composable token
TODO: should be tested


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_decompose_entire_token">decompose_entire_token</a>(owner_signer: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core_Composable">core::Composable</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_digital_asset"></a>

## Function `transfer_digital_asset`

Directly transfer a token to a user.


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_digital_asset">transfer_digital_asset</a>&lt;T: key&gt;(owner_signer: &<a href="">signer</a>, token_address: <b>address</b>, new_owner_address: <b>address</b>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_fungible_asset"></a>

## Function `transfer_fungible_asset`

Directly transfer a token to a user.


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_transfer_fungible_asset">transfer_fungible_asset</a>&lt;FA: key&gt;(signer_ref: &<a href="">signer</a>, recipient: <b>address</b>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, amount: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_set_token_name"></a>

## Function `set_token_name`

--------
Mutators
--------
set token name


<pre><code><b>public</b> entry <b>fun</b> <a href="studio.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_studio_set_token_name">set_token_name</a>(signer_ref: &<a href="">signer</a>, token_object_address: <b>address</b>, new_name: <a href="_String">string::String</a>)
</code></pre>
