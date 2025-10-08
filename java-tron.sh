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
unzip -q "${DIST_ZIP}" -d "${INSTALL_DIR}" || die "unzip failed"

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

# === optional snapshot download/extract ===
if [[ -n "${SNAPSHOT_URL}" ]]; then
  info "Snapshot URL supplied. Attempting to download snapshot..."
  SNAP_TMP="/tmp/tron_snapshot.tar.gz"
  if ! curl -fSL "${SNAPSHOT_URL}" -o "${SNAP_TMP}"; then
    warn "Failed to download snapshot with curl; trying wget..."
    if ! wget -qO "${SNAP_TMP}" "${SNAPSHOT_URL}"; then
      warn "Snapshot download failed - skipping snapshot step."
    fi
  fi
  if [[ -f "${SNAP_TMP}" ]]; then
    # where to extract? java-tron default DB path is relative to working dir; create data dir
    DATA_DIR="${DATA_DIR:-/home/${TRON_USER}/tron_data}"
    info "Extracting snapshot to ${DATA_DIR} (you can set DATA_DIR env var before running script to change)"
    rm -rf "${DATA_DIR}"
    mkdir -p "${DATA_DIR}"
    tar -xzf "${SNAP_TMP}" -C "${DATA_DIR}" || warn "Extraction failed; snapshot archive may not be a tar.gz or may be structured differently"
    rm -f "${SNAP_TMP}"
    info "Snapshot extraction attempted. You may need to set the snapshot path in main_net_config.conf (check 'dbPath' or similar) to ${DATA_DIR}."
  fi
else
  info "No SNAPSHOT_URL provided — skipping DB snapshot step."
fi

# === ownership fixes ===
info "Fixing ownership to ${TRON_USER}..."
chown -R "${TRON_USER}:${TRON_USER}" "${INSTALL_DIR}" || warn "chown install_dir failed"
chown -R "${TRON_USER}:${TRON_USER}" "${SRC_DIR}" || warn "chown src_dir failed"

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
ExecStart=/usr/bin/java -Xmx${JVM_XMX} -XX:+UseConcMarkSweepGC -jar ${EXTRACTED_DIR}/FullNode.jar -c ${TARGET_CONF_DIR}/main_net_config.conf
Restart=on-failure
RestartSec=10
LimitNOFILE=65536
# Optional: set environment if needed
# Environment=JAVA_OPTS="-DsomeOption=value"

[Install]
WantedBy=multi-user.target
EOF

info "Reloading systemd daemon and enabling service..."
systemctl daemon-reload
systemctl enable --now tron.service || warn "systemctl enable/start returned non-zero (check 'systemctl status tron')"

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

# === summary & run instructions ===
cat <<EOF

✅ Installation steps finished.

Important paths:
 - Source repo & build dir: ${SRC_DIR}
 - Java-tron extracted dir: ${EXTRACTED_DIR}
 - main_net_config.conf: ${TARGET_CONF_DIR}/main_net_config.conf
 - Systemd unit: ${SERVICE_PATH}
 - Run-as user: ${TRON_USER}
 - Example run heap size (JVM Xmx): ${JVM_XMX}

Service control examples:
 - Check status:        sudo systemctl status tron
 - Follow logs:         sudo journalctl -u tron -f
 - Start/stop:          sudo systemctl start|stop tron
 - To run manually:     sudo -u ${TRON_USER} bash -c "cd '${EXTRACTED_DIR}' && /usr/bin/java -Xmx${JVM_XMX} -jar FullNode.jar -c ${TARGET_CONF_DIR}/main_net_config.conf"

Notes:
 - If you provided SNAPSHOT_URL it attempted to download & extract it into /home/${TRON_USER}/tron_data (or DATA_DIR if you set it before running).
 - If java process fails due to OOM, reduce JVM_XMX (for example to 12g) in the systemd unit or by setting env JVM_XMX before re-running to regenerate the unit (or edit the service file manually).
 - main_net_config.conf contains RPC and data folder settings. If you used a snapshot, ensure the DB path in the config points to the extracted snapshot folder (edit ${TARGET_CONF_DIR}/main_net_config.conf).
 - If the node fails to start, run: sudo journalctl -u tron -n 200 --no-pager and inspect logs.

If anything fails, paste the **first 50 lines** of:
  sudo journalctl -u tron -n 200 --no-pager

and also the output of:
  ls -la "${EXTRACTED_DIR}"
  head -n 40 "${TARGET_CONF_DIR}/main_net_config.conf"

so I can help debug. 👍

EOF

info "Done."
