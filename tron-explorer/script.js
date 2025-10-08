// Global variables
let tronWeb;
let currentAccount;
let syncCheckInterval;
let blockUpdateInterval;

// TRON node configuration
const TRON_CONFIG = {
    fullNode: 'http://localhost:8090',
    solidityNode: 'http://localhost:8091',
    eventServer: 'http://localhost:8092'
};

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeTronWeb();
    checkSyncStatus();
    loadStoredWallet();
    
    // Set up intervals
    syncCheckInterval = setInterval(checkSyncStatus, 30000);
    blockUpdateInterval = setInterval(updateLatestBlocks, 60000);
});

// Initialize TronWeb
function initializeTronWeb() {
    try {
        tronWeb = new TronWeb({
            fullHost: TRON_CONFIG.fullNode,
            solidityNode: TRON_CONFIG.solidityNode,
            eventServer: TRON_CONFIG.eventServer
        });
        console.log('TronWeb initialized successfully');
    } catch (error) {
        console.error('Failed to initialize TronWeb:', error);
        showToast('Failed to connect to TRON network', 'error');
    }
}

// Tab management
function showTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Remove active class from all tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Show selected tab and activate button
    document.getElementById(tabName).classList.add('active');
    event.target.classList.add('active');
    
    // Load tab-specific data
    switch(tabName) {
        case 'explorer':
            updateLatestBlocks();
            break;
        case 'resources':
            updateResourceInfo();
            break;
        case 'staking':
            loadStakingInfo();
            break;
    }
}

// Wallet Management
function generateWallet() {
    try {
        const mnemonic = generateMnemonic();
        document.getElementById('seedPhrase').value = mnemonic;
        showToast('New wallet generated! Please save your seed phrase securely.', 'success');
    } catch (error) {
        console.error('Error generating wallet:', error);
        showToast('Failed to generate wallet', 'error');
    }
}

function generateMnemonic() {
    const words = [
        'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract', 'absurd', 'abuse',
        'access', 'accident', 'account', 'accuse', 'achieve', 'acid', 'acoustic', 'acquire', 'across', 'act',
        'action', 'actor', 'actress', 'actual', 'adapt', 'add', 'addict', 'address', 'adjust', 'admit',
        'adult', 'advance', 'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'agent', 'agree',
        'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album', 'alcohol', 'alert', 'alien',
        'all', 'alley', 'allow', 'almost', 'alone', 'alpha', 'already', 'also', 'alter', 'always',
        'amateur', 'amazing', 'among', 'amount', 'amused', 'analyst', 'anchor', 'ancient', 'anger', 'angle',
        'angry', 'animal', 'ankle', 'announce', 'annual', 'another', 'answer', 'antenna', 'antique', 'anxiety',
        'any', 'apart', 'apology', 'appear', 'apple', 'approve', 'april', 'arcade', 'arch', 'arctic',
        'area', 'arena', 'argue', 'arm', 'armed', 'armor', 'army', 'around', 'arrange', 'arrest',
        'arrive', 'arrow', 'art', 'artefact', 'artist', 'artwork', 'ask', 'aspect', 'assault', 'asset',
        'assist', 'assume', 'asthma', 'athlete', 'atom', 'attack', 'attend', 'attitude', 'attract', 'auction'
    ];
    
    const mnemonic = [];
    for (let i = 0; i < 12; i++) {
        mnemonic.push(words[Math.floor(Math.random() * words.length)]);
    }
    return mnemonic.join(' ');
}

async function importWallet() {
    const seedPhrase = document.getElementById('seedPhrase').value.trim();
    
    if (!seedPhrase) {
        showToast('Please enter a seed phrase', 'warning');
        return;
    }
    
    try {
        showLoading(true);
        
        // Generate private key from seed phrase (simplified approach)
        const privateKey = await seedPhraseToPrivateKey(seedPhrase);
        
        // Set the private key in TronWeb
        tronWeb.setPrivateKey(privateKey);
        const address = tronWeb.address.fromPrivateKey(privateKey);
        
        currentAccount = {
            address: address,
            privateKey: privateKey,
            seedPhrase: seedPhrase
        };
        
        // Store wallet data (encrypted)
        storeWalletData(currentAccount);
        
        // Update UI
        await updateWalletUI();
        
        showToast('Wallet imported successfully!', 'success');
        
    } catch (error) {
        console.error('Error importing wallet:', error);
        showToast('Failed to import wallet. Please check your seed phrase.', 'error');
    } finally {
        showLoading(false);
    }
}

