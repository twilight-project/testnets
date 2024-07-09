FROM ubuntu:22.04 as base
# get and install necessary sysytem packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    vim \
    telnet

# update the package repository and install essestial build packages
RUN apt update && \
    apt-get install -y \
        build-essential \
        ca-certificates

# setup woekdir and install go and ignite
WORKDIR /testnet
RUN curl -OL https://golang.org/dl/go1.22.2.linux-amd64.tar.gz
RUN tar -C /usr/local -xvf go1.22.2.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /testnet
RUN mkdir -p /root
RUN curl https://get.ignite.com/cli@v0.26.1! | bash
RUN ignite version > version.txt


RUN git config --global http.postBuffer 524288000
# clone cosmos-sdk v45.3
RUN git clone https://github.com/twilight-project/cosmos-sdk.git
WORKDIR /testnet/cosmos-sdk
RUN git fetch origin
RUN git checkout twilightv453

WORKDIR /testnet
# clone nyks chain node source code
RUN git clone https://github.com/twilight-project/nyks.git
WORKDIR /testnet/nyks
RUN git fetch origin
RUN git checkout clearingv03
RUN go mod tidy
# build nyks chain node binary
RUN USER=root ignite chain build --release
WORKDIR /testnet/nyks/release
RUN ls -a
RUN tar -xf nyks_linux_arm64.tar.gz
ENV PATH="/testnet/nyks/release:${PATH}"

# initialize the nyks chain node 
RUN nyksd init validator-self --chain-id nyks
# create a add a key named validator-self  to the node
RUN nyksd keys add validator-self --keyring-backend test

# ========================================================================================
# for new chain setup or new single node setup
# add genesis account and generate genesis transaction
RUN ./nyksd add-genesis-account validator-self 100000000000nyks --keyring-backend test
RUN ./nyksd gentx validator-self 100000000nyks --chain-id nyks --keyring-backend test 
RUN ./nyksd collect-gentxs
# update the genesis.json file to change the stake to nyks
RUN sed -i 's/stake/nyks/g' /root/.nyks/config/genesis.json
# ========================================================================================

# ========================================================================================
# for joining existing chain

#COPY ./nyks/genesis.json /root/.nyks/config/genesis.json
#RUN sed -i 's/persistent_peers = ""/persistent_peers = "cfac2e24742cc7ad3f972c0c9e0228d051abd034@64.23.150.96:26656"/' /root/.nyks/config/config.toml
# ========================================================================================

RUN sed -i '11s/.*/minimum-gas-prices = "0nyks"/' /root/.nyks/config/app.toml
RUN sed -i '129s/.*/enabled-unsafe-cors = true/' /root/.nyks/config/app.toml
RUN sed -i '108s/.*/enable = true/' /root/.nyks/config/app.toml
RUN sed -i '96s/.*/cors_allowed_origins = ["*"]/' /root/.nyks/config/config.toml
RUN sed -i '91s/.*/laddr = "tcp:\/\/0.0.0.0:26657"/' /root/.nyks/config/config.toml

WORKDIR /testnet
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/nyks_entrypoint.sh

RUN mkdir -p /testnet/data
RUN cp -R /root/.nyks/* /testnet/data/
WORKDIR /testnet

RUN git clone https://github.com/twilight-project/btc-oracle.git
WORKDIR /testnet/btc-oracle
RUN git fetch origin
RUN git checkout fragments
RUN sed -i '9s|.*|github.com/btcsuite/btcd v0.22.1|' /testnet/nyks/go.mod
RUN go mod tidy
ENV CGO_ENABLED=0
RUN go build -o btcoracle

WORKDIR /testnet/btc-oracle/configs
RUN sed -i '2s|.*|"accountName": "validator-self",|' config.json
RUN sed -i '4s|.*| "DB_host": "postgres_container",|' config.json
RUN sed -i '10s|.*| "forkscanner_host": "forkscanner",|' config.json
# replace the nyksd_url and nyksd_socket_url with the ip address of the nyksd node
RUN sed -i '14s|.*| "nyksd_url": "http://0.0.0.0:1317",|' config.json
RUN sed -i '15s|.*| "nyksd_socket_url" : "ws://0.0.0.0:26657/websocket",|' config.json
# enable the validator
RUN sed -i '25s|.*| "validator": true,|' config.json
# configure the btc-oracle as Judge
#RUN sed -i '23s|.*| "running_mode": judge,|' config.json
WORKDIR /testnet
COPY ./scripts/wait_for_it.sh /testnet/wait_for_it.sh
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/wait_for_it.sh
RUN chmod +x /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/btc-oracle/btcoracle

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657
EXPOSE 26660