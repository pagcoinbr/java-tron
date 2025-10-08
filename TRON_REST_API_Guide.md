# TRON REST API Complete Developer Guide

## Overview

This comprehensive guide covers all TRON network REST API endpoints for building decentralized applications. TRON provides HTTP APIs through Full Node and Solidity Node services, enabling developers to interact with the TRON blockchain, manage accounts, execute smart contracts, and query network data.

## Base URLs

- **Full Node (MainNet)**: `https://api.trongrid.io`
- **Solidity Node (MainNet)**: `https://api.trongrid.io`  
- **Nile TestNet**: `https://nile.trongrid.io`
- **Shasta TestNet**: `https://api.shasta.trongrid.io`
- **Local Development**: `http://localhost:8090` (Full Node), `http://localhost:8091` (Solidity Node)

## Authentication & Rate Limiting

Most public endpoints require API keys for production use. Include your API key in the header:
```
TRON-PRO-API-KEY: your-api-key-here
```

## Request/Response Format

- **Content-Type**: `application/json`
- **Methods**: Both GET and POST supported for most endpoints
- **Addresses**: Support both HEX and Base58 formats using `visible` parameter
- **Parameter**: `visible=true` for Base58 addresses, `visible=false` for HEX addresses

---

## 1. Account Management APIs

### 1.1 Get Account Information
**Endpoint**: `/wallet/getaccount`  
**Method**: POST  
**Description**: Retrieve account details including balance, resources, and permissions.

```bash
curl -X POST https://api.trongrid.io/wallet/getaccount \
  -H "Content-Type: application/json" \
  -d '{
    "address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "visible": true
  }'
```

**Response**:
```json
{
  "address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
  "balance": 100000000,
  "create_time": 1611892291000,
  "latest_operation_time": 1611892291000,
  "account_resource": {
    "energy_usage": 0,
    "frozen_balance_for_energy": {
      "frozen_balance": 0,
      "expire_time": 0
    }
  }
}
```

### 1.2 Create Account
**Endpoint**: `/wallet/createaccount`  
**Method**: POST  
**Description**: Create a new account on TRON network.

```bash
curl -X POST https://api.trongrid.io/wallet/createaccount \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "account_address": "TNEw3RnG6bJh6N7xYb4cCN8cR1w3h4F5",
    "visible": true
  }'
```

### 1.3 Update Account
**Endpoint**: `/wallet/updateaccount`  
**Method**: POST  
**Description**: Update account name.

```bash
curl -X POST https://api.trongrid.io/wallet/updateaccount \
  -H "Content-Type: application/json" \
  -d '{
    "account_name": "My Account",
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "visible": true
  }'
```

### 1.4 Get Account Resources
**Endpoint**: `/wallet/getaccountresource`  
**Method**: POST  
**Description**: Get account energy and bandwidth resources.

```bash
curl -X POST https://api.trongrid.io/wallet/getaccountresource \
  -H "Content-Type: application/json" \
  -d '{
    "address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "visible": true
  }'
```

### 1.5 Get Account Network Resources
**Endpoint**: `/wallet/getaccountnet`  
**Method**: POST  
**Description**: Get account bandwidth information.

```bash
curl -X POST https://api.trongrid.io/wallet/getaccountnet \
  -H "Content-Type: application/json" \
  -d '{
    "address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "visible": true
  }'
```

---

## 2. Transaction Management APIs

### 2.1 Create Transaction
**Endpoint**: `/wallet/createtransaction`  
**Method**: POST  
**Description**: Create a TRX transfer transaction.

```bash
curl -X POST https://api.trongrid.io/wallet/createtransaction \
  -H "Content-Type: application/json" \
  -d '{
    "to_address": "TNEw3RnG6bJh6N7xYb4cCN8cR1w3h4F5",
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "amount": 1000000,
    "visible": true
  }'
```

### 2.2 Broadcast Transaction
**Endpoint**: `/wallet/broadcasttransaction`  
**Method**: POST  
**Description**: Broadcast a signed transaction to the network.

```bash
curl -X POST https://api.trongrid.io/wallet/broadcasttransaction \
  -H "Content-Type: application/json" \
  -d '{
    "signature": ["..."],
    "txID": "...",
    "raw_data": {...}
  }'
```

### 2.3 Get Transaction by ID
**Endpoint**: `/wallet/gettransactionbyid`  
**Method**: POST  
**Description**: Get transaction details by transaction ID.

```bash
curl -X POST https://api.trongrid.io/wallet/gettransactionbyid \
  -H "Content-Type: application/json" \
  -d '{
    "value": "transaction_id_here",
    "visible": true
  }'
```

