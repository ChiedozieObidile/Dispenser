# Decentralized Autonomous Organization (DAO) Smart Contract

## Overview

This project implements a robust Decentralized Autonomous Organization (DAO) smart contract using Clarity, the smart contract language for the Stacks blockchain. The DAO allows stakeholders to create and vote on proposals, manage a shared treasury, and govern the organization through token-based voting.

## Recent Updates: Gas Optimization

We've recently implemented several changes to optimize gas usage and resolve naming conflicts:

1. Renamed the `votes` map to `vote-records` to avoid conflict with the `votes` parameter in batch voting functions.
2. Updated the `has-voted` and `vote` functions to use the new `vote-records` map name.
3. Renamed the `batch-vote` function to `batch-vote-multiple` to avoid conflict with the `vote` function.
4. Renamed the `vote-single` function to `vote-on-proposal` for better clarity and to avoid potential conflicts.

These changes improve the contract's efficiency and resolve compilation errors without altering the core functionality.

## Features

1. **Token Management**
   - Governance token representation
   - Token transfers between users
   - Minting new tokens (restricted to the contract)

2. **Proposal System**
   - Creation of proposals by token holders
   - Voting on proposals with token-weighted voting power
   - Automatic vote counting and result determination
   - Batch voting on multiple proposals

3. **Treasury Management**
   - STX deposits into the DAO treasury
   - Execution of passed proposals, including fund transfers
   - Batch execution of multiple proposals

4. **Access Control**
   - Role-based permissions for various functions
   - Security checks to prevent unauthorized actions

## Smart Contract Functions

### Read-Only Functions

1. `get-balance`: Retrieve the token balance of an account
2. `get-proposal`: Get details of a specific proposal
3. `has-voted`: Check if an account has voted on a specific proposal

### Public Functions

1. `create-proposal`: Create a new proposal
2. `vote`: Cast a vote on an existing proposal
3. `execute-proposal`: Execute a passed proposal
4. `deposit-stx`: Deposit STX into the DAO treasury
5. `mint`: Mint new governance tokens (restricted to contract)
6. `transfer`: Transfer tokens between accounts
7. `batch-vote-multiple`: Vote on multiple proposals in a single transaction
8. `batch-execute`: Execute multiple passed proposals in a single transaction

## Deployment Guide

To deploy this DAO smart contract:

1. Ensure you have the Stacks CLI installed and configured.
2. Save the contract code in a file named `smartDAO.clar`.
3. Use the Stacks CLI to deploy the contract:

   ```
   stx deploy_contract smartDAO.clar
   ```

4. Note the contract address after successful deployment.

## Usage Guide

### For DAO Administrators

1. **Initial Setup**
   - After deployment, use the `mint` function to distribute initial governance tokens to founding members.

2. **Treasury Management**
   - Use the `deposit-stx` function to add funds to the DAO treasury.

### For DAO Members

1. **Participating in Governance**
   - Create proposals using `create-proposal` function.
   - Vote on proposals using the `vote` function or `batch-vote-multiple` for multiple proposals.
   - Execute passed proposals with `execute-proposal` or `batch-execute` after the voting period.

2. **Managing Tokens**
   - Transfer tokens to other members using the `transfer` function.
   - Check your balance with `get-balance`.

## Security Considerations

- The contract includes various security checks, but a thorough audit is recommended before mainnet deployment.
- Ensure proper key management for administrative functions.
- Regularly monitor proposal activities and treasury balance.
- Be cautious with arithmetic operations to prevent overflow/underflow issues.

## Testing

To test the contract:

1. Deploy the contract to a Stacks testnet.
2. Use the Stacks CLI or a dApp to interact with the contract functions.
3. Create test proposals, vote with different accounts, and verify correct behavior.
4. Test batch voting and batch execution functionality.
5. Attempt unauthorized actions to ensure security measures are working.

## Future Improvements

- Implement a timelock mechanism for executed proposals.
- Add support for different types of proposals (e.g., text-only proposals).
- Integrate with other DeFi protocols for treasury management.

## Contributing

Contributions to improve the DAO contract are welcome. Please submit pull requests with detailed descriptions of changes and ensure all tests pass.

## Author

Chiedozie Obidile