# TRON (java-tron) Installation Guide for Ubuntu

A complete installation guide for setting up a TRON FullNode on Ubuntu using the automated installation script.

## Table of Contents
- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Post-Installation](#post-installation)
- [Service Management](#service-management)
- [Troubleshooting](#troubleshooting)
- [Configuration](#configuration)

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu 20.04+ (tested on Ubuntu 25.04)
- **RAM**: Minimum 8GB, recommended 16GB+ (script defaults to 24GB heap, adjustable)
- **Storage**: Minimum 500GB free space (blockchain data grows continuously)
- **Network**: Stable internet connection for blockchain synchronization
- **User**: sudo privileges required for installation

### Pre-Installation Checks
```bash
# Check OS version
cat /etc/os-release

# Check available RAM
free -h

# Check available disk space
df -h /home

# Verify sudo access
sudo -v
```

## Installation

### Step 1: Download the Installation Script

Save the following script as `java-tron.sh`:

```bash
#!/usr/bin/env bash
# Complete TRON (java-tron) installer for Ubuntu (no /opt usage).
# Usage:
#   sudo ./install_tron_complete.sh
# Optional env vars:
#   SNAPSHOT_URL="https://…"   # if you have a snapshot URL, set before running
#   JVM_XMX="24g"              # heap size for the node Java process (default 24g)
#   TRON_USER="pagcoin"        # linux user to run node under
set -euo pipefail

# === Config ===
TRON_USER="${TRON_USER:-pagcoin}"
SRC_DIR="${SRC_DIR:-/home/${TRON_USER}/src/java-tron}"
INSTALL_DIR="${INSTALL_DIR:-/home/${TRON_USER}/java-tron}"   # where we will unzip distribution
REPO="${REPO:-https://github.com/tronprotocol/java-tron.git}"
BRANCH="${BRANCH:-master}"
CONFIG_URL="${CONFIG_URL:-https://raw.githubusercontent.com/tronprotocol/tron-deployment/master/main_net_config.conf}"
SNAPSHOT_URL="${SNAPSHOT_URL:-}"   # optional, leave empty to skip snapshot download
JVM_XMX="${JVM_XMX:-24g}"
UFW_ALLOW_PORTS="${UFW_ALLOW_PORTS:-8090 50051 50052 50053}"  # adjust as needed

# helper prints
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
die(){ printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; exit 1; }

# require root
if [[ "$EUID" -ne 0 ]]; then
  die "Please run this script as root: sudo $0"
fi

info "Starting TRON (java-tron) installation"
info "TRON user: ${TRON_USER}"
info "Source dir: ${SRC_DIR}"
info "Install dir: ${INSTALL_DIR}"
info "Repo: ${REPO}"
if [[ -n "${SNAPSHOT_URL}" ]]; then
  info "Snapshot URL provided; script will attempt to download and extract it."
fi

# === create pagcoin user if missing ===
if ! id -u "${TRON_USER}" >/dev/null 2>&1; then
  info "Creating user ${TRON_USER}..."
  useradd -m -s /bin/bash "${TRON_USER}" || die "useradd failed"
else
  info "User ${TRON_USER} exists"
fi

# === apt update & install deps ===
info "Updating apt and installing required packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y git curl unzip build-essential wget ca-certificates gnupg lsb-release apt-transport-https ufw || die "apt-get install failed"

# === Install Java 8 (try openjdk-8, then temurin-8, then default-jdk) ===
info "Installing Java 8 (best-effort)"
if apt-cache show openjdk-8-jdk >/dev/null 2>&1; then
  apt-get install -y openjdk-8-jdk
else
  warn "openjdk-8-jdk not in apt-cache. Attempting Adoptium (Temurin 8) repo..."
  CODENAME=$(lsb_release -sc || echo "focal")
  # Add Adoptium repo
  curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - >/dev/null 2>&1 || warn "failed to add adpotium key (continuing)"
  echo "deb https://packages.adoptium.net/artifactory/deb ${CODENAME} main" > /etc/apt/sources.list.d/adoptium.list
  apt-get update -y
  if apt-cache show temurin-8-jdk >/dev/null 2>&1; then
    apt-get install -y temurin-8-jdk
  else
    warn "temurin-8-jdk not available for ${CODENAME}. Installing default-jdk as fallback."
    apt-get install -y default-jdk
  fi
fi

# verify java
if ! command -v java >/dev/null 2>&1; then
  die "Java not found after install. Install Oracle/OpenJDK 8 manually and re-run."
fi
JAVA_VER=$(java -version 2>&1 | head -n1 || true)
info "Java installed: ${JAVA_VER}"

# === prepare directories ===
info "Preparing directories..."
rm -rf "${SRC_DIR}"
mkdir -p "${SRC_DIR}"
chown -R "${TRON_USER}:${TRON_USER}" "$(dirname "${SRC_DIR}")"

# === clone repo ===
info "Cloning java-tron repo into ${SRC_DIR} (branch ${BRANCH})..."
if ! git clone "${REPO}" "${SRC_DIR}"; then
  die "git clone failed"
fi
cd "${SRC_DIR}"
git fetch --all --tags
git checkout "${BRANCH}"

# make gradlew executable
chmod +x ./gradlew || warn "chmod gradlew failed (continuing)"

# === build as TRON_USER ===
info "Building java-tron (this may take a while). Building as user ${TRON_USER}."
# use su -c to run inside user's shell; preserve HOME to user's home
su - "${TRON_USER}" -c "cd '${SRC_DIR}' && ./gradlew build -x test" || {
  warn "Gradle build as ${TRON_USER} failed; retrying build as root (may work / show more logs)"
  (cd "${SRC_DIR}" && ./gradlew build -x test) || die "Gradle build failed. Inspect output above."
}

# === locate distribution zip and unzip into INSTALL_DIR ===
info "Locating build distribution..."
DIST_ZIP=$(ls "${SRC_DIR}"/build/distributions/java-tron-*.zip 2>/dev/null || true)
if [[ -z "${DIST_ZIP}" ]]; then
  die "Could not find java-tron distribution zip in ${SRC_DIR}/build/distributions. Build may have failed."
fi
info "Found distribution: ${DIST_ZIP}"

info "Unzipping distribution into ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
unzip -q "${DIST_ZIP}" -d "${INSTALL_DIR}" || {
  warn "Standard unzip failed, trying with -o flag for zip bomb detection"
  unzip -o "${DIST_ZIP}" -d "${INSTALL_DIR}" || die "unzip failed completely"
}

# Find extracted directory (zip usually creates java-tron or java-tron-<ver>)
EXTRACTED_DIR=$(find "${INSTALL_DIR}" -maxdepth 1 -type d -name "java-tron*" | head -n1 || true)
if [[ -z "${EXTRACTED_DIR}" ]]; then
  # maybe unzip created files directly in INSTALL_DIR
  EXTRACTED_DIR="${INSTALL_DIR}"
fi
info "Using extracted directory: ${EXTRACTED_DIR}"

# === download main_net_config.conf into framework/src/main/resources ===
info "Downloading main_net_config.conf..."
TMP_CONF="/tmp/main_net_config.conf"
if ! curl -fsSL "${CONFIG_URL}" -o "${TMP_CONF}"; then
  warn "curl failed; trying wget..."
  if ! wget -qO "${TMP_CONF}" "${CONFIG_URL}"; then
    die "Could not download main_net_config.conf. Check network or URL: ${CONFIG_URL}"
  fi
fi
TARGET_CONF_DIR="${EXTRACTED_DIR}/framework/src/main/resources"
mkdir -p "${TARGET_CONF_DIR}"
mv -f "${TMP_CONF}" "${TARGET_CONF_DIR}/main_net_config.conf" || die "Failed to place main_net_config.conf into ${TARGET_CONF_DIR}"
info "main_net_config.conf placed at ${TARGET_CONF_DIR}/main_net_config.conf"

# === ownership fixes ===
info "Fixing ownership to ${TRON_USER}..."
chown -R "${TRON_USER}:${TRON_USER}" "${INSTALL_DIR}" || warn "chown install_dir failed"
chown -R "${TRON_USER}:${TRON_USER}" "${SRC_DIR}" || warn "chown src_dir failed"

# Make FullNode script executable
chmod +x "${EXTRACTED_DIR}/bin/FullNode" || warn "chmod FullNode failed"

# === create systemd service ===
SERVICE_PATH="/etc/systemd/system/tron.service"
info "Creating systemd unit ${SERVICE_PATH}..."
cat > "${SERVICE_PATH}" <<EOF
[Unit]
Description=TRON FullNode (java-tron)
After=network.target

[Service]
Type=simple
User=${TRON_USER}
WorkingDirectory=${EXTRACTED_DIR}
ExecStart=${EXTRACTED_DIR}/bin/FullNode -c framework/src/main/resources/main_net_config.conf
Restart=on-failure
RestartSec=10
LimitNOFILE=65536
Environment=JAVA_OPTS="-Xmx${JVM_XMX}"

[Install]
WantedBy=multi-user.target
EOF

info "Reloading systemd daemon and enabling service..."
systemctl daemon-reload
systemctl enable tron.service || warn "systemctl enable returned non-zero (check 'systemctl status tron')"

# === open firewall ports (ufw) ===
if command -v ufw >/dev/null 2>&1; then
  info "Configuring UFW: allowing ports ${UFW_ALLOW_PORTS}"
  ufw allow OpenSSH || true
  for p in ${UFW_ALLOW_PORTS}; do
    ufw allow "${p}" || warn "ufw allow ${p} failed"
  done
  # Enable ufw if inactive
  UFW_STATUS=$(ufw status | head -n1 || true)
  if [[ "${UFW_STATUS}" == "Status: inactive" ]]; then
    info "Enabling UFW (will allow only rules above + ssh)"
    ufw --force enable
  fi
else
  warn "ufw not installed / not found. Please open required ports in your cloud firewall (e.g., 8090, 50051)."
fi

info "Starting TRON service..."
systemctl start tron.service || warn "systemctl start returned non-zero (check 'systemctl status tron')"

# === summary & run instructions ===
cat <<EOF

✅ Installation steps finished.

Important paths:
 - Source repo & build dir: ${SRC_DIR}
 - Java-tron extracted dir: ${EXTRACTED_DIR}
 - main_net_config.conf: ${TARGET_CONF_DIR}/main_net_config.conf
 - Systemd unit: ${SERVICE_PATH}
 - Run-as user: ${TRON_USER}
 - JVM heap size: ${JVM_XMX}

Service control examples:
 - Check status:        sudo systemctl status tron
 - Follow logs:         sudo journalctl -u tron -f
 - Start/stop:          sudo systemctl start|stop tron

Network ports (opened in UFW firewall):
 - 8090:  HTTP JSON-RPC API
 - 50051: gRPC API
 - 50052: gRPC API (SolidityNode)
 - 50053: gRPC API

Notes:
 - The node is now synchronizing with TRON mainnet (this takes hours/days)
 - Monitor sync progress: sudo journalctl -u tron -f
 - Check listening ports: ss -tulpn | grep java
 - If JVM fails with OOM, reduce JVM_XMX and restart: sudo systemctl restart tron

EOF

info "TRON FullNode installation completed successfully!"
```

### Step 2: Make Script Executable and Run

```bash
# Make the script executable
chmod +x java-tron.sh

# Run with custom memory allocation (recommended for systems with <32GB RAM)
# For 16GB system, use 8-12GB heap:
sudo JVM_XMX="12g" ./java-tron.sh

# Or run with default 24GB heap (only for systems with 32GB+ RAM):
sudo ./java-tron.sh
```

### Step 3: Monitor Installation Progress

The installation process will:
1. Install Java 8 and dependencies (~5 minutes)
2. Clone TRON repository (~2 minutes)
3. Build from source (~10-30 minutes depending on system)
4. Configure and start service

```bash
# Watch the installation progress
tail -f /var/log/syslog | grep tron
```

## Post-Installation

### Verify Installation Success

```bash
# Check service status
sudo systemctl status tron

# Verify listening ports
ss -tulpn | grep java

# Expected output should show:
# tcp LISTEN *:8090  (HTTP RPC)
# tcp LISTEN *:50051 (gRPC)
```

### Monitor Blockchain Synchronization

```bash
# Follow real-time logs
sudo journalctl -u tron -f

# Check recent logs
sudo journalctl -u tron -n 100 --no-pager
```

## Service Management

### Basic Commands

```bash
# Start the service
sudo systemctl start tron

# Stop the service  
sudo systemctl stop tron

# Restart the service
sudo systemctl restart tron

# Check status
sudo systemctl status tron

# Enable auto-start on boot (already done by script)
sudo systemctl enable tron

# Disable auto-start
sudo systemctl disable tron
```

### Log Management

```bash
# View logs in real-time
sudo journalctl -u tron -f

# View last 50 log entries
sudo journalctl -u tron -n 50

# View logs since a specific time
sudo journalctl -u tron --since "2025-10-07 10:00:00"

# View logs with timestamps
sudo journalctl -u tron -o short-iso
```

## Configuration

### Important File Locations

| Component | Path |
|-----------|------|
| Source Code | `/home/pagcoin/src/java-tron` |
| Installation | `/home/pagcoin/java-tron/java-tron-1.0.0` |
| Configuration | `/home/pagcoin/java-tron/java-tron-1.0.0/framework/src/main/resources/main_net_config.conf` |
| Service File | `/etc/systemd/system/tron.service` |
| Logs | `sudo journalctl -u tron` |

### Adjusting Memory Allocation

If you need to change the JVM heap size:

```bash
# Edit the service file
sudo nano /etc/systemd/system/tron.service

# Modify the Environment line:
Environment=JAVA_OPTS="-Xmx8g"  # Change to desired size

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart tron
```

### Network Configuration

The following ports are automatically configured:

| Port | Protocol | Purpose |
|------|----------|---------|
| 8090 | HTTP | JSON-RPC API |
| 50051 | gRPC | gRPC API |
| 50052 | gRPC | SolidityNode API |
| 50053 | gRPC | gRPC API |

### Testing API Access

```bash
# Test HTTP RPC (should return JSON)
curl -X POST http://localhost:8090/wallet/getnowblock

# Test gRPC health (requires grpcurl)
# Install grpcurl first: sudo apt install grpcurl
grpcurl -plaintext localhost:50051 protocol.Wallet/GetNowBlock
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Service Fails to Start

```bash
# Check detailed error logs
sudo journalctl -u tron -n 50 --no-pager

# Common causes:
# - Insufficient memory (reduce JVM_XMX)
# - Port conflicts (check with: sudo ss -tulpn)
# - Permissions (check file ownership)
```

#### 2. Out of Memory Errors

```bash
# Reduce memory allocation in service file
sudo nano /etc/systemd/system/tron.service

# Change Environment line to:
Environment=JAVA_OPTS="-Xmx8g"  # or lower

# Restart service
sudo systemctl daemon-reload
sudo systemctl restart tron
```

#### 3. Slow Synchronization

```bash
# Check network connectivity
ping 8.8.8.8

# Monitor sync progress in logs
sudo journalctl -u tron -f | grep -i "sync\|block\|height"

# Note: Initial sync can take 24-48 hours
```

#### 4. Port Already in Use

```bash
# Check what's using the port
sudo ss -tulpn | grep 8090

# Kill conflicting process if safe to do so
sudo kill <PID>

# Or change TRON configuration to use different ports
```

#### 5. Disk Space Issues

```bash
# Check available space
df -h

# TRON blockchain data grows continuously
# Ensure at least 500GB+ free space
# Consider moving to larger partition if needed
```

### Log Analysis

#### Successful Startup Indicators:
- `Started tron.service - TRON FullNode`
- `Listening on ports 8090, 50051`
- `Synchronization started`

#### Warning Signs:
- `OutOfMemoryError` - Reduce heap size
- `Connection refused` - Network/port issues  
- `Permission denied` - File ownership problems

### Getting Help

1. **Check logs first**: `sudo journalctl -u tron -n 100`
2. **Verify system resources**: `free -h`, `df -h`
3. **Check network**: `ss -tulpn | grep java`
4. **Community support**: TRON Discord/Telegram channels
5. **GitHub issues**: [tronprotocol/java-tron](https://github.com/tronprotocol/java-tron/issues)

## Performance Optimization

### System Tuning

```bash
# Increase file descriptor limits (recommended)
echo "pagcoin soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "pagcoin hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Optimize network settings
echo "net.core.rmem_default = 262144" | sudo tee -a /etc/sysctl.conf
echo "net.core.rmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Monitoring

```bash
# Check resource usage
htop

# Monitor TRON process specifically
ps aux | grep java

# Check network connections
ss -tulpn | grep java
```

---

**⚠️ Important Notes:**
- Initial blockchain synchronization takes 24-48 hours
- Ensure adequate disk space (500GB+ recommended)
- Monitor system resources during sync
- Keep the system updated and secure
- Regular backups recommended for configuration files

**🎉 Congratulations!** You now have a fully functional TRON FullNode running on your Ubuntu system.
