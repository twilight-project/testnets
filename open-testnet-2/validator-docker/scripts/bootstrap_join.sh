set -e

echo "Setting delegate addresses"
nyksd tx nyks set-delegate-addresses $(nyksd keys show validator-self -a --bech val --keyring-backend test) $(nyksd keys show validator-self -a --keyring-backend test) 03b2b1d509b1655b422118a34c1c4b92967287bc4b0e722e168b8d5ce744f71cd8 $(nyksd keys show validator-self -a --keyring-backend test) --from validator-self --chain-id nyks --keyring-backend test -y

sleep 6