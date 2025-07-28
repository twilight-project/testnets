#!/bin/bash
set -e

echo "Setting delegate addresses"
nyksd tx nyks set-delegate-addresses $(nyksd keys show validator-self -a --bech val --keyring-backend test) $(nyksd keys show validator-self -a --keyring-backend test) 03b2b1d509b1655b422118a34c1c4b92967287bc4b0e722e168b8d5ce744f71cd8 $(nyksd keys show validator-self -a --keyring-backend test) --from validator-self --chain-id nyks --keyring-backend test -y

sleep 6
echo "Bootstrapping fragment"
nyksd tx bridge bootstrap-fragment $(nyksd keys show validator-self -a --keyring-backend test) 6 5 1 1 22 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Adding signers"
echo "Adding signer1"
nyksd keys add signer1 --keyring-backend test
sleep 1
echo "Adding signer2"
nyksd keys add signer2 --keyring-backend test
sleep 1
echo "Adding signer3"
nyksd keys add signer3 --keyring-backend test
sleep 1
echo "Adding signer4"
nyksd keys add signer4 --keyring-backend test
sleep 1
echo "Adding signer5"
nyksd keys add signer5 --keyring-backend test
sleep 1
echo "Adding signer6"
nyksd keys add signer6 --keyring-backend test
sleep 3

echo "Sending funds to signers"
echo "Sending funds to signer1"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer1 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 4
echo "Sending funds to signer2"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer2 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 4
echo "Sending funds to signer3"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer3 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 4
echo "Sending funds to signer4"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer4 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 4
echo "Sending funds to signer5"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer5 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 4
echo "Sending funds to signer6"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show signer6 -a --keyring-backend test) 1000nyks --keyring-backend test -y
sleep 5

echo "Submitting signer applications"
echo "Submitting signer1 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf45adad --from signer1 --keyring-backend test --chain-id nyks -y
sleep 5
echo "Submitting signer2 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf46adad --from signer2 --keyring-backend test --chain-id nyks -y
sleep 5
echo "Submitting signer3 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf47adad --from signer3 --keyring-backend test --chain-id nyks -y
sleep 5
echo "Submitting signer4 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf48adad --from signer4 --keyring-backend test --chain-id nyks -y
sleep 5
echo "Submitting signer5 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf49adad --from signer5 --keyring-backend test --chain-id nyks -y
sleep 5
echo "Submitting signer6 application"
nyksd tx volt signer-application 1 1 1 03a34fa8b8371a6a14a2faec5e3e85b6d5f32f3c1603ad7a7b22d43aaabf50adad --from signer6 --keyring-backend test --chain-id nyks -y
sleep 5

echo "Accepting signers"
echo "Accepting signer1"
nyksd tx volt accept-signers 1 1 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Accepting signer2"
nyksd tx volt accept-signers 1 2 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Accepting signer3"
nyksd tx volt accept-signers 1 3 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Accepting signer4"
nyksd tx volt accept-signers 1 4 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Accepting signer5"
nyksd tx volt accept-signers 1 5 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5
echo "Accepting signer6"
nyksd tx volt accept-signers 1 6 --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5

echo "Registering reserve address"
nyksd tx bridge register-reserve-address 1 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM --from validator-self --chain-id nyks --keyring-backend test -y
sleep 5

echo "Adding faucet"
nyksd keys add faucet --keyring-backend test
sleep 2
echo "Sending funds to faucet"
nyksd tx bank send $(nyksd keys show validator-self -a --keyring-backend test) $(nyksd keys show faucet -a --keyring-backend test) 10000000000nyks --keyring-backend test -y
sleep 5
echo "Registering deposit address for faucet"
nyksd tx bridge register-deposit-address 1BY1odPsGFFhQZCcc7M6V4w2v4kaVHFTgp 100000000000000 1000 --from faucet --chain-id nyks --keyring-backend test -y
sleep 5
echo "Confirming deposit for faucet"
nyksd tx bridge msg-confirm-btc-deposit 14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM 100000000000000 10000 000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f $(nyksd keys show faucet -a --keyring-backend test) $(nyksd keys show validator-self -a --keyring-backend test) --from validator-self --chain-id nyks --keyring-backend test -y
sleep 2