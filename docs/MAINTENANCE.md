# Maintenance

## Monthly or before a class

Inside the VM:

```bash
sudo apt update
sudo apt full-upgrade
osint-doctor
python3 /path/to/clemson-osint-workstation/tests/test_case_workflow.py
```

Reboot after kernel or core library updates. Run the validation lab, confirm `auditd`, process accounting, and UFW are active, and verify a synthetic encrypted export and receipt chain. Do not upgrade Ubuntu to a new release mid-semester; rebuild and validate a new image separately.

## Host audit

On Windows:

```powershell
.\windows\Test-OSINTVM.ps1
```

Also confirm that no shared folders, USB devices, or port-forwarding rules were added in the VirtualBox GUI. After a successful patch cycle and validation, replace the clean snapshot; keep one prior known-good snapshot until the new one has been used successfully.

## Tool drift

Search engines, public records portals, username sites, package names, and platform terms change. At the start of each semester:

1. Test every portal link.
2. Review each tool's official installation and usage documentation.
3. Remove broken or abandoned tools rather than teaching workarounds from random repositories.
4. Revisit the course's acceptable-use examples and incident contacts.
5. Record the kit version, Ubuntu release, package manifest, build date, and validation result.
6. Confirm Tor, VPN clients, proxies, active scanners, Netcat, and bulk profile collectors remain absent.
7. Compare the audit public-key fingerprint, age recipient, managed student, and clean-snapshot identifier with the instructor registry.

## Source basis for this release

- Ubuntu 24.04 LTS releases and checksums: https://releases.ubuntu.com/24.04/
- Ubuntu installation documentation: https://ubuntu.com/desktop/docs/en/24.04/tutorial/install-ubuntu-desktop/
- VirtualBox downloads/licensing: https://www.virtualbox.org/wiki/Downloads
- Kasm requirements: https://www.kasmweb.com/docs/latest/install/system_requirements.html
- Kasm Community Edition: https://kasm.com/community-edition
- yt-dlp installation: https://github.com/yt-dlp/yt-dlp/wiki/Installation
- Clemson web colors: https://www.clemson.edu/brand/web/color.html

The kit uses Clemson Orange `#F56600` and Regalia `#522D80`, published by Clemson for web use. It intentionally includes no Clemson logo, wordmark, seal, or Tiger Paw.
