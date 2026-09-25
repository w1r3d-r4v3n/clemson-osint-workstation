#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer as the instructor administrator with sudo." >&2
  exit 1
fi

usage() {
  cat <<'EOF'
Usage: sudo ./install.sh --student-user USER --age-recipient AGE_PUBLIC_KEY

USER must already exist and must not belong to sudo or admin. Generate the
instructor's age key off the student VM and pass only its public age1... key.
EOF
}

TARGET_USER=""
AGE_RECIPIENT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --student-user) TARGET_USER="${2:-}"; shift 2 ;;
    --age-recipient) AGE_RECIPIENT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
if [[ -z "${TARGET_USER}" || -z "${AGE_RECIPIENT}" ]]; then
  usage >&2
  exit 2
fi
if [[ ! "${AGE_RECIPIENT}" =~ ^age1[0-9a-z]{58}$ ]]; then
  echo "--age-recipient must be a complete age X25519 public recipient." >&2
  exit 2
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
if ! id "${TARGET_USER}" >/dev/null 2>&1 || [[ "${TARGET_USER}" == "root" ]]; then
  echo "The managed student account does not exist or is invalid: ${TARGET_USER}" >&2
  exit 1
fi
if id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -Eq '^(sudo|admin|wheel)$'; then
  echo "The managed student must not have sudo/admin membership: ${TARGET_USER}" >&2
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

echo "Removing tools prohibited by the managed classroom baseline"
for package in torbrowser-launcher nmap netcat-openbsd openvpn wireguard-tools proxychains4 torsocks; do
  if dpkg-query -W -f='${db:Status-Status}' "${package}" 2>/dev/null | grep -Fxq installed; then
    apt-get purge -y "${package}"
  fi
done
if command -v pipx >/dev/null 2>&1; then
  for package in sherlock-project maigret yt-dlp gallery-dl instaloader; do
    if runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx list --short 2>/dev/null | awk '{print $1}' | grep -Fxq "${package}"; then
      runuser -u "${TARGET_USER}" -- env HOME="${TARGET_HOME}" pipx uninstall "${package}"
    fi
  done
fi

echo "[2/7] Installing maintained Ubuntu packages"
apt-get install -y --no-install-recommends \
  ca-certificates curl wget git jq sqlite3 ripgrep tree file less nano vim-tiny \
  python3 python3-venv openssl age auditd audispd-plugins acct \
  libimage-exiftool-perl imagemagick ffmpeg mediainfo poppler-utils \
  whois dnsutils traceroute yt-dlp \
  keepassxc libreoffice qgis flameshot geeqie \
  ufw unattended-upgrades xdg-utils zenity zip unzip p7zip-full

echo "[3/7] Configuring managed audit and encrypted submission controls"
install -d -m 0755 /etc/clemson-osint /usr/local/libexec/clemson-osint /opt/clemson-osint
install -d -m 0700 /var/lib/clemson-osint/audit /var/log/clemson-osint
install -d -o "${TARGET_USER}" -g "${TARGET_USER}" -m 0700 "${TARGET_HOME}/Cases"
printf '%s\n' "${AGE_RECIPIENT}" > /etc/clemson-osint/instructor-age-recipient
chmod 0644 /etc/clemson-osint/instructor-age-recipient
touch /etc/clemson-osint/managed
chmod 0644 /etc/clemson-osint/managed
if [[ ! -s /var/lib/clemson-osint/audit-private.pem ]]; then
  openssl genpkey -algorithm ED25519 -out /var/lib/clemson-osint/audit-private.pem
fi
chmod 0600 /var/lib/clemson-osint/audit-private.pem
openssl pkey -in /var/lib/clemson-osint/audit-private.pem -pubout -out /opt/clemson-osint/audit-public.pem
chmod 0644 /opt/clemson-osint/audit-public.pem
install -m 0755 "${SOURCE_DIR}/bin/osint-audit-anchor" /usr/local/libexec/clemson-osint/osint-audit-anchor
install -m 0755 "${SOURCE_DIR}/bin/osint-audit-verify" /usr/local/bin/osint-audit-verify
install -m 0755 "${SOURCE_DIR}/bin/osint-case" /usr/local/bin/osint-case
printf '%s ALL=(root) NOPASSWD: /usr/local/libexec/clemson-osint/osint-audit-anchor *\n' "${TARGET_USER}" > /etc/sudoers.d/clemson-osint-audit
chmod 0440 /etc/sudoers.d/clemson-osint-audit
visudo -cf /etc/sudoers.d/clemson-osint-audit >/dev/null

cat > /etc/audit/rules.d/clemson-osint.rules <<EOF
-w ${TARGET_HOME}/Cases -p wa -k clemson_osint_cases
-w /usr/local/bin/osint-case -p x -k clemson_osint_tools
EOF
if [[ -e /usr/bin/firefox ]]; then echo '-w /usr/bin/firefox -p x -k clemson_osint_browser' >> /etc/audit/rules.d/clemson-osint.rules; fi
if [[ -e /snap/bin/firefox ]]; then echo '-w /snap/bin/firefox -p x -k clemson_osint_browser' >> /etc/audit/rules.d/clemson-osint.rules; fi
augenrules --load
systemctl enable --now auditd.service
systemctl enable --now acct.service

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
  echo "AUDIT"
  echo "student=${TARGET_USER}"
  echo "student_is_admin=false"
  echo "audit_public_key_sha256=$(sha256sum /opt/clemson-osint/audit-public.pem | awk '{print $1}')"
  echo "export_recipient=${AGE_RECIPIENT}"
} > "${MANIFEST}"
chmod 0644 "${MANIFEST}"

echo
echo "Installation complete. Sign in as ${TARGET_USER}, then run: osint-doctor"
echo "Cases will be stored with private permissions under: ${TARGET_HOME}/Cases"
echo "Register /opt/clemson-osint/audit-public.pem and the manifest with the instructor before class."
