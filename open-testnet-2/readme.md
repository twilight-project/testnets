# open-testnet-2

[validator-docker](/open-testnet-2/validator-docker/)
This folder contains detailed instructions to setup and deploy a validator node for the testnet. The instructions on how to create and run a new testnet are also included.

**docker components**
- nyks node software configured as `validator`
- btc-oracle  configured in `validator` /`judge` mode   
- Forkscanner


[btc-signer-docker](/open-testnet-2/btc-signer-docker/)
This folder provides detailed instructions for setting up a node to function as a BTC Fragments signer. Detailed instructions to setup a offline BTC wallet are included [here](/open-testnet-2/btc-signer-docker/readme.md). 

**docker components** 
- nyks node software
- btc-oracle configured in `signer` mode