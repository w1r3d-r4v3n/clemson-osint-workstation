#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "osint-case"


class CaseWorkflowTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "Cases"
        self.recipient = Path(self.temp.name) / "recipient.txt"
        self.recipient.write_text("age1testrecipient000000000000000000000000000000000000000000000000000\n", encoding="utf-8")
        self.fake_age = Path(self.temp.name) / "fake_age.py"
        self.fake_age.write_text(
            "import shutil, sys\n"
            "args = sys.argv[1:]\n"
            "output = args[args.index('--output') + 1]\n"
            "shutil.copyfile(args[-1], output)\n",
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_case(self, *args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(self.root), *args],
            text=True,
            capture_output=True,
            check=check,
            env={
                **os.environ,
                "OSINT_AGE_RECIPIENT_FILE": str(self.recipient),
                "OSINT_AGE_COMMAND": f"{Path(sys.executable).as_posix()} {self.fake_age.as_posix()}",
                "OSINT_MANAGED_MARKER": str(Path(self.temp.name) / "not-managed"),
            },
        )

    def case_dir(self) -> Path:
        return next(self.root.iterdir())

    def test_complete_workflow(self) -> None:
        created = self.run_case("new", "Public claim training", "--purpose", "Class exercise")
        self.assertIn("Created case", created.stdout)
        case = self.case_dir()
        metadata = json.loads((case / "case.json").read_text(encoding="utf-8"))
        case_ref = metadata["case_id"][:8]

        self.run_case("source", case_ref, "https://example.org/a?x=1", "--title", "Example")
        sample = Path(self.temp.name) / "sample file.txt"
        sample.write_text("evidence\n", encoding="utf-8")
        self.run_case("ingest", case_ref, str(sample), "--source", "https://example.org/a")
        self.run_case("verify", case_ref)
        self.run_case("close", case_ref)

        with (case / "evidence_manifest.csv").open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        self.assertEqual(len(rows), 1)
        self.assertEqual(len(rows[0]["sha256"]), 64)
        self.assertEqual(json.loads((case / "case.json").read_text())["status"], "closed")
        self.assertEqual(len(list((case / "exports").glob("*.zip.age"))), 1)
        self.assertEqual(len(list((case / "exports").glob("*.sha256"))), 1)
        self.assertEqual(len((case / "audit.jsonl").read_text(encoding="utf-8").splitlines()), 6)
        self.assertEqual(len(list((case / "exports").glob(".*.zip"))), 0)

    def test_rejects_non_web_source(self) -> None:
        self.run_case("new", "URL validation")
        case_ref = json.loads((self.case_dir() / "case.json").read_text())["case_id"][:8]
        result = self.run_case("source", case_ref, "file:///etc/passwd", check=False)
        self.assertEqual(result.returncode, 2)
        self.assertIn("http:// or https://", result.stderr)

    def test_detects_audit_chain_tampering(self) -> None:
        self.run_case("new", "Audit integrity")
        case = self.case_dir()
        audit = case / "audit.jsonl"
        audit.write_text(audit.read_text(encoding="utf-8").replace("case-created", "case-erased"), encoding="utf-8")
        case_ref = json.loads((case / "case.json").read_text())['case_id'][:8]
        result = self.run_case("source", case_ref, "https://example.org/", check=False)
        self.assertEqual(result.returncode, 2)
        self.assertIn("audit hash is invalid", result.stderr)


if __name__ == "__main__":
    unittest.main()
