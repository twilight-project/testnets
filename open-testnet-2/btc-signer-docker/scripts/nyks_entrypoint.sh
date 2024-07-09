#!/bin/bash
# This script is the entrypoint for the nyksd container.
# It copies the testnet data to the nyksd data directory and starts the nyksd daemon.
cp -Rv /testnet/data/* /root/.nyks/
nyksd start

