# Safety, privacy, and identity separation

## Three different goals

Do not collapse these into the word "privacy."

1. **Endpoint isolation** limits what risky content can do to the student's Windows computer. A dedicated VM, disposable snapshots, disabled host integration, and local analysis help.
2. **Network attribution** concerns what websites, network operators, and authorized institutional reviewers can see about the connection. VirtualBox NAT still presents the host network's public IP. This baseline intentionally includes no Tor, VPN, or configurable proxy path.
3. **Identity protection** concerns account logins, cookies, writing style, disclosed facts, timing, phone numbers, recovery email, payment details, and other identifiers. A VM does not solve these problems.

## Classroom profiles

- **Ordinary research profile:** the default for public records and course exercises. Use the managed VM, no browser sync, no saved passwords, and no personal/Clemson account login unless the instructor explicitly requires it.
- **Authenticated research:** use only an account you are authorized to use, under the site's terms and exercise scope. Authentication makes activity attributable to that account. Never try to hide that attribution with a proxy or relay.

This kit does not create personas or accounts. Any undercover or deceptive interaction needs institutional authorization, training, and a separate plan.

## VM boundary

Keep these VirtualBox settings:

- Network adapter: NAT, not bridged.
- Shared Clipboard: Disabled.
- Drag and Drop: Disabled.
- Shared Folders: none during research.
- USB passthrough: disabled unless deliberately needed.
- Host port forwarding: none.
- 3D acceleration: disabled by default.

Use `windows/Test-OSINTVM.ps1` on the Windows host to audit these settings. The VM is a containment boundary, not a guarantee. Patch it, use a standard user for research, and restore the clean snapshot after suspicious content.

## Files and malicious content

- Prefer metadata and headers before opening a file.
- Hash the original, ingest it into the case, and analyze a copy.
- Do not enable macros or embedded content.
- Do not move an untrusted file to the host merely for convenience.
- Do not submit sensitive files to public analysis services.
- If a file may be malicious, stop and use a lab designed for malware analysis; this workstation is not one.

## Handling people data

Collect the minimum data necessary for the question. Avoid home addresses, family members, minors, health information, intimate imagery, credentials, and precise live location unless the exercise has a documented and lawful need. Apply redactions to reports, not originals. Never use OSINT findings to harass, intimidate, discriminate, or facilitate unwanted contact.

## No anonymity layer

The student baseline intentionally omits Tor Browser, VPN clients, proxy configuration, browser private mode, browser extensions, and encrypted-DNS bypass. Attempting to add or use an anonymity layer violates the managed-classroom model. A separately authorized research activity requiring identity protection needs a different institutionally approved environment, legal and ethics review, trained operators, and its own oversight plan.

## Transparent audit boundary

The workstation records executed program names through process accounting, case changes, signed case receipts, execution of the case tool and browser, and kernel-observed writes to the case directory. It does not record command-line arguments, passwords, cookies, form contents, keystrokes, private messages, or the contents of evidence. See `docs/AUDIT-AND-GOVERNANCE.md` for access, review, retention, and verification requirements.
