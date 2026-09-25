# Safety, privacy, and identity separation

## Three different goals

Do not collapse these into the word "privacy."

1. **Endpoint isolation** limits what risky content can do to the student's Windows computer. A dedicated VM, disposable snapshots, disabled host integration, and local analysis help.
2. **Traffic privacy** concerns what websites, network operators, and observers can see about the connection. VirtualBox NAT still presents the host network's public IP. Tor Browser can change the route for activity inside Tor Browser, but it has limitations and can be blocked.
3. **Identity protection** concerns account logins, cookies, writing style, disclosed facts, timing, phone numbers, recovery email, payment details, and other identifiers. Neither a VM nor Tor automatically solves this.

## Classroom profiles

- **Ordinary research profile:** default for benign public records and course exercises. Use the VM, no personal browser sync, no saved passwords, and no personal/Clemson account login unless the instructor explicitly requires it.
- **Separated passive profile:** only when the instructor has approved the purpose. Start from a clean snapshot, use Tor Browser for passive public browsing, do not install extensions, do not resize or customize the browser, do not download and open files outside the VM, and never log into identifying accounts.
- **Authenticated research:** use only an account you are authorized to use, under the site's terms and the exercise scope. Authentication makes the activity attributable to that account. Do not route it through Tor merely to appear anonymous.

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

## Tor limitations

Tor Browser is useful for traffic separation, not magic anonymity. Downloads opened in other applications may connect outside Tor. Account login identifies the account. Browser modifications can increase fingerprint uniqueness. Timing, behavior, and disclosed facts can still correlate activity. Follow the Tor Project's current user guidance and your instructor's policy.
