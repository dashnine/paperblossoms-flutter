# Paper Blossoms (Flutter)

[![CI](https://github.com/dashnine/paperblossoms-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/dashnine/paperblossoms-flutter/actions/workflows/ci.yml)

A character generator for Legend of the Five Rings.

## About

Paper Blossoms is an open source character generator and manager for Legend of the Five Rings 5th Edition, a roleplaying game by Fantasy Flight Games. It walks you through the Game of Twenty Questions to build a character, then tracks that character through play — advancement, equipment, bonds, and titles — and prints a PDF character sheet.

This is a Flutter port of the original [PaperBlossoms](https://github.com/dashnine/PaperBlossoms) Qt desktop application, by the same developer. The port brings the same data and rules logic to mobile and desktop from a single codebase, and adds a book-audited data set and a localized interface.

The application and author(s) are not affiliated with FFG or any other official L5R party. Legend of the Five Rings and all associated content is property of Fantasy Flight Games.

## Features

- Guided character creation following the Game of Twenty Questions
- Character management: rings, skills, techniques, equipment, bonds, titles, and XP-tracked advancement (curriculum-aware, matching the rank-progress rules)
- PDF character sheet export
- Localized interface and game data (English, French, German, Spanish)
- Fully offline — no network connection is used or needed

## Downloading and Using Paper Blossoms

Caution: as always, this software is provided without warranty, and the author assumes no responsibility or liability for its use.

Prebuilt downloads for each release are on the [Releases page](https://github.com/dashnine/paperblossoms-flutter/releases):

- **macOS** — download the `.dmg`, open it, and drag Paper Blossoms to Applications. Builds are signed and notarized, so it opens like any other app.
- **Windows** — download the `-windows-x64.zip`, extract it anywhere, and run `paperblossoms.exe`. Windows SmartScreen may warn about an unrecognized app the first time (the build is not code-signed); choose "More info" → "Run anyway".
- **Android** — download the `.apk` and open it on your device. You may need to allow installs from unknown sources when prompted; this is normal for apps distributed outside the Play Store.
- **Linux** — download the `-linux-x64.tar.gz`, extract it, and run `./paperblossoms` from the extracted folder. Requires GTK 3 (present on virtually all desktop distributions).

### Building from source

Being a Flutter application, it builds for macOS, Windows, Linux, iOS, Android, and web from one codebase. Development and testing are currently conducted on macOS. To build from source:

```sh
flutter pub get
flutter run
```

## Data

Game data (clans, families, schools, techniques, equipment, and so on) ships as JSON under `assets/data/`, originally taken from the upstream project's data set. During the port, the data was audited page-by-page against the printed sourcebooks; the corrections made here — and issues worth fixing upstream — are documented in [docs/UPSTREAM_NOTES.md](docs/UPSTREAM_NOTES.md).

Much like the excellent Star Wars character generator by OggDude, the application does not bundle rules description text; you are expected to own and use the books while creating or editing your character. If you own the books, you can enter descriptions yourself in the built-in descriptions editor (Tools page), and import/export them as JSON. Imports also accept the original Qt application's `user_descriptions.csv`, so existing data carries over.

## Localization

The app supports a localized interface and game-content display (currently
French, German, and Spanish), selected with a single language setting on
the Tools page. See [docs/I18N.md](docs/I18N.md) for the architecture and
how to add a locale.

### Translation credits

- The French translation builds on the volunteer community translations
  shipped with the original
  [PaperBlossoms](https://github.com/dashnine/PaperBlossoms) (`i18n_fr.csv`). French editions of Legend of the Five Rings are published by
  [Edge Studio](https://fr.edge-studio.net/shares/la-legende-des-cinq-anneaux/).
- Official French terminology was verified against reference lists
  maintained by [La Voix de Rokugan](https://www.voixrokugan.org/), the
  French Legend of the Five Rings community — techniques (Kata, Kihō,
  Shūji, Rituels) and conditions.
- The German translation likewise builds on the volunteer community
  translations shipped with the original PaperBlossoms (`i18n_de.csv`).
  The German 5th-edition rulebook ("Die Legende der fünf Ringe – Das
  Rollenspiel") was published by Fantasy Flight Games / Asmodee; no freely
  available official term list was found, so the German locale is **not
  book-verified** — corrections from owners of the German books are very
  welcome.
- The Spanish translation likewise builds on the volunteer community
  translations shipped with the original PaperBlossoms (`i18n_es.csv`). No freely available official term list was found, so the Spanish locale is **not book-verified** — corrections from owners of the Spanish books are very welcome.

  As a reminder, this project is fan-made and
  unaffiliated with Edge Studio, Fantasy Flight Games, or Asmodee.

## Contributing

Paper Blossoms is written in Dart with Flutter. Game data is loaded through `lib/game_data.dart`, derived character statistics (including curriculum/XP logic) live in `lib/derived_stats.dart`, and the UI is under `lib/screens/` and `lib/wizard/`. Pull requests are welcome.

If you're contributing a data correction, please cite the book and page it comes from — the data set aims to match the printed books (not community errata), and English entry names are canonical identifiers, so a rename must be applied to every `assets/i18n/data_*.json` file in the same change (a test enforces this).

For translation contributions, see [docs/I18N.md](docs/I18N.md).

## Credits

Data modeling and data entry for the original data set ninja-provided by [@meow9th](https://github.com/meow9th).

L5R and all associated data is owned by FFG. You should go buy the books [here](https://www.drivethrurpg.com/browse/pub/6/Fantasy-Flight-Games/subcategory/36_28812/Legend-of-the-Five-Rings-5th-Edition), or at your friendly local game store.

Ring images are property of FFG, and were originally created for the original Legend of the Five Rings card game by AEG (1995). Some assets used here were taken from www.imperialadvisor.com (originally created by u/mproud on Reddit) and modified to work with the application; these can be removed immediately upon request by any owning party.

Sakura imagery is from http://pngimg.com/download/49821, licensed under [Creative Commons BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). The icon is a modified version of "sakura" by Pham Duy Phuong Hung from [the Noun Project](https://thenounproject.com/term/sakura/1565575/), also CC licensed. Bundled fonts (Roboto, Caveat, DejaVu Sans) are under their respective licenses in `assets/fonts/`.

## License

[GPLv3](LICENSE), same as the original project.

## Thanks and Contributor List

Thanks to our users, bug reporters, contributors, well wishers, and (of course) to the folks that have produced this excellent game (current AND prior editions)!

Since Github is not always good about listing who has helped out on a project (and many of those contributions were on the original application), I wanted to do so. The following handles have contributed to Paper Blossoms -- thanks for your contributions!

* dashnine
* meow9th
* aajabrams
* OpenNinjia
* MJKruszewski
* Cvelth
* ruronin (French UI & DB Translation)
* Albertorius (Spanish UI & DB Translation)
* Tylsar (German UI & DB Translation)
