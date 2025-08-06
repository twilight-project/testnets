nyksd init validator-self --chain-id nyks
# Create and add a key named validator-self to the node
nyksd keys add validator-self --keyring-backend test > tmp.log 2>&1 && grep -iE '^[a-z]{3,}( [a-z]{3,}){11,}' tmp.log > validator-self.mnemonic && cat validator-self.mnemonic

# Add genesis account and generate genesis transaction
nyksd add-genesis-account validator-self 10000000000000nyks --keyring-backend test
nyksd gentx validator-self 100000000000nyks --chain-id nyks --keyring-backend test 
nyksd collect-gentxs

# Update the genesis.json file to change the stake to nyks
sed -i 's/stake/nyks/g' /root/.nyks/config/genesis.json
sed -i '11s/.*/minimum-gas-prices = "0nyks"/' /root/.nyks/config/app.toml
sed -i '129s/.*/enabled-unsafe-cors = true/' /root/.nyks/config/app.toml
sed -i '108s/.*/enable = true/' /root/.nyks/config/app.toml
sed -i '96s/.*/cors_allowed_origins = ["*"]/' /root/.nyks/config/config.toml
sed -i '91s/.*/laddr = "tcp:\/\/0.0.0.0:26657"/' /root/.nyks/config/config.toml