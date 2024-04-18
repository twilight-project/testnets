# Twilight Testnet 🧪 ⚙️

This repo contains docker files to run the Twilight.

## Architecture

![Architecture Diagram](architecture-open-testnet-1.jpeg)

## ✨ Features

The Twilight Docker repo performs the following tasks:

- **BTC Nodes**: This system will connect with hosted bitcoin nodes. In case switch to switch to your own node, pleasea update the forkscanner/nodes_setup.sql file.

- **Storage (Postgres)**: Creates a container for postgres with respective volume for persistent storage, creates Databases and applies schemas

- **Forkscanner**: Builds and runs forkscanner in a docker container

- **Network**: Create a network to allow inter container communication

- **Nyks**: Builds and runs the Nyks chain

- **BTC Oracle**: Builds and runs the BTC Oracle 

##  How To Run

To run Twilight, follow these steps:

1. Install [Docker](https://www.docker.com/)

2. Clone this repo.

3. Go to the Root Folder. This folder will have the docker-compose.yml file

4. run the command

```bash
docker-compose up
```
This command will create docker containers, clone twilight repos in those containers, build and run the system.

#### Processor Architecture
The name of the nyks release executable file varies depending on the processor's architecture and the operating system. Please ensure that you update line 45 in the `/nyks/Dockerfile` accordingly:
1. For Linux on an Apple chipset, replace with `RUN tar -xf nyks_linux_arm64.tar.gz`.
2. For Linux on an AMD/Intel chipset, replace with `RUN tar -xf nyks_linux_amd64.tar.gz`.
3. For macOS on an Apple chipset, replace with `RUN tar -xf nyks_darwin_arm64.tar.gz`.

#### Key Points to Consider
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

#### Storage
The Docker compose used the following directories for persistent storage. If you want to remove all the data, delete the following
1. /nyks/data/
2. /psql/data/

#### SSH into the container
After the docker images are built and the container are running. you can ssh into the container using the below command.
```bash
docker ps
```
Above command will the active containers along with their Ids.

```bash
docker exec -it <container id> /bin/bash
```


## Testing
Once the containers are up you can run the following command to check if they are working fine.
1. ```bash curl --location 'http://<ip address>:<port>' --header 'Content-Type: application/json' --data '{"method": "get_tips", "params": { "active_only": false }, "jsonrpc": "2.0", "id": 1}' ```
 This will give us the current chaitips from forkscanner.It will only work if forkscanner is working properly. Please note that it can take some time (approx. 10 min), since forkscanner need to process 100 historic blocks before becoming active.

 2. ```bash curl http://localhost:26657/status ```
 This will retrieve the current status for the nyks node. This contains information such as no. of peers and if the node is catching up.