async function seedPhraseToPrivateKey(seedPhrase) {
    // Simple hash-based approach (in production, use proper BIP39/BIP44)
    const hash = CryptoJS.SHA256(seedPhrase).toString();
    return hash.substring(0, 64);
}

function storeWalletData(walletData) {
    try {
        const encrypted = CryptoJS.AES.encrypt(JSON.stringify(walletData), 'tron-explorer-key').toString();
        localStorage.setItem('tron-wallet', encrypted);
    } catch (error) {
        console.error('Error storing wallet data:', error);
    }
}

function loadStoredWallet() {
    try {
        const encrypted = localStorage.getItem('tron-wallet');
        if (encrypted) {
            const decrypted = CryptoJS.AES.decrypt(encrypted, 'tron-explorer-key').toString(CryptoJS.enc.Utf8);
            currentAccount = JSON.parse(decrypted);
            
            tronWeb.setPrivateKey(currentAccount.privateKey);
            document.getElementById('seedPhrase').value = currentAccount.seedPhrase;
            
            updateWalletUI();
        }
    } catch (error) {
        console.error('Error loading stored wallet:', error);
        localStorage.removeItem('tron-wallet');
    }
}

function clearWallet() {
    if (confirm('Are you sure you want to clear the wallet? Make sure you have saved your seed phrase!')) {
        localStorage.removeItem('tron-wallet');
        currentAccount = null;
        document.getElementById('seedPhrase').value = '';
        document.getElementById('accountInfo').style.display = 'none';
        document.getElementById('tokensSection').style.display = 'none';
        document.getElementById('stakeInterface').style.display = 'none';
        showToast('Wallet cleared', 'success');
    }
}

async function updateWalletUI() {
    if (!currentAccount) return;
    
    try {
        // Show account info section
        document.getElementById('accountInfo').style.display = 'block';
        document.getElementById('tokensSection').style.display = 'block';
        document.getElementById('stakeInterface').style.display = 'block';
        
        // Update address
        document.getElementById('walletAddress').textContent = currentAccount.address;
        
        // Get account information
        const account = await tronWeb.trx.getAccount(currentAccount.address);
        
        // Update TRX balance
        const balance = account.balance || 0;
        document.getElementById('trxBalance').textContent = (balance / 1000000).toFixed(6) + ' TRX';
        
        // Update resources
        await updateAccountResources();
        
        // Load tokens
        await loadAccountTokens();
        
    } catch (error) {
        console.error('Error updating wallet UI:', error);
        showToast('Error loading account information', 'error');
    }
}

async function updateAccountResources() {
    if (!currentAccount) return;
    
    try {
        const accountResources = await tronWeb.trx.getAccountResources(currentAccount.address);
        
        // Energy
        const energyUsed = accountResources.EnergyUsed || 0;
        const energyLimit = accountResources.EnergyLimit || 0;
        const availableEnergy = energyLimit - energyUsed;
        
        document.getElementById('energyBalance').textContent = availableEnergy.toLocaleString();
        document.getElementById('availableEnergy').textContent = availableEnergy.toLocaleString();
        document.getElementById('totalEnergy').textContent = energyLimit.toLocaleString();
        document.getElementById('usedEnergy').textContent = energyUsed.toLocaleString();
        
        // Update energy progress bar
        const energyPercent = energyLimit > 0 ? (energyUsed / energyLimit) * 100 : 0;
        document.getElementById('energyProgress').style.width = energyPercent + '%';
        
        // Bandwidth
        const bandwidthUsed = accountResources.NetUsed || 0;
        const bandwidthLimit = accountResources.NetLimit || 0;
        const availableBandwidth = bandwidthLimit - bandwidthUsed;
        
        document.getElementById('bandwidthBalance').textContent = availableBandwidth.toLocaleString();
        document.getElementById('availableBandwidth').textContent = availableBandwidth.toLocaleString();
        document.getElementById('totalBandwidth').textContent = bandwidthLimit.toLocaleString();
        document.getElementById('usedBandwidth').textContent = bandwidthUsed.toLocaleString();
        
        // Update bandwidth progress bar
        const bandwidthPercent = bandwidthLimit > 0 ? (bandwidthUsed / bandwidthLimit) * 100 : 0;
        document.getElementById('bandwidthProgress').style.width = bandwidthPercent + '%';
        
    } catch (error) {
        console.error('Error updating account resources:', error);
    }
}

