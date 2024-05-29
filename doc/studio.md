
<a id="0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio"></a>

# Module `0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37::studio`



-  [Struct `TokensCreated`](#0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_TokensCreated)
-  [Function `mint_tokens`](#0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_mint_tokens)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0xe3f938b1a3bd9ae7b890c06629b092409ca3adcaa48a3b393b4f142652b7ff57::composable_token</a>;
</code></pre>



<a id="0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_TokensCreated"></a>

## Struct `TokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="studio.md#0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_TokensCreated">TokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_mint_tokens"></a>

## Function `mint_tokens`

Mint a batch of tokens


<pre><code>entry <b>fun</b> <a href="studio.md#0xaefe1195386f4dd4cf819f8a193a15edb5f64c6d09d77539d2b36ec08f653c37_studio_mint_tokens">mint_tokens</a>&lt;T: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">composable_token::Collection</a>&gt;, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, name_with_index_prefix: <a href="_String">string::String</a>, name_with_index_suffix: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, token_count: u64, folder_uri: <a href="_String">string::String</a>)
</code></pre>
