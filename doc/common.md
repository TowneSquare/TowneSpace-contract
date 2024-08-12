
<a id="0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common"></a>

# Module `0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0::common`



-  [Function `create_sticky_object`](#0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_create_sticky_object)
-  [Function `pseudorandom_u64`](#0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_pseudorandom_u64)


<pre><code></code></pre>



<a id="0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_create_sticky_object"></a>

## Function `create_sticky_object`

Common logic for creating sticky object


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_create_sticky_object">create_sticky_object</a>(caller_address: <b>address</b>): (<a href="_ConstructorRef">object::ConstructorRef</a>, <a href="_ExtendRef">object::ExtendRef</a>, <a href="">signer</a>, <b>address</b>)
</code></pre>



<a id="0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_pseudorandom_u64"></a>

## Function `pseudorandom_u64`

Generate a pseudorandom number
We use timestamp to ensure that people can't predict it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x7e0b68ab33fe8446cd0036f7aab93cb469e2d5405c812f5e18326529052dd3c0_common_pseudorandom_u64">pseudorandom_u64</a>(size: u64): u64
</code></pre>