### 2.4 Get Transaction Info by ID
**Endpoint**: `/wallet/gettransactioninfobyid`  
**Method**: POST  
**Description**: Get transaction execution info by transaction ID.

```bash
curl -X POST https://api.trongrid.io/wallet/gettransactioninfobyid \
  -H "Content-Type: application/json" \
  -d '{
    "value": "transaction_id_here",
    "visible": true
  }'
```

### 2.5 Get Transaction Sign Weight
**Endpoint**: `/wallet/gettransactionsignweight`  
**Method**: POST  
**Description**: Get transaction signature weight information.

### 2.6 Get Transaction Approved List
**Endpoint**: `/wallet/gettransactionapprovedlist`  
**Method**: POST  
**Description**: Get transaction approval list for multi-signature accounts.

---

## 3. Block and Network Query APIs

### 3.1 Get Latest Block
**Endpoint**: `/wallet/getnowblock`  
**Method**: GET/POST  
**Description**: Get the latest block on the network.

```bash
curl -X GET https://api.trongrid.io/wallet/getnowblock
```

### 3.2 Get Block by Number
**Endpoint**: `/wallet/getblockbynum`  
**Method**: POST  
**Description**: Get block information by block number.

```bash
curl -X POST https://api.trongrid.io/wallet/getblockbynum \
  -H "Content-Type: application/json" \
  -d '{
    "num": 12345678
  }'
```

### 3.3 Get Block by ID
**Endpoint**: `/wallet/getblockbyid`  
**Method**: POST  
**Description**: Get block information by block ID.

```bash
curl -X POST https://api.trongrid.io/wallet/getblockbyid \
  -H "Content-Type: application/json" \
  -d '{
    "value": "block_id_here",
    "visible": true
  }'
```

### 3.4 Get Block Range
**Endpoint**: `/wallet/getblockbylimitnext`  
**Method**: POST  
**Description**: Get a range of blocks.

```bash
curl -X POST https://api.trongrid.io/wallet/getblockbylimitnext \
  -H "Content-Type: application/json" \
  -d '{
    "startNum": 100,
    "endNum": 200
  }'
```

### 3.5 Get Latest Blocks
**Endpoint**: `/wallet/getblockbylatestnum`  
**Method**: POST  
**Description**: Get the latest N blocks.

```bash
curl -X POST https://api.trongrid.io/wallet/getblockbylatestnum \
  -H "Content-Type: application/json" \
  -d '{
    "num": 10
  }'
```

### 3.6 Get Chain Parameters
**Endpoint**: `/wallet/getchainparameters`  
**Method**: GET/POST  
**Description**: Get blockchain parameters.

```bash
curl -X GET https://api.trongrid.io/wallet/getchainparameters
```

### 3.7 Get Node Info
**Endpoint**: `/wallet/getnodeinfo`  
**Method**: GET/POST  
**Description**: Get information about the current node.

---

## 4. Smart Contract APIs

### 4.1 Deploy Contract
**Endpoint**: `/wallet/deploycontract`  
**Method**: POST  
**Description**: Deploy a smart contract to the TRON network.

```bash
curl -X POST https://api.trongrid.io/wallet/deploycontract \
  -H "Content-Type: application/json" \
  -d '{
    "abi": "[...]",
    "bytecode": "contract_bytecode",
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "name": "MyContract",
    "call_value": 0,
    "consume_user_resource_percent": 100,
    "visible": true
  }'
```

### 4.2 Trigger Smart Contract
**Endpoint**: `/wallet/triggersmartcontract`  
**Method**: POST  
**Description**: Call a smart contract method.

```bash
curl -X POST https://api.trongrid.io/wallet/triggersmartcontract \
  -H "Content-Type: application/json" \
  -d '{
    "contract_address": "contract_address_here",
    "function_selector": "transfer(address,uint256)",
    "parameter": "encoded_parameters",
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "call_value": 0,
    "visible": true
  }'
```

### 4.3 Trigger Constant Contract
**Endpoint**: `/wallet/triggerconstantcontract`  
**Method**: POST  
**Description**: Call a read-only smart contract method.

### 4.4 Get Contract
**Endpoint**: `/wallet/getcontract`  
**Method**: POST  
**Description**: Get contract information by address.

```bash
curl -X POST https://api.trongrid.io/wallet/getcontract \
  -H "Content-Type: application/json" \
  -d '{
    "value": "contract_address_here",
    "visible": true
  }'
```

