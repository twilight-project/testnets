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
RUN tar -xf nyks_linux**
ENV PATH="/testnet/nyks/release:${PATH}"
# ========================================================================================

# ========================================================================================
# for joining existing chain

# COPY ./nyks/genesis.json /root/.nyks/config/genesis.json
# RUN sed -i 's/persistent_peers = ""/persistent_peers = "cfac2e24742cc7ad3f972c0c9e0228d051abd034@64.23.150.96:26656"/' /root/.nyks/config/config.toml
# ========================================================================================

WORKDIR /testnet
RUN git clone -b fix-mod https://github.com/twilight-project/zkoracle-go.git
WORKDIR /testnet/zkoracle-go
# RUN git fetch origin
RUN go mod tidy
RUN CGO_ENABLED=0 go build .

WORKDIR /testnet/zkoracle-go/config
# RUN sed -i '2s|.*|"accountName": "validator-self",|' config.json
# RUN sed -i '2s|.*| "nyks_url": "0.0.0.0:1317"|' config.json
# Replace the value of accountName
RUN sed -i 's|"accountName": *"[^"]*"|"accountName": "validator-self"|' config.json

# Replace the value of nyks_url
RUN sed -i 's|"nyks_url": *"[^"]*"|"nyks_url": "http://0.0.0.0:1317"|' config.json
RUN cat config.json
# configure the btc-oracle as Judge


# build the faucet server
# ========================================================================================

WORKDIR /testnet

COPY ./nyks/btcDepositConfirmer/ /testnet/btcDepositConfirmer/
WORKDIR /testnet/btcDepositConfirmer

RUN go mod tidy
RUN CGO_ENABLED=0 go build .

RUN chmod +x /testnet/btcDepositConfirmer/depositconfirmer



WORKDIR /testnet
COPY ./scripts/wait_for_it.sh /testnet/wait_for_it.sh
COPY ./scripts/nyks_entrypoint.sh /testnet/nyks_entrypoint.sh
COPY ./scripts/bootstrap.sh /testnet/bootstrap.sh
COPY ./scripts/pre_bootstrap.sh /testnet/pre_bootstrap.sh
RUN chmod +x /testnet/wait_for_it.sh
RUN chmod +x /testnet/nyks_entrypoint.sh
RUN chmod +x /testnet/zkoracle-go/zkoracle-go
RUN chmod +x /testnet/bootstrap.sh
RUN chmod +x /testnet/pre_bootstrap.sh

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657
EXPOSE 26660
EXPOSE 7000
EXPOSE 6969