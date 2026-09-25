#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SecurityControlsTest(unittest.TestCase):
    def test_baseline_omits_anonymity_scanning_and_bulk_collection_tools(self) -> None:
        installer = (ROOT / "install.sh").read_text(encoding="utf-8")
        package_section = installer.split("apt-get install", 1)[1].split('echo "[3/7]', 1)[0]
        for forbidden in ("torbrowser-launcher", "openvpn", "wireguard", "nmap", "netcat-openbsd", "sherlock-project", "maigret", "gallery-dl", "instaloader", "pipx"):
            self.assertNotIn(forbidden, package_section)

    def test_managed_install_requires_non_admin_student_and_age_recipient(self) -> None:
        installer = (ROOT / "install.sh").read_text(encoding="utf-8")
        self.assertIn("--student-user", installer)
        self.assertIn("--age-recipient", installer)
        self.assertRegex(installer, r"sudo\|admin\|wheel")
        self.assertIn("/etc/sudoers.d/clemson-osint-audit", installer)
        self.assertIn("/etc/audit/rules.d/clemson-osint.rules", installer)

    def test_browser_identity_and_proxy_controls_are_locked(self) -> None:
        policies = json.loads((ROOT / "firefox-policies.json").read_text(encoding="utf-8"))["policies"]
        self.assertTrue(policies["DisableFirefoxAccounts"])
        self.assertTrue(policies["DisablePrivateBrowsing"])
        self.assertTrue(policies["BlockAboutConfig"])
        self.assertEqual(policies["ExtensionSettings"]["*"]["installation_mode"], "blocked")
        self.assertEqual(policies["Preferences"]["network.proxy.type"], {"Value": 0, "Status": "locked"})
        self.assertEqual(policies["Preferences"]["network.trr.mode"], {"Value": 5, "Status": "locked"})

    def test_actions_are_pinned_to_full_commits(self) -> None:
        workflow = (ROOT / ".github" / "workflows" / "ci.yml").read_text(encoding="utf-8")
        uses = re.findall(r"uses:\s*actions/checkout@([^\s]+)", workflow)
        self.assertGreaterEqual(len(uses), 2)
        self.assertTrue(all(re.fullmatch(r"[0-9a-f]{40}", item) for item in uses))


if __name__ == "__main__":
    unittest.main()
