---
name: import-book-descriptions
description: Build a descriptions JSON file for an L5R sourcebook you own — from your own PDF — and import it into Paper Blossoms via Tools → Import descriptions
---

# Building your own description file from a sourcebook PDF

Paper Blossoms deliberately ships no rules text: the app shows *names* of
techniques, abilities, and items, and you supply the descriptions for books
you own. This skill is the pipeline for doing that in bulk from a PDF —
producing a JSON file the app imports via **Tools → Import descriptions…**.

**You need to own the book.** Work only from PDFs you have legally purchased
(e.g. from DriveThruRPG). The descriptions you write must be **original
paraphrases of the mechanics, never verbatim rulebook prose** — restate the
rules accurately in your own words. Keep the resulting file for personal use;
don't redistribute it or submit it to this repository.

## The file format

A JSON array; each entry has exactly three keys:

```json
{
  "name": "Striking as Water",
  "short_desc": "One flavorful sentence.",
  "description": "The full mechanical effect in your own words: activation, cost, check and TN, effect, duration/opportunities where the book gives them."
}
```

- `name` must exactly match a name in the app's game data (see the worklist
  below) or the description will never be shown anywhere.
- The import merges: imported entries overwrite same-name ones, everything
  else you already had is kept. The app also accepts the original Qt Paper
  Blossoms `user_descriptions.csv` format.

## Phase 1 — Build the worklist

From the repository root, list every describable name for your book:

```bash
python3 .claude/skills/import-book-descriptions/check_descriptions.py --book PoW
```

Book codes are the `reference.book` values in `assets/data/*.json` (Core,
CR, PoW, EE, CoS, SL, Mantis, FoV, WotW, CotFW). The output is
`name<TAB>book p.page` — exactly what you need to find each entry in the PDF.

What counts as describable (mirrors `describableNames()` in
[lib/game_data.dart](lib/game_data.dart)): techniques, advantage/disadvantage
entries, weapons, armor, personal effects, item qualities, bond names, each
school's school ability and mastery ability, and each title's title ability.
Names are unique — schools that share an ability name (e.g. the Isawa Tensai
variants) need only one description.

## Phase 2 — Extract the PDF text

Set up a Python venv with `pypdf`, `cryptography`, and `pdfminer.six`
(DriveThruRPG PDFs are AES-encrypted; pypdf handles that with `cryptography`
installed).

**Verify the printed-page → PDF-index offset before extracting anything**:
find a printed page number near the start of the range you need and another
near the end, and confirm both. Known offsets: Core/PoW/EE/CoS/FoV/WotW/CotFW
printed N = index N; Shadowlands and Mantis DLC printed N = index N−1;
Celestial Realms printed N = index N+2. New books can differ — never assume.

**Symbol font**: the FFG-era PDFs put dice symbols at private-use Unicode
code points. Decode with a `chr()` table in your extraction script:

| Code point | Meaning |
|---|---|
| U+F3B0 | success |
| U+F3B1 | strife |
| U+F3B2 | explosive success |
| U+F3B3 | opportunity |
| U+F3B4 | skill die |
| U+F3B5 | ring die |
| U+F3B7–F3BC | technique-category icons — drop |
| U+F2Ax | NPC stat-block icons — ignore |

Quirks seen in specific books, in case yours matches:

- **Path of Waves-style CID font** (symbols AND stat-block digits come out as
  `(cid:N)` or mangled Latin-1): use pdfminer.six; cid 2=opportunity,
  6=strife, 5/1=success/explosive, 4=ring die; digit CIDs equal the Latin-1
  code point of the mangled glyph (£=1, Ó=2, Î=3, {=4, x=5, È=6, ä=0,
  q=minus).
- **Courts of Stone-style raster pages** (invisible OCR layer that drops bold
  runs): decrypt with a pypdf `PdfWriter`, render the page with Ghostscript
  (`gs -sDEVICE=png16m -dFirstPage=N`), and read the image. At low DPI the
  ring die prints as a solid black box (the skill die is outlined).

## Phase 3 — Write the descriptions

Work in fragment files of ~15–25 entries, then merge — it keeps any one
mistake small. After merging, diff the merged names against the worklist and
chase every discrepancy; it is very easy to read an entry from the page and
never write it down.

Describe what the book *actually provides* — never invent mechanics:

- Items that appear only in a school's starting outfit with no rules entry:
  say exactly that.
- Techniques a book references but never defines: say exactly that.
- If a name in the game data doesn't match the book's spelling, the game
  data may have a typo — please open an issue rather than silently working
  around it.

## Phase 4 — Validate and import

```bash
python3 .claude/skills/import-book-descriptions/check_descriptions.py my_book_descriptions.json
```

This checks that every entry has all three fields, no name appears twice,
and every name matches the game data. The import itself doesn't reject
unknown names — they'd just sit invisibly in your data — so fix them here.

Then in the app: **Tools → Import descriptions…**, pick the file, and
confirm the reported count matches. Spot-check a few entries in the app
(technique detail views and the descriptions editor on the Tools page).
Export from Tools → Export descriptions… any time for backup.
