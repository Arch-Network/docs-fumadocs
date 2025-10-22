# Cross-Program Invocation (CPI)

Cross-Program Invocation (CPI) lets one Arch program call another program within the same transaction. CPI enables composition, modularity, and reuse of on-chain logic.

## When to use CPI

- Reuse core program logic (e.g., token transfers)
- Orchestrate multi-program workflows atomically
- Delegate permissions via PDAs instead of exposing private keys

## Basic CPI

```rust
use arch_program::{
    account_info::AccountInfo,
    instruction::{AccountMeta, Instruction},
    program::invoke,
    pubkey::Pubkey,
};

pub fn transfer_tokens_cpi(
    token_program_id: &Pubkey,
    source: &AccountInfo,
    destination: &AccountInfo,
    authority: &AccountInfo,
    amount: u64,
) -> arch_program::entrypoint::ProgramResult {
    let accounts = vec![
        AccountMeta::new(*source.key, false),
        AccountMeta::new(*destination.key, false),
        AccountMeta::new_readonly(*authority.key, true),
    ];

    // Your program's instruction layout here
    let instruction = Instruction::new_with_bytes(
        *token_program_id,
        &amount.to_le_bytes(),
        accounts,
    );

    invoke(&instruction, &[source.clone(), destination.clone(), authority.clone()])
}
```

## CPI with Program-Derived Address (PDA)

Use `invoke_signed` when the "authority" is a PDA owned by your program.

```rust
use arch_program::{
    account_info::AccountInfo,
    program::invoke_signed,
    pubkey::Pubkey,
    system_instruction,
};

pub fn transfer_from_pda(
    program_id: &Pubkey,
    pda_account: &AccountInfo,
    recipient: &AccountInfo,
    lamports: u64,
    seeds: &[&[u8]],
) -> arch_program::entrypoint::ProgramResult {
    let ix = system_instruction::transfer(pda_account.key, recipient.key, lamports);

    // PDA must be the signer via seeds
    invoke_signed(
        &ix,
        &[pda_account.clone(), recipient.clone()],
        &[seeds],
    )
}
```

### Deriving PDAs

```rust
use arch_program::pubkey::Pubkey;

pub fn user_pda(user: &Pubkey, program_id: &Pubkey) -> (Pubkey, u8) {
    Pubkey::find_program_address(&[b"user", user.as_ref()], program_id)
}
```

## Common Patterns

### Initialize + Use Flow

```rust
use arch_program::{
    account_info::{next_account_info, AccountInfo},
    instruction::{AccountMeta, Instruction},
    program::{invoke, invoke_signed},
    pubkey::Pubkey,
    entrypoint::ProgramResult,
};

pub fn process_initialize(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let payer = next_account_info(accounts_iter)?;
    let pda_account = next_account_info(accounts_iter)?;
    let system_program = next_account_info(accounts_iter)?;

    // Derive PDA
    let (pda, bump) = Pubkey::find_program_address(&[b"vault"], program_id);
    if pda != *pda_account.key { return Err(arch_program::program_error::ProgramError::InvalidSeeds); }

    // Create PDA account via CPI to system program
    let rent = arch_program::sysvar::rent::Rent::get()?;
    let lamports = rent.minimum_balance(0);
    let create_ix = arch_program::system_instruction::create_account(
        payer.key,
        &pda,
        lamports,
        0,
        program_id,
    );

    invoke_signed(
        &create_ix,
        &[payer.clone(), pda_account.clone(), system_program.clone()],
        &[&[b"vault", &[bump]]],
    )
}
```

### Chaining Calls

You can call multiple programs in sequence within a single transaction. If any CPI fails, the entire transaction aborts.

## Client-Side Considerations

- Build messages so that all required program accounts and PDAs are present
- Ensure PDA bumps and seeds are reproduced client-side for address derivation
- Keep instruction data small; respect transaction size limits

```typescript
// TypeScript helper to derive the same PDA as on-chain
import { PublicKey } from '@solana/web3.js'; // replace with Arch TS when available

export function deriveVaultPda(programId: PublicKey) {
  return PublicKey.findProgramAddressSync([Buffer.from('vault')], programId);
}
```

## Security Best Practices

- Verify account ownership: check that accounts are owned by expected programs
- Validate signer/writable flags for all accounts used in CPI
- Never trust instruction data from clients; validate thoroughly
- Use PDAs to avoid holding private keys on-chain

## Troubleshooting

- InvalidSeeds: PDA mismatch between client and program (check seeds/bump)
- MissingRequiredSignature: Caller did not provide required signer
- IncorrectProgramId: Account not owned by expected program
- Size/limit errors: Split flows into multiple transactions if needed
