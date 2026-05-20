###############################################################################
# ── Stage 1 ─────────────────────────── Builder ───────────────────────────── #
###############################################################################
# Uses full Ubuntu because we need build-essentials, git, Ignite, etc.
FROM ubuntu:22.04 AS builder

ARG GO_VERSION=1.22.2
ARG IGNITE_VERSION=v0.26.1
ENV DEBIAN_FRONTEND=noninteractive

# 1) OS packages (single layer; cleans cache afterwards)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl git unzip wget ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2) Go tool-chain
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"
# ENV GOPATH="/root/go"
# ENV PATH="${GOPATH}/bin:${PATH}"
# 3) Ignite CLI
RUN mkdir -p /root
# RUN curl -s "https://get.ignite.com/cli@${IGNITE_VERSION}!" | bash


WORKDIR /root
RUN git clone --branch ${IGNITE_VERSION} --depth 1 https://github.com/ignite/cli
WORKDIR /root/cli
# Install to /usr/local/bin directly so later RUN steps see it
ENV GOBIN=/usr/local/bin
RUN make install
RUN ignite version



WORKDIR /build

# 4) Get nyks + its forked Cosmos SDK
RUN git clone --branch twilightv453 \
    https://github.com/twilight-project/cosmos-sdk.git

RUN git clone --branch clearingv03 \
    https://github.com/twilight-project/nyks.git

WORKDIR /build/nyks
# tidy & remove toolchain stanza
RUN go mod tidy && sed -i '/toolchain/d' go.mod

# 5) Build nyksd (static binary inside release tar)
RUN USER=root ignite chain build --release
WORKDIR /build/nyks/release
RUN tar -xf nyks_linux**

# 6) Build deposit-confirmer
WORKDIR /build
COPY ./nyks/btcDepositConfirmer ./btcDepositConfirmer
# COPY ./nyks/twilight-faucet ./btcDepositConfirmer
WORKDIR /build/btcDepositConfirmer
RUN go mod tidy
RUN CGO_ENABLED=0 go build -o /usr/local/bin/depositconfirmer .

###############################################################################
# ── Stage 2 ─────────────────────────── Runner ────────────────────────────── #
###############################################################################
FROM debian:bookworm-slim AS runner         
LABEL org.opencontainers.image.source="https://github.com/twilight-project/nyks-docker"

# runtime utils: bash (scripts), curl (health), ca-certificates (TLS)
RUN apt-get update && \
    apt-get install -y --no-install-recommends bash curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 1) copy the two statically-linked binaries
COPY --from=builder /build/nyks/release/nyksd /usr/local/bin/nyksd
COPY --from=builder /usr/local/bin/depositconfirmer /usr/local/bin/depositconfirmer

# 2) copy entry scripts
COPY ./scripts/nyks_entrypoint.sh  /usr/local/bin/
COPY ./scripts/pre_bootstrap.sh    /usr/local/bin/
COPY ./scripts/bootstrap.sh        /usr/local/bin/
COPY ./scripts/wait_for_it.sh      /usr/local/bin/
RUN chmod +x /usr/local/bin/nyks_entrypoint.sh \
    /usr/local/bin/pre_bootstrap.sh \
    /usr/local/bin/bootstrap.sh \
    /usr/local/bin/wait_for_it.sh

# 3) working directory for scripts & volume for chain data
WORKDIR /root
VOLUME ["/root/.nyks"]

EXPOSE 1317 26656 26657 26660 6969 9090

ENTRYPOINT ["nyks_entrypoint.sh"]