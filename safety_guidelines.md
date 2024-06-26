# Safety Guidelines for Network Security
 
BTC oracle can be configured in either Judge or Signer mode.  Operating a nyks node involves securing a range of cryptographic keys and ensuring the security of your funds. As a node operator, it is your responsibility to protect your node from unauthorized access, loss, and theft. Here are some best practices to help you secure your network node effectively.

At present, the network is under active development and constantly evolving. It is not recommended to put any large amounts of BTC into the network.

## 1. Device Security

### 1.1. Physical Access:

Ensure that physical access to your device is restricted. If your node is set up on a personal device, restrict the access to the physical interfaces.
For rented dedicated servers or virtual private servers, research the provider’s security policies and track record. Ensure your account is secure and disable any hidden administration panels.

### 1.2. Personal Devices:

Secure all personal devices that contain Bitcoin/Twilight wallets, SSH keys, or authentication tokens. Ensure these devices are carefully considered into your threat model.

## 2. Platform Security

### 2.1. Operating System Maintenance:

Regularly update and actively maintain your device’s operating system. This includes all services and third-party code such as OpenSSH.

### 2.2 Firewall Configuration:

Use a firewall to limit exposure to your platform and its services. Opening port 26657 is recommended to accept incoming connections and p2p networking.
Only expose REST and RPC ports (default: 1317 and 26656) if required by an external application.

### 2.3. Network Security:

Consider restricting access to some endpoints from trusted networks or connect to your node via SSH or VPN. Use keys for authentication instead of passwords.

## 3. Software Security

### 3.1. Installation Verification:

Verify the authenticity of node binaries or source code using PGP and git verify-tag. Also, verify all dependencies such as Go.

### 3.2. Regular Updates:

Regularly update your node software. Follow the latest releases on [GitHub](https://github.com/twilight-project/nyks).

## 4. Wallet Security
The network Node supports a BIP39 compatible cosmos SDK keyring wallet in Validator/Judge mode. A BTC wallet is addded in case the node is run in Signer Mode. 

### 4.1. Node wallet 
Cosmos SDK keyring module is used to hold the cryptographic keys for network node. The keyring provides multiple keyring storage backends such as `os`, `file`, `pass`, `test`. Detailed instructions for setting up the keyring backend are provided [here](https://docs.cosmos.network/v0.46/run-node/keyring.html). 

The `test` backend stores keys unencrypted on the storage disk and is intended strictly for testing purposes. It must not be used in production environments. For autonomous environments, the recommended backends are `file` and `pass`.

When creating your wallet, you will receive a 24-word seed phrase. This seed phrase can be used to recover your on-chain funds, which poses a risk as anyone with access to the seed phrase can gain control of your funds. Ensuring the safety of the seed phrase is critical for maintaining the integrity of the wallet. One way of doing that is to write your seed phrase in the correct order on a piece of paper and store it ina asafe and secure location, such as fireproof and waterproof safe. Alternatively, you can store it in encrypted storage, such as a password manager. Consider creating multipkle copies and storing them in different locations. 

Never run two separate twilight nodes with the same seed phrase

### 4.2 BTC wallet
BTC oracle configured as Signer uses a [bitcoind](/docs/btc_wallet_management.md) wallet configured in remote signing mode.   

#### 4.2.1. Passphrase

When creating your descriptor wallet with `createwallet` RPC, the `wallet.dat` file is not encrypted by default. Encrypting the wallet with a passphrase can prevent unauthorized access. However this, significantly increases the risk of losing the coins due to forgotten passphrase. There is no way to recover a passphrase. This tradeoff should be well thought out by the user. 

Store the passphrase securely preferably offline in a safe place or in encrypted storage like a password manager.
Never run two separate nodes with the same passphrase.

#### 4.2.2 Backup 
The private key for the BTC wallet is stored in the wallet.dat file, which is encrypted with a password. To back up the wallet, the `backupwallet` RPC command should be utilized. Comprehensive instructions for backing up the wallet are available [here](https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md).
This backup file should be stored on one or multiple reliable offline devices. Regularly testing these backup files helps prevent future issues. A malware-infected computer can compromise the wallet when recovering the backup file. To minimize this risk, avoid connecting the backup to an online device.

If both the wallet and all backups are lost for any reason, the bitcoins associated with this wallet will become permanently inaccessible.

