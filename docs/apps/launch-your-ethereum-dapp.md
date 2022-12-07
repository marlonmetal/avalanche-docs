---
description: The purpose of this document is to help you with launching your existing Ethereum dapp on the Metal Blockchain.
---

# Launch Your Ethereum dApp on Metal Blockchain

## Overview

The purpose of this document is to help you with launching your existing dapp on Metal Blockchain. It contains a series of resources designed to help you get the basics of the Metal Blockchain and how it works, show how to connect to the network, how to use your existing tools and environments in developing and deploying on Metal Blockchain, as well as some common pitfalls you need to consider when running your dapp on Metal Blockchain.

## Platform Basics

Metal Blockchain  is a [network of networks](../overview/getting-started/intro.md). It means that it is not a single chain running a single, uniform type of blocks. It contains multiple Subnets, each running one of more heterogeneous chains. But, to run an Ethereum dapp on a low-fee, fast network with instant finality, we don't need to concern ourselves with that right now. Using the link above you can find out more if you wish, but all you need to know right now is that one of the chains running on Metal Blockchain Primary Network is the C-Chain (contract chain).

C-Chain runs a fork of [go-ethereum](https://geth.ethereum.org/docs/rpc/server) called [coreth](https://github.com/MetalBlockchain/coreth) that has the networking and consensus portions replaced with Metal Blockchain equivalents. What's left is the Ethereum VM, which runs Solidity smart contracts and manages data structures and blocks on the chain. As a result, you get a blockchain that can run all the Solidity smart contracts from Ethereum, but with much greater transaction bandwidth and instant finality that [Metal Blockchain's revolutionary consensus](../overview/getting-started/avalanche-consensus.md) enables.

Coreth is loaded as a plugin into [MetalGo](https://github.com/MetalBlockchain/metalgo), the client node application used to run Metal Blockchain network.

As far as your dapp is concerned, it will be running the same as on Ethereum, just quicker and cheaper. Let's find out how.

## Accessing Metal Blockchain C-Chain

C-Chain exposes the [same API](../apis/metalgo/apis/c-chain.md) as go-ethereum, so you can use all the familiar APIs that are available on Ethereum for interaction with the platform.

There are multiple ways of working with the C-Chain.

### Through MetaMask

You can access C-Chain through MetaMask, by defining a custom network. Go to MetaMask, log in, click the network dropdown, and select 'Custom RPC'. Data for Metal Blockchain is as follows.

#### **Metal Blockchain Mainnet Settings:**

- **Network Name**: Metal C-Chain 
- **New RPC URL**: [https://api.metalblockchain.org/ext/bc/C/rpc](https://api.metalblockchain.org/ext/bc/C/rpc)
- **ChainID**: `381931`
- **Symbol**: `METAL`
- **Explorer**: [https://metalscan.io/](https://metalscan.io/)

#### **Metal Blockchain TAHOE Testnet Settings:**

- **Network Name**: Metal Tahoe C-Chain
- **New RPC URL**: [https://tahoe.metalblockchain.org/ext/bc/C/rpc](https://tahoe.metalblockchain.org/ext/bc/C/rpc)
- **ChainID**: `381932`
- **Symbol**: `METAL`
- **Explorer**: [https://tahoe.metalscan.io/](https://tahoe.metalscan.io/)


In your application's web interface, you can [add Metal Blockchain programmatically](../dapps/smart-contracts/add-avalanche-programmatically.md#metamask) so your users don't have to enter the network data manually.

### Using the Public API Nodes

Instead of proxying network operations through MetaMask, you can use the public API, which consists of a number of AvalancheGo nodes behind a load balancer.

The C-Chain API endpoint is [https://api.metalblockchain.org/ext/bc/C/rpc](https://api.metalblockchain.org/ext/bc/C/rpc) for the mainnet and [https://tahoe.metalblockchain.org/ext/bc/C/rpc](https://tahoe.metalblockchain.org/ext/bc/C/rpc) for the testnet.

For more information, see [documentation](../apis/metalgo/public-api-server.md).

However, public API does not expose all the APIs that are available on the node, as some of them would not make sense on a publicly accessible service, and some would present a security risk. If you need to use an API that is not available publicly, you can run your own node.

## Running Your Own Node

If you don't want your dapp to depend on a centralized service you don't control, or have specific needs that cannot be met through the public API, you can run your own node and access the network that way. Running your own node also avoids potential issues with public API congestion and rate-limiting.

For development and experimental purposes, [here](../nodes/build/run-metal-node-manually.md) is a tutorial that shows how to download, build, and install MetalGo. Simpler solution is to use the prebuilt binary, available on [GitHub](https://github.com/MetalBlockchain/metalgo/releases). If you're going to run a node on a Linux machine, you can use the [installer script](../nodes/build/set-up-node-with-installer.md) to install the node as a `systemd` service. Script also handles node upgrading. If you want to run a node in a docker container, there are [build scripts](https://github.com/MetalBlockchain/metalgo/tree/master/scripts) in the MetalGo repo for various Docker configs.

### Node Configuration

Node configuration options are explained [here](../nodes/maintain/avalanchego-config-flags.md). But unless you have specific needs, you can mostly leave the main node config options at their default values.

On the other hand, you will most likely need to adjust C-Chain configuration to suit your intended use. You can look up complete configuration options for C-Chain [here](../nodes/maintain/chain-config-flags.md#c-chain-configs) as well as the default configuration. Note that only the options that are different from their default values need to be included in the config file.

By default, the C-Chain config file is located at `$HOME/.metalgo/configs/chains/C/config.json`. We will go over how to adjust the config to cover some common use cases in the following sections.

#### Running an Archival Node

If you need Ethereum [Archive Node](https://ethereum.org/en/developers/docs/nodes-and-clients/#archive-node) functionality, you need to disable C-Chain pruning, which is enabled by default to conserve disk space. To preserve full historical state, include `"pruning-enabled": false` in the C-Chain config file.

:::note
After changing the flag to disable the database pruning, you will need to run the bootstrap process again, as the node will not backfill any already pruned and missing data.

To re-bootstrap the node, stop it, delete the database (by default stored in `~/.metalgo/db/`) and start the node again.
:::

#### Running a Node in Debug Mode

By default, debug APIs are disabled. To enable them, you need to enable the appropriate EVM APIs in the config file by including the `eth-apis` value in your C-Chain config file to include the `debug`, `debug-tracer`, and `internal-debug` APIs.

:::note
Including the `eth-apis` in the config flag overrides the defaults, so you need to include the default APIs as well!
:::

#### Example C-Chain Config File

An example C-Chain config file that includes the archival mode, enables debug APIs as well as default EVM APIs:

```json
{
  "eth-apis": [
    "eth",
    "eth-filter",
    "net",
    "web3",
    "internal-eth",
    "internal-blockchain",
    "internal-transaction",
    "debug-tracer"
  ],
  "pruning-enabled": false
}
```

Default config values for the C-Chain can be seen [here](../nodes/maintain/chain-config-flags.md#c-chain-configs).

### Running a Local Test Network

If you need a private test network to test your dapp, [Metal Network Runner](https://github.com/MetalBlockchain/metal-network-runner) is a shell client for launching local Metal Blockchain networks, similar to Ganache on Ethereum.

For more information, see [documentation](../subnets/network-runner.md).

## Developing and Deploying Contracts

Being an Ethereum-compatible blockchain, all of the usual Ethereum developer tools and environments can be used to develop and deploy dapps for Metal Blockchain's C-Chain.

### Remix

There is a [tutorial](../dapps/smart-contracts/deploy-a-smart-contract-on-avalanche-using-remix-and-metamask.md) for using Remix to deploy smart contracts on Metal Blockchain. It relies on MetaMask for access to the Avalanche network.

### Truffle

You can also use Truffle to test and deploy smart contracts on Metal Blockchain. Find out how in this [tutorial](../dapps/smart-contracts/using-truffle-with-the-avalanche-c-chain.md).

### Hardhat

Hardhat is the newest development and testing environment for Solidity smart contracts, and the one our developers use the most. Due to its superb testing support, it is the recommended way of developing for Metal Blockchain.

For more information see [this doc](../dapps/smart-contracts/using-hardhat-with-the-avalanche-c-chain.md).

## Metal Explorer

An essential part of the smart contract development environment is the explorer, which indexes and serves blockchain data. Mainnet C-Chain explorer is available at [https://metaltrace.io/](https://metaltrace.io/) and testnet explorer at [https://tahoe.snowtrace.io/](https://tahoe.snowtrace.io/). Besides the web interface, it also exposes the standard [Ethereum JSON RPC API](https://eth.wiki/json-rpc/API).

## Metal Blockchain Faucet

For development purposes, you will need test tokens. Metal Blockchain has a [Faucet](https://faucet.metalblockchain.org/) that drips test tokens to the address of your choice. Paste your C-Chain address there.

If you need, you can also run a faucet locally, but building it from the [repository](https://github.com/MetalBlockchain/metal-faucet).

## Contract Verification

Smart contract verification provides transparency for users interacting with smart contracts by publishing the source code, allowing everyone to attest that it really does what it claims to do. You can verify your smart contracts using the [C-Chain explorer](https://metaltrace.io/). The procedure is simple:

- navigate to your published contract address on the explorer
- on the `code` tab select `verify & publish`
- copy and paste the flattened source code and enter all the build parameters exactly as they are on the published contract
- click `verify & publish`

If successful, the `code` tab will now have a green checkmark, and your users will be able to verify the contents of your contract. This is a strong positive signal that your users can trust your contracts, and it is strongly recommended for all production contracts.

See [this](../dapps/smart-contracts/verify-smart-contracts-with-truffle-verify.md) for a detailed tutorial with Truffle.

## Contract Security Checks

Due to the nature of distributed apps, it is very hard to fix bugs once the application is deployed. Because of that, making sure your app is running correctly and securely before deployment is of great importance. Contract security reviews are done by specialized companies and services. They can be very expensive, which might be out of reach for single developers and startups. But, there are also automated services and programs that are free to use.

Most popular are:

- [Slither](https://github.com/crytic/slither), here's a [tutorial](https://blog.trailofbits.com/2018/10/19/slither-a-solidity-static-analysis-framework/)
- [MythX](https://mythx.io/)
- [Mythril](https://github.com/ConsenSys/mythril)

We highly recommend using at least one of them if professional contract security review is not possible. A more comprehensive look into secure development practices can be found [here](https://github.com/crytic/building-secure-contracts/blob/master/development-guidelines/workflow.md).

## Gotchas and Things to Look out For

The Metal Blockchain's C-Chain is EVM-compatible, but it is not identical. There are some differences you need to be aware of, otherwise, you may create subtle bugs or inconsistencies in how your dapps behave.

Here are the main differences you should be aware of.

### Measuring Time

Metal Blockchain does not use the same mechanism to measure time as Ethereum which uses consistent block times. Instead, Metal Blockchain supports asynchronous block issuance, block production targets a rate of every 2 seconds. If there is sufficient demand, a block can be produced earlier. If there is no demand, a block will not be produced until there are transactions for the network to process.

Because of that, you should not measure the passage of time by the number of blocks that are produced. The results will not be accurate, and your contract may be manipulated by third parties.

Instead of block rate, you should measure time simply by reading the timestamp attribute of the produced blocks. Timestamps are guaranteed to be monotonically increasing and to be within 30 seconds of the real time.

### Finality

On Ethereum, the blockchain can be reorganized and blocks can be orphaned, so you cannot rely on the fact that a block has been accepted until it is several blocks further from the tip (usually, it is presumed that blocks 6 places deep are safe). That is not the case on Metal Blockchain. Blocks are either accepted or rejected within a second or two. And once the block has been accepted, it is final, and cannot be replaced, dropped, or modified. So the concept of 'number of confirmations' on Metal Blockchain is not used. As soon as a block is accepted and available in the explorer, it is final.

### Using `eth_newFilter` and Related Calls with the Public API

If you're using the [`eth_newFilter`](https://eth.wiki/json-rpc/API#eth_newfilter) API method on the public API server, it may not behave as you expect because the public API is actually several nodes behind a load balancer. If you make an `eth_newFilter` call, subsequent calls to [`eth_getFilterChanges`](https://eth.wiki/json-rpc/API#eth_getfilterchanges) may not end up on the same node as the first call, and you will end up with undefined results.

If you need the log filtering functionality, you should use a websocket connection, which ensures that your client is always talking to the same node behind the load balancer. Alternatively, you can use [`eth_getLogs`](https://eth.wiki/json-rpc/API#eth_getlogs), or run your own node and make API calls to it.

## Support

Using this tutorial you should be able to quickly get up to speed on Avalanche, deploy, and test your dapps. If you have questions, problems, or just want to chat with us, you can reach us on our public [Telegram](https://chat.avalabs.org/) server. We'd love to hear from you and find out what you're building on Metal Blockchain!
