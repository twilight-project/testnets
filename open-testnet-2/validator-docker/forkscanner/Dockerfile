FROM rust:latest as builder

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    vim \
    telnet \
    lsof \
    postgresql-client
    
RUN apt update && \
    apt-get install -y \
        build-essential \
        ca-certificates \
        libpq-dev
WORKDIR /testnet

RUN git config --global http.postBuffer 524288000
RUN git clone https://github.com/twilight-project/forkscanner.git
WORKDIR /testnet/forkscanner
RUN git fetch origin
RUN git checkout develop
RUN cargo install diesel_cli --no-default-features --features postgres
ENV DATABASE_URL=postgres://forkscanner:forkscanner@postgres_container/forkscanner

COPY ./forkscanner/nodes_setup.sql /testnet/forkscanner/scripts/nodes_setup.sql

WORKDIR /testnet/forkscanner
RUN cargo build --release

WORKDIR /testnet
COPY ./scripts/wait_for_it.sh /testnet/wait_for_it.sh
COPY ./scripts/fk_entrypoint.sh /testnet/fk_entrypoint.sh
RUN chmod +x /testnet/wait_for_it.sh
RUN chmod +x /testnet/fk_entrypoint.sh

EXPOSE 8340
EXPOSE 8339
