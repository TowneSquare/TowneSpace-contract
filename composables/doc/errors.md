
<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors"></a>

# Module `0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62::errors`



-  [Constants](#@Constants_0)
-  [Function `type_not_recognized`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_type_not_recognized)
-  [Function `ungated_transfer_disabled`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_ungated_transfer_disabled)
-  [Function `token_not_found`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_token_not_found)
-  [Function `is_owner`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_is_owner)
-  [Function `recipient_should_be_account`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_recipient_should_be_account)
-  [Function `not_owner`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_owner)
-  [Function `not_townespace`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_townespace)
-  [Function `insufficient_funds`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_insufficient_funds)
-  [Function `mint_info_not_found`](#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_mint_info_not_found)


<pre><code><b>use</b> <a href="">0x1::error</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_ALREADY_OWNER"></a>

Already owner


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_ALREADY_OWNER">E_ALREADY_OWNER</a>: u64 = 7;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_INSUFFICIENT_FUNDS"></a>

Insufficient funds


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_INSUFFICIENT_FUNDS">E_INSUFFICIENT_FUNDS</a>: u64 = 9;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_INTERNAL"></a>

Internal error


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_INTERNAL">E_INTERNAL</a>: u64 = 10;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_NOT_OWNER"></a>

Sender is not the owner


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_NOT_OWNER">E_NOT_OWNER</a>: u64 = 5;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_NOT_TOWNESPACE"></a>

Not townespace


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_NOT_TOWNESPACE">E_NOT_TOWNESPACE</a>: u64 = 8;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_RECIPIENT_SHOULD_BE_ACCOUNT"></a>

Recipient should be an account


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_RECIPIENT_SHOULD_BE_ACCOUNT">E_RECIPIENT_SHOULD_BE_ACCOUNT</a>: u64 = 6;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TOKEN_DOES_NOT_EXIST"></a>

Token does not exist


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TOKEN_DOES_NOT_EXIST">E_TOKEN_DOES_NOT_EXIST</a>: u64 = 4;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TOKEN_NOT_BURNABLE"></a>

Token is not burnable


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TOKEN_NOT_BURNABLE">E_TOKEN_NOT_BURNABLE</a>: u64 = 3;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TYPE_NOT_RECOGNIZED"></a>

Token type is not recognized


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_TYPE_NOT_RECOGNIZED">E_TYPE_NOT_RECOGNIZED</a>: u64 = 1;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_UNGATED_TRANSFER_DISABLED"></a>

Ungated transfer is disabled


<pre><code><b>const</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_E_UNGATED_TRANSFER_DISABLED">E_UNGATED_TRANSFER_DISABLED</a>: u64 = 2;
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_type_not_recognized"></a>

## Function `type_not_recognized`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_type_not_recognized">type_not_recognized</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_ungated_transfer_disabled"></a>

## Function `ungated_transfer_disabled`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_ungated_transfer_disabled">ungated_transfer_disabled</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_token_not_found"></a>

## Function `token_not_found`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_token_not_found">token_not_found</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_is_owner"></a>

## Function `is_owner`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_is_owner">is_owner</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_recipient_should_be_account"></a>

## Function `recipient_should_be_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_recipient_should_be_account">recipient_should_be_account</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_owner"></a>

## Function `not_owner`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_owner">not_owner</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_townespace"></a>

## Function `not_townespace`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_not_townespace">not_townespace</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_insufficient_funds"></a>

## Function `insufficient_funds`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_insufficient_funds">insufficient_funds</a>(): u64
</code></pre>



<a id="0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_mint_info_not_found"></a>

## Function `mint_info_not_found`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="errors.md#0x62161ae07778f042f4baf6d7af7b9b95e9bc24c57f311159a1ef68edc622be62_errors_mint_info_not_found">mint_info_not_found</a>(): u64
</code></pre>
