# Clemson OSINT Club Workstation

![An ethical OSINT research workspace connecting maps, public records, imagery, metadata, and evidence verification](assets/readme-banner.png)

An unofficial, no-cost, student-ready OSINT workstation kit for a dedicated Ubuntu 24.04 LTS virtual machine. It provides a research launchpad, case and evidence workflow, local analysis tools, privacy guardrails, and a reproducible installer.

This kit is for lawful research of public information. It is not a license to bypass access controls, misrepresent identity, harass people, scan systems without authorization, or publish sensitive personal data.

## What students get

- A local research portal organized from question framing through reporting.
- One command to create, log, preserve, verify, and package a case.
- Firefox, ExifTool, FFmpeg, ImageMagick, MediaInfo, SQLite, DNS/WHOIS tools, QGIS, LibreOffice, KeePassXC, yt-dlp, and supporting Ubuntu packages.
- A host-side VirtualBox builder with NAT, no shared clipboard, no drag-and-drop, no shared folders, and no exposed host ports.
- Root-protected audit receipts, encrypted instructor exports, a health check, and an automated test suite.

No paid API keys or accounts are required for the core workflow. Some linked public services apply rate limits or offer optional accounts.

## Managed classroom installation

The default build separates the instructor administrator from the student account. On a fresh Ubuntu VM, the instructor creates both accounts, keeps the administrator credential private, and gives the student account no `sudo` membership:

```bash
git clone https://github.com/w1r3d-r4v3n/clemson-osint-workstation.git
cd clemson-osint-workstation
chmod +x install.sh bin/* tests/*
sudo adduser osint-student
sudo deluser osint-student sudo 2>/dev/null || true

# Generate and retain this private key on the instructor's separate system:
age-keygen -o instructor-age-key.txt
# Copy only the printed age1... public recipient into the command below:
sudo ./install.sh --student-user osint-student --age-recipient 'age1...'
```

Do not put `instructor-age-key.txt` in the VM or repository. Register the VM's `/opt/clemson-osint/audit-public.pem`, install manifest, and assigned student before issuing the VM. Do not use a `curl | sudo bash` shortcut.

## Fast path from Windows

### 1. Create the VM shell

Requirements: Oracle VirtualBox 7.x base package and an Ubuntu 24.04 LTS Desktop ISO. The Extension Pack is not required.

Open PowerShell in this folder and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\New-OSINTVM.ps1 -IsoPath "C:\path\to\ubuntu-24.04.5-desktop-amd64.iso"
```

The script creates and starts a VM named `Clemson-OSINT`. Complete Ubuntu's normal installer. Use full-disk encryption inside the VM if the computer and recovery plan support it. Do not enable automatic login.

Recommended host minimum: 16 GB RAM, 4 free CPU threads, and 80 GB free storage. The VM defaults to 4 CPUs, 6 GB RAM, and an 80 GB dynamically allocated disk.

### 2. Configure the managed accounts

Create the first Ubuntu account as the instructor administrator. Create a separate `osint-student` standard account, then clone and install the repository from the instructor account using the managed command above. The student must not know the instructor password.

### 3. Install the workstation

```bash
cd ~/clemson-osint-workstation
sudo ./install.sh --student-user osint-student --age-recipient 'age1...'
```

The installer is safe to run again with the same managed student and recipient. It records package versions and the audit public-key fingerprint, never credentials. It may take 20-45 minutes.

Log out and back in once. Open **OSINT Launchpad** from the application menu, or run:

```bash
osint-portal
osint-doctor
```

## First investigation

```bash
osint-case new "Training - verify a public claim"
osint-case list
osint-case source <case-id> "https://example.org/page" \
  --title "Example source" --category web --notes "Public training source"
osint-case ingest <case-id> ~/Downloads/example.pdf \
  --source "https://example.org/report.pdf" --notes "Downloaded from publisher"
osint-case verify <case-id>
osint-case close <case-id>
```

Cases live under `~/Cases`. Every case action extends a hash chain and receives a receipt signed by a root-owned workstation key. `close` creates an age-encrypted `.zip.age` submission package and checksum; only the instructor's separate private key can decrypt it. See [Student Runbook](docs/STUDENT-RUNBOOK.md) and [Audit and Governance](docs/AUDIT-AND-GOVERNANCE.md).

## Security model in one minute

| Goal | What this build does | What it does not do |
|---|---|---|
| Endpoint isolation | Keeps research activity in a disposable VM; disables shared clipboard, drag/drop, and shared folders | It cannot make an infected VM safe forever; restore a known-good snapshot after risky work |
| Network exposure | Uses VirtualBox NAT and a guest firewall denying unsolicited inbound traffic | NAT does not hide the host's public IP from websites |
| Attribution | Omits Tor, VPN, proxy, active-scanning, and bulk-profile tools; locks browser proxy/private-mode settings | A local VM cannot defeat every web proxy; institutional egress controls require separate Clemson approval |
| Identity safety | Disables browser sync, saved passwords, private browsing, extensions, custom proxy settings, and encrypted DNS bypass | It does not create accounts, personas, phone numbers, or false identities |
| Evidence integrity | Hash-chains case events, obtains root-protected signed receipts, records kernel audit events, and encrypts submissions | Audit metadata proves workstation events, not that a claim is true or collection was lawful |

Read [Safety and Identity](docs/SAFETY-AND-IDENTITY.md) and [Audit and Governance](docs/AUDIT-AND-GOVERNANCE.md) before handling accounts or sensitive personal data.

## Instructor workflow

1. Build one VM with separate instructor and student accounts, install this kit, run `osint-doctor`, and complete the validation lab.
2. Shut down the VM and take a VirtualBox snapshot named `clean-installed`.
3. Export an appliance only if Clemson policy permits distribution and you have removed student data, browser history, credentials, SSH keys, and unique identifiers.
4. Keep the instructor credential and age private key outside the student VM. Give each student a unique standard-user password and never distribute a shared credential.
5. Register the student, install-manifest digest, audit public-key fingerprint, VM snapshot, and retention date before use.
6. Refresh or rebuild each semester; public sources and OSINT tools change frequently.

See [Instructor Guide](docs/INSTRUCTOR-GUIDE.md), [Audit and Governance](docs/AUDIT-AND-GOVERNANCE.md), [Tool Catalog](docs/TOOL-CATALOG.md), and [Maintenance](docs/MAINTENANCE.md). Repository checks run automatically on Linux and Windows for every pull request.

## Why Ubuntu 24.04 rather than Kasm as the default

Kasm Community Edition is useful browser isolation and remains an optional instructor exercise, but it is limited to five concurrent sessions and requires a supported Linux/Docker host. A local Kasm VM still uses the host network's public IP. This kit therefore makes a per-student Ubuntu VM the complete baseline; no central server, subscription, or license key is needed.

## Branding and status

This is an unofficial student-club toolkit, not a Clemson University service or security boundary. It uses Clemson's published accessible color values but contains no university marks or restricted logos.
