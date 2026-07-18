#!/usr/bin/env python3
"""Worklist builder and validator for Paper Blossoms description files.

Run from the repository root.

List every name a description can attach to (optionally for one book):

    python3 .claude/skills/import-book-descriptions/check_descriptions.py
    python3 .claude/skills/import-book-descriptions/check_descriptions.py --book PoW

Validate a generated descriptions JSON file before importing it in the app:

    python3 .claude/skills/import-book-descriptions/check_descriptions.py my_book_descriptions.json

Book codes are the `reference.book` values used in assets/data/*.json
(Core, CR, PoW, EE, CoS, SL, Mantis, FoV, WotW, CotFW, ...).
"""

import argparse
import json
import sys
from pathlib import Path

DATA = Path("assets/data")


def _load(name):
    with open(DATA / f"{name}.json", encoding="utf-8") as f:
        return json.load(f)


def describable_names(book=None):
    """name -> (book, page), mirroring GameData.describableNames() in
    lib/game_data.dart. When several entries share a name, the first
    sighting's reference is kept."""
    names = {}

    def add(name, ref):
        if not name:
            return
        ref = ref or {}
        if book and ref.get("book") != book:
            return
        names.setdefault(name, (ref.get("book"), ref.get("page")))

    for group in _load("techniques"):
        for sub in group["subcategories"]:
            for t in sub["techniques"]:
                add(t["name"], t.get("reference"))
    for group in _load("advantages_disadvantages"):
        for e in group["entries"]:
            add(e["name"], e.get("reference"))
    for category in _load("weapons"):
        for e in category["entries"]:
            add(e["name"], e.get("reference"))
    for flat in ("armor", "personal_effects", "qualities", "bonds"):
        for e in _load(flat):
            add(e["name"], e.get("reference"))
    for s in _load("schools"):
        add(s["school_ability"], s.get("reference"))
        add(s["mastery_ability"], s.get("reference"))
    for t in _load("titles"):
        add(t["title_ability"], t.get("reference"))
    return names


def validate(path):
    with open(path, encoding="utf-8") as f:
        entries = json.load(f)
    if not isinstance(entries, list):
        sys.exit(f"{path}: expected a JSON array of description objects")

    known = describable_names()
    seen, dupes, unknown, incomplete = set(), [], [], []
    for e in entries:
        name = e.get("name", "")
        if name in seen:
            dupes.append(name)
        seen.add(name)
        if name not in known:
            unknown.append(name)
        if not name or not e.get("description") or not e.get("short_desc"):
            incomplete.append(name or "<missing name>")

    print(f"{path}: {len(entries)} entries, {len(seen)} unique names")
    for label, items in (("duplicate", dupes), ("unknown", unknown),
                         ("incomplete", incomplete)):
        for name in items:
            print(f"  {label}: {name}")
    if dupes or unknown or incomplete:
        sys.exit(1)
    print("OK — every entry has all three fields and matches a game-data name")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", nargs="?",
                        help="descriptions JSON file to validate")
    parser.add_argument("--book",
                        help="limit the name listing to one book code")
    args = parser.parse_args()

    if not DATA.is_dir():
        sys.exit("assets/data/ not found — run from the repository root")
    if args.file:
        validate(args.file)
    else:
        names = describable_names(args.book)
        for name, (book, page) in sorted(names.items()):
            where = f"{book} p.{page}" if book else "no reference"
            print(f"{name}\t{where}")
        print(f"# {len(names)} names", file=sys.stderr)


if __name__ == "__main__":
    main()
