FROM ubuntu:22.04 as base
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    vim \
    telnet

RUN apt update && \
    apt-get install -y \
        build-essential \
        ca-certificates

WORKDIR /testnet
RUN curl -OL https://golang.org/dl/go1.22.2.linux-amd64.tar.gz
RUN tar -C /usr/local -xvf go1.22.2.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /testnet
RUN mkdir -p /root
RUN curl https://get.ignite.com/cli@v0.26.1! | bash
RUN ignite version > version.txt


RUN git config --global http.postBuffer 524288000

RUN git clone https://github.com/twilight-project/cosmos-sdk.git
WORKDIR /testnet/cosmos-sdk
RUN git fetch origin
RUN git checkout twilightv453

WORKDIR /testnet

RUN git clone https://github.com/twilight-project/nyks.git
WORKDIR /testnet/nyks
RUN git fetch origin
RUN git checkout open-testnet
RUN go mod tidy

RUN USER=root ignite chain build --release
WORKDIR /testnet/nyks/release
RUN ls -a
RUN tar -xf nyks_linux_arm64.tar.gz
ENV PATH="/testnet/nyks/release:${PATH}"


RUN nyksd init validator-self --chain-id nyks
RUN nyksd keys add validator-self --keyring-backend test

# ========================================================================================
# for new chain setup or new single node setup

# RUN ./nyksd add-genesis-account validator-self 100000000000nyks --keyring-backend test
# RUN ./nyksd gentx validator-self 100000000nyks --chain-id nyks --keyring-backend test 
# RUN ./nyksd collect-gentxs
# RUN sed -i 's/stake/nyks/g' /root/.nyks/config/genesis.json
# ========================================================================================

# ========================================================================================
# for joining existing chain

COPY ./nyks/genesis.json /root/.nyks/config/genesis.json
RUN sed -i 's/persistent_peers = ""/persistent_peers = "aa0fd7534f2b4ab69d7d7d0465eb19027261a2f8@64.23.150.96:26656"/' /root/.nyks/config/config.toml
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
RUN git checkout dev
RUN sed -i '9s|.*|github.com/btcsuite/btcd v0.22.1|' /testnet/nyks/go.mod
RUN go mod tidy
ENV CGO_ENABLED=0
RUN go build .

WORKDIR /testnet/btc-oracle/configs
RUN sed -i '2s|.*|"accountName": "validator-self",|' config.json
RUN sed -i '4s|.*| "DB_host": "postgres_container",|' config.json
RUN sed -i '8s|.*| "forkscanner_host": "forkscanner",|' config.json
RUN sed -i '11s|.*| "nyksd_url": "http://0.0.0.0:1317",|' config.json
RUN sed -i '12s|.*| "nyksd_socket_url" : "ws://0.0.0.0:26657/websocket",|' config.json

WORKDIR /testnet
COPY ./scripts/wait_for_it.sh /testnet/wait_for_it.sh
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/wait_for_it.sh
RUN chmod +x /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/btc-oracle/forkoracle-go

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657
EXPOSE 26660