#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${CI:-}" != "true" || "${EUID}" -ne 0 ]]; then
  echo "This destructive account-level integration test runs only as root in disposable CI." >&2
  exit 2
fi

STUDENT=osint-ci-student
STUDENT_HOME=/home/${STUDENT}
SCRIPT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CI_BIN=/opt/clemson-osint/ci-bin

useradd --create-home --shell /bin/bash "${STUDENT}"
install -d -o "${STUDENT}" -g "${STUDENT}" -m 0700 "${STUDENT_HOME}/Cases"
install -d -m 0700 /var/lib/clemson-osint/audit /var/log/clemson-osint
install -d -m 0755 /opt/clemson-osint
install -d -m 0755 "${CI_BIN}"
install -m 0755 \
  "${SCRIPT_ROOT}/bin/osint-case" \
  "${SCRIPT_ROOT}/bin/osint-audit-anchor" \
  "${SCRIPT_ROOT}/bin/osint-audit-verify" \
  "${CI_BIN}/"
openssl genpkey -algorithm ED25519 -out /var/lib/clemson-osint/audit-private.pem
chmod 0600 /var/lib/clemson-osint/audit-private.pem
openssl pkey -in /var/lib/clemson-osint/audit-private.pem -pubout -out /opt/clemson-osint/audit-public.pem

runuser -u "${STUDENT}" -- env \
  HOME="${STUDENT_HOME}" \
  OSINT_CASES_DIR="${STUDENT_HOME}/Cases" \
  OSINT_MANAGED_MARKER=/does-not-exist \
  python3 "${CI_BIN}/osint-case" new "Managed audit CI" --purpose "Synthetic integration test"

cases=("${STUDENT_HOME}"/Cases/*)
CASE_PATH="${cases[0]}"
SUDO_USER="${STUDENT}" python3 "${CI_BIN}/osint-audit-anchor" "${CASE_PATH}"

runuser -u "${STUDENT}" -- env \
  HOME="${STUDENT_HOME}" \
  OSINT_CASES_DIR="${STUDENT_HOME}/Cases" \
  OSINT_MANAGED_MARKER=/does-not-exist \
  python3 "${CI_BIN}/osint-case" source "${CASE_PATH}" https://example.org/ --title Example
SUDO_USER="${STUDENT}" python3 "${CI_BIN}/osint-audit-anchor" "${CASE_PATH}"

runuser -u "${STUDENT}" -- python3 "${CI_BIN}/osint-audit-verify" "${CASE_PATH}"
sed -i 's/source-logged/source-erased/' "${CASE_PATH}/audit.jsonl"
if runuser -u "${STUDENT}" -- python3 "${CI_BIN}/osint-audit-verify" "${CASE_PATH}"; then
  echo "Tampered audit chain unexpectedly verified." >&2
  exit 1
fi
echo "Managed audit integration and tamper rejection passed."