### 4.5 Get Contract Info
**Endpoint**: `/wallet/getcontractinfo`  
**Method**: POST  
**Description**: Get detailed contract information including source code and ABI.

---

## 5. TRC10 Token APIs

### 5.1 Create Asset (TRC10)
**Endpoint**: `/wallet/createassetissue`  
**Method**: POST  
**Description**: Create a new TRC10 token.

```bash
curl -X POST https://api.trongrid.io/wallet/createassetissue \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "name": "MyToken",
    "abbr": "MTK",
    "total_supply": 1000000000,
    "trx_num": 1,
    "num": 100,
    "start_time": 1575648000000,
    "end_time": 1575734400000,
    "description": "My awesome token",
    "url": "https://mytoken.com",
    "visible": true
  }'
```

### 5.2 Transfer Asset
**Endpoint**: `/wallet/transferasset`  
**Method**: POST  
**Description**: Transfer TRC10 tokens.

```bash
curl -X POST https://api.trongrid.io/wallet/transferasset \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "to_address": "TNEw3RnG6bJh6N7xYb4cCN8cR1w3h4F5",
    "asset_name": "MyToken",
    "amount": 100,
    "visible": true
  }'
```

### 5.3 Participate in Asset Issue
**Endpoint**: `/wallet/participateassetissue`  
**Method**: POST  
**Description**: Buy tokens during ICO period.

### 5.4 Get Asset Issue List
**Endpoint**: `/wallet/getassetissuelist`  
**Method**: GET/POST  
**Description**: Get list of all TRC10 tokens.

### 5.5 Get Asset Issue by Name
**Endpoint**: `/wallet/getassetissuebyname`  
**Method**: POST  
**Description**: Get TRC10 token information by name.

### 5.6 Get Asset Issue by Account
**Endpoint**: `/wallet/getassetissuebyaccount`  
**Method**: POST  
**Description**: Get TRC10 tokens issued by an account.

---

## 6. Resource Management APIs

### 6.1 Freeze Balance (Stake v1 - Deprecated)
**Endpoint**: `/wallet/freezebalance`  
**Method**: POST  
**Description**: Freeze TRX to gain bandwidth or energy (deprecated).

### 6.2 Unfreeze Balance (Stake v1 - Deprecated)
**Endpoint**: `/wallet/unfreezebalance`  
**Method**: POST  
**Description**: Unfreeze TRX and lose resources (deprecated).

### 6.3 Freeze Balance V2 (Current Staking)
**Endpoint**: `/wallet/freezebalancev2`  
**Method**: POST  
**Description**: Stake TRX for bandwidth or energy (current system).

```bash
curl -X POST https://api.trongrid.io/wallet/freezebalancev2 \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "frozen_balance": 1000000,
    "resource": "BANDWIDTH",
    "visible": true
  }'
```

### 6.4 Unfreeze Balance V2
**Endpoint**: `/wallet/unfreezebalancev2`  
**Method**: POST  
**Description**: Unstake TRX from bandwidth or energy.

### 6.5 Delegate Resource
**Endpoint**: `/wallet/delegateresource`  
**Method**: POST  
**Description**: Delegate staked resources to another account.

### 6.6 Un-delegate Resource
**Endpoint**: `/wallet/undelegateresource`  
**Method**: POST  
**Description**: Reclaim delegated resources.

### 6.7 Get Delegated Resource
**Endpoint**: `/wallet/getdelegatedresource`  
**Method**: POST  
**Description**: Get delegated resources between accounts.

### 6.8 Get Bandwidth Prices
**Endpoint**: `/wallet/getbandwidthprices`  
**Method**: GET/POST  
**Description**: Get current bandwidth prices.

### 6.9 Get Energy Prices
**Endpoint**: `/wallet/getenergyprices`  
**Method**: GET/POST  
**Description**: Get current energy prices.

---

## 7. Super Representative (SR) & Governance APIs

### 7.1 List Witnesses
**Endpoint**: `/wallet/listwitnesses`  
**Method**: GET/POST  
**Description**: Get list of all Super Representatives.

```bash
curl -X GET https://api.trongrid.io/wallet/listwitnesses
```

### 7.2 Create Witness
**Endpoint**: `/wallet/createwitness`  
**Method**: POST  
**Description**: Apply to become a Super Representative.

```bash
curl -X POST https://api.trongrid.io/wallet/createwitness \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "url": "https://mysr.com",
    "visible": true
  }'
```

### 7.3 Update Witness
**Endpoint**: `/wallet/updatewitness`  
**Method**: POST  
**Description**: Update Super Representative information.

