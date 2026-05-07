# SDK Reference

Arch documentation covers two SDK surfaces:

- The **Rust SDK**, published as the `arch_sdk` crate.
- The external **TypeScript SDK**, published as `@arch-network/arch-sdk`.

This page is audited against the Rust SDK source available to the Arch team. TypeScript examples are covered separately and should be checked against the TypeScript SDK repository before release.

## Rust SDK

Use the Rust SDK when building backend services, tooling, tests, or other Rust clients that talk to an Arch validator.

```toml
[dependencies]
arch_sdk = "0.6.4"
```

The crate re-exports:

- `arch_program` types
- RPC clients from `client`
- helpers from `helper`
- serializable data types from `types`

## RPC Clients

The Rust SDK exposes both async and blocking clients:

```rust
use arch_sdk::{ArchRpcClient, Config};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::localnet();
    let client = ArchRpcClient::new(&config);

    let ready = client.call_method::<bool>("is_node_ready").await?;
    println!("Node ready: {:?}", ready);

    Ok(())
}
```

For synchronous code, use `BlockingArchRpcClient`:

```rust
use arch_sdk::{BlockingArchRpcClient, Config};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::localnet();
    let client = BlockingArchRpcClient::new(&config);

    let block_count = client.get_block_count()?;
    println!("Block count: {}", block_count);

    Ok(())
}
```

## Configuration

`Config::localnet()` points at the standard local stack:

- Bitcoin RPC: `http://127.0.0.1:18443/wallet/testwallet`
- Titan: `http://127.0.0.1:3030`
- Arch RPC: `http://localhost:9002/`
- Bitcoin network: `regtest`

`Config::devnet()`, `Config::testnet()`, and `Config::mainnet()` are also available, but their endpoint fields are intentionally empty in the SDK and must be filled with the endpoints for your environment.

## Supported Rust Client Methods

The Rust SDK wraps the current validator RPC methods:

- Raw calls: `call_method`, `call_method_with_params`, `call_method_raw`, `call_method_with_params_raw`
- Accounts: `read_account_info`, `get_multiple_accounts`, `get_account_address`, `get_program_accounts`
- Transactions: `send_transaction`, `send_transactions`, `get_processed_transaction`, `wait_for_processed_transaction`, `wait_for_processed_transactions`
- Blocks: `get_block_count`, `get_block_hash`, `get_best_block_hash`, `get_best_finalized_block_hash`, `get_block_by_hash`, `get_full_block_by_hash`, `get_block_by_height`, `get_full_block_by_height`, `get_full_block_with_txids`
- Faucet and conflict helpers: `request_airdrop`, `create_and_fund_account_with_faucet`, `check_pre_anchor_conflict`
- Network: `get_network_pubkey`

## Program Deployment Helpers

The Rust SDK includes program deployment helpers:

- `ProgramDeployer` for async code
- `BlockingProgramDeployer` for synchronous code

The CLI exposes deployment through `arch-cli deploy`.

## TypeScript SDK

Install the TypeScript SDK from npm:

```bash
npm install @arch-network/arch-sdk
```

The TypeScript SDK is maintained separately. For current TypeScript APIs, verify against [Arch-Network/arch-typescript-sdk](https://github.com/Arch-Network/arch-typescript-sdk).

## Choosing an SDK

Use the TypeScript SDK for web apps and Node.js services when your codebase is JavaScript or TypeScript. Use the Rust SDK for Rust services, tools, tests, and clients that need direct access to the Rust types used by the validator.

For on-chain programs, depend on `arch_program` directly rather than treating `arch_sdk` as an on-chain framework.

## Next Steps

- [TypeScript SDK Getting Started](./typescript/getting-started.md)
- [RPC API Reference](/docs/tools-apis/api-reference)
- [Arch CLI Reference](/docs/tools-apis/arch-cli-reference)
- [Program Development](/docs/development/writing-your-first-program)
