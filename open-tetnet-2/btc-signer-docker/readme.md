# Btc-Signer Setup Guide 🧪 ⚙️

This folder contains docker files necessary for setting-up and deploying the Btc-Signer node according to the proposed [architecture](./btc-signer-setup-architecture.png).

## Docker Features

The btc-signer-docker script performs the following tasks:

- **nyks**: Builds and runs the nyks full node using [Ignite CLI](https://docs.ignite.com) tools.
- **btc-oracle**: Builds and runs the [btc-oracle](https://github.com/twilight-project/btc-oracle).
- **Storage (Postgres)**: Creates a PostgreSQL container with a volume for persistent storage, sets up the necessary databases, and applies the required schemas for `btc-oracle`.

## Architecture

```text
         xxxxxxxxx
  xxxxxxxxx      xxxx
xxx                 xx
x     nyks network  xx
x                   x
xxx               xx
   xxxxx   xxxxxxxx
        xxx
          ^                       +----------------------------------+
          | broadcast/            |                                  |
          | query BTC Tx          | firewalled/offline network zone  |
          |                       |                                  |
          v                       |                                  |
  +----------------+   JSON-RPC   |   +-------------------------+    |
  |   BTC oracle   +--------------+-->| bitcoind offline wallet |    |
  |   Signer mode  |              |   +-------------------------+    |                
  +-------+--------+              |                                  |
                                  |                                  |
                                  +----------------------------------+

```

## 1. Overview
The architecture includes the following components:
- **btc-oracle**: A program responsible for fetching unsigned sweep/refund transactions from the nyks chain and publishing the signed transactions back on-chain.
- **bitcoind Offline Wallet**: An offline server that hosts a single wallet containing a signer BTC key. This server is used to sign sweep transactions forwarded by the `btc-oracle`.
- **nyks Full Node**: A `nyks` full node monitoring the sweep/refund transactions. 

**For a production environment, it is highly recommended to deploy the bitcoind Offline Wallet and the nyks Full Node/btc-oracle on separate hosts**.

The btc-oracle offline signer design is based on remote signing available in `bitcoind` and `lnd`. Signer mode, however, does not require a BTC full node connection as the signer is not responsible for creating or broadcasting transactions.

References:
- [Bitcoind: Managing the Wallet](https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md)
- [Bitcoind: Offline Signing Tutorial](https://github.com/bitcoin/bitcoin/blob/master/doc/offline-signing-tutorial.md)
- [Lightning: Remote Signing](https://github.com/lightningnetwork/lnd/blob/master/docs/remote-signing.md)

## 2. BTC offline wallet setup

We recommend using an instance of [bitcoin-core] (https://bitcoin.org/en/releases/27.0/) configured in the Offline signing wallet mode.The Bitcoin Core wallet is the preferred choice because it enables clients to utilize external signers and boasts a long-standing, rigorously tested codebase.

For ensuring wallet security, it is strongly recommended to use a separate host system with atleast 4 GB RAM and 2 GB available storage space. The system should be completely disconnected from all public networks (internet, tor, wifi etc.). The `offline` wallet host is not required to download or synchronize blockchain data.

The offline wallet should be setup as a server as part of a secured private network where, the wallet is only accessible through a designated rpc connection with `btc-oracle`. To ensure the integrity and security of the data, only `TLS` based rpc connection should be allowed between `btc-oracle` and the offline wallet node. 

### 2.1 Installation

Download and install the bitcoin binaries according to your operating systemfrom the official [Bitcoind Core registry](https://bitcoincore.org/bin/bitcoin-core-27.0/). All programs in this guide are compatible with version `27.0`.

### 2.2 Configuration
`bitcoind` instance can be configured by using a `bitcoin.conf` file. In `Linux` based systems the file is found in `/home/<username>/.bitcoin`.

A sample configuration file with recommended settings is as follows
```shell
# Accept command line and JSON-RPC commands
server=1

# RPC server settings
rpcuser=<rpc-username>
rpcpassword=<rpc-password>
# field <userpw> comes in the format: <USERNAME>:<SALT>$<HASH>.
# rpcauth = <userpw>

# Port your bitcoin node will listen for incoming requests;
# listening for bitcoin mainnet
rpcport=8332 
# Address your bitcoin node will listen for incoming requests
# should be the address of your offline host
rpcbind=0.0.0.0
# Needed for remote node connectivity
# btc-oracle IP should only be allowed 
rpcallowip=0.0.0.0/0
# Offline Wallet server shouldn't connect to any external p2p or chain node
connect=0
```

JSON-RPC connection authentication can be configured to use `rpc-username`:`rpc-password` pair or a `username and HMAC-SHA-256 hashed password` through rpcauth option. It is not recommended to hardcode `rpc-password` in the config file. The salted hash can be created from canonical python script included in the share/rpcauth in bitcoin-core installed directory. 

### 2.3. Run the RPC Server 

By default, the `bitcoind` server can be run using the following command.
```shell
bitcoind
```
In case, a non-default home directory was used during installation:

```shell
bitcoind -datadir=/path/to/bitcoin/home
```
### 2.3. Manage Wallet 

The following commands shall be used to create and manage BTC wallet on the offline host. The wallet will contain a single address controlled by a private key that will be used to sign transactions recieved from `btc-oracle`

1. Create the wallet
    ```shell
    bitcoin-cli -named createwallet \
        wallet_name=<wallet_name> \
        passphrase=<passphrase> \
        load_on_startup=true \
    ```
    Flags explanation:
    - `wallet_name`: The name of the wallet
    - `passphrase`: The passphrase that will be used to encrypt the `wallet.dat` file. 
    - `load_on_startup=true`: Ensures that the wallet is automatically loaded in
      case of `bitcoind` server restart

2. Create a new address
    ```shell
    bitcoin-cli getnewaddress
    ```
  Save the address for future use. This address shall be used to recieve/send funds on the BTC chain. 

3. Obtain 33-byte BTC public key derived from the above address
    ```shell
    bitcoin-cli getaddressinfo <btc_address> | jq -r .pubkey
    ```
Maintain a record of the public key in its hexadecimal string fromat. The btc public key will be used during the signer registration process when setting up the `btc-oracle` to act as Fragment `Signer`.  

4. The wallet can be unlocked on the offline host using the following command
```shell
bitcoin-cli walletpassphrase <passphrase> <unlock_time>
```
where:
- `passphrase` is the same as when used for creating the wallet and,
- `unlock_time` is the amount of time the wallet is unlocked for in seconds

5. The wallet can be backedup and restored 
```shell
# Backup the wallet
bitcoin-cli -rpcwallet=<wallet-name> backupwallet /path/to/backup/wallet.dat
# Restore the wallet
bitcoin-cli restorewallet <wallet-name> /path/to/backup/wallet.dat
```
It is recommended to take periodic backups of the wallet to keep it secure.     

## 3. Setup btc-oracle
### Overview
`btc-oracle` is a service that can be configured to work in Validator/Judge/Signer mode. This can be done through setting the appropriate parameters in `config.json` file. 

Set 
```
"running_mode" = signer
"validator" = false
``` 
The `validator` option needs to be set to `true` in case the Signer is also running as a `Validator`.  

Who can run a Signer:
 - Existing `Validator` who is not acting as `Judge` can be configured to also act as `Signer`
 - Any new node can register to act as a `Signer`

Note: The `Signer` does not need to act as a Validator
 

### Setup
The `btc-oracle` can be deployed using the provided docker file. The file contains instructions to deploy a `nyks` full node and connect it to an existing network.

To build and run the NYKS node, follow these steps:

1. Install [Docker](https://docs.docker.com/get-docker/) from the specified link.

2. Make a clone of this [repository](https://github.com/twilight-project/testnets).

3. Go to the [btc-signer-docker](/open-tetnet-2/btc-signer-docker/) folder. This contains the main docker-compose.yml file.

4. Select the appropriate processor architecture for your node.
The name of the nyks release executable file varies depending on the processor's architecture and the operating system. Please ensure that you update line 44 in the [nyks/Dockerfile](/open-testnet-1/btc-signer-docker/nyks/Dockerfile) accordingly:

- For Linux on an Apple chipset, replace with `RUN tar -xf nyks_linux_arm64.tar.gz`.
- For Linux on an AMD/Intel chipset, replace with `RUN tar -xf nyks_linux_amd64.tar.gz`.
- For macOS on an Apple chipset, replace with `RUN tar -xf nyks_darwin_arm64.tar.gz`.

5. Provide the `genesis.json` and `persistent_peers.txt` for the chain [here](/open-tetnet-2/required-files/). 

5. run the command to inititalize the docker

```bash
   docker-compose up
```
This command will create docker containers, clone required repositories, and then build and initialize the node. 

**Note**: 
- Upon initialization, the node will enter the Initial Block Download (IBD) phase. This indicates that your node has joined the chain and is currently synchronizing. During this period, `btc-oracle` cannot be run until the chain has fully caught up. 

6. SSH into the [docker](#ssh-connection-to-the-container) container.
```bash
   cd ./btc-oracle
``` 
7. Start BTC-Oracle using the following command

```bash
   ./testnet/btc-oracle/btcoracle 
```

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

1. ```curl http://localhost:26657/status ```
This will retrieve the current status for the nyks node. This contains information such as no. of peers and if the node is catching up.

2.  ```docker exec -it <psql container id> psql -U forkscanner -d judge ```

These commands will open psql for the database `btcoracle`. Afterwards you can query the `address` table. 
    ```select * from address;```


## Grafana Stats
Enable the [grafane](#grafana-stats/open-tetnet-2/validator-docker/readme.md) stats 
After enabling the statistics, they will be accessible on port 26660. For detailed instructions on deploying a Prometheus and Grafana server, you can refer to this [link](https://medium.com/@ironsf/zetachain-testnet-monitoring-with-grafana-35609cd9308e)

`latest_sweep_tx_hash` stat is broadcasted by btc-oracle   on port 2555
