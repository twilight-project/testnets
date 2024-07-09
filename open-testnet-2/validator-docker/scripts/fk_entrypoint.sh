# Description: Entrypoint script for forkscanner container
# runs diesel migrations and starts forkscanner

cd /testnet/forkscanner
diesel migration run
diesel setup
psql -f /testnet/forkscanner/scripts/nodes_setup.sql postgres://forkscanner:forkscanner@postgres_container/forkscanner
/testnet/forkscanner/target/release/forkscanner -a all