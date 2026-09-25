# Instructor guide

## Intended use

This image supports public-source research, verification, preservation, analysis, and reporting. It intentionally omits anonymity clients, VPNs, configurable proxies, credential attacks, exploitation frameworks, active scanners, bulk people-data collection, and preconfigured API keys.

## Build and validation

1. Create the VirtualBox VM with `windows/New-OSINTVM.ps1`.
2. Verify the Ubuntu ISO hash against Ubuntu's signed `SHA256SUMS` material.
3. Install Ubuntu 24.04 LTS interactively and create an instructor administrator account.
4. Create a unique student standard account and verify it is not in `sudo`, `admin`, or `wheel`.
5. Generate the instructor age key on a separate protected system. Run `sudo ./install.sh --student-user USER --age-recipient age1...` with only its public recipient.
6. Register the install-manifest and audit-public-key fingerprints outside the VM.
7. Sign in as the student, run `osint-doctor`, and run `python3 tests/test_case_workflow.py`.
8. Complete `docs/VALIDATION-LAB.md` using only the reserved training targets.
9. Shut down and take a snapshot named `clean-installed-YYYY-MM-DD`.
10. Run `windows/Test-OSINTVM.ps1` from the host.

Do not distribute a VM that contains browser history, student work, credentials, API tokens, SSH keys, personal cookies, or a reusable shared password. Prefer giving students the builder and kit so each creates their own credentials.

Read and adapt `docs/AUDIT-AND-GOVERNANCE.md` before issue. Tell students exactly what metadata is collected, who can review it, how long it is retained, and how to challenge an error. Do not add keylogging, screenshots, TLS interception, credential capture, or content surveillance.

## Course guardrails

Publish a written acceptable-use statement. At minimum, prohibit:

- bypassing access controls, password guessing, credential testing, or accessing nonpublic systems;
- pretexting, contact with subjects, or covert interaction without separate authorization;
- active scanning outside instructor-owned lab infrastructure;
- Tor, VPN, proxy, relay, alternate-boot, or administrator-access attempts intended to evade attribution;
- mass collection, doxxing, harassment, or unnecessary sensitive-person data;
- uploading case material to third-party AI or analysis services without authorization;
- presenting username, face, or name similarity as identity proof;
- publishing student work without harm review and redaction.

Use instructor-controlled synthetic personas, reserved domains, public institutional records, or subjects who have opted in. Do not build assignments around private individuals who did not consent.

## Evidence rubric

Suggested 100-point rubric:

- 15: scoped and answerable research question;
- 15: lawful, proportionate collection plan;
- 20: source quality and independent corroboration;
- 15: identity/time/location/context verification;
- 10: provenance, UTC timestamps, originals, and hash verification;
- 15: observation/inference separation, confidence, and alternatives;
- 10: citations, redaction, clarity, and reproducible packaging.

## Snapshot lifecycle

- `clean-os`: Ubuntu installed and patched, before the toolkit.
- `clean-installed`: toolkit installed and validated; use as the normal reset point.
- Never snapshot while a case or account is open.
- Never give the student the instructor administrator credential or age private key.
- Rebuild each semester or after a major Ubuntu/toolchain change.
- For a suspected compromise, power off and restore; do not try to clean the VM during class.

## Kasm option

Kasm Community Edition can be a useful separate lesson in remote browser isolation. As of the sources checked for this release, Community Edition is free for individuals and nonprofits but limited to five concurrent sessions; minimum documented host resources are 2 cores, 4 GB RAM, and 50 GB storage, with more resources needed per session. Keep it local-only, in a dedicated supported Linux VM, and do not describe the local deployment as anonymity: its outbound traffic still uses the local network unless a separately designed egress layer is used.

For a club larger than five simultaneous users, deploy this per-student VM baseline instead of treating one CE server as the class workstation.

## Incident path

Before class, name the person and channel students should use for accidental sensitive-data exposure, credible threats, illegal content, suspected malware, or legal questions. Do not ask students to forward dangerous content by email. Preserve minimal context, stop collection, and follow Clemson's current incident and safety procedures.

## Audit review

Routine grading should verify the encrypted package, registered workstation public-key fingerprint, receipt chain, and case contents. Inspect root-owned kernel audit logs only for a disclosed spot check, integrity discrepancy, or documented incident. Record the reviewer, reason, time range, and disposition. Do not use course audit data for unrelated monitoring.
