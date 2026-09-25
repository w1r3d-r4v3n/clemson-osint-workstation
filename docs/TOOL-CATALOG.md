# Tool catalog

## Core local tools

| Task | Tool | Why it is included |
|---|---|---|
| Case workflow | `osint-case` | Local case creation, source log, evidence ingest, SHA-256 verification, ZIP export |
| Image metadata | ExifTool | Mature local metadata reader; originals need not be uploaded |
| Video/audio | FFmpeg, FFprobe, MediaInfo | Frame extraction, container inspection, conversion of working copies |
| Documents | Poppler tools, LibreOffice | Local PDF inspection/text extraction and report authoring |
| Geospatial | QGIS | Reproducible map and spatial analysis |
| Structured data | SQLite, `jq` | Inspect CSV/JSON-derived research data without a server |
| Network records | `dig`, WHOIS, traceroute | Public DNS and registration queries; outputs still require interpretation |
| Credentials | KeePassXC | Local encrypted storage for authorized research accounts; no shared vault is supplied |
| Username leads | Sherlock, Maigret | Broad public-profile discovery; results are not identity proof |
| Public media | yt-dlp, gallery-dl, Instaloader | Preserve permitted public media and metadata under site terms |
| Traffic separation | Tor Browser Launcher | Optional passive research path; not a universal anonymity control |

`nmap` is installed for instructor-owned lab exercises and local service validation. Students must not scan external systems without explicit authorization.

## Deliberately not bundled

- Paid data brokers and paid API subscriptions.
- API keys, credentials, cookies, or shared accounts.
- Exploit frameworks, credential tools, phishing kits, or bypass utilities.
- Facial-recognition services; face similarity is high-risk and easy to overstate.
- A free VPN. “Free” VPN services introduce trust, privacy, and sustainability problems and do not create identity separation.
- Browser extensions. Extensions expand attack surface and change fingerprinting; install one only for a defined class need.
- A malware-analysis sandbox. Do not use this workstation to detonate suspicious files.

## Public web services

The portal links to public services including Internet Archive, Common Crawl, ICANN Lookup, Certificate Transparency, urlscan.io, OpenStreetMap, Copernicus Browser, SEC EDGAR, SAM.gov, GLEIF, OpenCorporates, and IRS Tax Exempt Organization Search. Their availability, rate limits, account requirements, data coverage, and terms can change. Check the primary source and record the date accessed.

Submitting a URL or file to a public analysis service may disclose the research target. Check whether a submission becomes public before using it.
