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

## 12. "Kifu's Oath" typo in `titles.json` (patched here)

Upstream `titles.json` names the Fields of Victory Deathseeker title
ability "Kifu's Oath"; the book (FoV p. 132) prints **Kirifu's Oath** —
named for Kirifu, the first Deathseeker (see the "Kirifu, the First
Deathseeker" sidebar on the same page). Nothing else in the data
references the ability by name, so the rename is safe. Guarded by the
"Kirifu's Oath matches the book name" test in
`test/game_data_validation_test.dart`.

## 13. "Incite True Nature" is a phantom technique (NOT patched — follow up)

Upstream `techniques.json` lists "Incite True Nature" as a learnable
rank-3 Fire shūji (3 XP) citing FoV p. 79. That page is the Isawa Tensai
School profile, and the technique's only appearance in the entire book is
in that school's rank-4 curriculum table — Fields of Victory never prints
an activation/effects block for it, and the curriculum entry lacks the
bold marker the book uses for new-in-this-book techniques. It looks like
a technique that was renamed or cut during development but left in the
curriculum table (no official FFG errata found as of 2026-07-12).

We have NOT patched anything: the entry is kept as-is for parity with the
Qt app, and our description file (docs/fields_of_victory_descriptions.json)
documents the gap instead of inventing mechanics. Follow-ups to consider:

- ~~Check FFG/EDGE errata and community errata threads for an official
  resolution~~ **Done 2026-07-13, negative result**: FFG's final errata
  (v3.0, 8/12/2020) predates Fields of Victory (2021) and Edge Studio
  never published errata for any L5R book, so no official document can
  cover this. The name appears nowhere on the indexed web outside the
  book — no Reddit/forum threads, no community errata (lynks.se covers
  older editions only), no code repositories. The upstream entry came in
  via PaperBlossoms PR #216 (Aug 2021), which transcribed the curriculum
  table faithfully and invented the stub so the row resolves. There is
  nothing to populate the technique from.
- Decide whether to file this upstream (dashnine/PaperBlossoms) as a data
  issue: the technique is selectable and costs XP but has no rules text
  in any book.
- If errata ever names a replacement, update techniques.json, the Isawa
  Tensai curricula in schools.json, and the description file together.
  (A plausible in-book candidate remains "Sting of Warrior's Pride", but
  applying that would be speculation, not correction.)

## 14. "Rejuvinating Breath" typo in `techniques.json` and `titles.json` (patched here)

Upstream spells the Writ of the Wilds rank-3 Earth kihō "Rejuvinating
Breath" in `techniques.json` AND in the Temple Abbot title curriculum in
`titles.json`; the book (WotW p. 109, and the Temple Abbot curriculum on
p. 143) prints **Rejuvenating Breath**. Both occurrences are patched
together so the curriculum reference still resolves. Guarded by the
"Rejuvenating Breath is spelled correctly" test in
`test/game_data_validation_test.dart`.

## 15. "Eternal Mind's Gates" name error in `techniques.json` and `titles.json` (patched here)

Upstream names the Writ of the Wilds rank-4 Void kihō "Eternal Mind's
Gates" in `techniques.json` AND in the Awakened Soul title curriculum in
`titles.json`; the book (WotW p. 114, and the Awakened Soul curriculum on
p. 142) prints **Eternal Mind's Gate** (singular). Both occurrences are
patched together so the curriculum reference still resolves. Guarded by
the "Eternal Mind's Gate matches the book name" test in
`test/game_data_validation_test.dart`.

## 16. "Logical Comclusion" typo in `schools.json` (patched here)

Upstream names the Children of the Five Winds Scholar of al-Zawira
mastery ability "Logical Comclusion"; the book (CotFW p. 89) prints
**Logical Conclusion**. Nothing else references the name, so the rename
is safe. Guarded by the "Logical Conclusion is spelled correctly" test in
`test/game_data_validation_test.dart`.

## 17. "Meishŭdŭ Secrets" mojibake in `titles.json` (patched here)

Upstream garbles the Children of the Five Winds Student of Names title
ability as "Meishŭdŭ Secrets" (U+016D u-breve where U+014D ō belongs);
the book (CotFW p. 137) prints **Meishōdō Secrets**, and the data itself
spells "meishōdō" correctly everywhere else (e.g. the Iuchi Meishōdō
Master school). Nothing else references the ability name. Guarded by the
"Meishōdō Secrets matches the book name" test in
`test/game_data_validation_test.dart`.

## 18. "Mirror Armour" spelling in `armor.json` (patched here)

Upstream spells the Children of the Five Winds riding armor "Mirror
Armour"; the book (CotFW p. 103, Table 2-5) prints **Mirror Armor**, and
the data uses the US spelling "armor" everywhere else. Nothing else
references the name. Guarded by the "Mirror Armor is spelled correctly"
test in `test/game_data_validation_test.dart`.

## 19. "Ganzu Ring Axe" spelling in `weapons.json` and `schools.json` (patched here)

Upstream names the Children of the Five Winds weapon "Ganzu Ring Axe" in
`weapons.json` AND in the Ganzu Guardian Tradition's starting outfit in
`schools.json`; the book (CotFW pp. 99-100, header and Table 2-2) prints
**Ganzu Ring Ax** — the same convention as Fields of Victory's "Ichirō
Sapper Ax". Both occurrences are patched together so the outfit reference
still resolves. Guarded by the "Ganzu Ring Ax matches the book name" test
in `test/game_data_validation_test.dart`.

## 20. "Kisshūten's Blessing" broken heritage grant in `samurai_heritage.json` (patched here)

The Writ of the Wilds "Revered Parent" heritage (WotW table 2-3, p. 107)
offers a choice of "Kisshōten's Blessing" or "Famously Lucky". Upstream
spells the first outcome "Kisshūten's Blessing" (u-macron), which matches
no entry in `advantages_disadvantages.json` — the grant silently fails to
resolve. Also fixed the same entry's instructions typo "Knowledgable" →
"Knowledgeable" (Medical Innovator row). Guarded by the "Kisshōten's
Blessing heritage outcome resolves" test in
`test/game_data_validation_test.dart`.

## 21. Spiritual Debt ring die mapping reversed in `samurai_heritage.json` (patched here)

The CotFW "Spiritual Debt" heritage (table 2-1, p. 98) rolls 1–2: Fire,
3–4: Earth, 5–6: Water, 7–8: Air, 9–10: Void. Upstream instead carries
1–2: Air, 3–4: Water, 5–6: Earth, 7–8: Fire — a copy-paste of the
previous row's ("Spirit Companion", which really is Air/Water/Earth/Fire)
mapping — so rolled results grant the wrong ring. Also closed the
unbalanced paren in its instructions text. Guarded by the "Spiritual Debt
ring die mapping matches the book" test.

## 22. "Heart of a Horse" heritage name in `samurai_heritage.json` (patched here)

The book (CotFW table 2-1, p. 98) prints **Heart of the Horse**; upstream
has "Heart of a Horse". Renamed in `samurai_heritage.json` together with
the two hardcoded wizard maps that key on the exact string
(`autoGrantedTraits` / `namedItemGrants` in `lib/wizard/wizard_state.dart`
— the Qt equivalent is the heritage `switch` in
`src/characterwizard/newcharwizardpage7.cpp`, which needs the same rename
upstream). Guarded by the "Heart of the Horse matches the book name" test.

## 23. Cutting Wind Talons wrong rank in `techniques.json` (patched here)

Upstream lists the Writ of the Wilds Air kihō "Cutting Wind Talons" as
rank 4; the technique block (WotW p. 109) prints **Rank 2**, and each
ring's kihō line in that chapter runs rank 2/3/4 (Grace of the Gentle
Breeze is the 3, Step of the Storm the 4). The Tengu Mask of Air rank-1
curriculum lists it with special access, consistent with rank 2. Guarded
by the "Cutting Wind Talons is rank 2" test.

