# 🚀 TRON Explorer & Wallet Interface

A comprehensive web-based TRON blockchain explorer and wallet management system with **TRON Staking 2.0** support, **Tailscale remote access**, and **local persistent storage**.

## ✨ Features

### 💼 **Wallet Management**
- **🔐 Secure Seed Phrase Import/Export**: Import existing wallets or generate new 12/24-word seed phrases
- **💾 Encrypted Local Storage**: AES-encrypted seed phrase storage in browser (persistent across sessions)
- **👁️ Account Overview**: Real-time TRX balance, Energy, Bandwidth, and token holdings
- **🔄 Auto-sync**: Automatic account data refresh and blockchain sync status monitoring

### 🔍 **Blockchain Explorer**
- **📊 Real-time Sync Status**: Visual indicator showing if your TRON node is synchronized
- **📦 Latest Blocks Display**: Browse recent blockchain blocks with transaction details
- **🔎 Universal Search**: Search by block number, transaction hash, or account address
- **📋 Detailed Information**: Complete transaction and account information display
- **⚡ Fast Loading**: Optimized for quick blockchain data retrieval

### 🥩 **TRON Staking 2.0**
- **⚡ Energy Staking**: Stake TRX to obtain Energy for smart contract operations
- **📡 Bandwidth Staking**: Stake TRX to obtain Bandwidth for transaction fees
- **👥 Delegate Staking**: Stake TRX for other addresses (delegation support)
- **📈 Stake Management**: View current active stakes with expiration times
- **💸 Unstaking**: Withdraw staked TRX when lock period expires
- **📊 Resource Tracking**: Monitor staking efficiency and returns

### 📊 **Resource Monitoring**
- **⚡ Energy Tracking**: Visual progress bars showing available, used, and total Energy
- **📡 Bandwidth Tracking**: Real-time bandwidth consumption and limits monitoring
- **🌐 Network Statistics**: Active connections, sync status, and node performance
- **📈 Usage Analytics**: Historical resource consumption patterns

### 🌐 **Remote Access via Tailscale**
- **🔒 Secure Remote Access**: Access your TRON node from anywhere via Tailscale VPN
- **📱 Multi-device Support**: Works on phones, tablets, and computers
- **🚫 No Port Forwarding**: No need to expose ports to the public internet
- **⚡ CORS-free**: Apache proxy eliminates cross-origin request issues

## 🛠️ Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ (or compatible Linux distribution)
- **RAM**: Minimum 16GB (for TRON node)
- **Storage**: 500GB+ SSD recommended (for blockchain data)
- **Network**: Stable internet connection

### Required Software
- **TRON Java Node**: Full node running and synchronized
- **Apache 2.4+**: Web server with proxy modules
- **Tailscale** (optional): For remote access
- **Modern Web Browser**: Chrome 60+, Firefox 55+, Safari 12+, Edge 79+

## 🚀 Installation Guide

### Step 1: Clone Repository

```bash
git clone https://github.com/pagcoinbr/java-tron.git
cd java-tron
```

### Step 2: TRON Node Setup

Ensure your TRON node is running on the standard ports:
- **Full Node**: `localhost:8090`
- **Solidity Node**: `localhost:8091`  
- **Event Server**: `localhost:8092`

Verify node is running:
```bash
curl -X POST http://localhost:8090/wallet/getnodeinfo
```

### Step 3: Run Installation Script

The provided script will automatically:
- Install and configure Apache 2.4
- Set up virtual hosts with CORS headers
- Configure proxy for TRON API endpoints
- Set proper file permissions
- Enable required Apache modules

```bash
# Make script executable
chmod +x tron-explorer/setup.sh

# Run installation (requires sudo)
sudo ./tron-explorer/setup.sh
```

### Step 4: Verify Installation

Test local access:
```bash
curl -I http://localhost
```

Check TRON API proxy:
```bash
curl -X POST http://localhost/tron-api/fullnode/wallet/getnodeinfo
```

## 🌐 Tailscale Setup (Optional)

### Install Tailscale

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Connect to your Tailscale network
sudo tailscale up
```

### Configure for Remote Access

The setup script automatically configures Apache for Tailscale access. After setup:

1. **Get your Tailscale IP**: `tailscale ip -4`
2. **Access remotely**: `http://YOUR-TAILSCALE-IP`
3. **Install Tailscale on other devices** and access the same URL

## 📁 Project Structure

```
java-tron/
├── README.md                          # This file
├── README_original.md                 # Original TRON node installation guide
├── tron-explorer/                     # TRON Explorer Web Interface
│   ├── index.html                     # Main application interface
│   ├── styles.css                     # CSS styling and responsive design
│   ├── script.js                      # JavaScript functionality
│   ├── setup.sh                       # Automated installation script
│   ├── apache-config.conf             # Apache virtual host configuration
│   ├── README.md                      # Detailed usage instructions
│   └── TAILSCALE_ACCESS.md            # Tailscale setup guide
├── tron-node-dashboard/               # Node monitoring dashboard
│   ├── server.js                      # Express.js backend
│   ├── package.json                   # Node.js dependencies
│   └── public/                        # Static web assets
├── tronstation-sdk/                   # TronStation SDK integration
│   ├── src/                           # SDK source code
│   ├── package.json                   # SDK dependencies
│   └── webpack.config.js              # Build configuration
├── java-tron-1.0.0/                  # TRON node binaries
│   ├── bin/                           # Executable files
│   ├── lib/                           # Java libraries
│   └── local_config.conf              # Node configuration
└── start-tron-node.sh                 # Node startup script
```

