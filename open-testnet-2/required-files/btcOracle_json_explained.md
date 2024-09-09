- `accountName`: The name of the account.
  
- `DB_port`: The port number for the database connection.
- `DB_host`: The host address for the database connection.
- `DB_user`: The username for the database connection.
- `DB_password`: The password for the database connection.
- `DB_name`: The name of the database.
  
- `forkscanner_host`: The host address for the forkscanner.
- `forkscanner_ws_port`: The WebSocket port for the forkscanner.
- `forkscanner_rpc_port`: The RPC port for the forkscanner.
  
- `nyksd_url`: The URL for the NYKS API.
- `nyksd_socket_url`: The WebSocket URL for the NYKS API.
- `confirmation_limit`: The number of btc block confirmations required for a deposit to be marked successful on NYKS.
- `unlocking_time`: Used at the time of address generation, locks the reserve by current btc height + unlocking_time. based on OP_CLTV.
- `csv_delay`: Determines the delay period after which the refund tx in runable. based on OP_CSV.
- `sweep_preblock`: Sweep process starts this many BTC blocks before the unlocking height.
  
- `running_mode`: The running mode of the application, it can be either "judge" or "signer".
- `judge_address`: The NYKS address of the judge.
- `validator`: A boolean value indicating whether this node is also a validator, Right now the node has to be validator.
- `own_validator_address`: This node's NYKS validator address.
- `own_address`: This nodes on NYKS address.
- `judge_address`: The NYKS address of the judge this node is linked to.

- `btc_node_host`: The host address for the Bitcoin node.
- `btc_node_user`: The username for the Bitcoin node.
- `btc_node_pass`: The password for the Bitcoin node.
- `fee_rate_adjustment`: The adjustment for the fee rate. In case we want to increase or decrease fee. Amount in satoshi.
- `wallet_name`: The name of the Descriptor wallet.
- `judge_btc_wallet_name`: Name of the online wallet Judge is going to use to pay the fee. Only applicable if judge.
- `btc_xpublic_key`: The extended public key for the descriptor Bitcoin wallet.
