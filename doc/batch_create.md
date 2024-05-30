
<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create"></a>

# Module `0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a::batch_create`



-  [Struct `TokensCreated`](#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_TokensCreated)
-  [Constants](#@Constants_0)
-  [Function `create_batch`](#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch)
-  [Function `create_batch_tokens`](#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch_tokens)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x9a7cfebc7b8366b37f868912d89e6e194e860044ca00a319a74be7d04753ed41::composable_token</a>;
</code></pre>



<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_TokensCreated"></a>

## Struct `TokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="batch_create.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_TokensCreated">TokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_ELENGTH_MISMATCH"></a>

Token names and count length mismatch


<pre><code><b>const</b> <a href="batch_create.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 1;
</code></pre>



<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch"></a>

## Function `create_batch`

Create a batch of tokens


<pre><code><b>public</b> entry <b>fun</b> <a href="batch_create.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch">create_batch</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, folder_uri: <a href="_String">string::String</a>, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch_tokens"></a>

## Function `create_batch_tokens`

Helper function for creating a batch of tokens


<pre><code><b>public</b> <b>fun</b> <a href="batch_create.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_batch_create_create_batch_tokens">create_batch_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, descriptions: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, uri_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_prefix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, name_with_index_suffix: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, folder_uri: <a href="_String">string::String</a>, count: u64, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;<a href="_ConstructorRef">object::ConstructorRef</a>&gt;
</code></pre>
