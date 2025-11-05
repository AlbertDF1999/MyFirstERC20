# OurToken ERC20

A simple ERC20 token implementation built with Solidity and OpenZeppelin contracts.

## Overview

OurToken is a basic ERC20 token with a fixed initial supply that is minted to the deployer upon contract creation. The token follows the ERC20 standard and includes all standard functionality for transfers, approvals, and allowances.

## Features

- **Fixed Supply**: Total supply is set at deployment and cannot be changed
- **No Minting**: Users cannot mint additional tokens after deployment
- **Standard ERC20**: Fully compliant with the ERC20 token standard
- **OpenZeppelin**: Built on battle-tested OpenZeppelin contracts

## Contract Details

- **Token Name**: OurToken
- **Token Symbol**: OT
- **Decimals**: 18 (default)
- **Solidity Version**: 0.8.19

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.19

### Installation

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

### Compilation

```bash
forge build
```

### Testing

Run the full test suite:

```bash
forge test
```

Run tests with verbosity:

```bash
forge test -vvv
```

Run specific test:

```bash
forge test --match-test testTransfer
```

Run fuzz tests with custom runs:

```bash
forge test --fuzz-runs 1000
```

## Deployment

To deploy the token, you'll need to specify the initial supply in the deployment script:

```solidity
// Example: Deploy with 1,000,000 tokens
uint256 initialSupply = 1_000_000 * 10**18;
OurToken token = new OurToken(initialSupply);
```

Deploy to local network:

```bash
forge script script/DeployOurToken.s.sol --rpc-url http://localhost:8545 --broadcast
```

Deploy to testnet (e.g., Sepolia):

```bash
forge script script/DeployOurToken.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Usage

### Transfer Tokens

```solidity
// Transfer 100 tokens to an address
token.transfer(recipientAddress, 100 * 10**18);
```

### Approve Spending

```solidity
// Approve spender to use 50 tokens
token.approve(spenderAddress, 50 * 10**18);
```

### Transfer From (Allowance)

```solidity
// After approval, spender can transfer tokens
token.transferFrom(ownerAddress, recipientAddress, 50 * 10**18);
```

### Check Balance

```solidity
uint256 balance = token.balanceOf(address);
```

### Check Allowance

```solidity
uint256 allowance = token.allowance(ownerAddress, spenderAddress);
```

## Test Coverage

The test suite includes comprehensive coverage for:

### Core Functionality
- Initial supply verification
- Mint prevention (users cannot mint)
- Token metadata (name, symbol, decimals)

### Transfers
- Basic transfers
- Transfer from deployer
- Insufficient balance handling
- Zero address protection
- Event emission
- Self-transfers

### Allowances
- Approve functionality
- TransferFrom with allowances
- Third-party transfers
- Insufficient allowance handling
- Increase/decrease allowance
- Multiple approvals

### Edge Cases
- Zero amount transfers
- Zero approvals
- Transfer to self
- Balance consistency

### Fuzz Testing
- Random transfer amounts and addresses
- Random approval scenarios
- Random transferFrom operations

## Security Considerations

- The contract uses OpenZeppelin's audited ERC20 implementation
- No custom minting functionality reduces attack surface
- Fixed supply prevents inflation attacks
- Standard ERC20 prevents common vulnerabilities

## License

MIT

## Resources

- [OpenZeppelin ERC20 Documentation](https://docs.openzeppelin.com/contracts/4.x/erc20)
- [ERC20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [Foundry Book](https://book.getfoundry.sh/)

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting a pull request.

## Contact

For questions or issues, please open an issue in the repository.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
