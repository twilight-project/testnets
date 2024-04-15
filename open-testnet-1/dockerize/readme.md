# Twilight Testnet 🧪 ⚙️

This repo contains docker files to run the Twilight ecosystem.

## ✨ Features

The Twilight Docker repo performs the following tasks:

- 🔧 **Storage (Postgres)**: Creates a container for postgres with respective volume for persistent storage, creates Databases and applies schemas.

- 🌐 **Forkscanner**: Builds and runs forkscanner in a docker container.

- ⬇️ **Network**: Create a network to allow inter container communication.

- ⚙️ **NYKS**: Builds and runs the Nyks chain.

- 🔌 **Btc Oracle**: Builds and runs the Btc Oracle 

##  How To Run

To run Twilight Eco system. follow these steps:

1. Install [Docker](https://www.docker.com/)

2. Clone this repo.

3. Go to the Root Folder. this folder will have the docker-compose.yml file

4. run the command

```bash
Docker-compose up
```

This command will create docker containers, clone twilight repo's in those containers, build and run the system.

> When the docker starts the chain. it will go into initial block download (IBD) phase. this means that your node has joined the chain and is catching up. we cannot run btc-oracle until the chain has caught up.
> When the chain starts. your twilight address will be displayed. please ensure that this address has nyks tokens in it.
> Once the IBD is done. go t0 ./scripts/nyks_entrypoint.sh file and uncomment line 10. then simply rerun the container using the commands 
```bash
docker-compose down
docker-compose up
```


## Configurations.

#### NYKS
As of now the docker container builds and joins to an existing chain. if you want to star a standalone node or a new chain, then docker file needs to be changed. this information is mentioned as comments in the ./nyks/dockerfile. 

#### Btc Oracle
> As of now Btc oracle starts with a new wallet. if you have a an old one you want to use please use the --mnemonic flag, followed by the 12 word mnemonic. Example is mentioned in ./scripts/nyks_entrypoint.sh
