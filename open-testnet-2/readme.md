# Testnets
This repository contains detailed instructions for joining testnets for Twilight network. Each directory is dedicated to a specific testnet and provides all necessary information and steps for participation.

## Recommended: [open-testnet-2](/open-testnet-2/)

**open-testnet-2** includes the links to the latest software and is the recommended version for running a testnet node. 

This directory contains two separate docker files organized to setup and deploy testnet nodes as follows

### [Validator Docker](/open-testnet-2/validator-docker/) 
- **Purpose:** Set up and deploy a standard validator node.
- **Components:** Includes the setup environment and instructions for deploying a standard NYKS validator node along with ZKOS and Faucet.
- **Additional Information:** Instructions to set up a new testnet are also provided here.

### [Relayer-docker](/open-testnet-2/relayer-docker/)
- **Purpose:** Set up a relayer node and all the required services.
- **Components:** includes the setup environment and detailed instructions for setting up a standard Relayer node.

## Instructions to Join the Latest Network

To join the latest open-testnet-2 network, follow these steps:

1. Clone the Repository:
```bash
git clone https://github.com/twilight-project/testnets.git
cd testnets/open-testnet-2
```
2. Navigate to the desired Directory:
- For validator node setup, navigate to [validator-docker](/open-testnet-2/validator-docker/) .
- For BTC signer node setup, navigate to [relayer-docker](/open-testnet-2/relayer-docker/).

3. Follow the detailed instructions provided to build and run the dockers containers.

For detailed setup and configuration, please refer to the respective README files:

- Validator Docker [Instructions](/open-testnet-2/validator-docker/readme.md)
- Relayer Docker [Instructions](/open-testnet-2/relayer-docker/readme.md)
