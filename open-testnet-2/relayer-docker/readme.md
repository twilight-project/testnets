# Twilight Open-Testnet-2  🧪 ⚙️

# Relayer Node setup

This repository contains docker files necessary for setting-up and deploying the relayer. It sets up a full relayer node along with all of its dependencies.

## What's Included?
- Kafka 
- Zookeeper
- Psql
- Relayer-core
- Relayer-api
- Redis

## Docker Features

The Twilight relayer docker script performs the following tasks:

- **relayer**: Builds and runs the Relayer along with all of its dependencies.


##  Run a Relayer

To build and run the validator node, follow these steps:

1. Install [Docker](https://docs.docker.com/get-docker/) from the specified link.

2. Make a clone of this [repository](https://github.com/twilight-project/testnets).

3. Make sure that validator is running. follow this [readme](/open-testnet-2/validator-docker/readme.md)  

4. Go to the [open-testnet-2](/open-testnet-2/relayer-docker/) directory. This contains the main docker-compose.yml file.

5. run the command

   ```bash
   docker compose up
   ```
   This command will create docker containers, clone required repositories, and then build and initialize the chain. 
