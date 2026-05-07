---
title: "Accounts"
---

Accounts are the state containers used by Arch programs. An account has an address, an owner program, lamports, data bytes, a Bitcoin UTXO anchor, and execution/access flags.

## AccountInfo

Programs receive accounts as `AccountInfo` values during instruction execution:

```rust
pub struct AccountInfo<'a> {
    pub key: &'a Pubkey,
    pub lamports: Rc<RefCell<&'a mut u64>>,
    pub utxo: &'a UtxoMeta,
    pub data: Rc<RefCell<&'a mut [u8]>>,
    pub owner: &'a Pubkey,
    pub is_signer: bool,
    pub is_writable: bool,
    pub is_executable: bool,
}
```

The owner is always a program public key. Programs should verify ownership before reading or mutating account data.

## Account Metadata

Clients and programs describe which accounts an instruction touches with `AccountMeta`:

```rust
pub struct AccountMeta {
    pub pubkey: Pubkey,
    pub is_signer: bool,
    pub is_writable: bool,
}
```

Use the helpers to avoid mixing up writable and readonly accounts:

```rust
let writable = AccountMeta::new(account_pubkey, true);
let readonly = AccountMeta::new_readonly(program_pubkey, false);
```

## Bitcoin UTXO Anchor

Each `AccountInfo` includes a `UtxoMeta`, which is a compact `txid || vout` reference to a Bitcoin output. The account key is represented in the output script, and runtime syscalls can validate UTXO ownership or derive account script pubkeys.

```rust
let txid = account.utxo.txid();
let vout = account.utxo.vout();
```

## Creating Accounts

Create accounts with system instructions from `arch_program::system_instruction`. The current system instruction variants include `CreateAccount`, `CreateAccountWithAnchor`, `Assign`, `Anchor`, `SignInput`, `Transfer`, `Allocate`, `CreateAccountWithSeed`, `AssignWithSeed`, and `TransferWithSeed`.

```rust
use arch_program::{rent::minimum_rent, system_instruction};

let ix = system_instruction::create_account(
    payer,
    new_account,
    minimum_rent(space as usize),
    space,
    owner_program,
);
```

For accounts that must be anchored to a specific Bitcoin output at creation time, use `create_account_with_anchor` and pass the `txid` and `vout`.

## Program-Derived Addresses

Use PDAs when a program needs a deterministic account address that it can authorize through `invoke_signed`.

```rust
let (pda, bump) = Pubkey::find_program_address(&[b"vault", user.as_ref()], program_id);
```

When invoking another program with a PDA authority, pass the same seed group and bump to `invoke_signed`.

## Reading and Writing State

Account data is a mutable byte slice. Serialize and deserialize your program state with a deterministic format such as Borsh.

```rust
let mut data = account.data.borrow_mut();
state.serialize(&mut &mut data[..])?;
```

Validate these invariants before mutation:

- The account owner matches your program.
- The account is writable when data or lamports will change.
- Required signer accounts have `is_signer == true`.
- The account data length is large enough for the state you serialize.

## Related Topics

- [Bitcoin Integration](/docs/core-concepts/bitcoin-integration) - How UTXOs integrate with accounts
- [Programs](./program.md) - Programs that own and modify accounts
- [Instructions](./instructions-and-messages.md) - How to interact with accounts
- [Syscalls](./syscall.md) - Runtime helpers available to programs
