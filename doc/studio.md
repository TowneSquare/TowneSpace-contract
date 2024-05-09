
<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_studio"></a>

# Module `0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950::studio`



-  [Function `mint_tokens`](#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_studio_mint_tokens)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x51ad96e82f8a4a5f0e32b7a4ea25ed7672661661a86cac795e41bb8d26cf0721::composable_token</a>;
</code></pre>



<a id="0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_studio_mint_tokens"></a>

## Function `mint_tokens`

Mint a batch of tokens


<pre><code>entry <b>fun</b> <a href="studio.md#0xe12419559a1285d19b3419ca1561a56b43b79a9ded42e06156f66f70db662950_studio_mint_tokens">mint_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, name_with_index_prefix: <a href="_String">string::String</a>, name_with_index_suffix: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, token_count: u64, folder_uri: <a href="_String">string::String</a>)
</code></pre>
