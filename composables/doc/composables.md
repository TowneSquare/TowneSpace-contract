
<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables"></a>

# Module `0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee::composables`



-  [Resource `Collection`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection)
-  [Resource `Composable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable)
-  [Resource `Trait`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait)
-  [Resource `DA`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA)
-  [Resource `References`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_References)
-  [Resource `Indexed`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Indexed)
-  [Resource `Named`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Named)
-  [Resource `Equip`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Equip)
-  [Resource `Unequip`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Unequip)
-  [Struct `CollectionMetadata`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionMetadata)
-  [Struct `CollectionCreatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionCreatedEvent)
-  [Struct `TokenBurnedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenBurnedEvent)
-  [Struct `TokenDescriptionUpdatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenDescriptionUpdatedEvent)
-  [Struct `TokenNameUpdatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenNameUpdatedEvent)
-  [Struct `TokenUriUpdatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenUriUpdatedEvent)
-  [Struct `PropertyAddedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyAddedEvent)
-  [Struct `TypedPropertyAddedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TypedPropertyAddedEvent)
-  [Struct `PropertyRemovedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyRemovedEvent)
-  [Struct `PropertyUpdatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyUpdatedEvent)
-  [Struct `ComposableMetadata`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableMetadata)
-  [Struct `ComposableCreatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableCreatedEvent)
-  [Struct `TraitMetadata`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitMetadata)
-  [Struct `TraitCreatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitCreatedEvent)
-  [Struct `DAMetadata`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DAMetadata)
-  [Struct `DACreatedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DACreatedEvent)
-  [Struct `TraitEquippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitEquippedEvent)
-  [Struct `TraitUnequippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitUnequippedEvent)
-  [Struct `TokenMetadata`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenMetadata)
-  [Struct `DigitalAssetEquippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetEquippedEvent)
-  [Struct `DigitalAssetUnequippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetUnequippedEvent)
-  [Struct `FAEquippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAEquippedEvent)
-  [Struct `FAUnequippedEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAUnequippedEvent)
-  [Struct `TokenTransferredEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenTransferredEvent)
-  [Struct `FATransferredEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FATransferredEvent)
-  [Struct `TransferFrozenEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferFrozenEvent)
-  [Struct `TransferUnfrozenEvent`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferUnfrozenEvent)
-  [Constants](#@Constants_0)
-  [Function `create_collection`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_collection)
-  [Function `create_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_token)
-  [Function `equip_trait`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_trait)
-  [Function `equip_digital_asset`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset)
-  [Function `equip_digital_asset_to_trait`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset_to_trait)
-  [Function `unequip_digital_asset_from_composable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_composable)
-  [Function `unequip_digital_asset_from_trait`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_trait)
-  [Function `equip_fa_to_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_fa_to_token)
-  [Function `unequip_fa_from_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_fa_from_token)
-  [Function `unequip_trait`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_trait)
-  [Function `transfer_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_token)
-  [Function `transfer_fa`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_fa)
-  [Function `is_mutable_collection_description`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_description)
-  [Function `is_mutable_collection_royalty`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_royalty)
-  [Function `is_mutable_collection_uri`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_uri)
-  [Function `is_mutable_collection_token_description`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_description)
-  [Function `is_mutable_collection_token_name`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_name)
-  [Function `is_mutable_collection_token_uri`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_uri)
-  [Function `is_mutable_collection_token_properties`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_properties)
-  [Function `are_collection_tokens_burnable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_burnable)
-  [Function `are_collection_tokens_freezable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_freezable)
-  [Function `get_collection_name`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_name)
-  [Function `get_collection_symbol`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_symbol)
-  [Function `get_collection_supply_type`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_supply_type)
-  [Function `get_parent_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_parent_token)
-  [Function `get_index`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_index)
-  [Function `get_traits_from_composable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_traits_from_composable)
-  [Function `are_properties_mutable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_properties_mutable)
-  [Function `is_burnable`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_burnable)
-  [Function `is_freezable_by_creator`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_freezable_by_creator)
-  [Function `is_mutable_description`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_description)
-  [Function `is_mutable_name`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_name)
-  [Function `is_mutable_uri`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_uri)
-  [Function `get_token_signer`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_token_signer)
-  [Function `burn_token`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_burn_token)
-  [Function `freeze_transfer`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_freeze_transfer)
-  [Function `unfreeze_transfer`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unfreeze_transfer)
-  [Function `set_description`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_description)
-  [Function `set_name`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_name)
-  [Function `set_trait_uri`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_trait_uri)
-  [Function `add_property`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_property)
-  [Function `add_typed_property`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_typed_property)
-  [Function `remove_property`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_remove_property)
-  [Function `update_property`](#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_update_property)


<pre><code><b>use</b> <a href="">0x1::error</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::property_map</a>;
<b>use</b> <a href="">0x4::royalty</a>;
<b>use</b> <a href="">0x4::token</a>;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection"></a>

## Resource `Collection`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection">Collection</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable"></a>

## Resource `Composable`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">Composable</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait"></a>

## Resource `Trait`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">Trait</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA"></a>

## Resource `DA`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA">DA</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_References"></a>

## Resource `References`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_References">References</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Indexed"></a>

## Resource `Indexed`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Indexed">Indexed</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Named"></a>

## Resource `Named`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Named">Named</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Equip"></a>

## Resource `Equip`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Equip">Equip</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Unequip"></a>

## Resource `Unequip`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Unequip">Unequip</a> <b>has</b> key
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionMetadata"></a>

## Struct `CollectionMetadata`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionMetadata">CollectionMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionCreatedEvent"></a>

## Struct `CollectionCreatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_CollectionCreatedEvent">CollectionCreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenBurnedEvent"></a>

## Struct `TokenBurnedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenBurnedEvent">TokenBurnedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenDescriptionUpdatedEvent"></a>

## Struct `TokenDescriptionUpdatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenDescriptionUpdatedEvent">TokenDescriptionUpdatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenNameUpdatedEvent"></a>

## Struct `TokenNameUpdatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenNameUpdatedEvent">TokenNameUpdatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenUriUpdatedEvent"></a>

## Struct `TokenUriUpdatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenUriUpdatedEvent">TokenUriUpdatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyAddedEvent"></a>

## Struct `PropertyAddedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyAddedEvent">PropertyAddedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TypedPropertyAddedEvent"></a>

## Struct `TypedPropertyAddedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TypedPropertyAddedEvent">TypedPropertyAddedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyRemovedEvent"></a>

## Struct `PropertyRemovedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyRemovedEvent">PropertyRemovedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyUpdatedEvent"></a>

## Struct `PropertyUpdatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_PropertyUpdatedEvent">PropertyUpdatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableMetadata"></a>

## Struct `ComposableMetadata`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableMetadata">ComposableMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableCreatedEvent"></a>

## Struct `ComposableCreatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ComposableCreatedEvent">ComposableCreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitMetadata"></a>

## Struct `TraitMetadata`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitMetadata">TraitMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitCreatedEvent"></a>

## Struct `TraitCreatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitCreatedEvent">TraitCreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DAMetadata"></a>

## Struct `DAMetadata`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DAMetadata">DAMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DACreatedEvent"></a>

## Struct `DACreatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DACreatedEvent">DACreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitEquippedEvent"></a>

## Struct `TraitEquippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitEquippedEvent">TraitEquippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitUnequippedEvent"></a>

## Struct `TraitUnequippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TraitUnequippedEvent">TraitUnequippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenMetadata"></a>

## Struct `TokenMetadata`



<pre><code><b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenMetadata">TokenMetadata</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetEquippedEvent"></a>

## Struct `DigitalAssetEquippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetEquippedEvent">DigitalAssetEquippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetUnequippedEvent"></a>

## Struct `DigitalAssetUnequippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DigitalAssetUnequippedEvent">DigitalAssetUnequippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAEquippedEvent"></a>

## Struct `FAEquippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAEquippedEvent">FAEquippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAUnequippedEvent"></a>

## Struct `FAUnequippedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FAUnequippedEvent">FAUnequippedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenTransferredEvent"></a>

## Struct `TokenTransferredEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TokenTransferredEvent">TokenTransferredEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FATransferredEvent"></a>

## Struct `FATransferredEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_FATransferredEvent">FATransferredEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferFrozenEvent"></a>

## Struct `TransferFrozenEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferFrozenEvent">TransferFrozenEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferUnfrozenEvent"></a>

## Struct `TransferUnfrozenEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_TransferUnfrozenEvent">TransferUnfrozenEvent</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ENOT_OWNER"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ENOT_OWNER">ENOT_OWNER</a>: u64 = 10;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ECOLLECTION_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ECOLLECTION_DOES_NOT_EXIST">ECOLLECTION_DOES_NOT_EXIST</a>: u64 = 3;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EFIELD_NOT_MUTABLE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EFIELD_NOT_MUTABLE">EFIELD_NOT_MUTABLE</a>: u64 = 7;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ENOT_CREATOR"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ENOT_CREATOR">ENOT_CREATOR</a>: u64 = 6;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ECOMPOSABLE_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ECOMPOSABLE_DOES_NOT_EXIST">ECOMPOSABLE_DOES_NOT_EXIST</a>: u64 = 4;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EDA_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EDA_DOES_NOT_EXIST">EDA_DOES_NOT_EXIST</a>: u64 = 12;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EPROPERTIES_NOT_MUTABLE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EPROPERTIES_NOT_MUTABLE">EPROPERTIES_NOT_MUTABLE</a>: u64 = 8;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EREFS_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EREFS_DOES_NOT_EXIST">EREFS_DOES_NOT_EXIST</a>: u64 = 11;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ETRAIT_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_ETRAIT_DOES_NOT_EXIST">ETRAIT_DOES_NOT_EXIST</a>: u64 = 5;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNGATED_TRANSFER_DISABLED"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNGATED_TRANSFER_DISABLED">EUNGATED_TRANSFER_DISABLED</a>: u64 = 9;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_COLLECTION_TYPE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_COLLECTION_TYPE">EUNKNOWN_COLLECTION_TYPE</a>: u64 = 0;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_NAMING_TYPE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_NAMING_TYPE">EUNKNOWN_NAMING_TYPE</a>: u64 = 2;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_PROCESS_TYPE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_PROCESS_TYPE">EUNKNOWN_PROCESS_TYPE</a>: u64 = 13;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_TOKEN_TYPE"></a>



<pre><code><b>const</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_EUNKNOWN_TOKEN_TYPE">EUNKNOWN_TOKEN_TYPE</a>: u64 = 1;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_collection"></a>

## Function `create_collection`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_collection">create_collection</a>&lt;SupplyType: key&gt;(signer_ref: &<a href="">signer</a>, description: <a href="_String">string::String</a>, max_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, name: <a href="_String">string::String</a>, symbol: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, mutable_description: bool, mutable_royalty: bool, mutable_uri: bool, mutable_token_description: bool, mutable_token_name: bool, mutable_token_properties: bool, mutable_token_uri: bool, tokens_burnable_by_creator: bool, tokens_freezable_by_creator: bool, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;): <a href="_ConstructorRef">object::ConstructorRef</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_token"></a>

## Function `create_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_create_token">create_token</a>&lt;Type: key, NamingStyle: key&gt;(signer_ref: &<a href="">signer</a>, <a href="">collection</a>: <a href="_String">string::String</a>, description: <a href="_String">string::String</a>, name: <a href="_String">string::String</a>, name_with_index_prefix: <a href="_String">string::String</a>, name_with_index_suffix: <a href="_String">string::String</a>, uri: <a href="_String">string::String</a>, royalty_numerator: <a href="_Option">option::Option</a>&lt;u64&gt;, royalty_denominator: <a href="_Option">option::Option</a>&lt;u64&gt;, property_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_types: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, property_values: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="_ConstructorRef">object::ConstructorRef</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_trait"></a>

## Function `equip_trait`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_trait">equip_trait</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">composables::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset"></a>

## Function `equip_digital_asset`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset">equip_digital_asset</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">composables::Composable</a>&gt;, da_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA">composables::DA</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset_to_trait"></a>

## Function `equip_digital_asset_to_trait`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_digital_asset_to_trait">equip_digital_asset_to_trait</a>(signer_ref: &<a href="">signer</a>, trait_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;, da_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA">composables::DA</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_composable"></a>

## Function `unequip_digital_asset_from_composable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_composable">unequip_digital_asset_from_composable</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">composables::Composable</a>&gt;, da_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA">composables::DA</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_trait"></a>

## Function `unequip_digital_asset_from_trait`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_digital_asset_from_trait">unequip_digital_asset_from_trait</a>(signer_ref: &<a href="">signer</a>, trait_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;, da_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_DA">composables::DA</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_fa_to_token"></a>

## Function `equip_fa_to_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_equip_fa_to_token">equip_fa_to_token</a>&lt;FA: key, Token: key&gt;(signer_ref: &<a href="">signer</a>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, token_obj: <a href="_Object">object::Object</a>&lt;Token&gt;, amount: u64)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_fa_from_token"></a>

## Function `unequip_fa_from_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_fa_from_token">unequip_fa_from_token</a>&lt;FA: key, Token: key&gt;(signer_ref: &<a href="">signer</a>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, token_obj: <a href="_Object">object::Object</a>&lt;Token&gt;, amount: u64)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_trait"></a>

## Function `unequip_trait`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unequip_trait">unequip_trait</a>(signer_ref: &<a href="">signer</a>, composable_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">composables::Composable</a>&gt;, trait_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;, new_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_token"></a>

## Function `transfer_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_token">transfer_token</a>&lt;Token: key&gt;(signer_ref: &<a href="">signer</a>, token_addr: <b>address</b>, new_owner: <b>address</b>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_fa"></a>

## Function `transfer_fa`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_transfer_fa">transfer_fa</a>&lt;FA: key&gt;(signer_ref: &<a href="">signer</a>, recipient: <b>address</b>, fa: <a href="_Object">object::Object</a>&lt;FA&gt;, amount: u64)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_description"></a>

## Function `is_mutable_collection_description`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_description">is_mutable_collection_description</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_royalty"></a>

## Function `is_mutable_collection_royalty`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_royalty">is_mutable_collection_royalty</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_uri"></a>

## Function `is_mutable_collection_uri`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_uri">is_mutable_collection_uri</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_description"></a>

## Function `is_mutable_collection_token_description`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_description">is_mutable_collection_token_description</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_name"></a>

## Function `is_mutable_collection_token_name`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_name">is_mutable_collection_token_name</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_uri"></a>

## Function `is_mutable_collection_token_uri`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_uri">is_mutable_collection_token_uri</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_properties"></a>

## Function `is_mutable_collection_token_properties`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_collection_token_properties">is_mutable_collection_token_properties</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_burnable"></a>

## Function `are_collection_tokens_burnable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_burnable">are_collection_tokens_burnable</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_freezable"></a>

## Function `are_collection_tokens_freezable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_collection_tokens_freezable">are_collection_tokens_freezable</a>&lt;T: key&gt;(<a href="">collection</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_name"></a>

## Function `get_collection_name`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_name">get_collection_name</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection">composables::Collection</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_symbol"></a>

## Function `get_collection_symbol`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_symbol">get_collection_symbol</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection">composables::Collection</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_supply_type"></a>

## Function `get_collection_supply_type`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_collection_supply_type">get_collection_supply_type</a>(collection_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Collection">composables::Collection</a>&gt;): <a href="_String">string::String</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_parent_token"></a>

## Function `get_parent_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_parent_token">get_parent_token</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): <b>address</b>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_index"></a>

## Function `get_index`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_index">get_index</a>&lt;T: key&gt;(token_obj: <a href="_Object">object::Object</a>&lt;T&gt;): u64
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_traits_from_composable"></a>

## Function `get_traits_from_composable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_traits_from_composable">get_traits_from_composable</a>(composable_object: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Composable">composables::Composable</a>&gt;): <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;&gt;
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_properties_mutable"></a>

## Function `are_properties_mutable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_are_properties_mutable">are_properties_mutable</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_burnable"></a>

## Function `is_burnable`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_burnable">is_burnable</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_freezable_by_creator"></a>

## Function `is_freezable_by_creator`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_freezable_by_creator">is_freezable_by_creator</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_description"></a>

## Function `is_mutable_description`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_description">is_mutable_description</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_name"></a>

## Function `is_mutable_name`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_name">is_mutable_name</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_uri"></a>

## Function `is_mutable_uri`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_is_mutable_uri">is_mutable_uri</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): bool
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_token_signer"></a>

## Function `get_token_signer`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_get_token_signer">get_token_signer</a>&lt;T: key&gt;(<a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;): <a href="">signer</a>
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_burn_token"></a>

## Function `burn_token`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_burn_token">burn_token</a>&lt;Type: key&gt;(owner: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;Type&gt;)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_freeze_transfer"></a>

## Function `freeze_transfer`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_freeze_transfer">freeze_transfer</a>&lt;T: key&gt;(creator: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unfreeze_transfer"></a>

## Function `unfreeze_transfer`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_unfreeze_transfer">unfreeze_transfer</a>&lt;T: key&gt;(creator: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_description"></a>

## Function `set_description`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_description">set_description</a>&lt;T: key&gt;(creator: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, description: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_name"></a>

## Function `set_name`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_name">set_name</a>&lt;T: key&gt;(creator: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, name: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_trait_uri"></a>

## Function `set_trait_uri`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_set_trait_uri">set_trait_uri</a>(owner: &<a href="">signer</a>, trait_obj: <a href="_Object">object::Object</a>&lt;<a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_Trait">composables::Trait</a>&gt;, uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_property"></a>

## Function `add_property`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_property">add_property</a>&lt;T: key&gt;(owner: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, key: <a href="_String">string::String</a>, type: <a href="_String">string::String</a>, value: <a href="">vector</a>&lt;u8&gt;)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_typed_property"></a>

## Function `add_typed_property`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_add_typed_property">add_typed_property</a>&lt;T: key, V: drop&gt;(owner: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, key: <a href="_String">string::String</a>, value: V)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_remove_property"></a>

## Function `remove_property`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_remove_property">remove_property</a>&lt;T: key&gt;(owner: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, key: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_update_property"></a>

## Function `update_property`



<pre><code><b>public</b> <b>fun</b> <a href="composables.md#0x4d8dd898c13ab06a4897d2fdedb478cf7ac4d3e530d1daa5741c9b9d9ea15ee_composables_update_property">update_property</a>&lt;T: key&gt;(owner: &<a href="">signer</a>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;T&gt;, key: <a href="_String">string::String</a>, value: <a href="">vector</a>&lt;u8&gt;)
</code></pre>