## 24. Solidify Gratitude wrong rank in `techniques.json` (patched here)

Upstream lists the CotFW Earth shūji "Solidify Gratitude" as rank 3 —
apparently read off a school-curriculum table's rank column; the
technique block (CotFW p. 114) prints **Rank 2**. Rank 2 also makes the
curricula coherent: Ide Emissary and Kitsune Mediator list it at rank 2
without special access. Guarded by the "Solidify Gratitude is rank 2"
test.

## 25. Dragonfly Grace of the Spirits School deviations in `schools.json` (patched here)

Three mismatches against the school's page (WotW p. 96):

- **Starting techniques**: the book grants BOTH "Dominion of Suijin" and
  "Reflections of P'an Ku" (no "choose one"); upstream made the pair a
  choice of one (`size: 1` → `size: 2`).
- **Rank 3 curriculum**: the book lists Courtesy, Performance, and
  Martial Arts [Melee]; upstream omits **Performance**.
- **Ranks 4–5 curriculum**: the book opens "Rank 1–4 Invocations" /
  "Rank 1–5 Invocations" (all elements); upstream restricts both rows to
  Air and Water Invocations only.

Guarded by the "Dragonfly school matches the book (WotW p. 96)" test.

## 26. Naga Seer rank-5 capstone unlearnable in `schools.json` (patched here)