### 7.4 Vote Witness Account
**Endpoint**: `/wallet/votewitnessaccount`  
**Method**: POST  
**Description**: Vote for Super Representatives.

```bash
curl -X POST https://api.trongrid.io/wallet/votewitnessaccount \
  -H "Content-Type: application/json" \
  -d '{
    "owner_address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "votes": [
      {
        "vote_address": "witness_address_1",
        "vote_count": 100
      }
    ],
    "visible": true
  }'
```

### 7.5 List Proposals
**Endpoint**: `/wallet/listproposals`  
**Method**: GET/POST  
**Description**: Get list of network governance proposals.

### 7.6 Create Proposal
**Endpoint**: `/wallet/proposalcreate`  
**Method**: POST  
**Description**: Create a new governance proposal.

### 7.7 Approve Proposal
**Endpoint**: `/wallet/proposalapprove`  
**Method**: POST  
**Description**: Approve a governance proposal.

### 7.8 Delete Proposal
**Endpoint**: `/wallet/proposaldelete`  
**Method**: POST  
**Description**: Delete a governance proposal.

---

## 8. DEX Exchange APIs

### 8.1 List Exchanges
**Endpoint**: `/wallet/listexchanges`  
**Method**: GET/POST  
**Description**: Get list of all DEX trading pairs.

### 8.2 Create Exchange
**Endpoint**: `/wallet/exchangecreate`  
**Method**: POST  
**Description**: Create a new trading pair.

### 8.3 Exchange Inject
**Endpoint**: `/wallet/exchangeinject`  
**Method**: POST  
**Description**: Add liquidity to a trading pair.

### 8.4 Exchange Withdraw
**Endpoint**: `/wallet/exchangewithdraw`  
**Method**: POST  
**Description**: Remove liquidity from a trading pair.

### 8.5 Exchange Transaction
**Endpoint**: `/wallet/exchangetransaction`  
**Method**: POST  
**Description**: Execute a trade on the DEX.

### 8.6 Get Exchange by ID
**Endpoint**: `/wallet/getexchangebyid`  
**Method**: POST  
**Description**: Get trading pair information by ID.

---

## 9. Market & Pending Pool APIs

### 9.1 Get Market Pair List
**Endpoint**: `/wallet/getmarketpairlist`  
**Method**: GET/POST  
**Description**: Get list of market trading pairs.

### 9.2 Get Pending Transactions
**Endpoint**: `/wallet/gettransactionlistfrompending`  
**Method**: GET/POST  
**Description**: Get list of pending transactions.

### 9.3 Get Pending Transaction Size
**Endpoint**: `/wallet/getpendingsize`  
**Method**: GET/POST  
**Description**: Get number of pending transactions.

### 9.4 Get Transaction from Pending
**Endpoint**: `/wallet/gettransactionfrompending`  
**Method**: POST  
**Description**: Get specific transaction from pending pool.

---

## 10. Solidity Node APIs (Read-Only)

All wallet APIs are available on Solidity nodes with `/walletsolidity/` prefix for confirmed data:

### 10.1 Get Account (Solidity)
**Endpoint**: `/walletsolidity/getaccount`  
**Method**: POST  
**Description**: Get confirmed account information.

### 10.2 Get Transaction Info (Solidity)  
**Endpoint**: `/walletsolidity/gettransactioninfobyid`  
**Method**: POST  
**Description**: Get confirmed transaction execution info.

### 10.3 Get Block (Solidity)
**Endpoint**: `/walletsolidity/getblockbynum`  
**Method**: POST  
**Description**: Get confirmed block information.

---

## 11. Address Utilities

### 11.1 Validate Address
**Endpoint**: `/wallet/validateaddress`  
**Method**: POST  
**Description**: Validate if an address is correctly formatted.

```bash
curl -X POST https://api.trongrid.io/wallet/validateaddress \
  -H "Content-Type: application/json" \
  -d '{
    "address": "TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E",
    "visible": true
  }'
```

---

## 12. Advanced Features

### 12.1 Multi-Signature Support
Use `permission_id` parameter for multi-signature transactions:
```json
{
  "owner_address": "...",
  "permission_id": 2,
  "visible": true
}
```

### 12.2 Fee Limit
Set fee limit for smart contract interactions:
```json
{
  "fee_limit": 100000000,
  "call_value": 0
}
```

### 12.3 Memo Field
Add memo to transactions:
```json
{
  "extra_data": "48656c6c6f20576f726c64"
}
```

---

## Error Handling

