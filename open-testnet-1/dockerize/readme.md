# Twilight Testnet 🧪 ⚙️

This repo contains docker files to run the Twilight.

## ✨ Features

The Twilight Docker repo performs the following tasks:

- 🔧 **Storage (Postgres)**: Creates a container for postgres with respective volume for persistent storage, creates Databases and applies schemas.

- 🌐 **Forkscanner**: Builds and runs forkscanner in a docker container.

- ⬇️ **Network**: Create a network to allow inter container communication.

- ⚙️ **NYKS**: Builds and runs the Nyks chain.

- 🔌 **Btc Oracle**: Builds and runs the Btc Oracle 

##  How To Run

To run Twilight, follow these steps:

1. Install [Docker](https://www.docker.com/)

2. Clone this repo.

3. Go to the Root Folder. This folder will have the docker-compose.yml file

4. run the command

```bash
Docker-compose up
```

This command will create docker containers, clone twilight repos in those containers, build and run the system.

1. When the docker starts the chain. it will go into initial block download (IBD) phase. This means that your node has joined the chain and is catching up. We cannot run btc-oracle until the chain has caught up.
2. When the chain starts, your twilight address will be displayed. Please ensure that this address has nyks tokens in it.
3. Once the IBD is done, go to ./scripts/nyks_entrypoint.sh file and uncomment line 10. Then simply rerun the container using the commands 
```bash
docker-compose down
docker-compose up
```


## Configurations

#### Nyks
As of now the docker container builds and joins to an existing chain. If you want to star a standalone node or a new chain, then docker file needs to be changed. This information is mentioned as comments in the ./nyks/dockerfile. 

#### BTC Oracle
As of now BTC oracle starts with a new wallet. If you have a an old one, please use the --mnemonic flag, followed by the 12 word mnemonic. An example is mentioned in ./scripts/nyks_entrypoint.sh
