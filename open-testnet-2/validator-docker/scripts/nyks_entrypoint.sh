#!/bin/bash
cp -Rv /testnet/data/* /root/.nyks/
nyksd start

# =====================================================
#Uncomment once the chain is up to date.
# nyksd keys show validator-self -a --keyring-backend test
# sleep 900
# cd /testnet/btc-oracle
# /testnet/btc-oracle/forkoracle-go --new_wallet true # --mnemonic "<12 word mnemonic>"
# ====================================================