### Common Error Codes
- `SIGERROR`: Invalid signature
- `CONTRACT_VALIDATE_ERROR`: Contract validation failed
- `CONTRACT_EXE_ERROR`: Contract execution failed
- `BANDWITH_ERROR`: Insufficient bandwidth
- `ENERGY_ERROR`: Insufficient energy
- `TAPOS_ERROR`: Invalid transaction reference
- `DUP_TRANSACTION_ERROR`: Duplicate transaction

### Example Error Response
```json
{
  "Error": "CONTRACT_VALIDATE_ERROR",
  "code": "INVALID_ADDRESS",
  "message": "Invalid address format"
}
```

---

## Rate Limiting & Best Practices

### Production Guidelines
1. **API Keys**: Always use API keys in production
2. **Rate Limits**: Respect rate limits (varies by endpoint)
3. **Error Handling**: Implement proper error handling
4. **Retry Logic**: Use exponential backoff for retries
5. **Caching**: Cache frequently accessed data
6. **Connection Pooling**: Use HTTP connection pooling

### Sample Implementation (JavaScript)
```javascript
const axios = require('axios');

class TronAPI {
  constructor(apiKey, baseUrl = 'https://api.trongrid.io') {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        'TRON-PRO-API-KEY': apiKey,
        'Content-Type': 'application/json'
      }
    });
  }

  async getAccount(address) {
    try {
      const response = await this.client.post('/wallet/getaccount', {
        address: address,
        visible: true
      });
      return response.data;
    } catch (error) {
      console.error('API Error:', error.response.data);
      throw error;
    }
  }

  async createTransaction(from, to, amount) {
    const response = await this.client.post('/wallet/createtransaction', {
      to_address: to,
      owner_address: from,
      amount: amount,
      visible: true
    });
    return response.data;
  }
}

// Usage
const tron = new TronAPI('your-api-key');
const account = await tron.getAccount('TRX9Yg4xP4cPHpnp8p8Xq8cCN8cR1w3h4E');
```

---

## Testing & Development

### Test Networks
1. **Shasta TestNet**: Full featured testnet
2. **Nile TestNet**: Lightweight testnet  
3. **Private Network**: Local development

### Getting Test TRX
- Shasta Faucet: https://www.trongrid.io/shasta
- Nile Faucet: https://nileex.io/join/getJoinPage

### Local Development Setup
```bash
# Clone TRON node
git clone https://github.com/tronprotocol/java-tron.git

# Run local node
./gradlew run -Pwitness

# Test API endpoint
curl http://localhost:8090/wallet/getnodeinfo
```

---

## SDK Integration

### TronWeb (JavaScript)
```javascript
const TronWeb = require('tronweb');

const tronWeb = new TronWeb({
  fullHost: 'https://api.trongrid.io',
  headers: { 'TRON-PRO-API-KEY': 'your-api-key' },
  privateKey: 'your-private-key'
});

// Send TRX
const transaction = await tronWeb.transactionBuilder.sendTrx(
  'destination-address',
  1000000, // amount in sun
  'from-address'
);

const signedTx = await tronWeb.trx.sign(transaction);
const broadcast = await tronWeb.trx.sendRawTransaction(signedTx);
```

### TronStation SDK
Based on the analyzed SDK in your workspace:

```javascript
import TronStation from 'tronstation';
import TronWeb from 'tronweb';

const tronWeb = new TronWeb({
  fullHost: 'https://api.trongrid.io',
  privateKey: 'your-private-key'
});

const tronStation = new TronStation(tronWeb);

// Energy calculations
const energyRequired = await tronStation.energy.trx2FrozenEnergy(1);
const bandwidth = await tronStation.bp.getAccountBandwidth(address);
const srRewards = await tronStation.witness.getSrVoteRewardList();
```

---

## Security Considerations

### Private Key Management
- Never expose private keys in client-side code
- Use hardware wallets for production
- Implement proper key rotation policies

### Transaction Security  
- Always verify transaction details before signing
- Implement transaction limits
- Use time-based transaction expiration
- Validate all input parameters

### Smart Contract Security
- Audit contract code before deployment
- Set appropriate fee limits
- Use reentrancy guards
- Implement access controls

---

## Conclusion

This comprehensive guide covers all major TRON REST API endpoints for building robust DApps. The TRON network provides extensive APIs for account management, transactions, smart contracts, governance, and more. Use this guide as a reference for implementing TRON blockchain functionality in your applications.

For the most up-to-date information, always refer to the official [TRON Developer Documentation](https://developers.tron.network/).

---

*Last Updated: October 2025*
*Version: 1.0*