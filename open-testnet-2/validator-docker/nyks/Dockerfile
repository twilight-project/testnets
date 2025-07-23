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
RUN ignite version


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
RUN echo "Contents of go.mod after modification (first 10 lines):" && head -n 10 go.mod 

RUN sed -i '/toolchain/d' go.mod 
RUN head -n 10 go.mod 
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
RUN ./nyksd add-genesis-account validator-self 10000000000000nyks --keyring-backend test
RUN ./nyksd gentx validator-self 100000000000nyks --chain-id nyks --keyring-backend test 
RUN ./nyksd collect-gentxs
# update the genesis.json file to change the stake to nyks
RUN sed -i 's/stake/nyks/g' /root/.nyks/config/genesis.json
# ========================================================================================

# ========================================================================================
# for joining existing chain

# COPY ./nyks/genesis.json /root/.nyks/config/genesis.json
# RUN sed -i 's/persistent_peers = ""/persistent_peers = "cfac2e24742cc7ad3f972c0c9e0228d051abd034@64.23.150.96:26656"/' /root/.nyks/config/config.toml
# ========================================================================================

RUN sed -i '11s/.*/minimum-gas-prices = "0nyks"/' /root/.nyks/config/app.toml
RUN sed -i '129s/.*/enabled-unsafe-cors = true/' /root/.nyks/config/app.toml
RUN sed -i '108s/.*/enable = true/' /root/.nyks/config/app.toml
RUN sed -i '96s/.*/cors_allowed_origins = ["*"]/' /root/.nyks/config/config.toml
RUN sed -i '91s/.*/laddr = "tcp:\/\/0.0.0.0:26657"/' /root/.nyks/config/config.toml

WORKDIR /testnet
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
COPY ./scripts/bootstrap.sh /testnet/bootstrap.sh
RUN chmod +x /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/bootstrap.sh

RUN git clone https://github.com/twilight-project/zkoracle-go.git
WORKDIR /testnet/zkoracle-go
RUN git fetch origin
RUN go mod tidy

WORKDIR /testnet/zkoracle-go/configs
RUN sed -i '2s|.*|"accountName": "validator-self",|' config.json
RUN sed -i '2s|.*| "nyks_url": "0.0.0.0:1317"|' config.json
# configure the btc-oracle as Judge

WORKDIR /testnet
COPY ./scripts/wait_for_it.sh /testnet/wait_for_it.sh
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/wait_for_it.sh
RUN chmod +x /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/zkoracle-go/zkoracle-go
RUN chmod +x /testnet/bootstrap.sh

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657
EXPOSE 26660