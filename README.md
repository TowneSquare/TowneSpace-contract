# Marketplace

A marketplace for trading NFTs leveraging Aptos and Token V2.

## Roadmap

1. [x] Create marketplace contracts
2. [ ] Create studio contracts
3. [ ] Create a marketplace for web
4. [ ] Create a studio for web
5. [ ] Create a marketplace for mobile

--------------------

## Initial Structure

### Off-chain

These are the functionalities that will be implemented off-chain.

#### Marketplace

- Combine listed NFTs to get overview of the end product.

#### Studio

- Combine owned NFTs to get overview of the end product.

### On-chain

#### Marketplace

(forking move-examples/marketplace.move)
- Buy/Sell NFTs.
- Auction NFTs.
> Class Diagrams will be implemented upon discussing the structure explictly.
```mermaid
classDiagram
    class coin_listing{

    }
    class collection_offer{

    }
    class fee_schedule{

    }
    class listing{

    }

    class token_offer{

    }
    coin_listing "1" -- "0..*" listing 
    fee_schedule "1" -- "0..*" listing : "applies to"
    collection_offer "1" -- "0..*" token_offer : "contains"
    listing -- collection_offer : "is a part of"
    token_offer -- listing : "is listed as"
```

#### Studio

built on top of aptos_token.move
functionalities:
- Create tokenV2 and collections.
- Create Composable NFTs.
> Class Diagrams will be added soon.

##### Glossary

|Abbreviation|Term|Definition|
|---|---|---|
|tNFT|trait non-fungible token| A token V2 that is based on the object model|
|cNFT|Composable non-fungible token|A token V2 that can hold tNFTs inside|
|[tbd]|[tbd]|A token V2 that can hold tNFTs and fungible assets|

## Schedule

```mermaid
gantt
    title Schedule Plan
    dateFormat  DD-MM-YYYY
    
    section Contracts
    marketplaceV2  :done, 17-07-2023, 3d
    studio   :active, 04-08-2023  , 18d
    audit   :26-09-2023 , 14d
    section UI 
    web  phase 1:18-08-2023 , 26d
    web  phase 2:13-09-2023 , 27d
    section Deploy 
    testnet      : milestone, crit, 13-09-2023 ,
    mainnet      : milestone, crit, 10-10-2023 ,
    section Events
    Hack Singapore : crit, 11-09-2023, 2d
```