The Shinomen Naga Seer Tradition's rank-5 curriculum ends in
"Ever-Changing Waves" — a rank-5 **Water invocation**, and Invocations
are not among the tradition's available technique categories. The book
(WotW p. 98) marks the row special access; upstream instead put the
special-access flag on the rank-5 Kata/Shūji group rows (which the book
does not mark) and left Ever-Changing Waves without it, making the
capstone impossible to learn. Flags swapped to match the book. Guarded by
the "Naga Seer rank-5 capstone is learnable" test.

## 27. Kitsune Mediator extra starting techniques in `schools.json` (patched here)

Upstream gives the CotFW Kitsune Mediator School a third starting
technique choice — "Call to Ride" or "Shallow Waters" — copy-pasted from
the Iuchi Horse Lord Disciple's list. The book (CotFW p. 86) grants only
"Commune with the Spirits" plus one shūji (Appreciate the Scenery or
Shallow Waters), so upstream hands every Mediator a free extra
technique. Guarded by the "Kitsune Mediator has exactly two starting
technique sets" test.

## 28. Ujik Nomad rank-2 curriculum duplicate in `schools.json` (patched here)

Upstream lists "Sudden Downpour Style" in BOTH rank 2 and rank 3 of the
Ujik Nomad Tradition curriculum. The book (CotFW p. 92) lists **Stalking
Leopard Style** at rank 2 (Sudden Downpour Style is the rank-3 entry).
Guarded by the "Ujik Nomad rank 2 teaches Stalking Leopard Style" test.

## 29. Syncretic Philosophy wrong ring in `advantages_disadvantages.json` (patched here)

Upstream marks the CotFW distinction "Syncretic Philosophy" as Air; the
book header (CotFW p. 93) prints **(Water)**. Guarded by the "Syncretic
Philosophy is a Water distinction" test.

## 30. Saddle Cutter wrong range in `weapons.json` (patched here)

Upstream gives the CotFW Saddle Cutter range 1–2; the book (CotFW p. 100,
Table 2-2) prints **0–1**. Damage 4, deadliness 6, and the rest of the
row match. Guarded by the "Saddle Cutter is a range 0-1 weapon" test.

## 31. Assorted WotW/CotFW page references (patched here)

Book-audit page-reference corrections, all cosmetic:

| File | Entry | Was | Book page |
|---|---|---|---|
| `techniques.json` | Spiritual Survey | CotFW 110 | 111 |
| `techniques.json` | Shadow of Days | CotFW 110 | 111 |
| `techniques.json` | Protection of the Flock | CotFW 110 | 111 |
| `techniques.json` | Traveler's Experience | CotFW 110 | 112 |
| `techniques.json` | Wayfinder's Instincts | CotFW 110 | 112 |
| `advantages_disadvantages.json` | Tip of the Tongue | CotFW 96 | 97 |
| `titles.json` | Temple Abbot | WotW 142 | 143 |
| `titles.json` | Doomhunter | CotFW 135 | 134 |

Guarded by the "audited WotW/CotFW page references match the books" test.

