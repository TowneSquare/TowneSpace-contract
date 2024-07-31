
<a id="0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common"></a>

# Module `0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374::common`



-  [Function `create_sticky_object`](#0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_create_sticky_object)
-  [Function `pseudorandom_u64`](#0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_pseudorandom_u64)


<pre><code></code></pre>



<a id="0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_create_sticky_object"></a>

## Function `create_sticky_object`

Common logic for creating sticky object


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_create_sticky_object">create_sticky_object</a>(caller_address: <b>address</b>): (<a href="_ConstructorRef">object::ConstructorRef</a>, <a href="_ExtendRef">object::ExtendRef</a>, <a href="">signer</a>, <b>address</b>)
</code></pre>



<a id="0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_pseudorandom_u64"></a>

## Function `pseudorandom_u64`

Generate a pseudorandom number
We use timestamp to ensure that people can't predict it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x5094651b0c628ceea4d38ce64e08965f15f5c1c010fe33d1b2ec991638251374_common_pseudorandom_u64">pseudorandom_u64</a>(size: u64): u64
</code></pre>
