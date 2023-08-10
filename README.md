# Marketplace

A marketplace for trading NFTs leveraging Aptos and Token V2.

## Roadmap

1. [ ] Create marketplace contracts
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
- Create Dynamic NFTs.
- Create Composed NFTs.
> Class Diagrams will be added soon.

## Schedule

```mermaid
gantt
    title Schedule Plan
    dateFormat  DD-MM-YYYY
    section Contracts
    marketplaceV2  :17-07-2023, 3d
    studio   :04-08-2023  , 9d
    audit   :14-09-2023 , 14d
    section UI 
    web  :11-08-2023 , 21d
    section Deploy 
    testnet      :01-09-2023  , 27d
    mainnet      :01-10-2023 ,
```

