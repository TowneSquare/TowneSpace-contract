
<a id="0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common"></a>

# Module `0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a::common`



-  [Function `create_sticky_object`](#0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_create_sticky_object)
-  [Function `pseudorandom_u64`](#0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_pseudorandom_u64)


<pre><code></code></pre>



<a id="0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_create_sticky_object"></a>

## Function `create_sticky_object`

Common logic for creating sticky object


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_create_sticky_object">create_sticky_object</a>(caller_address: <b>address</b>): (<a href="_ConstructorRef">object::ConstructorRef</a>, <a href="_ExtendRef">object::ExtendRef</a>, <a href="">signer</a>, <b>address</b>)
</code></pre>



<a id="0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_pseudorandom_u64"></a>

## Function `pseudorandom_u64`

Generate a pseudorandom number
We use timestamp to ensure that people can't predict it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0xb24c823511b3fa23edcfa95393184a1fb953b10286869da42dc9159c1ac920a_common_pseudorandom_u64">pseudorandom_u64</a>(size: u64): u64
</code></pre>