async function loadAccountTokens() {
    if (!currentAccount) return;
    
    try {
        const account = await tronWeb.trx.getAccount(currentAccount.address);
        const tokenList = document.getElementById('tokenList');
        tokenList.innerHTML = '';
        
        if (account.assetV2) {
            for (const [tokenId, balance] of Object.entries(account.assetV2)) {
                try {
                    const tokenInfo = await tronWeb.trx.getTokenByID(tokenId);
                    
                    const tokenItem = document.createElement('div');
                    tokenItem.className = 'token-item';
                    tokenItem.innerHTML = `
                        <div class="token-name">${tokenInfo.name}</div>
                        <div class="token-balance">${(balance / Math.pow(10, tokenInfo.precision)).toFixed(tokenInfo.precision)} ${tokenInfo.abbr}</div>
                    `;
                    tokenList.appendChild(tokenItem);
                } catch (error) {
                    console.error('Error loading token info:', error);
                }
            }
        }
        
        if (tokenList.children.length === 0) {
            tokenList.innerHTML = '<p class="no-tokens">No tokens found</p>';
        }
        
    } catch (error) {
        console.error('Error loading account tokens:', error);
    }
}

// Blockchain Explorer Functions
async function updateLatestBlocks() {
    try {
        const latestBlock = await tronWeb.trx.getCurrentBlock();
        const blockNumber = latestBlock.block_header.raw_data.number;
        
        const blocksContainer = document.getElementById('latestBlocks');
        blocksContainer.innerHTML = '';
        
        // Load last 5 blocks
        for (let i = 0; i < 5; i++) {
            const blockNum = blockNumber - i;
            try {
                const block = await tronWeb.trx.getBlockByNumber(blockNum);
                const blockElement = createBlockElement(block);
                blocksContainer.appendChild(blockElement);
            } catch (error) {
                console.error(`Error loading block ${blockNum}:`, error);
            }
        }
        
    } catch (error) {
        console.error('Error updating latest blocks:', error);
    }
}

function createBlockElement(block) {
    const blockDiv = document.createElement('div');
    blockDiv.className = 'block-item';
    
    const timestamp = new Date(block.block_header.raw_data.timestamp);
    const txCount = block.transactions ? block.transactions.length : 0;
    
    blockDiv.innerHTML = `
        <div class="block-header">
            <span class="block-number">Block #${block.block_header.raw_data.number}</span>
            <span class="block-time">${timestamp.toLocaleString()}</span>
        </div>
        <div class="block-details">
            <div>Transactions: ${txCount}</div>
            <div>Size: ${(JSON.stringify(block).length / 1024).toFixed(2)} KB</div>
            <div>Hash: ${block.blockID.substring(0, 20)}...</div>
        </div>
    `;
    
    blockDiv.addEventListener('click', () => {
        showBlockDetails(block);
    });
    
    return blockDiv;
}

function showBlockDetails(block) {
    const resultsContainer = document.getElementById('searchResults');
    resultsContainer.style.display = 'block';
    resultsContainer.innerHTML = `
        <h3>Block Details</h3>
        <div class="block-details-full">
            <p><strong>Block Number:</strong> ${block.block_header.raw_data.number}</p>
            <p><strong>Timestamp:</strong> ${new Date(block.block_header.raw_data.timestamp).toLocaleString()}</p>
            <p><strong>Hash:</strong> ${block.blockID}</p>
            <p><strong>Parent Hash:</strong> ${block.block_header.raw_data.parentHash}</p>
            <p><strong>Transactions:</strong> ${block.transactions ? block.transactions.length : 0}</p>
            <p><strong>Witness:</strong> ${tronWeb.address.fromHex(block.block_header.raw_data.witness_address)}</p>
        </div>
    `;
    resultsContainer.scrollIntoView({ behavior: 'smooth' });
}

async function search() {
    const query = document.getElementById('searchInput').value.trim();
    if (!query) return;
    
    showLoading(true);
    
    try {
        const resultsContainer = document.getElementById('searchResults');
        resultsContainer.style.display = 'block';
        
        // Determine query type
        if (/^\d+$/.test(query)) {
            // Block number
            const block = await tronWeb.trx.getBlockByNumber(parseInt(query));
            showBlockDetails(block);
        } else if (query.length === 64) {
            // Transaction hash
            const tx = await tronWeb.trx.getTransaction(query);
            showTransactionDetails(tx);
        } else if (query.length === 34 || query.length === 42) {
            // Address
            const account = await tronWeb.trx.getAccount(query);
            showAccountDetails(account, query);
        } else {
            resultsContainer.innerHTML = '<p>Invalid search query format</p>';
        }
        
    } catch (error) {
        console.error('Search error:', error);
        document.getElementById('searchResults').innerHTML = '<p>No results found</p>';
    } finally {
        showLoading(false);
    }
}

