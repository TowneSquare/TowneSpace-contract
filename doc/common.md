
<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common"></a>

# Module `0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a::common`



-  [Function `create_sticky_object`](#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_create_sticky_object)
-  [Function `pseudorandom_u64`](#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_pseudorandom_u64)


<pre><code></code></pre>



<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_create_sticky_object"></a>

## Function `create_sticky_object`

Common logic for creating sticky object for the liquid NFTs


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_create_sticky_object">create_sticky_object</a>(caller_address: <b>address</b>): (<a href="_ConstructorRef">object::ConstructorRef</a>, <a href="_ExtendRef">object::ExtendRef</a>, <a href="">signer</a>, <b>address</b>)
</code></pre>



<a id="0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_pseudorandom_u64"></a>

## Function `pseudorandom_u64`

Generate a pseudorandom number

We use AUID to generate a number from the transaction hash and a globally unique
number, which allows us to spin this multiple times in a single transaction.

We use timestamp to ensure that people can't predict it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x801c65c2fee7186f7c730a9880bcbcd52a525c0ec787851db01904ec8ef5ff5a_common_pseudorandom_u64">pseudorandom_u64</a>(size: u64): u64
</code></pre>
