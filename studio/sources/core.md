# TowneSpace Modules (smart contracts)

## Marketplace

[tbd]

## Studio

A studio is a place where Users can create a collection of composable NFTs (cNFTs) and object NFTs (oNFTs). A cNFT is a NFT that can be composed of other NFTs. An oNFT is a NFT that can be composed into a cNFT. A cNFT can be composed of multiple oNFTs. An oNFT can only be composed into one cNFT. A cNFT can be decomposed into its oNFTs. An oNFT cannot be decomposed.

### `core.move`

#### Resources

- Storage state data structures.
- Globally accessible.
- Based on the Object model.

``` rust
struct TokenCollection has key {
        collection: Object<aptos_token::AptosCollection>,
        name: String,
        symbol: String,
        // TODO: create_collection_events
        // TODO: delete_collection_events
    }
```

``` rust
struct ComposableToken has key {
        token: Object<aptos_token::AptosToken>,
        // The object tokens to store in the composable token.
        object_tokens: vector<Object<ObjectToken>>, // TODO: this must be extended to each object type.
        // TODO: transfer event
        // burn_events: ,
        // mint_events: EventHandle<CreateTraitTokenEvent> // TODO: refactor to CreateObjectTokenEvent
    }
```

``` rust
struct ObjectToken has key {
        token: Object<aptos_token::AptosToken>,
        // TODO: add events
        // TODO: transfer event
        // burn_events: ,
        // mint_events: EventHandle<CreateTraitTokenEvent> // TODO: refactor to CreateObjectTokenEvent
    }
```

``` rust
struct TokenSupply has key {
        // TODO: supply -> max_supply || total_supply
        total_supply: u64,
        remaining_supply: u64,
        total_minted: u64,
        // burn_events: ,
        // mint_events: ,
    }
```

#### Functions

##### Entry Functions

###### Creating and minting
- `create_token_collection`
- `mint_composable_token`
- `mint_object_token`

###### Burning
- `burn_composable_token`
- `burn_object_token`

###### Composing and decomposing
- `compose_object`
- `decompose_object`
- `decompose_entire_token`

###### Transferring
- `raw_transfer`
- `transfer_with_fee`

###### Freezing
- see `aptos_token.move`

###### Thawing (unfreezing)
- see `aptos_token.move`

###### Mutating
- `set_uri`: used for updating the URI of a cNFT when de/composition occurs.
- see `aptos_token.move`

##### Internal Functions

###### Creating and minting
- `create_token_collection_internal`
    - returns `(Object<TokenCollection>, Object<AptosCollection>)`
- `mint_composable_token_internal`
    - returns `(Object<ComposableToken>, Object<AptosToken>)`
- `mint_object_token_internal`
    - returns `(Object<ObjectToken>, Object<AptosToken>)`


#### User Journey

``` mermaid
journey
    section Create/Mint/Burn
        Create collections: x:Creator
        Mint cNFT: x:Creator
        Mint oNFT: x:Creator
    section Compose/Decompose
        Compose cNFT: x:Creator, User
        Decompose cNFT: x:Creator, User
    section Transfer
        Transfer cNFT: x:Creator, User
        Transfer oNFT: x:Creator, User
```
**User Journey**

1. Create a collection.
2. Mint a cNFT specifying **the token supply (not the collection supply!)**.
3. Mint oNFTs.
    - The maximum number of oNFTs minted cannot exceed the token supply of the cNFT.
    - when minting a oNFT, the 
4. Compose oNFTs into the cNFT.
5. Decompose oNFTs from the cNFT.
6. Transfer cNFTs.


**(Normal) User Journey**

1. Compose oNFTs into the cNFT.
2. Decompose oNFTs from the cNFT.
3. Transfer cNFTs.

### `test_utils.move`

- `a_create_collection_and_mint_tokens`:
    1. create a collection.
    2. mint a composble token.
    3. mint an object token.

- `b_compose_token`:
    1. create a collection.
    2. mint a composble token.
    3. mint an object token.
    4. compose object token to composble token.

- `c_compose_decompose_token`:
    1. create a collection.
    2. mint a composble token.
    3. mint an object token.
    4. compose object token to composble token.
    5. decompose object token from composble token.

- `d_decompose_entire_token`:
    1. create a collection.
    2. mint a composble token.
    3. mint object token 1.
    4. mint object token 2.
    5. mint object token 3.
    6. compose object token 1 to composble token.
    7. compose object token 2 to composble token.
    8. compose object token 3 to composble token.
    9. decompose all object tokens using `decompose_entire_token` function.

- `e_supply_token`:
    1. create a collection.
    2. mint a composble token with `total_supply = 1` (only one object token can be minted).
    3. mint object token 1.
    4. mint object token 2 and expect a failure.

- TODO: `f_transfer_composable_token`:

- TODO: `g_transfer_object_token`:

- TODO: `h_transfer_frozen_object_token`:

### events.move