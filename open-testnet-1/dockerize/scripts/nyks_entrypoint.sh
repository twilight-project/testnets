#!/bin/bash

cp /testnet/priv_validator_state.json /root/.nyks/data/priv_validator_state.json
nyksd start > /dev/null 2>&1 &
nyksd keys show validator-self -a --keyring-backend test
sleep 30
cd /testnet/btc-oracle
# =====================================================
#uncomment once the Chain is up to date.
# /testnet/btc-oracle/forkoracle-go --new_wallet true # --mnemonic "<12 word mnemonic>"
# ====================================================