## 32. WotW/CotFW quirks verified against the books (no change)

Noted while auditing so nobody "fixes" them into bugs:

- **Medical Innovator really grants Knowledgeable Wilderness Guide**
  (WotW p. 107) despite the flavor mismatch.
- Book-side typos where the data correctly uses the real name: the
  Awakened Soul table prints "Trance of Past Lives" (technique is Trance
  of Lives Past), the White Guard Veteran table prints "Stalking Panther
  Style" (technique is Stalking Leopard Style), Laughing Mountain rank 3
  prints "Trace of Lives Past", rank 4 prints "Bend the Storm" (Bend with
  the Storm), and Table 2-2 prints the Ide Parasol Shield quality as
  "Concealed" (Concealable).
- Naga Armor / Nezumi Armor / Yobanjin Armor and the Carving Knife have
  no purchase stats in WotW (outfit-only); their rarity/price in the data
  are upstream inventions, as are the Shinjo Horsebow's (its profile
  appears only in the p. 48 pregen).
- Minor special-access flags upstream adds where the book prints none
  (Laughing Mountain R5 Kihō, Woolen Hooves R4 Rituals, al-Zawira R5 Void
  Shūji, Utaku R4/R5 techniques, Ujik R4 Pillar of Calm, Dragonfly R1 By
  the Light of the Lord Moon): all are harmless or required for the row
  to be learnable at all; left as-is.

## 33. Jitte wrong damage/deadliness in `weapons.json` (patched here)

Upstream gives the Core jitte damage 2 / deadliness 4; the book (Core
p. 231, Table 5-1) prints **DMG 3 / DLS 2**. Neither the v1.0 (11/2018)
nor the final v3.0 (8/12/2020) FFG errata touches the jitte, so this is
a data-entry error, not an errata artifact. Guarded by the "Jitte is a
damage 3, deadliness 2 weapon" test.

## 34. Kama wrong quality in `weapons.json` (patched here)

Upstream gives the Core kama the **Ceremonial** quality; the book (Core
p. 237, Table 5-2) prints **Concealable**. No FFG errata changes the
kama. Guarded by the "Kama is Concealable, not Ceremonial" test.

## 35. Core Table 5-1 rows that final errata later changed (no change)

Noted while writing the Core gear descriptions: FFG's final errata
(v3.0, 8/12/2020) raises the **Dao's deadliness to 6** and grants the
**Jian's 2-hand grip Razor-Edged** in addition to +1 DLS. Upstream (and
our data) matches the printed book instead, consistent with upstream's
general book-not-errata stance. Left as-is; the descriptions mention the
errata values in passing.

## 36. "Ikomo Bard School" name error in `schools.json` (patched here)

Upstream names the Lion courtier school **Ikomo** Bard School; the
family is Ikoma and the book (Core p. 71) prints "Ikoma Bard School"
(the string "Ikomo" appears nowhere in the book). Guarded by the "Ikoma
Bard School matches the book name" test.

## 37. "Hands of Tides" name error in `techniques.json` and curricula (patched here)

Upstream drops the article from the rank-3 Water invocation: the
technique block (Core p. 208) and the book's index both print **"Hands
of the Tides"**, as do the Kitsu Medium and Iuchi Meishōdō Master
curriculum tables that grant it. Renamed in techniques.json, five
schools.json curricula, one titles.json advancement, and the
description files. Guarded by the "Hands of the Tides matches the book
name" test.

## 38. "The Body is an Anvil" capitalization in `techniques.json` (patched here)

The Earth kihō's block (Core p. 186) and the index print **"The Body Is
an Anvil"** (capital "Is"); upstream lowercases it. Renamed in
techniques.json, the one schools.json curriculum listing it, and the
description files. Guarded by the "The Body Is an Anvil matches the
book name" test.

## 39. Skulduggery skill rows entered as the "Skulk" technique in `schools.json` (patched here)

