
<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate"></a>

# Module `0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234::token_migrate`



-  [Struct `TokenMigratedFromV1toV2`](#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_TokenMigratedFromV1toV2)
-  [Constants](#@Constants_0)
-  [Function `init`](#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_init)
-  [Function `from_v1_to_v2_by_owner`](#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_owner)
-  [Function `from_v1_to_v2_by_creator`](#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_creator)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x3::token</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::royalty</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="resource_manager.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_resource_manager">0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234::resource_manager</a>;
</code></pre>



<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_TokenMigratedFromV1toV2"></a>

## Struct `TokenMigratedFromV1toV2`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_TokenMigratedFromV1toV2">TokenMigratedFromV1toV2</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_BURNABLE_BY_CREATOR"></a>



<pre><code><b>const</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_BURNABLE_BY_CREATOR">BURNABLE_BY_CREATOR</a>: <a href="">vector</a>&lt;u8&gt; = [84, 79, 75, 69, 78, 95, 66, 85, 82, 78, 65, 66, 76, 69, 95, 66, 89, 95, 67, 82, 69, 65, 84, 79, 82];
</code></pre>



<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_BURNABLE_BY_OWNER"></a>



<pre><code><b>const</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_BURNABLE_BY_OWNER">BURNABLE_BY_OWNER</a>: <a href="">vector</a>&lt;u8&gt; = [84, 79, 75, 69, 78, 95, 66, 85, 82, 78, 65, 66, 76, 69, 95, 66, 89, 95, 79, 87, 78, 69, 82];
</code></pre>



<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_init"></a>

## Function `init`



<pre><code><b>public</b> entry <b>fun</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_init">init</a>(signer_ref: &<a href="">signer</a>, uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_owner"></a>

## Function `from_v1_to_v2_by_owner`



<pre><code><b>public</b> entry <b>fun</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_owner">from_v1_to_v2_by_owner</a>(signer_ref: &<a href="">signer</a>, creator_addr: <b>address</b>, collection_name: <a href="_String">string::String</a>, token_name: <a href="_String">string::String</a>, property_version: u64)
</code></pre>



<a id="0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_creator"></a>

## Function `from_v1_to_v2_by_creator`



<pre><code><b>public</b> entry <b>fun</b> <a href="token_migrate.md#0xc602d1c7f5770993c74463576a11385529d8dc23892d407049c77b0f49a15234_token_migrate_from_v1_to_v2_by_creator">from_v1_to_v2_by_creator</a>(creator_signer_ref: &<a href="">signer</a>, owner_addr: <b>address</b>, collection_name: <a href="_String">string::String</a>, token_name: <a href="_String">string::String</a>, property_version: u64)
</code></pre>
