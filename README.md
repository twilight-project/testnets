# Testnets
This repository contains detailed instructions for joining testnets for Twilight network. Each directory is dedicated to a specific testnet and provides all necessary information and steps for participation.

## deprecated: [open-testnet-1](/open-testnet-1/)

This provides guide to setup and deploy a standard validator node along with a standard btc-oracle instance. This also contains instructions on how to setup your own testnet. 


## Recommended: [open-testnet-2](/open-testnet-2/)

**open-testnet-2** includes the links to the latest software and is the recommended version for running a testnet node. 

This directory contains two separate docker files organized to setup and deploy testnet nodes as follows

### [Validator Docker](/open-testnet-2/validator-docker/) 
- **Purpose:** Set up and deploy a standard validator node.
- **Components:** Includes the setup environment and instructions for deploying a standard validator node along with a BTC-oracle instance configured as a validator/judge.
- **Additional Information:** Instructions to set up a new testnet are also provided here.

### [BTC Signer Docker](/open-testnet-2/btc-signer-docker/)
- **Purpose:** Set up a node to act as a BTC Fragments signer.
- **Components:** Contains detailed instructions for setting up a standard network node and an offline signer for signing BTC transactions.

## Instructions to Join the Latest Network

To join the latest open-testnet-2 network, follow these steps:

1. Clone the Repository:
```bash
git clone https://github.com/twilight-project/testnets.git
cd testnets/open-testnet-2
```
2. Navigate to the desired Directory:
- For validator node setup, navigate to [validator-docker](/open-testnet-2/validator-docker/) .
- For BTC signer node setup, navigate to [btc-signer-docker](/open-testnet-2/btc-signer-docker/).

3. Follow the detailed instructions provided to build and run the dockers containers.

For detailed setup and configuration, please refer to the respective README files:

- Validator Docker [Instructions](/open-testnet-2/validator-docker/readme.md)
- BTC Signer Docker [Instructions](/open-testnet-2/btc-signer-docker/readme.md)