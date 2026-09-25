# Validation lab: Example Domain provenance

This lab verifies the workstation without researching a real person. It uses IANA's reserved Example Domain.

## Objective

Answer: who reserves `example.org`, and can another analyst reproduce the supporting artifact and its integrity check?

## Steps

```bash
osint-case new "Validation - Example Domain" --purpose "Workstation validation"
osint-case list
```

Open `https://example.org/` and `https://www.iana.org/help/example-domains`. Log each page with `osint-case source`.

Download the IANA page as a training artifact:

```bash
wget --https-only --max-redirect=5 \
  -O ~/Downloads/iana-example-domains.html \
  https://www.iana.org/help/example-domains
```

Ingest and verify it:

```bash
osint-case ingest CASE_ID ~/Downloads/iana-example-domains.html \
  --source "https://www.iana.org/help/example-domains" \
  --notes "Reserved-domain validation artifact"
osint-case verify CASE_ID
```

Write a three-paragraph finding in the case `README.md`: direct observation, supporting source, and limitation. Do not overclaim ownership of the website from a DNS record alone.

Have a peer verify the case, then close it:

```bash
osint-case close CASE_ID
cd ~/Cases/*validation-example*/exports
sha256sum -c ./*.sha256
```

The instructor decrypts the `.zip.age` file on the separate review system, extracts it, compares `audit-public.pem` with the registered fingerprint, and runs `osint-audit-verify` on the extracted case directory.

## Pass criteria

- `osint-doctor` has no failures.
- Source log contains both URLs and UTC access times.
- Evidence manifest contains the file, byte count, source URL, and SHA-256.
- `verify` passes before closing.
- The encrypted `.zip.age` checksum verifies, no plaintext ZIP remains in `exports`, and every audit event has a valid signed receipt.
- The finding separates observation from inference and cites the source IDs.
