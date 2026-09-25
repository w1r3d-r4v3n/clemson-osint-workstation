# Clemson OSINT Club Workstation

![An ethical OSINT research workspace connecting maps, public records, imagery, metadata, and evidence verification](assets/readme-banner.png)

An unofficial, no-cost, student-ready OSINT workstation kit for a dedicated Ubuntu 24.04 LTS virtual machine. It provides a research launchpad, case and evidence workflow, local analysis tools, privacy guardrails, and a reproducible installer.

This kit is for lawful research of public information. It is not a license to bypass access controls, misrepresent identity, harass people, scan systems without authorization, or publish sensitive personal data.

## What students get

- A local research portal organized from question framing through reporting.
- One command to create, log, preserve, verify, and package a case.
- Firefox, Tor Browser Launcher, ExifTool, FFmpeg, ImageMagick, MediaInfo, SQLite, DNS/WHOIS tools, QGIS, LibreOffice, KeePassXC, and supporting utilities.
- Isolated Python applications installed with `pipx`: Sherlock, Maigret, yt-dlp, gallery-dl, and Instaloader.
- A host-side VirtualBox builder with NAT, no shared clipboard, no drag-and-drop, no shared folders, and no exposed host ports.
- A health check and a small automated test suite.

No paid API keys or accounts are required for the core workflow. Some linked public services apply rate limits or offer optional accounts.

## Clone and install

Students can clone the public repository directly:

```bash
git clone https://github.com/w1r3d-r4v3n/clemson-osint-workstation.git
cd clemson-osint-workstation
chmod +x install.sh bin/* tests/*
sudo ./install.sh
```

Do not use a `curl | sudo bash` shortcut. Cloning first lets students inspect the installer, retain the documentation, and identify the exact commit used for a class.

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

### 2. Clone the repository in Ubuntu

After installing Ubuntu, open Terminal and clone the repository using the command above. This uses the VM's normal outbound NAT connection and does not require a VirtualBox shared folder.

### 3. Install the workstation

```bash
cd ~/clemson-osint-workstation
chmod +x install.sh bin/* tests/*
sudo ./install.sh
```

The installer is safe to run again. It logs package names and versions, never credentials. It may take 20-45 minutes depending on the connection and whether QGIS is already cached.

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

Cases live under `~/Cases`. `close` creates a ZIP in the case's `exports` folder and writes a SHA-256 checksum next to it. See [Student Runbook](docs/STUDENT-RUNBOOK.md) for the complete workflow.

## Security model in one minute

| Goal | What this build does | What it does not do |
|---|---|---|
| Endpoint isolation | Keeps research activity in a disposable VM; disables shared clipboard, drag/drop, and shared folders | It cannot make an infected VM safe forever; restore a known-good snapshot after risky work |
| Network exposure | Uses VirtualBox NAT and a guest firewall denying unsolicited inbound traffic | NAT does not hide the host's public IP from websites |
| Traffic privacy | Includes Tor Browser Launcher for appropriate passive browsing | Tor is not a universal anonymity switch; logging into identifying accounts defeats separation |
| Identity separation | Provides a written profile plan and discourages cross-contamination | It does not create accounts, personas, phone numbers, or false identities |
| Evidence integrity | Records UTC timestamps, source URLs, hashes, tool versions, and packaged case exports | A hash proves file consistency, not that a claim is true or collection was lawful |

Read [Safety and Identity](docs/SAFETY-AND-IDENTITY.md) before using Tor, alternate accounts, or sensitive personal data.

## Instructor workflow

1. Build one VM, install this kit, run `osint-doctor`, and complete the validation lab.
2. Shut down the VM and take a VirtualBox snapshot named `clean-installed`.
3. Export an appliance only if Clemson policy permits distribution and you have removed student data, browser history, credentials, SSH keys, and unique identifiers.
4. Have each student create their own OS user password on first use. Never distribute a shared credential.
5. Refresh or rebuild each semester; public sources and OSINT tools change frequently.

See [Instructor Guide](docs/INSTRUCTOR-GUIDE.md), [Tool Catalog](docs/TOOL-CATALOG.md), and [Maintenance](docs/MAINTENANCE.md). Repository checks run automatically on Linux and Windows for every pull request.

## Why Ubuntu 24.04 rather than Kasm as the default

Kasm Community Edition is useful browser isolation and remains an optional instructor exercise, but it is limited to five concurrent sessions and requires a supported Linux/Docker host. A local Kasm VM still uses the host network's public IP. This kit therefore makes a per-student Ubuntu VM the complete baseline; no central server, subscription, or license key is needed.

## Branding and status

This is an unofficial student-club toolkit, not a Clemson University service or security boundary. It uses Clemson's published accessible color values but contains no university marks or restricted logos.
