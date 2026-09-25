#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer with sudo: sudo ./install.sh" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify this Linux distribution." >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
  echo "This release is tested only on Ubuntu 24.04 LTS. Detected: ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-}"
if [[ -z "${TARGET_USER}" || "${TARGET_USER}" == "root" ]]; then
  echo "Run with sudo from the student's normal desktop account, not from a root login." >&2
  exit 1
fi
TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
if [[ -z "${TARGET_HOME}" || ! -d "${TARGET_HOME}" ]]; then
  echo "Could not resolve the home directory for ${TARGET_USER}." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "[1/7] Updating Ubuntu package metadata"
apt-get update

echo "[2/7] Installing maintained Ubuntu packages"
apt-get install -y --no-install-recommends \
  ca-certificates curl wget git jq sqlite3 ripgrep tree file less nano vim-tiny \
  python3 python3-venv pipx \
  libimage-exiftool-perl imagemagick ffmpeg mediainfo poppler-utils \
  whois dnsutils traceroute netcat-openbsd nmap \
  keepassxc libreoffice qgis flameshot geeqie \
  torbrowser-launcher ufw unattended-upgrades xdg-utils zenity zip unzip p7zip-full

echo "[3/7] Installing isolated Python OSINT applications"
runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx ensurepath
PYTHON_TOOLS=(sherlock-project maigret yt-dlp gallery-dl instaloader)
for package in "${PYTHON_TOOLS[@]}"; do
  if runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx list --short 2>/dev/null | awk '{print $1}' | grep -Fxq "${package}"; then
    runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx upgrade "${package}" || true
  else
    runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx install "${package}"
  fi
done

echo "[4/7] Installing the local portal and case tooling"
install -d -m 0755 /opt/clemson-osint/portal /opt/clemson-osint/docs /usr/local/lib/clemson-osint
install -m 0644 "${SOURCE_DIR}/portal/index.html" /opt/clemson-osint/portal/index.html
install -m 0644 "${SOURCE_DIR}/portal/styles.css" /opt/clemson-osint/portal/styles.css
install -m 0644 "${SOURCE_DIR}/portal/app.js" /opt/clemson-osint/portal/app.js
install -m 0644 "${SOURCE_DIR}"/docs/*.md /opt/clemson-osint/docs/
install -m 0755 "${SOURCE_DIR}/bin/osint-case" /usr/local/bin/osint-case
install -m 0755 "${SOURCE_DIR}/bin/osint-doctor" /usr/local/bin/osint-doctor
install -m 0755 "${SOURCE_DIR}/bin/osint-portal" /usr/local/bin/osint-portal
install -m 0644 "${SOURCE_DIR}/VERSION" /opt/clemson-osint/VERSION

install -d -o "${TARGET_USER}" -g "${TARGET_USER}" -m 0700 "${TARGET_HOME}/Cases"

echo "[5/7] Applying restrained browser and host safeguards"
install -d -m 0755 /etc/firefox/policies
install -m 0644 "${SOURCE_DIR}/firefox-policies.json" /etc/firefox/policies/policies.json
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
systemctl enable --now unattended-upgrades.service || true

echo "[6/7] Adding desktop launchers"
install -d -m 0755 /usr/local/share/applications
install -m 0644 "${SOURCE_DIR}/clemson-osint-portal.desktop" /usr/local/share/applications/clemson-osint-portal.desktop
install -m 0644 "${SOURCE_DIR}/clemson-osint-cases.desktop" /usr/local/share/applications/clemson-osint-cases.desktop

echo "[7/7] Writing an auditable install manifest"
MANIFEST=/opt/clemson-osint/install-manifest.txt
{
  echo "installed_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "kit_version=$(tr -d '\r\n' < /opt/clemson-osint/VERSION)"
  echo "os=${PRETTY_NAME}"
  echo
  echo "APT PACKAGES"
  dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort
  echo
  echo "PIPX APPLICATIONS (${TARGET_USER})"
  runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx list --short || true
} > "${MANIFEST}"
chmod 0644 "${MANIFEST}"

echo
echo "Installation complete. Log out and back in, then run: osint-doctor"
echo "Cases will be stored with private permissions under: ${TARGET_HOME}/Cases"
echo "Tor Browser is included as a launcher and completes its own verified download on first use."