Two curriculum rows misread the **Skulduggery** skill as the **Skulk**
ninjutsu (Core p. 226): Kuni Purifier rank 1 (Core p. 60 prints
"Skulduggery  Skill") and Shinjo Outrider rank 4 (Core p. 85, same).
Neither school could otherwise learn ninjutsu, and both lost a
curriculum skill. The legitimate special-access Skulk rows in other
schools (Hiruma, Bayushi, Shosuro, Soshi, Yogo, …) are unchanged.
Guarded by the "Kuni Purifier and Shinjo Outrider teach Skulduggery,
not Skulk" test.

## 40. Kaiu Engineer rank 1 missing Smithing in `schools.json` (patched here)

The book (Core p. 59) lists Martial Arts [Ranged], **Smithing**, and
Tactics as the rank-1 skills; upstream omits Smithing (of all things,
for the engineer school). Guarded by the "Kaiu Engineer rank 1 includes
Smithing" test.

## 41. Matsu Berserker rank 3 wrong skill in `schools.json` (patched here)

Upstream repeats **Command** at rank 3; the book (Core p. 73) prints
**Composition** there (Command is a rank-4 row, which the data already
has). Guarded by the "Matsu Berserker rank 3 includes Composition"
test.

## 42. Asako Loremaster rank 4 wrong technique in `schools.json` (patched here)

Upstream lists **Cleansing Rite** (the ritual, Core p. 212) at rank 4;
the book (Core p. 74) prints **Cleansing Spirit** (the Earth kihō, Core
p. 182) — which also explains the special-access mark, since the
Loremasters cannot otherwise learn kihō. Guarded by the "Asako
Loremaster rank 4 grants Cleansing Spirit" test.

## 43. Worldly Rōnin rank 1 missing Fitness in `schools.json` (patched here)

The book (Core p. 87) lists **Fitness**, Martial Arts [Choose One], and
Performance as the rank-1 skills; upstream omits Fitness. (The data's
expansion of "Martial Arts [Choose One]" into all three Martial Arts
rows is equivalent and kept.) Guarded by the "Worldly Rōnin rank 1
includes Fitness" test.

## 44. Yasuki and Iuchi starting outfits begin with a second Traveling Pack in `schools.json` (patched here)

Both schools' first outfit entry is "Traveling Pack" — duplicating the
pack both books grant at the end of the list — where the books (Core
p. 61 and p. 83) open with **traveling clothes**. The characters ended
up with two packs and no clothes. Guarded by the "Yasuki and Iuchi
outfits start with traveling clothes" test.

## 45. Paragon of Righteousness wrong types in `advantages_disadvantages.json` (patched here)

Upstream types it Mental, Spiritual; the book (Core p. 108) types every
Paragon-of-a-Bushidō-Tenet distinction **Mental, Virtue** (the other
six Paragon rows in the data already say so). Guarded by the "Paragon
of Righteousness is a Virtue" test.

## 46. Incurable Illness stray type qualifier in `advantages_disadvantages.json` (patched here)

Upstream types it "Physical (Appearance)" — a qualifier copy-pasted
from Gaijin Name, Culture, or Appearance; the book (Core p. 123) types
it plain **Physical**. Guarded by the "Incurable Illness is typed
Physical" test.

## 47. "Gaijin Name, Culture or Appearance" missing comma in `advantages_disadvantages.json` (patched here)

The book (Core p. 121) prints the adversity with the serial comma:
**"Gaijin Name, Culture, or Appearance"**. Renamed here and in the
description files. Guarded by the "Gaijin Name, Culture, or Appearance
matches the book name" test.

## 48. Core rulebook quirks verified against the book (no change)

