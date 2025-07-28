#!/bin/bash
set -e

# Run pre_bootstrap.sh only once
if [ ! -f "/root/.nyks/prebootstrap_done" ]; then
    echo "Running pre_bootstrap.sh for the first time..."
    ./pre_bootstrap.sh
    touch /root/.nyks/prebootstrap_done
else
    echo "pre_bootstrap.sh already completed. Skipping..."
fi

# Start nyksd and wait
nyksd start &

# Run bootstrap.sh only once
if [ ! -f "/root/.nyks/bootstrap_done" ]; then
sleep 15
    echo "Running bootstrap.sh for the first time..."
    ./bootstrap.sh
    touch /root/.nyks/bootstrap_done
else
sleep 3
    echo "bootstrap.sh already completed. Skipping..."
fi
echo "Starting zkoracle-go"
cd /testnet/zkoracle-go
# exec ./ZkOracle &
exec ./zkoracle-go &

echo "Starting btcDepositConfirmer"
cd /testnet/btcDepositConfirmer
exec ./depositconfirmer
