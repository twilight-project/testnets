#!/bin/bash
nyksd tx nyks set-delegate-addresses $(nyksd keys show validator-self -a --bech val --keyring-backend test) $(nyksd keys show validator-self -a --keyring-backend test) 03b2b1d509b1655b422118a34c1c4b92967287bc4b0e722e168b8d5ce744f71cd8 $(nyksd keys show validator-self -a --keyring-backend test) --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx bridge register-judge $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show validator-self --bech val -a --keyring-backend test) --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx bridge bootstrap-fragment $(nyksd keys show validator-self -a --keyring-backend test) 6 5 1 1 22 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd keys add signer1 --keyring-backend test
sleep 10
nyksd keys add signer2 --keyring-backend test
sleep 10
nyksd keys add signer3 --keyring-backend test
sleep 10
nyksd keys add signer4 --keyring-backend test
sleep 10
nyksd keys add signer5 --keyring-backend test
sleep 10
nyksd keys add signer6 --keyring-backend test
sleep 10

nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer1 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer2 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer3 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer4 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer5 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer6 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 10

nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf45adad --from signer1 --keyring-backend test --chain-id nyks -y
sleep 10
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf46adad --from signer2 --keyring-backend test --chain-id nyks -y
sleep 10
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf47adad --from signer3 --keyring-backend test --chain-id nyks -y
sleep 10
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf48adad --from signer4 --keyring-backend test --chain-id nyks -y
sleep 10
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf49adad --from signer5 --keyring-backend test --chain-id nyks -y
sleep 10
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf50adad --from signer6 --keyring-backend test --chain-id nyks -y
sleep 10

nyksd tx volt accept-signers 1 1 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx volt accept-signers 1 2 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx volt accept-signers 1 3 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx volt accept-signers 1 4 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx volt accept-signers 1 5 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx volt accept-signers 1 6 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10

nyksd tx bridge register-reserve-address 1 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10

nyksd keys add faucet --keyring-backend test
sleep 10
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show faucet -a --keyring-backend test) 1000000000nyks --keyring-backend test -y
sleep 10
nyksd tx bridge register-deposit-address 1BY1odPsGFFhQZCcc7M6V4w2v4kaVHFTgp 100000000000000 1000 --from faucet --chain-id nyks --keyring-backend test -y
sleep 10
nyksd tx bridge msg-confirm-btc-deposit 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM 100000000000000 10000 000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f $(nyksd keys show faucet -a --keyring-backend test) twilight1k5knhhd6p9zxxwug77aqgrayvyt8yh6nw8ca7h --from validator-self --chain-id nyks --keyring-backend test -y
sleep 10