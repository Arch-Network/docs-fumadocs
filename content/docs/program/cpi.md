---
title: "Cross-Program Invocation (CPI)"
---

Cross-Program Invocation (CPI) lets one Arch program invoke another program during transaction execution. Use CPI for composition, shared token operations, and PDA-authorized workflows.

## Basic CPI

Use `arch_program::program::invoke` with a real `Instruction` and the accounts required by the target program.

```rust
use arch_program::{
    account::AccountInfo,
    entrypoint::ProgramResult,
    program::invoke,
};

pub fn invoke_token_transfer(
    source: &AccountInfo,
    destination: &AccountInfo,
    authority: &AccountInfo,
    amount: u64,
) -> ProgramResult {
    let ix = apl_token::instruction::transfer(
        &apl_token::id(),
        source.key,
        destination.key,
        authority.key,
        &[],
        amount,
    )?;

    invoke(&ix, &[source.clone(), destination.clone(), authority.clone()])
}
```

For APL token transfers, build the instruction through `apl_token::instruction` so the instruction data and account order match the token program.

## CPI with PDA Signers

Use `invoke_signed` when the authority is a PDA owned by the calling program. Signer seeds are passed as a slice of signer groups: `&[&[&[u8]]]`.

```rust
use arch_program::{
    account::AccountInfo,
    entrypoint::ProgramResult,
    program::invoke_signed,
    pubkey::Pubkey,
};

pub fn invoke_with_vault_authority(
    program_id: &Pubkey,
    vault_authority: &AccountInfo,
    source: &AccountInfo,
    destination: &AccountInfo,
    amount: u64,
) -> ProgramResult {
    let (vault_pda, bump) = Pubkey::find_program_address(&[b"vault"], program_id);
    if vault_pda != *vault_authority.key {
        return Err(arch_program::program_error::ProgramError::InvalidSeeds);
    }

    let ix = apl_token::instruction::transfer(
        &apl_token::id(),
        source.key,
        destination.key,
        vault_authority.key,
        &[],
        amount,
    )?;

    let signer_seeds: &[&[&[u8]]] = &[&[b"vault", &[bump]]];
    invoke_signed(
        &ix,
        &[source.clone(), destination.clone(), vault_authority.clone()],
        signer_seeds,
    )
}
```

## Account Creation and Rent

For account creation flows, use system instructions from `arch_program::system_instruction`. Compute rent with `arch_program::rent::minimum_rent(space)` instead of Solana sysvar patterns.

```rust
use arch_program::{
    pubkey::Pubkey,
    rent::minimum_rent,
    system_instruction,
};

pub fn create_account_ix(
    payer: &Pubkey,
    new_account: &Pubkey,
    owner: &Pubkey,
    space: u64,
) -> arch_program::instruction::Instruction {
    system_instruction::create_account(
        payer,
        new_account,
        minimum_rent(space as usize),
        space,
        owner,
    )
}
```

## Client-Side Considerations

- Include every account the target program expects, in the order expected by that program.
- Reproduce PDA seeds and bumps exactly on the client and on-chain.
- Use target-program instruction builders where available instead of manually packing bytes.
- Keep instruction data small enough for transaction limits.

## Troubleshooting

- `InvalidSeeds`: PDA mismatch between client and program.
- `MissingRequiredSignature`: A required signer was not present or signer seeds were wrong.
- `IncorrectProgramId`: An account is not owned by the expected program.
- Size or compute errors: split large workflows into smaller transactions.