function showTransactionDetails(tx) {
    const resultsContainer = document.getElementById('searchResults');
    resultsContainer.innerHTML = `
        <h3>Transaction Details</h3>
        <div class="transaction-details">
            <p><strong>Hash:</strong> ${tx.txID}</p>
            <p><strong>Block:</strong> ${tx.blockNumber || 'Pending'}</p>
            <p><strong>Timestamp:</strong> ${tx.blockTimeStamp ? new Date(tx.blockTimeStamp).toLocaleString() : 'Pending'}</p>
            <p><strong>Result:</strong> ${tx.ret && tx.ret[0] ? tx.ret[0].contractRet : 'Unknown'}</p>
            <p><strong>Energy Used:</strong> ${tx.receipt ? tx.receipt.energy_usage_total || 0 : 0}</p>
            <p><strong>Bandwidth Used:</strong> ${tx.receipt ? tx.receipt.net_usage || 0 : 0}</p>
        </div>
    `;
}

function showAccountDetails(account, address) {
    const balance = account.balance || 0;
    const resultsContainer = document.getElementById('searchResults');
    resultsContainer.innerHTML = `
        <h3>Account Details</h3>
        <div class="account-details">
            <p><strong>Address:</strong> ${address}</p>
            <p><strong>TRX Balance:</strong> ${(balance / 1000000).toFixed(6)} TRX</p>
            <p><strong>Account Type:</strong> ${account.type || 'Normal'}</p>
            <p><strong>Create Time:</strong> ${account.create_time ? new Date(account.create_time).toLocaleString() : 'Unknown'}</p>
        </div>
    `;
}

// Staking Functions
async function loadStakingInfo() {
    if (!currentAccount) return;
    
    try {
        const account = await tronWeb.trx.getAccount(currentAccount.address);
        const stakesContainer = document.getElementById('currentStakes');
        
        let hasStakes = false;
        let stakesHTML = '';
        
        // Check for frozen balance (Energy stakes)
        if (account.account_resource && account.account_resource.frozen_balance_for_energy) {
            const energyStake = account.account_resource.frozen_balance_for_energy;
            stakesHTML += `
                <div class="stake-item">
                    <h4>Energy Stake</h4>
                    <p>Amount: ${(energyStake.frozen_balance / 1000000).toFixed(6)} TRX</p>
                    <p>Expire Time: ${new Date(energyStake.expire_time).toLocaleString()}</p>
                </div>
            `;
            hasStakes = true;
        }
        
        // Check for bandwidth stakes
        if (account.frozen) {
            account.frozen.forEach(freeze => {
                stakesHTML += `
                    <div class="stake-item">
                        <h4>Bandwidth Stake</h4>
                        <p>Amount: ${(freeze.frozen_balance / 1000000).toFixed(6)} TRX</p>
                        <p>Expire Time: ${new Date(freeze.expire_time).toLocaleString()}</p>
                    </div>
                `;
                hasStakes = true;
            });
        }
        
        if (hasStakes) {
            stakesContainer.innerHTML = stakesHTML;
        } else {
            stakesContainer.innerHTML = '<p class="no-stakes">No active stakes found</p>';
        }
        
    } catch (error) {
        console.error('Error loading staking info:', error);
    }
}

