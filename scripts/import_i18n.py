#!/usr/bin/env python3
"""Build/refresh assets/i18n/data_<locale>.json from the upstream Qt CSV.

Usage: python3 scripts/import_i18n.py <locale> [path/to/i18n_<locale>.csv]
       (locale is a two-letter code: fr, de, es, ...)

Workflow:
  1. flutter test test/i18n_sync_test.dart   # writes build/l10n_harvest.json
  2. python3 scripts/import_i18n.py <locale>
  3. Review the reports; add renames to scripts/i18n_rekey_<locale>.json for
     any orphan caused by a data-audit rename, then re-run.

Rules:
  - Only keys present in the harvest (the strings the app can display) are
    emitted, so the overlay can never hold junk keys.
  - Hand-authored entries already in the overlay always win over the CSV.
  - Empty CSV translations are skipped (identity fallback covers them).
"""

import csv
import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HARVEST = ROOT / "build" / "l10n_harvest.json"
UPSTREAM_I18N_DIR = Path(
    "/Users/flux/git/PaperBlossoms_github/PaperBlossoms/data/i18n")


def normalize(value: str) -> str:
    value = unicodedata.normalize("NFC", value).strip()
    # Straight apostrophe between letters -> typographic apostrophe.
    out = []
    for i, ch in enumerate(value):
        if ch == "'" and 0 < i < len(value) - 1 and value[i - 1].isalpha() \
                and value[i + 1].isalpha():
            out.append("’")
        else:
            out.append(ch)
    return "".join(out)


def main() -> int:
    if len(sys.argv) < 2 or not re.fullmatch(r"[a-z]{2}", sys.argv[1]):
        print("Usage: python3 scripts/import_i18n.py <locale> "
              "[path/to/i18n_<locale>.csv]   (e.g. fr, de, es)")
        return 1
    locale = sys.argv[1]
    rekey_path = ROOT / "scripts" / f"i18n_rekey_{locale}.json"
    overlay_path = ROOT / "assets" / "i18n" / f"data_{locale}.json"
    csv_path = (Path(sys.argv[2]) if len(sys.argv) > 2
                else UPSTREAM_I18N_DIR / f"i18n_{locale}.csv")
    if not HARVEST.exists():
        print("Missing build/l10n_harvest.json — run "
              "`flutter test test/i18n_sync_test.dart` first.")
        return 1
    harvest = set(json.loads(HARVEST.read_text(encoding="utf-8")))
    rekey = (json.loads(rekey_path.read_text(encoding="utf-8"))
             if rekey_path.exists() else {})
    existing = (json.loads(overlay_path.read_text(encoding="utf-8"))
                if overlay_path.exists() else {})

    def resolve(key: str) -> str:
        """Match a CSV key to the harvest: rekey map first, then the
        apostrophe variants (the CSV uses typographic apostrophes where some
        data names use straight ones, and vice versa)."""
        key = rekey.get(key, key)
        for candidate in (key, key.replace("’", "'"),
                          key.replace("'", "’")):
            if candidate in harvest:
                return candidate
        return key

    upstream = {}
    unmatched = {}
    if csv_path.exists():
        with csv_path.open(encoding="utf-8", newline="") as fh:
            for row in csv.reader(fh):
                if len(row) < 2:
                    continue
                key = resolve(unicodedata.normalize("NFC", row[0]).strip())
                value = normalize(row[1])
                if not key or not value:
                    continue
                if key in harvest:
                    upstream[key] = value
                else:
                    unmatched[key] = value
        # Comma-joined lists (trait types, school roles): upstream translated
        # the joined string, the app translates the parts — split and align.
        for key, value in list(unmatched.items()):
            key_parts = [p.strip() for p in key.split(",")]
            value_parts = [p.strip() for p in value.split(",")]
            if len(key_parts) > 1 and len(key_parts) == len(value_parts) \
                    and all(p in harvest for p in key_parts):
                for part_key, part_value in zip(key_parts, value_parts):
                    upstream.setdefault(part_key, part_value)
                del unmatched[key]
    else:
        print(f"note: upstream CSV not found at {csv_path}; "
              "merging existing entries only")

    merged = dict(upstream)
    orphans_csv = list(unmatched)
    # Hand-authored entries win; anything not in the harvest is dropped and
    # reported (the sync test would fail on it anyway).
    orphans_existing = []
    for key, value in existing.items():
        if key in harvest:
            merged[key] = value
        else:
            orphans_existing.append(key)

    overlay_path.write_text(
        json.dumps(dict(sorted(merged.items())), ensure_ascii=False,
                   indent=2) + "\n",
        encoding="utf-8")

    gaps = sorted(harvest - merged.keys())
    dupes = {}
    for key, value in merged.items():
        dupes.setdefault(value, []).append(key)
    collisions = {v: ks for v, ks in dupes.items() if len(ks) > 1}

    print(f"harvest: {len(harvest)} strings")
    print(f"emitted: {len(merged)} translations -> {overlay_path}")
    print(f"coverage: {len(merged) / len(harvest) * 100:.1f}%")
    print(f"\nCSV keys not in harvest ({len(orphans_csv)}) — rename "
          f"candidates for scripts/i18n_rekey_{locale}.json, or strings "
          "the app never displays:")
    for key in sorted(orphans_csv):
        print(f"  {key}")
    if orphans_existing:
        print(f"\nDROPPED hand-authored keys not in harvest "
              f"({len(orphans_existing)}):")
        for key in orphans_existing:
            print(f"  {key}")
    print(f"\nuntranslated ({len(gaps)}) — authoring worklist:")
    for key in gaps:
        print(f"  {key}")
    if collisions:
        print(f"\nduplicate translated values (informational, "
              f"{len(collisions)}):")
        for value, keys in sorted(collisions.items()):
            print(f"  {value!r}: {keys}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
