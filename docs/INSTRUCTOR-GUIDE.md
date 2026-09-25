# Instructor guide

## Intended use

This image supports public-source research, verification, preservation, analysis, and reporting. It intentionally omits credential attacks, exploitation frameworks, stealth scanners, bulk people-data collection, and preconfigured API keys.

## Build and validation

1. Create the VirtualBox VM with `windows/New-OSINTVM.ps1`.
2. Verify the Ubuntu ISO hash against Ubuntu's signed `SHA256SUMS` material.
3. Install Ubuntu 24.04 LTS interactively and create a non-shared local account.
4. Run `sudo ./install.sh` from this kit.
5. Log out/in, then run `osint-doctor` and `python3 tests/test_case_workflow.py`.
6. Complete `docs/VALIDATION-LAB.md` using only the reserved training targets.
7. Shut down and take a snapshot named `clean-installed-YYYY-MM-DD`.
8. Run `windows/Test-OSINTVM.ps1` from the host.

Do not distribute a VM that contains browser history, student work, credentials, API tokens, SSH keys, personal cookies, or a reusable shared password. Prefer giving students the builder and kit so each creates their own credentials.

## Course guardrails

Publish a written acceptable-use statement. At minimum, prohibit:

- bypassing access controls, password guessing, credential testing, or accessing nonpublic systems;
- pretexting, contact with subjects, or covert interaction without separate authorization;
- active scanning outside instructor-owned lab infrastructure;
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
- Rebuild each semester or after a major Ubuntu/toolchain change.
- For a suspected compromise, power off and restore; do not try to clean the VM during class.

## Kasm option

Kasm Community Edition can be a useful separate lesson in remote browser isolation. As of the sources checked for this release, Community Edition is free for individuals and nonprofits but limited to five concurrent sessions; minimum documented host resources are 2 cores, 4 GB RAM, and 50 GB storage, with more resources needed per session. Keep it local-only, in a dedicated supported Linux VM, and do not describe the local deployment as anonymity: its outbound traffic still uses the local network unless a separately designed egress layer is used.

For a club larger than five simultaneous users, deploy this per-student VM baseline instead of treating one CE server as the class workstation.

## Incident path

Before class, name the person and channel students should use for accidental sensitive-data exposure, credible threats, illegal content, suspected malware, or legal questions. Do not ask students to forward dangerous content by email. Preserve minimal context, stop collection, and follow Clemson's current incident and safety procedures.
