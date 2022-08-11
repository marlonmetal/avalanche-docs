---
description: There is a public API server that allows developers to access the Metal platform without having to run a node themselves.
---

# Public API Server

There is a public API server that allows developers to access the Metal network without having to run a node themselves. The public API server is actually several [MetalGo](https://github.com/MetalBlockchain/metalgo) nodes behind a load balancer to ensure high availability and high request throughput.

## Using the Public API nodes

The public API server is at `api.metalblockchain.org` for Metal Mainnet and `tahoe.metalblockchain.org` for Metal Tahoe Testnet. To access a particular API, just append the relevant API endpoint, as documented [here](./apis/issuing-api-calls.md). Namely, use the following end points for each chain respectively:

### HTTP

- For C-Chain API, the URL is `https://api.metalblockchain.org/ext/bc/C/rpc`.
- For X-Chain API, the URL is `https://api.metalblockchain.org/ext/bc/X`.
- For P-Chain API, the URL is `https://api.metalblockchain.org/ext/bc/P`.

Note: on Tahoe Testnet, use `https://tahoe.metalblockchain.org/` instead of `https://api.metalblockchain.org/`.

### WebSocket

- For C-Chain API, the URL is `wss://api.metalblockchain.org/ext/bc/C/ws`.

Note: on Tahoe Testnet, the URL is `wss://tahoe.metalblockchain.org/ext/bc/C/ws`.

## Supported APIs

The public API server supports all the API endpoints that make sense to be available on a public-facing service, including APIs for the [X-Chain](./apis/x-chain.md), [P-Chain](./apis/p-chain.md), [C-Chain](./apis/c-chain.md), and full archival for the Primary Network. However, it does not support [Index APIs](./apis/index-api.md), which includes the X-Chain API's `getAddressTxs` method.

For a full list of available APIs see [here](./apis/README.md).

## Limitations

The public API only supports C-Chain websocket API calls for API methods that don't exist on the C-Chain's HTTP API.

The maximum number of blocks to serve per `getLogs` request is 2048, which is set by [`api-max-blocks-per-request`](../../nodes/maintain/chain-config-flags.md#api-max-blocks-per-request-int).

## Sticky sessions

Requests to the public API server API are distributed by a load balancer to an individual node. As a result, consecutive requests may go to different nodes. That can cause issues for some use cases. For example, one node may think a given transaction is accepted, while for another node the transaction is still processing. To work around this, you can use 'sticky sessions', as documented [here](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials). This allows consecutive API calls to be routed to the same node.

## Availability

Usage of public API nodes is free and available to everyone without any authentication or authorization. Rate limiting is present, but many of the API calls are cached, and the rate limits are quite high.
