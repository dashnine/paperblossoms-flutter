# Upstream data & code issues found during the port

Issues discovered in [dashnine/PaperBlossoms](https://github.com/dashnine/PaperBlossoms)
while porting to Flutter, for filing upstream later. Our bundled copies of the
JSON in `assets/data/` were taken verbatim from `PaperBlossoms/data/json/`
except where marked **patched here**.

## 1. Mislabeled `type` fields → silent half XP (patched here)

Curriculum and title-advancement entries carry a `type` field that tells the
XP engine which namespace the entry's name lives in. The engine
(`MainWindow::isInCurriculum` / `isInTitle` in `src/tabs/advancementpage.cpp`;
ported to `lib/derived_stats.dart`) sorts entries into a skills set or a
techniques set **by that label**, then checks purchases against the matching
set only. A mislabeled entry lands in the wrong set — or expands to nothing
(`skill_group` lookup on a non-group name returns an empty list) — so buying
that advance never counts as in-curriculum and credits **half** its cost
toward rank/title progress instead of full. Technique *availability* is
unaffected (that check compares names directly), which is why nobody notices.

17 entries are affected. To fix upstream, edit `PaperBlossoms/data/json/`
and regenerate the SQLite DB with `data/scripts/json_to_db.py`.

### `schools.json` (12)

| School | Rank | Advance | Is | Should be |
|---|---|---|---|---|
| Kuni Purifier School | 1 | Skulk | `skill` | `technique` |
| Kitsuki Investigator School | 3 | Earth Shūji | `technique` | `technique_group` |
| Kitsuki Investigator School | 5 | Skulduggery | `technique` | `skill` |
| Asako Loremaster School | 2 | Air Shūji | `skill_group` | `technique_group` |
| Shinjo Outrider School | 4 | Skulk | `skill` | `technique` |
| Miya Cartographer School | 5 | Artisan's Appraisal | `skill_group` | `technique` |
| Moto Avenger School | 4 | Earth Invocations | `skill` | `technique_group` |
| Storm Fleet Tide Seer | 2 | Tea Ceremony | `skill` | `technique` |
| Student of the Talon | 5 | Kata | `technique` | `technique_group` |
| Ivory Kingdoms Sage Tradition | 5 | Kata | `technique` | `technique_group` |
| Shinomen Naga Seer Tradition | 3 | Kata | `technique` | `technique_group` |
| Shinomen Naga Seer Tradition | 5 | Theology | `technique` | `skill` |

### `titles.json` (5)

| Title | Advancement | Is | Should be |
|---|---|---|---|
| Covert Agent | Meditation | `skill_group` | `skill` |
| General | Rituals | `technique` | `technique_group` |
| General | Shūji | `technique` | `technique_group` |
| War College Graduate | Shūji | `technique` | `technique_group` |
| Animal Handler | Martial Arts [Unarmed] | `skill_group` | `skill` |

Our copies of these two files carry exactly these 17 one-word fixes (a
17-line diff against upstream; everything else is byte-identical). The
regression guard lives in `test/game_data_validation_test.dart`
("every curriculum/title type label matches what its name resolves to") and
was verified to fail against the unpatched upstream files. When syncing
future upstream data updates, re-copy the files, run that test, and re-apply
whatever it flags.

## 2. "Tewnty Goblin Thief" typo in C++ (not applicable here)

`newcharwizardpage2/3/4/7.cpp` gate the Q18 heritage bonus skill on a
hardcoded heritage-name list containing the misspelling
`"Tewnty Goblin Thief"`. The data spells it `"Twenty Goblin Thief"`
(`samurai_heritage.json`, SL table), so that heritage's bonus skill is
silently never granted in the Qt app. Our wizard drives the effect from
`other_effects.type` instead of name lists, so the bug doesn't exist here.
Upstream fix: correct the string in all four files (or switch to type-driven
dispatch).

## 3. `question_8.json` mislabels the Q8 bonus (cosmetic upstream)

The first option's outcome says `{"attribute": "Glory", "value": 10}`, but
the core rulebook (and the Qt app's own hardcoded logic in
`newcharwizardpage7.cpp`, `socialmap["Honor"] += 10`) award **+10 Honor**.
The Qt app never reads this file for the bonus, so it's latent — but anything
consuming the JSON directly (like this port, or the schema docs) inherits the
error. We follow Qt/the rulebook (+10 Honor, `lib/wizard/wizard_state.dart`).

## 4. Duplicate weapon "Moshi Sun Ax" (informational)

Listed under both *Axes* and *Polearms* in `weapons.json` with identical
stats — apparently intentional (it is both). Noted because it breaks the
assumption that weapon names are globally unique; keys must be
(category, name).

## 5. Kitsu Realm Wanderer School cites the wrong book (patched here)

Upstream `schools.json` gives the Kitsu Realm Wanderer School `"reference":
{"book": "Core", "page": 85}`, but Core p. 85 is the Shinjo Outrider School
and the Realm Wanderer (with its Celestial Alignment / Walk the Hidden Ways
abilities) appears nowhere in the core rulebook. The correct source is
**Celestial Realms, p. 85**, so our copy now reads `"book": "CR"` — the
abbreviation the data already uses for other Celestial Realms content
(e.g. the Bond with a Spirit titles). Guarded by the "Kitsu Realm Wanderer
cites Celestial Realms" test in `test/game_data_validation_test.dart`.

## 6. "Elxir of Recovery" typo in `techniques.json` (patched here)

Upstream `techniques.json` names the rank-2 Qamarist ritual from Path of
Waves "Elxir of Recovery"; the book (PoW p. 96) spells it **Elixir of
Recovery**. Nothing else in the data references the technique by name
(no curriculum or title advancement lists it), so the rename is safe.
Our copy now uses the correct spelling. Guarded by the "Elixir of Recovery
is spelled correctly" test in `test/game_data_validation_test.dart`.

## 7. "No Sacrifice Too Greate" typo in `titles.json` (patched here)

Upstream `titles.json` names the Emerald Empire Yōjimbō title ability
"No Sacrifice Too Greate"; the book (EE p. 252) spells it **No Sacrifice
Too Great**. Nothing else in the data references the ability by name, so
the rename is safe. Our copy now uses the correct spelling. Guarded by the
"No Sacrifice Too Great is spelled correctly" test in
`test/game_data_validation_test.dart`.

## 8. "Inspired Creation" name mismatch in `titles.json` (patched here)

Upstream `titles.json` names the Courts of Stone Master Artisan title
ability "Inspired Creation"; the book (CoS p. 131) prints **Inspired
Creations**. Nothing else in the data references the ability by name, so
the rename is safe. Our copy now matches the book. Guarded by the
"Inspired Creations matches the book name" test in
`test/game_data_validation_test.dart`.

## 9. "Siege Wepaons" typo in `weapons.json` (patched here)

Upstream `weapons.json` names the Shadowlands weapon category "Siege
Wepaons"; the book (SL p. 104, Table 2-1) prints **Siege Weapons**. The
category holds the Ballista and O-Gata Dohou and is user-visible wherever
weapons are grouped by category. Nothing else in the data references the
category name, so the rename is safe. Guarded by the "Siege Weapons
category is spelled correctly" test in `test/game_data_validation_test.dart`.

## 10. "Asaka Inquisitor School" name error in `schools.json` (patched here)

Upstream `schools.json` names the Shadowlands Phoenix school "Asaka
Inquisitor School"; the book (SL p. 88) prints **Asako Inquisitor
School** — Asako is the Phoenix family (upstream itself spells the Core
"Asako Loremaster School" correctly). Nothing else in the data references
the school by name, so the rename is safe. Guarded by the "Asako Inquisitor
School matches the family name" test in `test/game_data_validation_test.dart`.

## 11. "Kaisen Whispers" typo in `advantages_disadvantages.json` (patched here)

Upstream names the alternative Air Taint disadvantage "Shadowlands Taint
[Kaisen Whispers]"; the book (SL p. 98) prints **Kansen Whispers** —
kansen are the corrupt kami that mahō entreats, a term used throughout
the book. Nothing else in the data references the disadvantage by name,
so the rename is safe. Guarded by the "Kansen Whispers matches the book
name" test in `test/game_data_validation_test.dart`.
