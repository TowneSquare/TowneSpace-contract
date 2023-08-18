# Findings

## Aptos_token is what we need

### Current approach
- Relies on building structs on top of `aptos_token` but not leveraging it at the fullest.
- These structs named `ComposableToken` and `TraitToken` are tokenV2s in essence however customised based on our needs.
- We didn't really make use of `mutator_ref`or mappings. This was only set for future mutation (in case the creator wants to add traits).

``` rust
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Storage state for managing the no-code Token.
    struct AptosToken has key {
        /// Used to burn.
        burn_ref: Option<token::BurnRef>,
        /// Used to control freeze.
        transfer_ref: Option<object::TransferRef>,
        /// Used to mutate fields
        mutator_ref: Option<token::MutatorRef>,
        /// Used to mutate properties
        property_mutator_ref: property_map::MutatorRef,
    }
```

### Proposed approach
- Make use of all `aptos_token` attributes.
- We still need to use structs for `composable_token` and `trait_token`. But we don't need to store of this data as it is already stored when building them since they are based on `aptos_token`.
- So what to store?
    -  `composable_token`: name, collection, token_supply.
    - `trair_token`: name, collection, tbd...

#### The new flow
**Make sure it aligns with cthe current one and make adjustments**
1. the creator will need to specify the token type (composable/trait).
2. If composable:
    1. trigger a function that takes `composable_token` inputs.
    the function should look something like this:
    ``` rust
    inline fun create_collection_internal<Supply: key>(
        creator: &signer,
        constructor_ref: ConstructorRef,
        description: String,
        name: String,
        royalty: Option<Royalty>,
        uri: String,
        supply: Option<Supply>,
    ): ConstructorRef {
        let collection = Collection {
            creator: signer::address_of(creator),
            description,
            name,
            uri,
            mutation_events: object::new_event_handle(&object_signer),
        };
        move_to(&object_signer, collection);

        if (option::is_some(&supply)) {
            move_to(&object_signer, option::destroy_some(supply))
        } else {
            option::destroy_none(supply)
        };

        if (option::is_some(&royalty)) {
            royalty::init(&constructor_ref, option::extract(&mut royalty))
        };

        let transfer_ref = object::generate_transfer_ref(&constructor_ref);
        object::disable_ungated_transfer(&transfer_ref);

        constructor_ref
    }
    ```
    2. we don't want to provide `supply` everytime we mint a new composable token so we make it an option: `Option<Supply>`.

**TL;DR**
Collection -> Composable Token -> Trait Token.

Flow:
- Mint composable token:
    1. User mints a composable token, inputting token data including `supply`.
    2. Once minted, user can compose tokens (regardless the type).
- Fast compose:
    1. User selects atleast two tokens (regardless the type).
    2. User needs to select a composable token next.
        - if it exists, compose happens.
        - if not:
            - User should mint composable token (the flow mentioned first).
            - User hit fast compose and we mint a composable token for him without `supply`.
    2. A composable token will be automatically minted, without having `supply`.
    3. Once minted, token composition can happen (regardless the type).

    **questions**:
    
----------------------------------
Good to know:     
``` rust
    /// This is a one time ability given to the creator to configure the object as necessary
    struct ConstructorRef has drop {
        self: address,
        /// True if the object can be deleted. Named objects are not deletable.
        can_delete: bool,
    }
```