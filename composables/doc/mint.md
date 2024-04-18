
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::mint`



-  [Function `initialize`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_initialize)
-  [Function `create_fixed_supply_collection`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_fixed_supply_collection)
-  [Function `create_unlimited_supply_collection`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_unlimited_supply_collection)
-  [Function `create_composable_tokens`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_composable_tokens)
-  [Function `create_trait_tokens`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_trait_tokens)
-  [Function `mint_token`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_mint_token)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="core.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_core">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::core</a>;
<b>use</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::errors</a>;
<b>use</b> <a href="events.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_events">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::events</a>;
<b>use</b> <a href="resource_manager.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager">0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::resource_manager</a>;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_initialize">initialize</a>(signer_ref: &<a href="">signer</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_fixed_supply_collection"></a>

## Function `create_fixed_supply_collection`

-------------------------
Creator related functions
-------------------------
create a new collection given metadata and a total number of supply (if it's a fixed supply collection).


<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_fixed_supply_collection">create_fixed_supply_collection</a>(creator_signer: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: u64, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64, is_burnable: bool, is_mutable: bool)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_unlimited_supply_collection"></a>

## Function `create_unlimited_supply_collection`



<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_unlimited_supply_collection">create_unlimited_supply_collection</a>(creator_signer: &<a href="">signer</a>, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64, is_burnable: bool, is_mutable: bool)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_composable_tokens"></a>

## Function `create_composable_tokens`

mint NFTs given a metadata and a number of tokens to mint; can either mint traits or composables.


<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_composable_tokens">create_composable_tokens</a>(creator_signer: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, number_of_tokens_to_mint: u64, description: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, base_mint_price: u64, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_trait_tokens"></a>

## Function `create_trait_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_create_trait_tokens">create_trait_tokens</a>(creator_signer: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, number_of_tokens_to_mint: u64, description: <a href="_String">string::String</a>, type: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, base_mint_price: u64, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_mint_token"></a>

## Function `mint_token`

------------------------
Minter related functions
------------------------
Assuming an NFT is already created, this function transfers it to the minter/caller
the minter pays the mint price to the creator


<pre><code><b>public</b> entry <b>fun</b> <a href="mint.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_mint_mint_token">mint_token</a>&lt;Type: key&gt;(signer_ref: &<a href="">signer</a>, token_addr: <b>address</b>)
</code></pre>