Recorded so nobody "fixes" these later. Everything below was checked
against the Core rulebook PDF during the 2026-07 core data audit, which
covered all 173 core techniques (names, ranks, restrictions, pages),
all 31 school profiles and curricula, the 128 advantages/disadvantages,
Tables 5-1/5-2/5-3 and the personal-effects costs, the Table 2-1
heritage table (rows, modifiers, and every sub-table's die ranges), the
Emerald Magistrate title, and every clan/family stat block — all clean
except the entries above.

- Book-side typos where the data correctly uses the real name: the Moto
  Conqueror rank-1 table (p. 84) prints "Stir the Embers" (the shūji's
  block on p. 219 and every other curriculum print "Stirring the
  Embers"), the Bayushi Manipulator rank-1 table (p. 78) prints "The
  Weight of Duty" (the block on p. 217 has no article), and the Emerald
  Magistrate table (p. 305) and Kuni rank 3 (p. 60) print "Open Hand
  Style" without the hyphen the block (p. 187) and the Worldly Rōnin
  table use.
- "+1 any two different rings" (Isawa Elementalist, Worldly Rōnin) is
  modeled as `["any", "any"]` — correct, two increases.
- The Asako Loremaster outfit's "ceremonial robes" is mapped to the
  Ceremonial Clothes armor entry; "any one musical instrument" (Ikoma)
  is modeled as a common/fine instrument choice; Hiruma and Kakita get
  their quiver unconditionally although the book bundles it with the
  yumi option — all harmless modeling choices.
- Inconspicuous Garb (Soshi outfit, p. 80), the Attendant, mounts, the
  journal, glass vials, and the arrow types have no purchase stats in
  the book; their prices/rarities in the data are upstream inventions,
  consistent with the WotW outfit-only items in #32.

## 49. Utaku Stablemaster rank 1 missing the Kata group in `schools.json` (patched here)

The book (CR p. 88) lists "Rank 1 Kata" as a technique-group row in the
rank-1 curriculum, alongside the two special-access rows the data
already has (Call Upon the Wind, Blessing of Fertile Fields); upstream
omits the group. Guarded by the "Utaku Stablemaster rank 1 includes the
Kata group" test.

## 50. Shosuro Shadowweaver outfit quantities in `schools.json` (patched here)

The book (CR p. 87) grants **six shuriken** and **three vials of
poison**; upstream grants one of each (compare the Core Yogo
Wardmaster, whose three shuriken upstream models as three entries).
Guarded by the "Shosuro Shadowweaver outfit has six shuriken and three
vials" test.

## 51. Assorted Celestial Realms page references (patched here)

The book opens the new-schools chapter with Agasha Alchemist (**p. 80**)
and Asahina Envoy (**p. 81**); upstream numbered them 88/89 as if they
were appended after Utaku (the other seven schools' pages are correct).
Religious Study sits on **p. 91**, not 90. Guarded by the "audited CR
page references match the book" test.

## 52. Celestial Realms quirks verified against the book (no change)

Recorded during the 2026-07 CR audit, which covered all 34 CR
techniques (the 16 inversions verified by page and
alphabetical-by-rank order, since their blocks print no rank line),
all 9 school profiles and curricula, the 5 titles, 16
advantages/disadvantages, the 7-row heritage table with every
sub-table die range, Table 2-2 weapons (with grips), both armors, all
item costs, and the Centipede/Moshi stat blocks. All clean except the
entries above.

- The Whip's quality is printed "**Ensnaring**, Mundane" (CR p. 98,
  Table 2-2) — no such weapon quality exists in the system (Ensnaring
  is a terrain quality); the data's **Snaring** is the evident intent.
- The book labels the "Rank 1-4 Rituals" (Utaku) and "Rank 1-4 Ranged
  Combat Kata" (Agasha) curriculum rows "Technique" instead of "Tech.
  Grp."; the data correctly models them as groups.
- Moon Cultist's "Disadvantage: Dark Secret" grant (CR p. 140) is not
  representable in the titles schema (titles carry no
  advantage/disadvantage field, matching upstream Qt); instead the app
  hardcodes it, like the Qt original: addTitleFlow adds Dark Secret to
  the character on taking the title (rules_constants.dart
  titleMoonCultistGrant, alongside The Damned → Ferocity).
- Dream Painter (rank-3 Air invocation) carries an extra harmless
  special-access flag in the Shosuro Shadowweaver rank-3 row; the book
  prints no "=" since the school already has Invocations — same class
  as #32/#48.
- "Elemental Deficiency [Ring]" uses brackets where the book prints
  "(Ring)"; the parenthesis in the book header doubles as the ring
  annotation, and the bracket suffix is the data's established
  disambiguation convention.
- Agasha Alchemist outfit simplifications: the book's "pouch of darts"
  has no item entry (ammunition is covered by the quiver convention),
  "one omamori (your choice)" is modeled as the generic Omamori, and
  the "pouch of 5 blessed glass vials" maps to Set of glass vials.
- The Priceless artifacts (Horagai of Sacred Rains, Daikoku's Mallet,
  Golden Obi) carry no meaningful price in the data, and the CR
  outfit-only items (Drafting Paper, Fine Set of Chisels, Pouch of
  Incense, Religious Texts, Bag of Horse Treats) reference their school
  pages with no purchase stats — same class as #32/#48.

## 53. Assorted Path of Waves page references (patched here)

Landslide Strike's technique block is on **p. 89** (upstream transposed
it to 98), Balancing Salve is on **p. 96** (not 95), and Many Mouths is
on **p. 72** (not 71). Guarded by the "audited PoW page references
match the book" test.

## 54. The Wandering Blade outfit missing its trinket in `schools.json` (patched here)

The book (PoW p. 48) ends the outfit list with "and one trinket (see
page 219)" — as every PoW school outfit does — but upstream drops it
for this school alone. Guarded by the "Wandering Blade outfit includes
a trinket" test.

