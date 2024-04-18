
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::resource_manager`



-  [Resource `PermissionConfig`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_PermissionConfig)
-  [Function `initialize`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_initialize)
-  [Function `get_signer`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_signer)
-  [Function `get_resource_address`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_resource_address)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::signer</a>;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_PermissionConfig"></a>

## Resource `PermissionConfig`

Stores permission config such as SignerCapability for controlling the resource account.


<pre><code><b>struct</b> <a href="resource_manager.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_PermissionConfig">PermissionConfig</a> <b>has</b> key
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_initialize"></a>

## Function `initialize`

Initialize PermissionConfig to establish control over the resource account.
This function is invoked only when this resource is deployed the first time.


<pre><code><b>public</b> entry <b>fun</b> <a href="resource_manager.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_initialize">initialize</a>(deployer: &<a href="">signer</a>)
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_signer"></a>

## Function `get_signer`

Can be called by friended modules to obtain the resource account signer.
Function will panic if the module is not friended or does not exist.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_manager.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_signer">get_signer</a>(): <a href="">signer</a>
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_resource_address"></a>

## Function `get_resource_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="resource_manager.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_resource_manager_get_resource_address">get_resource_address</a>(): <b>address</b>
</code></pre>
