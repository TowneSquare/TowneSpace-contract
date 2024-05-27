
<a id="0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager"></a>

# Module `0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de::resource_manager`



-  [Resource `PermissionConfig`](#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_PermissionConfig)
-  [Function `initialize`](#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_initialize)
-  [Function `resource_signer`](#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_signer)
-  [Function `resource_address`](#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_address)


<pre><code><b>use</b> <a href="">0x1::account</a>;
<b>use</b> <a href="">0x1::signer</a>;
</code></pre>



<a id="0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_PermissionConfig"></a>

## Resource `PermissionConfig`

Stores permission config such as SignerCapability for controlling the resource account.


<pre><code><b>struct</b> <a href="resource_manager.md#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_PermissionConfig">PermissionConfig</a> <b>has</b> key
</code></pre>



<a id="0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_initialize"></a>

## Function `initialize`

Initialize PermissionConfig to establish control over the resource account.
This function is invoked only when this resource is deployed the first time.


<pre><code><b>public</b> entry <b>fun</b> <a href="resource_manager.md#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_initialize">initialize</a>(deployer: &<a href="">signer</a>)
</code></pre>



<a id="0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_signer"></a>

## Function `resource_signer`

Can be called by friended modules to obtain the resource account signer.
Function will panic if the module is not friended or does not exist.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="resource_manager.md#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_signer">resource_signer</a>(): <a href="">signer</a>
</code></pre>



<a id="0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_address"></a>

## Function `resource_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="resource_manager.md#0x8ccfe7bf29ea35b26c2d42b1ff05acfbd6283ba5970bdb1ffca8110224adc5de_resource_manager_resource_address">resource_address</a>(): <b>address</b>
</code></pre>
