# Tool catalog

## Core local tools

| Task | Tool | Why it is included |
|---|---|---|
| Case workflow | `osint-case`, `osint-audit-verify` | Local case creation, signed audit receipts, evidence verification, encrypted export verification |
| Image metadata | ExifTool | Mature local metadata reader; originals need not be uploaded |
| Video/audio | FFmpeg, FFprobe, MediaInfo | Frame extraction, container inspection, conversion of working copies |
| Documents | Poppler tools, LibreOffice | Local PDF inspection/text extraction and report authoring |
| Geospatial | QGIS | Reproducible map and spatial analysis |
| Structured data | SQLite, `jq` | Inspect CSV/JSON-derived research data without a server |
| Network records | `dig`, WHOIS, traceroute | Public DNS and registration queries; outputs still require interpretation |
| Credentials | KeePassXC | Local encrypted storage for authorized research accounts; no shared vault is supplied |
| Public media | yt-dlp | Preserve specifically authorized public media and metadata under site terms |
| Submission confidentiality | age | Encrypt each case package to the instructor's registered public recipient |
| Audit | Linux auditd, process accounting, signed receipts | Root-protected case activity and program-name metadata; no command arguments, content, or credential capture |

Active scanners, network clients such as Netcat, bulk social-profile collectors, Tor, VPN software, and configurable proxies are not part of the student baseline. Use separate instructor-owned lab infrastructure for an authorized network-security exercise.

## Deliberately not bundled

- Paid data brokers and paid API subscriptions.
- API keys, credentials, cookies, or shared accounts.
- Exploit frameworks, credential tools, phishing kits, or bypass utilities.
- Tor Browser, VPN clients, configurable proxies, active scanners, Netcat, and encrypted-DNS bypass.
- Sherlock, Maigret, gallery-dl, and Instaloader; the baseline avoids handing students bulk profile/media collection tools and proxy-capable collectors.
- Facial-recognition services; face similarity is high-risk and easy to overstate.
- Browser extensions and private browsing. The managed browser policy locks both out for attribution and supportability.
- A malware-analysis sandbox. Do not use this workstation to detonate suspicious files.

## Public web services

The portal links to public services including Internet Archive, Common Crawl, ICANN Lookup, Certificate Transparency, urlscan.io, OpenStreetMap, Copernicus Browser, SEC EDGAR, SAM.gov, GLEIF, OpenCorporates, and IRS Tax Exempt Organization Search. Their availability, rate limits, account requirements, data coverage, and terms can change. Check the primary source and record the date accessed.

Submitting a URL or file to a public analysis service may disclose the research target. Check whether a submission becomes public before using it.
