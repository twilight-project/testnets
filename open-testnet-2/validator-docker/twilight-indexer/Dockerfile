FROM rust:1.87.0 as builder-twilight-indexer
RUN USER=root apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install git curl g++ build-essential libssl-dev pkg-config && \
    apt-get -y install software-properties-common protobuf-compiler && \
    apt-get update
RUN git clone -b bug-fix https://github.com/AhmadAshraf2/twilight-indexer.git
RUN cd twilight-indexer && cargo build --release

#############################
# Runtime stage
#############################
FROM debian:bookworm-slim AS runtime

# Install CA certificates so HTTPS works
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates protobuf-compiler jq libpq5 libpq-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*
# Create an unprivileged user to run the binary
RUN useradd -m indexer

# Set work directory to user home; this is where the JSON will be written
WORKDIR /home/indexer
COPY --from=builder-twilight-indexer ./twilight-indexer/target/release/twilight_indexer ./
COPY --from=builder-twilight-indexer ./twilight-indexer/target/release/twilight_indexer.d ./
ENTRYPOINT ["/home/indexer/twilight_indexer"]