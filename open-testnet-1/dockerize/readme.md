# Twilight Open-Testnet-1 🧪 ⚙️

# Twilight Blockchain Network

This repository contains Docker files necessary for setting-up and executing the Twilight blockchain network.

## Architecture

![Architecture Diagram](architecture-open-testnet-1.jpg)

## What's Included?
- Nyks (pseudo name of the chain)
- Forkscanner (monitors Bitcoin Mainnet for forks and updates Nyks)
- BTC Oracle (Relayer between Bitcoin Mainnet and Nyks)

## What's Not Included?
- ZkOS or other VMs

## Docker Features

The Twilight docker script performs the following tasks:

- **Nyks**: Builds and runs the Nyks chain.
- **BTC Oracle**: Builds and runs the BTC Oracle.
- **Forkscanner**: Builds and runs the Forkscanner. This system connects to 3 Twilight's hosted Bitcoin full nodes. If you prefer to use your own Bitcoin Core nodes, please update the [nodes_setup.sql](/open-testnet-1/dockerize/forkscanner/nodes_setup.sql) file with the relevant details.
- **Storage (Postgres)**: Creates a PostgreSQL container with a volume for persistent storage, sets up the necessary databases, and applies the required schemas for Forscanner.


###  How To Run

To build and run the Twilight node, follow these steps:

1. Install [Docker](https://docs.docker.com/get-docker/) from the specified link.

2. Make a clone of this [repository](https://github.com/twilight-project/testnets).

3. Go to the [open-test-net](/open-testnet-1/dockerize/) folder. This contains the main docker-compose.yml file.

4. Select the appropriate [Processor Architecture](#processor-architecture) for your node and update the [configuration](#configurations) options. 

5. run the command

```bash
   docker-compose up
```
This command will create docker containers, clone Twilight repositories, and then build and initialize the chain. 

6. SSH into the [docker](#ssh-connection-to-the-container) container.
```bash
   cd ./btc-oracle
``` 
7. Start BTC-Oracle using the following command

```bash
   ./testnet/btc-oracle/forkoracle-go --new_wallet true &
```

#### Processor Architecture
The name of the nyks release executable file varies depending on the processor's architecture and the operating system. Please ensure that you update line 44 in the [nyks/Dockerfile](/open-testnet-1/dockerize/nyks/Dockerfile) accordingly:
1. For Linux on an Apple chipset, replace with `RUN tar -xf nyks_linux_arm64.tar.gz`.
2. For Linux on an AMD/Intel chipset, replace with `RUN tar -xf nyks_linux_amd64.tar.gz`.
3. For macOS on an Apple chipset, replace with `RUN tar -xf nyks_darwin_arm64.tar.gz`.

## Configurations

### Nyks
Currently, the Docker container is configured to build a standalone node and creates a new chain. If you wish to join an existing chain, modifications to the Dockerfile will be necessary. 
#### Instructions for joining existing network
Make the following changes in [Dockerfile](/open-testnet-1/dockerize/nyks/Dockerfile)
1. Comment out the section for `single node setup`
2. Uncomment the section for `joining existing chain`
3. Provide the `genesis.json` and `persistent_peers.txt` for the existing chain [here](/open-testnet-1/required-files/).

4. Upon initialization, the node will enter the Initial Block Download (IBD) phase. This indicates that your node has joined the chain and is currently synchronizing. During this period, BTC-Oracle cannot be run until the chain has fully caught up. 
5. Once the IBD is done, go to [entrypoint_nyks.sh](/open-testnet-1/dockerize/scripts/nyks_entrypoint.sh) file and uncomment line 10. Then simply rerun the container using the commands 
```bash
   docker-compose down
   docker-compose up
```    

### BTC Oracle
BTC-Oracle includes a built-in BTC wallet, and initializing this wallet is mandatory when starting BTC-Oracle. There are three methods to initialize the wallet:
1. Create a New Wallet
```bash
    /testnet/btc-oracle/forkoracle-go --new_wallet true
```
BTC-Oracle creates a new wallet and return the 12 word mnemnic to the client for safekeeping. The wallet seed is encrypted and saved in `iv.txt` file.  

2. Import Wallet with Mnemonic 
```bash
    /testnet/btc-oracle/forkoracle-go --new_wallet true  --mnemonic "<12 word mnemonic>"
```
In this scenario, the client provides the 12 word mnemonic and the BTC-Oracle reconstructs the seed and keypairs from it.

3. Load Existing Wallet
```bash 
    /testnet/btc-oracle/forkoracle-go
```
BTC-Oracle will load an existing wallet using the encrypted seed file `iv.txt`.  

### Storage
The Docker container uses the following directories for persistent storage. Delete the following folders to completely remove all chain data, 
1. /nyks/data/
2. /psql/data/

#### SSH connection to the container
A user can SSH into the container using the following commands:

1. List the active containers along with their IDs:
```bash
   docker ps
```
2. Access the desired container using its ID:
```bash
   docker exec -it <container_id> /bin/bash
```
## Testing
Run the following commands to validate the system.

1. ```curl --location 'http://<ip address>:<port>' --header 'Content-Type: application/json' --data '{"method": "get_tips", "params": { "active_only": false }, "jsonrpc": "2.0", "id": 1}' ```

This will give us the current BTC chaitips from forkscanner. It will only work if forkscanner is working properly. Please note that it can take some time (approx. 10 min), since forkscanner need to process 100 historic blocks before becoming active.

2. ```curl http://localhost:26657/status ```
This will retrieve the current status for the nyks node. This contains information such as no. of peers and if the node is catching up.

3. ```docker exec -it <psql container id> psql -U forkscanner -d forkscanner ```
    ```docker exec -it <psql container id> psql -U forkscanner -d judge ```

These commands will open psql for the database Forkscanner (used by Forkscanner) and Judge (used by Btc-Oracle) respectively. Afterwards you can query the chaintips table. 
    ```select * from chaintips;```

## Join the network
You can use the following create-validator command to become a validator:

```bash
nyksd tx staking create-validator --amount=100000000nyks --pubkey=[your-pub-key] --moniker="validator-self" --chain-id=nyks --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1" --gas="auto" --gas-prices="0nyks" --from=validator-self --keyring-backend test
```

## Create a new network
To create a new network please refer to the [nyks/Dockerfile](/open-testnet-1/dockerize/nyks/Dockerfile). Please uncomment the `new network` section and comment out the `join network` section.

## Grafana Stats
To enable Grafana stats, please [SSH](#ssh-connection-to-the-container) into the container. The configurations can be found in the following file

1. [Instrumentation configuration](#instrumentation-configuration) section is found in `/root/.nyks/config/config.toml`  
2.  [Telemetry configuration](#telemetry-configuration) section is found in `/root/.nyks/config/app.toml`  

Sample configurations to enable stats
#### Telemetry Configuration
```
[telemetry]
service-name = ""
enabled = true
enable-hostname = true
enable-hostname-label = true
enable-service-label = true
prometheus-retention-time = 5000
global-labels = []
```
#### Instrumentation Configuration
```
[instrumentation]
prometheus = true
prometheus_listen_addr = ":26660"
max_open_connections = 3
namespace = "tendermint"
```
After enabling the statistics, they will be accessible on port 26660. For detailed instructions on deploying a Prometheus and Grafana server, you can refer to this [link](https://medium.com/@ironsf/zetachain-testnet-monitoring-with-grafana-35609cd9308e)

`latest_sweep_tx_hash` stat is broadcasted by btc-oracle   on port 2555