async function stakeForResource() {
    if (!currentAccount) {
        showToast('Please connect your wallet first', 'warning');
        return;
    }
    
    const resourceType = document.getElementById('resourceType').value;
    const amount = parseFloat(document.getElementById('stakeAmount').value);
    const receiveAddress = document.getElementById('receiveAddress').value.trim() || currentAccount.address;
    
    if (!amount || amount <= 0) {
        showToast('Please enter a valid amount', 'warning');
        return;
    }
    
    try {
        showLoading(true);
        
        const amountSun = amount * 1000000; // Convert TRX to SUN
        
        let transaction;
        if (resourceType === 'ENERGY') {
            transaction = await tronWeb.transactionBuilder.freezeBalanceV2(
                amountSun,
                'ENERGY',
                currentAccount.address,
                receiveAddress
            );
        } else {
            transaction = await tronWeb.transactionBuilder.freezeBalanceV2(
                amountSun,
                'BANDWIDTH',
                currentAccount.address,
                receiveAddress
            );
        }
        
        const signedTransaction = await tronWeb.trx.sign(transaction);
        const result = await tronWeb.trx.sendRawTransaction(signedTransaction);
        
        if (result.result) {
            showToast(`Successfully staked ${amount} TRX for ${resourceType}`, 'success');
            document.getElementById('stakeAmount').value = '';
            document.getElementById('receiveAddress').value = '';
            await loadStakingInfo();
            await updateAccountResources();
        } else {
            showToast('Staking transaction failed', 'error');
        }
        
    } catch (error) {
        console.error('Staking error:', error);
        showToast('Error processing stake transaction: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function unstakeResource() {
    if (!currentAccount) {
        showToast('Please connect your wallet first', 'warning');
        return;
    }
    
    const amount = parseFloat(document.getElementById('unstakeAmount').value);
    
    if (!amount || amount <= 0) {
        showToast('Please enter a valid amount', 'warning');
        return;
    }
    
    try {
        showLoading(true);
        
        const amountSun = amount * 1000000; // Convert TRX to SUN
        
        // For TronWeb v5+, use unfreezeBalanceV2
        const transaction = await tronWeb.transactionBuilder.unfreezeBalanceV2(
            amountSun,
            'ENERGY', // You might want to make this configurable
            currentAccount.address
        );
        
        const signedTransaction = await tronWeb.trx.sign(transaction);
        const result = await tronWeb.trx.sendRawTransaction(signedTransaction);
        
        if (result.result) {
            showToast(`Successfully unstaked ${amount} TRX`, 'success');
            document.getElementById('unstakeAmount').value = '';
            await loadStakingInfo();
            await updateAccountResources();
        } else {
            showToast('Unstaking transaction failed', 'error');
        }
        
    } catch (error) {
        console.error('Unstaking error:', error);
        showToast('Error processing unstake transaction: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

// Network and Resource Management
async function checkSyncStatus() {
    try {
        const nodeInfo = await tronWeb.trx.getNodeInfo();
        const currentBlock = await tronWeb.trx.getCurrentBlock();
        
        const syncStatus = document.getElementById('syncStatus');
        const syncDot = document.getElementById('syncDot');
        
        // Simple sync check (in production, implement more sophisticated logic)
        const blockTime = currentBlock.block_header.raw_data.timestamp;
        const currentTime = Date.now();
        const timeDiff = currentTime - blockTime;
        
        if (timeDiff < 60000) { // Less than 1 minute
            syncStatus.textContent = 'Synchronized';
            syncDot.className = 'dot-indicator synced';
        } else if (timeDiff < 300000) { // Less than 5 minutes
            syncStatus.textContent = 'Syncing...';
            syncDot.className = 'dot-indicator syncing';
        } else {
            syncStatus.textContent = 'Not Synchronized';
            syncDot.className = 'dot-indicator';
        }
        
    } catch (error) {
        console.error('Error checking sync status:', error);
        const syncStatus = document.getElementById('syncStatus');
        const syncDot = document.getElementById('syncDot');
        syncStatus.textContent = 'Connection Error';
        syncDot.className = 'dot-indicator';
    }
}

async function updateResourceInfo() {
    try {
        // Update network statistics
        const nodeInfo = await tronWeb.trx.getNodeInfo();
        const chainParams = await tronWeb.trx.getChainParameters();
        
        const networkStats = document.getElementById('networkStats');
        networkStats.innerHTML = `
            <div class="network-stat">
                <div class="network-stat-value">${nodeInfo.activeConnectCount || 0}</div>
                <div class="network-stat-label">Active Connections</div>
            </div>
            <div class="network-stat">
                <div class="network-stat-value">${nodeInfo.passiveConnectCount || 0}</div>
                <div class="network-stat-label">Passive Connections</div>
            </div>
            <div class="network-stat">
                <div class="network-stat-value">${nodeInfo.totalFlow || 0}</div>
                <div class="network-stat-label">Total Flow</div>
            </div>
            <div class="network-stat">
                <div class="network-stat-value">${(nodeInfo.beginSyncNum || 0).toLocaleString()}</div>
                <div class="network-stat-label">Sync Start Block</div>
            </div>
        `;
        
        // Update account resources if wallet is connected
        if (currentAccount) {
            await updateAccountResources();
        }
        
    } catch (error) {
        console.error('Error updating resource info:', error);
    }
}

// Utility Functions
function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    overlay.style.display = show ? 'flex' : 'none';
}

function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type} show`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 4000);
}

function loadMoreBlocks() {
    // This would load more blocks in a real implementation
    showToast('Loading more blocks...', 'info');
    updateLatestBlocks();
}

// Cleanup intervals on page unload
window.addEventListener('beforeunload', function() {
    if (syncCheckInterval) clearInterval(syncCheckInterval);
    if (blockUpdateInterval) clearInterval(blockUpdateInterval);
});