## 55. Urumi wrong range in `weapons.json` (patched here)

Upstream gives the urumi range 1-3; the book (PoW p. 113, Table 3-1)
prints **1-2**. Guarded by the "Urumi is a range 1-2 weapon" test.

## 56. Military upbringing grants both rings in `upbringings.json` (patched here)

Upstream's ring choice set has size 2, granting **both** +1 Earth and
+1 Fire; the book (PoW p. 45) reads "+1 Earth or +1 Fire", one choice
like every other upbringing. Guarded by the "Military upbringing grants
one ring choice" test.

## 57. Tradesperson upbringing missing from `upbringings.json` (patched here)

The book lists thirteen upbringings; upstream ships twelve, omitting
the last one, **Tradesperson** (PoW p. 46: +1 Air or +1 Water,
+1 Commerce, +1 Aesthetics, status -6 [minimum 0], starting wealth
2 koku). Added here. Guarded by the "Tradesperson upbringing exists and
matches the book" test.

## 58. Path of Waves quirks verified against the book (no change)

Recorded during the 2026-07 PoW audit, which covered all 53 techniques
(including the Summoning Mantra template), 12 school profiles and
curricula, 4 titles, 20 advantages/disadvantages, Table 3-1 weapons
with grips, all personal-effect costs, the 10 regions, 13 upbringings,
and the 5 PoW bonds. All clean except the entries above.

- Book-side curriculum-table typos where the data correctly uses the
  block name: "Void's Embrace Style" (Wandering Blade rank 4; the block
  on p. 105 prints "Void Embrace Style"), "Ruse of Moon's Reflection"
  (Treasure Hunter and School of Leaves rank 4; block and index print
  "Ruse of the Moon's Reflection"), "Iron Shield Style" (Qamarist
  Shield Bearer rank 2; the block prints "Iron Shell Style"), "Breath
  of the Wind Style" (Qamarist Alchemist rank 3; the Core block has no
  "the"), "Way of the Willlow" (Mystic of the Mountain rank 2, triple
  l), "Bend the Storm" (Mystic rank 5 — same recurring typo as in
  WotW), and "Summon(ing) Mantra: [One Implement]" table wordings for
  the technique whose block is "Summoning Mantra: [Implement Name]".
- Book-side special-access omissions where the data correctly (and
  necessarily) sets the flag: Voice of the Wilds rank 5 lists
  Ever-Changing Waves (rank-5 Water invocation, Invocations not
  available) with no "=", and Ivory Kingdoms Sage rank 1 lists Bellow
  of Resolve (Earth shūji, Shūji not available) with no "=". Without
  special access those rows would be unlearnable — the inverse of the
  WotW Naga Seer bug (#26), fixed upstream this time.
- Ghostlands Warrior and Astradhari status awards are "+0 (+10/+25 in
  the Ivory Kingdoms)"; the conditional bonus is not representable in
  the social-award schema and is modeled as base +0.
- The Alchemy Kit's "Cost for components: 10 koku. Rarity: 1-9" is
  modeled as [common] r1 / [rare] r9 entries, both 10 koku; Travel
  Rations' "1-3 bu" as [cheap] 1 bu / [expensive] 3 bu; both fine.
