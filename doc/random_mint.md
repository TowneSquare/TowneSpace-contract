
<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint"></a>

# Module `0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454::random_mint`



-  [Resource `MintInfo`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfo)
-  [Struct `MintInfoInitialized`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfoInitialized)
-  [Struct `TokensForMintCreated`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokensForMintCreated)
-  [Struct `TokenMinted`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokenMinted)
-  [Constants](#@Constants_0)
-  [Function `create_tokens_for_mint`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint)
-  [Function `create_composable_tokens_with_soulbound_traits_for_mint`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint)
-  [Function `mint_tokens`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_tokens)
-  [Function `add_tokens_for_mint`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint)
-  [Function `create_composable_tokens_with_soulbound_traits_for_mint_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint_internal)
-  [Function `create_tokens_for_mint_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint_internal)
-  [Function `mint_token`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_token)
-  [Function `mint_batch_tokens`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_batch_tokens)
-  [Function `add_tokens_for_mint_internal`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint_internal)
-  [Function `tokens_for_mint`](#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_tokens_for_mint)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::randomness</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::smart_table</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="studio.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_studio">0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454::studio</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="">0x5fe4421182921f3f4c847bb30127e25138ef463455c5981e7726fa08ce42855e::composable_token</a>;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfo"></a>

## Resource `MintInfo`

Global storage for the minting metadata


<pre><code><b>struct</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfo">MintInfo</a> <b>has</b> key
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfoInitialized"></a>

## Struct `MintInfoInitialized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_MintInfoInitialized">MintInfoInitialized</a> <b>has</b> drop, store
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokensForMintCreated"></a>

## Struct `TokensForMintCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokensForMintCreated">TokensForMintCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokenMinted"></a>

## Struct `TokenMinted`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_TokenMinted">TokenMinted</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ELENGTH_MISMATCH"></a>

Vector length mismatch


<pre><code><b>const</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 1;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_EINSUFFICIENT_FUNDS"></a>

Insufficient funds


<pre><code><b>const</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_EINSUFFICIENT_FUNDS">EINSUFFICIENT_FUNDS</a>: u64 = 3;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ETYPE_NOT_RECOGNIZED"></a>

Type not recognized


<pre><code><b>const</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ETYPE_NOT_RECOGNIZED">ETYPE_NOT_RECOGNIZED</a>: u64 = 4;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ETYPE_NOT_SUPPORTED"></a>

Type not supported


<pre><code><b>const</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_ETYPE_NOT_SUPPORTED">ETYPE_NOT_SUPPORTED</a>: u64 = 2;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint"></a>

## Function `create_tokens_for_mint`

Entry Function to create tokens for minting


<pre><code><b>public</b> entry <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint">create_tokens_for_mint</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;, folder_uri: <a href="_String">string::String</a>, token_count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint"></a>

## Function `create_composable_tokens_with_soulbound_traits_for_mint`

Entry Function to create composable tokens with soulbound traits for minting
Should not accept generic types as it is designed for composable tokens


<pre><code><b>public</b> entry <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint">create_composable_tokens_with_soulbound_traits_for_mint</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_description: <a href="_String">string::String</a>, trait_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_description: <a href="_String">string::String</a>, composable_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, folder_uri: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_tokens"></a>

## Function `mint_tokens`

Entry Function to mint tokens


<pre><code>#[lint::allow_unsafe_randomness]
<b>public</b> entry <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_tokens">mint_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>, count: u64)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint"></a>

## Function `add_tokens_for_mint`

Entry function for adding more tokens for minting


<pre><code><b>public</b> entry <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint">add_tokens_for_mint</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, mint_info_obj_addr: <b>address</b>, description: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;, folder_uri: <a href="_String">string::String</a>, token_count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint_internal"></a>

## Function `create_composable_tokens_with_soulbound_traits_for_mint_internal`

Helper function for creating composable tokens for minting with trait tokens bound to them


<pre><code><b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_composable_tokens_with_soulbound_traits_for_mint_internal">create_composable_tokens_with_soulbound_traits_for_mint_internal</a>(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, trait_description: <a href="_String">string::String</a>, trait_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, trait_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, composable_description: <a href="_String">string::String</a>, composable_uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, composable_property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, count: u64, folder_uri: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;): (<a href="">vector</a>&lt;<b>address</b>&gt;, <a href="">vector</a>&lt;<b>address</b>&gt;, <b>address</b>, <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint_internal"></a>

## Function `create_tokens_for_mint_internal`

Helper function for creating tokens for minting


<pre><code><b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_create_tokens_for_mint_internal">create_tokens_for_mint_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;, folder_uri: <a href="_String">string::String</a>, token_count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): (<a href="">vector</a>&lt;<b>address</b>&gt;, <b>address</b>, <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_token"></a>

## Function `mint_token`

Helper function for minting a token
Returns the address of the minted token and the mint price


<pre><code>#[lint::allow_unsafe_randomness]
<b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_token">mint_token</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>): (<b>address</b>, u64)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_batch_tokens"></a>

## Function `mint_batch_tokens`

Helper function for minting a batch of tokens


<pre><code>#[lint::allow_unsafe_randomness]
<b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_mint_batch_tokens">mint_batch_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>, count: u64): (<a href="">vector</a>&lt;<b>address</b>&gt;, <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint_internal"></a>

## Function `add_tokens_for_mint_internal`

Helper function to create more tokens and add them to the mint_info


<pre><code><b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_add_tokens_for_mint_internal">add_tokens_for_mint_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, mint_info_obj_addr: <b>address</b>, description: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, vec_mint_price: <a href="">vector</a>&lt;u64&gt;, folder_uri: <a href="_String">string::String</a>, token_count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_tokens_for_mint"></a>

## Function `tokens_for_mint`

Get a list of tokens available for minting


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="random_mint.md#0x2b9b97a29e90565915d63bda726f5db2871918497cf15a5f37f7b05fd3f6454_random_mint_tokens_for_mint">tokens_for_mint</a>&lt;T: key&gt;(mint_info_obj_addr: <b>address</b>): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>
