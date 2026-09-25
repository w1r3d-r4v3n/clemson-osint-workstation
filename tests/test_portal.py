#!/usr/bin/env python3
from __future__ import annotations

import unittest
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
PORTAL = ROOT / "portal" / "index.html"


class PortalParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.ids: list[str] = []
        self.links: list[dict[str, str | None]] = []
        self.scripts: list[str] = []
        self.styles: list[str] = []
        self.cards = 0
        self.has_main = False
        self.has_h1 = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.append(str(values["id"]))
        if tag == "a":
            self.links.append(values)
        if tag == "script" and values.get("src"):
            self.scripts.append(str(values["src"]))
        if tag == "link" and values.get("rel") == "stylesheet" and values.get("href"):
            self.styles.append(str(values["href"]))
        if tag == "article" and "tool-card" in str(values.get("class", "")).split():
            self.cards += 1
        if tag == "main":
            self.has_main = True
        if tag == "h1":
            self.has_h1 = True


class PortalTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.parser = PortalParser()
        cls.parser.feed(PORTAL.read_text(encoding="utf-8"))

    def test_landmarks_and_unique_ids(self) -> None:
        self.assertTrue(self.parser.has_main)
        self.assertTrue(self.parser.has_h1)
        self.assertEqual(len(self.parser.ids), len(set(self.parser.ids)))
        self.assertGreaterEqual(self.parser.cards, 8)

    def test_local_assets_exist(self) -> None:
        for relative in self.parser.scripts + self.parser.styles:
            self.assertTrue((PORTAL.parent / relative).is_file(), relative)

    def test_external_links_are_https_and_isolated(self) -> None:
        external = 0
        for link in self.parser.links:
            href = str(link.get("href") or "")
            if href.startswith("#"):
                continue
            parsed = urlparse(href)
            if parsed.scheme:
                external += 1
                self.assertEqual(parsed.scheme, "https", href)
                self.assertEqual(link.get("target"), "_blank", href)
                rel = set(str(link.get("rel") or "").split())
                self.assertTrue({"noopener", "noreferrer"}.issubset(rel), href)
        self.assertGreaterEqual(external, 15)


if __name__ == "__main__":
    unittest.main()