## 🔧 Configuration

### Apache Virtual Host

The setup script creates an Apache configuration with:
- **CORS Headers**: Enabled for all API endpoints
- **Proxy Configuration**: Routes `/tron-api/*` to local TRON node ports
- **Compression**: Enabled for better performance over Tailscale
- **Caching**: Static file caching for improved loading times

### TRON Node Endpoints

All TRON API calls are proxied through Apache to avoid CORS issues:

| Service | Direct Access | Proxied Access |
|---------|---------------|----------------|
| Full Node | `localhost:8090` | `/tron-api/fullnode/` |
| Solidity Node | `localhost:8091` | `/tron-api/soliditynode/` |
| Event Server | `localhost:8092` | `/tron-api/eventserver/` |

## 🎯 Usage Guide

### 1. **Wallet Setup**

1. Open the web interface: `http://localhost` or `http://YOUR-TAILSCALE-IP`
2. Navigate to the **Wallet** tab
3. Choose one option:
   - **Import Existing**: Enter your 12/24-word seed phrase
   - **Generate New**: Create a new wallet (save the seed phrase securely!)
4. Your wallet will be encrypted and stored locally in the browser

### 2. **Exploring the Blockchain**

1. Go to the **Explorer** tab
2. **View Latest Blocks**: Automatically displays recent blocks
3. **Search**: Enter block number, transaction hash, or address
4. **Block Details**: Click on any block for detailed information

### 3. **TRON Staking 2.0**

1. Navigate to **Staking 2.0** tab (wallet must be connected)
2. **Stake TRX**:
   - Select resource type (Energy or Bandwidth)
   - Enter amount to stake
   - Optionally specify receive address for delegation
   - Click "Stake TRX"
3. **View Stakes**: Current active stakes with expiration times
4. **Unstake**: Enter amount to withdraw (must wait for lock period)

### 4. **Resource Monitoring**

1. Go to **Resources** tab
2. **Energy Usage**: Visual progress bar and statistics
3. **Bandwidth Usage**: Current consumption and limits
4. **Network Stats**: Node connections and performance metrics

## 🔒 Security Best Practices

### Wallet Security
- **💾 Backup Seed Phrases**: Write down and store securely offline
- **🚫 Never Share**: Never share seed phrases with anyone
- **🔄 Regular Backups**: Export and backup wallet data regularly
- **🖥️ Local Only**: Seed phrases never leave your device

### Network Security
- **🔐 Tailscale Only**: Use Tailscale for remote access (avoid port forwarding)
- **🌐 HTTPS**: Consider SSL certificates for production use
- **🔥 Firewall**: Keep firewall enabled, only allow necessary ports
- **📱 Device Security**: Ensure remote devices are secure and updated

## 🐛 Troubleshooting

### Common Issues

#### "Connection Error" in sync status
```bash
# Check if TRON node is running
curl -X POST http://localhost:8090/wallet/getnodeinfo

# Check node logs
tail -f java-tron-1.0.0/logs/tron.log

# Restart TRON node if needed
./start-tron-node.sh
```

#### Apache not starting
```bash
# Check Apache configuration
sudo apache2ctl configtest

# Check Apache status
sudo systemctl status apache2

# Restart Apache
sudo systemctl restart apache2

# Check Apache error logs
sudo tail -f /var/log/apache2/error.log
```

#### CORS errors (should not happen with proxy setup)
```bash
# Verify proxy is working
curl -X POST http://localhost/tron-api/fullnode/wallet/getnodeinfo

# Check Apache proxy modules
sudo apache2ctl -M | grep proxy

# Reload Apache configuration
sudo systemctl reload apache2
```

#### Wallet import fails
- Verify seed phrase format (12 or 24 words, space-separated)
- Check browser console for JavaScript errors
- Try generating a new wallet for testing
- Clear browser cache and localStorage

#### Tailscale access issues
```bash
# Check Tailscale status
tailscale status

# Test connectivity from remote device
tailscale ping YOUR-TAILSCALE-IP

# Check if Apache is listening on all interfaces
sudo netstat -tlnp | grep :80
```

## 📊 Access Information

### Local Access
- **🏠 Web Interface**: http://localhost
- **🔗 TRON API**: http://localhost/tron-api/fullnode/wallet/...

### Tailscale Access (if configured)
- **🌐 Web Interface**: http://YOUR-TAILSCALE-IP
- **🔗 TRON API**: http://YOUR-TAILSCALE-IP/tron-api/fullnode/wallet/...

Get your Tailscale IP: `tailscale ip -4`

## 🤝 Contributing

Contributions are welcome! Please:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **📖 Documentation**: Check this README and `tron-explorer/README.md`
- **🐛 Issues**: Report bugs via GitHub Issues
- **💬 Discussions**: Use GitHub Discussions for questions
- **🔍 Original Guide**: See `README_original.md` for TRON node installation

### Useful Resources
- **TRON Documentation**: https://developers.tron.network/
- **TronWeb API**: https://tronweb.network/
- **Tailscale Docs**: https://tailscale.com/kb/
- **Apache Documentation**: https://httpd.apache.org/docs/

## 🎉 Acknowledgments

- **TRON Foundation** for the excellent blockchain platform
- **TronWeb Team** for the JavaScript SDK
- **Tailscale** for secure networking solutions
- **Apache Foundation** for the robust web server
- **Open Source Community** for tools and inspiration

---

**⚡ Enjoy exploring the TRON blockchain with secure remote access! ⚡**

For technical support or questions, please open an issue or check the troubleshooting section above.