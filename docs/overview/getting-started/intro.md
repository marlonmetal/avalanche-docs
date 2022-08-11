---
slug: /
---

# Overview

## Introduction

[Metal](https://metalblockchain.org) is an open-source platform for launching decentralized applications and enterprise blockchain deployments in one interoperable, highly scalable ecosystem. At its core Metal Blockchain is a fork of the highly successful Avalanche project.

Metal Blockchain improves upon the initial work of Avalanche by adding a fourth subchain (A-Chain) to offer a layer for payments and decentralized finance: Proton Blockchain (based on EOSIO protocol). Proton offers feeless transactions to end users.

Additionally, Metal introduces Web Authentication (WebAuthn) support for the Ethereum Virtual Machine (EVM) or C-Chain.

# Metal Platform

Metal features 4 built-in blockchains: [**Proton Chain (A-Chain)**](#proton-chain-a-chain), [**Exchange Chain (X-Chain)**](#exchange-chain-x-chain), [**Platform Chain (P-Chain)**](#platform-chain-p-chain), and [**Contract Chain (C-Chain**)](#contract-chain-c-chain). All 4 blockchains are [validated](../../nodes/validate/staking.md) and secured by all Metal validators which is also referred as the Primary Network. The Primary Network is a special subnet, and all members of all custom Subnets must also be a member of the Primary Network by staking at least 2,000 METAL.

## Proton Chain (A-Chain)

The **A-Chain** is a new Virtual Machine being developed to provide compatibility with EOSIO based chains, in this case the A-Chain will be an implementation of the Proton chain. For more information about Proton, [click here](https://proton.org).

## Contract Chain (C-Chain)

The **C-Chain** allows for the creation smart contracts using the C-Chain API.

The C-Chain is an instance of the Ethereum Virtual Machine.

## Platform Chain (P-Chain)

The **P-Chain** is the metadata blockchain on Metal and coordinates validators, keeps track of active Subnets, and enables the creation of new Subnets. The P-Chain implements the [Snowman consensus protocol](../../#snowman-consensus-protocol).

The [P-Chain API](../../apis/metalgo/apis/p-chain.md) allows clients to create Subnets, add validators to Subnets, and create blockchains.

## Exchange Chain (X-Chain)

The **X-Chain** acts as a decentralized platform for creating and trading digital smart assets, a representation of a real-world resource (e.g., equity, bonds) with a set of rules that govern its behavior, like "can’t be traded until tomorrow" or "can only be sent to US citizens."

One asset traded on the X-Chain is METAL. When you issue a transaction to a blockchain on Avalanche, you pay a fee denominated in METAL.

The X-Chain is an instance of the Avalanche Virtual Machine (AVM). The [X-Chain API](../../apis/metalgo/apis/x-chain.md) allows clients to create and trade assets on the X-Chain and other instances of the AVM.