- PoW outfit-only items (scrying tools, holy books, half-finished art,
  etc.) have no purchase stats — same class as #32/#48/#52.

## 59. Asako Inquisitor starting skills missing Meditation in `schools.json` (patched here)

The book (SL p. 88) lists six starting skills to choose three from
(Courtesy, Martial Arts [Melee], Martial Arts [Unarmed], **Meditation**,
Performance, Theology); upstream offers only five, dropping Meditation.
Guarded by the "Asako Inquisitor starting skills include Meditation"
test.

## 60. Harvester title Skulk row not special access in `titles.json` (patched here)

The book (SL p. 128) marks "= Skulk" in the Harvester track; upstream
sets special_access false. Since Skulk is a ninjutsu no Crab school can
otherwise learn, the row was unlearnable without the flag — same class
as the WotW Naga Seer capstone (#26). Guarded by the "Harvester's Skulk
is special access" test.

## 61. SL ritual role restrictions dropped in `techniques.json` (patched here)

The blocks (SL p. 114) print **Craft Shikigami (Shugenja)** and
**Blessing of Steel (Artisan)**; upstream stores no restriction for
either, although it stores the parenthetical restriction everywhere
else (clans, regions, Moon Cultist, Kolat…). The field is display-only
in both apps. Guarded by the "SL ritual role restrictions match the
book" test.

## 62. Hasegawa's Denial ignores its rank prerequisite in `techniques.json` (patched here)

The signature scroll's prerequisites (SL p. 108) are "Crab Clan
shugenja, **school rank 3**"; upstream models it rank 1 like the other
two scrolls (whose prerequisites have no rank component). Rank is the
one prerequisite the schema can express, so our copy sets rank 3.
Guarded by the "Hasegawa's Denial requires school rank 3" test.

## 63. Shadowlands quirks verified against the book (no change)

Recorded during the 2026-07 SL audit, which covered all 18 techniques
(signature scrolls, new rituals, and the 12 mahō), 8 school profiles
and curricula, 4 titles, 14 advantages/disadvantages, the 6-row
heritage table with sub-table die ranges, Table 2-1 weapons (including
the siege weapons and Prepare (2)), Table 2-2 armor, and all item
costs. All clean except the entries above.

- "The Blood Price" (SL pp. 115-116) is a mahō *rules section* (the
  blood-sacrifice mechanic), not a technique with an activation block;
  upstream lists it as a learnable rank-1 mahō entry (3 XP). Unlike
  "Incite True Nature" (#13), nothing in any curriculum or title
  references it, so we **removed the phantom entry** from
  techniques.json and both description files rather than keep it
  selectable. (Upstream fix: delete the row from techniques.json.)
  Guarded by the "The Blood Price phantom is not a learnable technique"
  test. A character who had already "learned" it renders as a custom
  technique and can be removed by hand.
- The Toritaka Phantom Hunter rank-5 table prints "= Flowing Water
  Cut", a technique that exists nowhere; upstream reads it as the Core
  kata **Flowing Water Strike** with special access (correct, since the
  school lacks Kata) — a reasonable resolution, left as-is.
- Book-side table wordings the data correctly normalizes: Toritaka's
  starting "By the Light of Lord Moon" (block has "the Lord Moon"),
  Mirumoto Taoist Blade rank 4 "Martial Ats [Unarmed]", and Harvester's
  "= Rank 1-2 Rituals  Technique" row mislabeled Technique.
- Kakita Swordsmith outfit maps the book's "smithing hammer" to the
  Smithy's Kit and its "personally crafted katana with Kakita pattern"
  to the invented Kakita Katana item (rarity 11, outfit-only) — same
  invented-stats class as #32/#48/#52/#58.
- Blood and Mortar's "your glory rank is treated as 1 higher while on
  the Wall" rider is narrative-conditional and not representable.
- Signature scrolls' clan/title prerequisites (Witch Hunter, Crab Clan,
  shugenja) are not representable in the technique schema; only
  Hasegawa's rank prerequisite could be captured (#62).
