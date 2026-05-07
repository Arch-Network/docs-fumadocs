# RPC Reference

This section documents the public HTTP JSON-RPC methods registered by the Arch validator. Methods use the exact snake_case names shown here.

## Node Status

- `get_version`
- `is_node_ready`
- `get_current_state`
- `get_peers`
- `get_network_pubkey`

## Accounts

- `read_account_info`
- `get_multiple_accounts`
- `get_program_accounts`
- `get_all_accounts` (local validator)
- `get_account_address`

## Transactions

- `send_transaction`
- `send_transactions`
- `get_processed_transaction`
- `get_arch_txid_from_btc_txid` (local validator)
- `get_transaction_report` (local validator)
- `get_latest_tx_using_account` (local validator)
- `recent_transactions`
- `get_transactions_by_block`
- `get_transactions_by_ids`
- `check_pre_anchor_conflict`
- `request_airdrop`
- `create_account_with_faucet`

## Blocks

- `get_block`
- `get_block_by_height`
- `get_full_block_with_txids`
- `get_block_count`
- `get_block_hash`
- `get_best_block_hash`
- `get_best_finalized_block_hash`
- `get_block_execution_report`

## Notes

- `get_block` and `get_block_by_height` accept an optional filter that controls whether the response contains transaction IDs or full transaction details.
- `recent_transactions`, `get_transactions_by_block`, and `get_transactions_by_ids` use object-style parameters for pagination and filtering.
- Methods marked "local validator" are registered by the local validator used for development workflows, but are not registered by the standalone validator RPC module.
- `reset_network` and `start_dkg` are not registered by the current validator or local validator RPC modules.

For request and response examples, see the [RPC API Reference](/docs/tools-apis/api-reference).
