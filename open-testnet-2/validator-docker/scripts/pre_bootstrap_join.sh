nyksd init validator-self --chain-id nyks
# Create and add a key named validator-self to the node
cd ..
nyksd keys add validator-self --keyring-backend test > tmp.log 2>&1 && grep -iE '^[a-z]{3,}( [a-z]{3,}){11,}' tmp.log > ./root/secrets/validator-self.mnemonic && cat ./root/secrets/validator-self.mnemonic


copy ./genesis.json /root/.nyks/config/genesis.json
RUN sed -i 's/persistent_peers = ""/persistent_peers = "cfac2e24742cc7ad3f972c0c9e0228d051abd034@64.23.150.96:26656"/' /root/.nyks/config/config.toml
sed -i '11s/.*/minimum-gas-prices = "0nyks"/' /root/.nyks/config/app.toml
sed -i '129s/.*/enabled-unsafe-cors = true/' /root/.nyks/config/app.toml
sed -i '108s/.*/enable = true/' /root/.nyks/config/app.toml
sed -i '96s/.*/cors_allowed_origins = ["*"]/' /root/.nyks/config/config.toml
sed -i '91s/.*/laddr = "tcp:\/\/0.0.0.0:26657"/' /root/.nyks/config/config.toml