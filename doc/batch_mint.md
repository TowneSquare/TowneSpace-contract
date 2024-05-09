
<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint"></a>

# Module `0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950::batch_mint`



-  [Resource `MintInfo`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfo)
-  [Struct `MintInfoInitialized`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfoInitialized)
-  [Struct `TokensForMintCreated`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokensForMintCreated)
-  [Struct `TokenMinted`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokenMinted)
-  [Constants](#@Constants_0)
-  [Function `create_tokens_for_mint`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint)
-  [Function `mint_tokens`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_tokens)
-  [Function `create_tokens_for_mint_internal`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint_internal)
-  [Function `mint_token`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_token)
-  [Function `mint_batch_tokens`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_batch_tokens)
-  [Function `tokens_for_mint`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_tokens_for_mint)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::from_bcs</a>;
<b>use</b> <a href="">0x1::hash</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::smart_table</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::transaction_context</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x51ad96e82f8a4a5f0e32b7a4ea25ed7672661661a86cac795e41bb8d26cf0721::composable_token</a>;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfo"></a>

## Resource `MintInfo`

Global storage for the minting metadata


<pre><code><b>struct</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfo">MintInfo</a> <b>has</b> key
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfoInitialized"></a>

## Struct `MintInfoInitialized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfoInitialized">MintInfoInitialized</a> <b>has</b> drop, store
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokensForMintCreated"></a>

## Struct `TokensForMintCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokensForMintCreated">TokensForMintCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokenMinted"></a>

## Struct `TokenMinted`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_TokenMinted">TokenMinted</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_EINSUFFICIENT_FUNDS"></a>

Insufficient funds


<pre><code><b>const</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_EINSUFFICIENT_FUNDS">EINSUFFICIENT_FUNDS</a>: u64 = 3;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ELENGTH_MISMATCH"></a>

Vector length mismatch


<pre><code><b>const</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 1;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ETYPE_NOT_RECOGNIZED"></a>

Type not recognized


<pre><code><b>const</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ETYPE_NOT_RECOGNIZED">ETYPE_NOT_RECOGNIZED</a>: u64 = 4;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ETYPE_NOT_SUPPORTED"></a>

Type not supported


<pre><code><b>const</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_ETYPE_NOT_SUPPORTED">ETYPE_NOT_SUPPORTED</a>: u64 = 2;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint"></a>

## Function `create_tokens_for_mint`

Entry Function to create tokens for minting


<pre><code><b>public</b> entry <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint">create_tokens_for_mint</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, token_count: u64, folder_uri: <a href="_String">string::String</a>, mint_price: <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_tokens"></a>

## Function `mint_tokens`

Entry Function to mint tokens


<pre><code><b>public</b> entry <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_tokens">mint_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>, count: u64)
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint_internal"></a>

## Function `create_tokens_for_mint_internal`

Helper function for creating tokens for minting


<pre><code><b>public</b> <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_create_tokens_for_mint_internal">create_tokens_for_mint_internal</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, folder_uri: <a href="_String">string::String</a>, token_count: u64, mint_price: <a href="">vector</a>&lt;u64&gt;): (<a href="">vector</a>&lt;<b>address</b>&gt;, <a href="_Object">object::Object</a>&lt;<a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_MintInfo">batch_mint::MintInfo</a>&gt;)
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_token"></a>

## Function `mint_token`

Helper function for minting a token
Returns the address of the minted token and the mint price


<pre><code><b>public</b> <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_token">mint_token</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>): (<b>address</b>, u64)
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_batch_tokens"></a>

## Function `mint_batch_tokens`

Helper function for minting a batch of tokens


<pre><code><b>public</b> <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_mint_batch_tokens">mint_batch_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, mint_info_obj_addr: <b>address</b>, count: u64): (<a href="">vector</a>&lt;<b>address</b>&gt;, <a href="">vector</a>&lt;u64&gt;)
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_tokens_for_mint"></a>

## Function `tokens_for_mint`

Get a list of tokens available for minting


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="batch_mint.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_batch_mint_tokens_for_mint">tokens_for_mint</a>&lt;T: key&gt;(mint_info_obj_addr: <b>address</b>): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>
