set -e
nyksd init validator-v2 --chain-id nyks-v2
# Create and add a key named validator-v2 to the node
cd ..
nyksd keys add validator-v2 --keyring-backend test > tmp.log 2>&1 && grep -iE '^[a-z]{3,}( [a-z]{3,}){11,}' tmp.log > ./root/secrets/validator-v2.mnemonic && cat ./root/secrets/validator-v2.mnemonic
sleep 2
nyksd keys add signer-1 --keyring-backend test
sleep 2
nyksd keys add signer-2 --keyring-backend test
sleep 2
nyksd keys add signer-3 --keyring-backend test
sleep 2
nyksd keys add signer-4 --keyring-backend test
sleep 2
nyksd keys add signer-5 --keyring-backend test
sleep 2
nyksd keys add signer-6 --keyring-backend test

sed -i 's/"bond_denom": "stake"/"bond_denom": "nyks"/g' ~/.nyks/config/genesis.json
sed -i 's/"mint_denom": "stake"/"mint_denom": "nyks"/g' ~/.nyks/config/genesis.json
sed -i 's/"denom": "stake"/"denom": "nyks"/g' ~/.nyks/config/genesis.json
# Add genesis account and generate genesis transaction
nyksd genesis add-genesis-account validator-v2 10000000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-1 1000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-2 1000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-3 1000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-4 1000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-5 1000000000nyks --keyring-backend test
nyksd genesis add-genesis-account signer-6 1000000000nyks --keyring-backend test

nyksd genesis gentx validator-v2 100000000nyks --chain-id nyks-v2 --keyring-backend test
nyksd genesis collect-gentxs


sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0nyks"/g' ~/.nyks/config/app.toml
sleep 5
sed -i '151s/.*/enabled-unsafe-cors = true/' /root/.nyks/config/app.toml
sed -i '130s/.*/enable = true/' /root/.nyks/config/app.toml
sed -i '133s/.*/swagger = true/' /root/.nyks/config/app.toml
sed -i '136s|.*|address = "tcp://0.0.0.0:1317"|' /root/.nyks/config/app.toml
sed -i '95s/.*/cors_allowed_origins = ["*"]/' /root/.nyks/config/config.toml
sed -i '90s|.*|laddr = "tcp://0.0.0.0:26657"|' /root/.nyks/config/config.toml
sleep 5