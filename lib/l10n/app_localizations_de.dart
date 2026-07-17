// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Paper Blossoms';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get importCharacterTooltip => 'Charakter importieren';

  @override
  String get newCharacter => 'Neuer Charakter';

  @override
  String get noCharactersYet =>
      'Noch keine Charaktere.\nErstelle einen, um deine Geschichte zu beginnen.';

  @override
  String deleteCharacterTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteCannotBeUndone =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String rankN(int rank) {
    return 'Rang $rank';
  }

  @override
  String get toolsTitle => 'Werkzeuge';

  @override
  String get languageSection => 'Sprache';

  @override
  String get appearanceSection => 'Erscheinungsbild';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get rulesTextSection => 'Regeltexte';

  @override
  String get editRulesDescriptions => 'Regelbeschreibungen bearbeiten';

  @override
  String get editRulesDescriptionsSubtitle =>
      'Die mitgelieferten Daten enthalten keine Regeltexte. Wenn du die Bücher besitzt, kannst du hier eigene Beschreibungen eintragen; sie erscheinen im Editor und auf dem PDF-Bogen.';

  @override
  String get importDescriptions => 'Beschreibungen importieren…';

  @override
  String get importDescriptionsSubtitle =>
      'Beschreibungen aus einer exportierten JSON-Datei oder der user_descriptions.csv des ursprünglichen Paper Blossoms zusammenführen; importierte Einträge überschreiben gleichnamige.';

  @override
  String get exportDescriptions => 'Beschreibungen exportieren…';

  @override
  String get exportDescriptionsSubtitle =>
      'Alle Beschreibungen zur Sicherung oder Weitergabe in eine JSON-Datei speichern.';

  @override
  String get homebrewSection => 'Eigene Inhalte';

  @override
  String get homebrewFolder => 'Homebrew-Ordner';

  @override
  String homebrewFolderSubtitle(String path) {
    return '$path\n\nLege JSON-Dateien mit denselben Namen wie die mitgelieferten Daten (weapons.json, titles.json, techniques.json, …) und derselben Struktur ab; die Einträge werden beim Start nach den offiziellen Inhalten eingebunden.';
  }

  @override
  String get reloadHomebrew => 'Homebrew jetzt neu laden';

  @override
  String get nothingMergedThisSession =>
      'In dieser Sitzung nichts eingebunden.';

  @override
  String mergedFiles(String files) {
    return 'Eingebunden: $files';
  }

  @override
  String get noHomebrewFilesFound => 'Keine Homebrew-Dateien gefunden.';

  @override
  String importedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beschreibungen importiert.',
      one: '1 Beschreibung importiert.',
    );
    return '$_temp0';
  }

  @override
  String exportedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beschreibungen exportiert.',
      one: '1 Beschreibung exportiert.',
    );
    return '$_temp0';
  }

  @override
  String get couldNotReadDescriptionsFile =>
      'Die Datei konnte nicht als Beschreibungs-JSON oder -CSV gelesen werden.';

  @override
  String get noDescriptionsToExport => 'Keine Beschreibungen zum Exportieren.';

  @override
  String get tabCharacter => 'Charakter';

  @override
  String get tabBackground => 'Hintergrund';

  @override
  String get tabTraits => 'Merkmale';

  @override
  String get tabBonds => 'Bindungen';

  @override
  String get tabTechniques => 'Techniken';

  @override
  String get tabEquipment => 'Ausrüstung';

  @override
  String get tabAdvancement => 'Entwicklung';

  @override
  String get unnamedSamurai => 'Namenloser Samurai';

  @override
  String get saved => 'Gespeichert';

  @override
  String get save => 'Speichern';

  @override
  String get saveUnsavedTooltip => 'Speichern (ungespeicherte Änderungen)';

  @override
  String get exportTooltip => 'Exportieren';

  @override
  String get printExportPdf => 'PDF-Bogen drucken / exportieren…';

  @override
  String get shareCharacterJson => 'Charakter-JSON teilen…';

  @override
  String get fullSkillTableOnSheet =>
      'Vollständige Fähigkeitentabelle auf dem Bogen';

  @override
  String get portraitOnSheet => 'Porträt auf dem Bogen';

  @override
  String get unsavedChanges => 'Ungespeicherte Änderungen';

  @override
  String get saveBeforeClosing =>
      'Diesen Charakter vor dem Schließen speichern?';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discard => 'Verwerfen';

  @override
  String get saveAndClose => 'Speichern & schließen';

  @override
  String get characterExported => 'Charakter exportiert.';

  @override
  String get nameLabel => 'Name';

  @override
  String get familyLabel => 'Familie';

  @override
  String get noClan => 'Kein Klan';

  @override
  String get noSchool => 'Keine Schule';

  @override
  String get socialStandingSection => 'Gesellschaftliche Stellung';

  @override
  String get honor => 'Ehre';

  @override
  String get glory => 'Ruhm';

  @override
  String get statusLabel => 'Status';

  @override
  String get wealthSection => 'Vermögen';

  @override
  String get koku => 'Koku';

  @override
  String get bu => 'Bu';

  @override
  String get zeni => 'Zeni';

  @override
  String get abilitiesSection => 'Fertigkeiten';

  @override
  String get noAbilitiesYet => 'Noch keine Fertigkeiten.';

  @override
  String get ringsSection => 'Ringe';

  @override
  String get derivedAttributesSection => 'Abgeleitete Werte';

  @override
  String get endurance => 'Ausdauer';

  @override
  String get composure => 'Gelassenheit';

  @override
  String get focusStat => 'Fokus';

  @override
  String get vigilance => 'Wachsamkeit';

  @override
  String get schoolRank => 'Schulrang';

  @override
  String get fatigueStrifeSection => 'Erschöpfung & Zwist';

  @override
  String fatigueOf(int max) {
    return 'Erschöpfung / $max';
  }

  @override
  String strifeOf(int max) {
    return 'Zwist / $max';
  }

  @override
  String get clearAllFatigue => 'Gesamte Erschöpfung entfernen';

  @override
  String get recover => 'Erholen';

  @override
  String get clearAllStrife => 'Gesamten Zwist entfernen';

  @override
  String get unmask => 'Demaskieren';

  @override
  String get conditionsSection => 'Zustände';

  @override
  String get addCondition => 'Zustand hinzufügen';

  @override
  String get noConditions => 'Keine Zustände.';

  @override
  String get incapacitatedRule =>
      'Erschöpfung übersteigt Ausdauer: keine Aktionen mit Proben und kein Verteidigen gegen Schaden.';

  @override
  String get compromisedRule =>
      'Zwist übersteigt Gelassenheit: Würfel mit Zwist-Symbolen können nicht behalten werden; Wachsamkeit zählt als 1.';

  @override
  String get criticalStrike => 'Kritischer Treffer…';

  @override
  String get skillsSection => 'Fähigkeiten';

  @override
  String get heritageSection => 'Herkunft';

  @override
  String get ninjoSection => 'Ninjō (persönliches Verlangen)';

  @override
  String get giriSection => 'Giri (Pflicht)';

  @override
  String get notesSection => 'Notizen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get undo => 'Rückgängig';

  @override
  String removedName(String name) {
    return 'Entfernt: $name';
  }

  @override
  String get unknownCustomSection => 'Unbekannt (eigene oder fehlende Daten)';

  @override
  String get bondsSection => 'Bindungen';

  @override
  String get addBond => 'Bindung hinzufügen';

  @override
  String get noBondsYet =>
      'Noch keine Bindungen geknüpft — tippe auf +, um eine hinzuzufügen.';

  @override
  String get rankLabel => 'Rang';

  @override
  String get techniquesSection => 'Techniken';

  @override
  String get noTechniquesYet => 'Noch keine Techniken bekannt.';

  @override
  String restrictionLabel(String restriction) {
    return 'Einschränkung: $restriction';
  }

  @override
  String get customOrUnknownTechnique => 'Eigene oder unbekannte Technik';

  @override
  String get weaponsSection => 'Waffen';

  @override
  String get armorSection => 'Rüstung';

  @override
  String get personalEffectsSection => 'Persönliche Gegenstände';

  @override
  String get addItem => 'Gegenstand hinzufügen';

  @override
  String get noWeaponsYet =>
      'Noch keine Waffen — tippe auf +, um eine hinzuzufügen.';

  @override
  String get noArmorYet =>
      'Noch keine Rüstung — tippe auf +, um eine hinzuzufügen.';

  @override
  String get noPersonalEffectsYet =>
      'Noch keine persönlichen Gegenstände — tippe auf +, um einen hinzuzufügen.';

  @override
  String gripStats(
    String grip,
    int min,
    int max,
    String damage,
    String deadliness,
  ) {
    return '$grip: Reichweite $min-$max · Sch. $damage · Tdl. $deadliness';
  }

  @override
  String armorStats(int physical, int supernatural) {
    return 'Physisch $physical · Übernatürlich $supernatural';
  }

  @override
  String priceLine(int price, String unit, int rarity) {
    return '$price $unit · Seltenheit $rarity';
  }

  @override
  String get colName => 'Name';

  @override
  String get colCategory => 'Kategorie';

  @override
  String get colSkill => 'Fähigkeit';

  @override
  String get colGrip => 'Griff';

  @override
  String get colRange => 'Reichweite';

  @override
  String get colDamage => 'Sch.';

  @override
  String get colDeadliness => 'Tdl.';

  @override
  String get colQualities => 'Eigenschaften';

  @override
  String get colPhysical => 'Physisch';

  @override
  String get colSupernatural => 'Übernatürlich';

  @override
  String addedAdvanceRankUp(String name, int rank) {
    return '$name hinzugefügt — Schulrang ist jetzt $rank!';
  }

  @override
  String addedAdvance(String name, int cost, String track) {
    return '$name hinzugefügt — $cost EP ($track)';
  }

  @override
  String get xpInRank => 'EP im Rang';

  @override
  String get xpSpentLabel => 'Ausgegebene EP';

  @override
  String get noTitleInProgress => 'Kein Titel in Arbeit';

  @override
  String currentTitleLine(String title, int xp, int total) {
    return 'Aktueller Titel: $title — $xp / $total EP';
  }

  @override
  String curriculumSection(String school) {
    return 'Lehrplan — $school';
  }

  @override
  String get noSchoolFallback => 'keine Schule';

  @override
  String get addAdvance => 'Steigerung hinzufügen';

  @override
  String get noSchoolNoCurriculum =>
      'Keine Schule gewählt, daher gibt es keinen Lehrplan.';

  @override
  String get currentLabel => 'aktuell';

  @override
  String skillRankLabel(int rank) {
    return 'Rang $rank';
  }

  @override
  String get specialAccess => 'Sonderzugang';

  @override
  String ranksRange(int min, int max) {
    return 'Ränge $min-$max';
  }

  @override
  String get atRank5 => 'Bei Rang 5';

  @override
  String get alreadyLearnedLabel => 'Bereits erlernt';

  @override
  String get buyThisAdvance => 'Diese Steigerung kaufen';

  @override
  String get titlesSection => 'Titel';

  @override
  String get addTitle => 'Titel hinzufügen';

  @override
  String get finishCurrentTitleFirst =>
      'Schließe zuerst den aktuellen Titel ab';

  @override
  String get noTitlesYet =>
      'Noch keine Titel — tippe auf +, um einen hinzuzufügen.';

  @override
  String get inProgressLabel => 'In Arbeit';

  @override
  String completedWithAbility(String ability) {
    return 'Abgeschlossen — $ability';
  }

  @override
  String maxRankLabel(int rank) {
    return 'max. Rang $rank';
  }

  @override
  String get advancesTakenSection => 'Gekaufte Steigerungen';

  @override
  String get noAdvancesYet =>
      'Noch keine Steigerungen gekauft — tippe auf + oder einen Lehrplan-Eintrag.';

  @override
  String advanceSubtitle(String type, String track, int cost) {
    return '$type · $track · $cost EP';
  }

  @override
  String get addAdvanceTitle => 'Steigerung hinzufügen';

  @override
  String get advTypeSkill => 'Fähigkeit';

  @override
  String get advTypeRing => 'Ring';

  @override
  String get advTypeTechnique => 'Technik';

  @override
  String get advanceSection => 'Steigerung';

  @override
  String get groupLabel => 'Gruppe';

  @override
  String get allGroups => 'Alle Gruppen';

  @override
  String get mahoWarning =>
      'Mahō ist verboten. Es zu erlernen hat Konsequenzen.';

  @override
  String get typeToFilter => 'Zum Filtern tippen';

  @override
  String get clearFilter => 'Filter löschen';

  @override
  String techSubtitle(String subcategory, int rank, int xp) {
    return '$subcategory · Rang $rank · $xp EP';
  }

  @override
  String get ignoreRestrictions =>
      'Einschränkungen ignorieren (Rang, Schulzugang)';

  @override
  String get trackSection => 'Konto';

  @override
  String get trackCurriculumLabel => 'Lehrplan';

  @override
  String get trackTitleLabel => 'Titel';

  @override
  String get trackFreeLabel => 'Frei (keine EP-Kosten)';

  @override
  String get reasonOptional => 'Grund (optional)';

  @override
  String get halfXpLabel => 'Halbe EP (Schul-/Titelrabatt)';

  @override
  String get chooseAnAdvance => 'Wähle eine Steigerung.';

  @override
  String alreadyLearnedError(String name) {
    return '„$name“ ist bereits erlernt.';
  }

  @override
  String costXp(int cost) {
    return 'Kosten: $cost EP';
  }

  @override
  String get addItemTitle => 'Gegenstand hinzufügen';

  @override
  String get itemWeapon => 'Waffe';

  @override
  String get itemArmor => 'Rüstung';

  @override
  String get itemPersonalEffect => 'Persönlicher Gegenstand';

  @override
  String get chooseWeapon => 'Waffe wählen';

  @override
  String get chooseArmor => 'Rüstung wählen';

  @override
  String get choosePersonalEffect => 'Persönlichen Gegenstand wählen';

  @override
  String weaponPickSubtitle(
    String category,
    String skill,
    String damage,
    String deadliness,
  ) {
    return '$category · $skill · Sch. $damage · Tdl. $deadliness';
  }

  @override
  String get chooseFromBook => 'Aus dem Buch wählen…';

  @override
  String get changeBaseItem => 'Basisgegenstand ändern…';

  @override
  String get customItem => 'Eigener Gegenstand';

  @override
  String get detailsSection => 'Details';

  @override
  String get priceLabel => 'Preis';

  @override
  String get rarityLabel => 'Seltenheit';

  @override
  String get qualitiesCommaSeparated => 'Eigenschaften (durch Komma getrennt)';

  @override
  String addNGrips(int count) {
    return 'Hinzufügen ($count Griffe)';
  }

  @override
  String gripEditorLabel(String grip) {
    return 'Griff: $grip';
  }

  @override
  String get minRange => 'Min. Reichweite';

  @override
  String get maxRange => 'Max. Reichweite';

  @override
  String get damageLabel => 'Schaden';

  @override
  String get deadlinessLabel => 'Tödlichkeit';

  @override
  String get addTrait => 'Merkmal hinzufügen';

  @override
  String addCategoryLower(String category) {
    return '$category hinzufügen';
  }

  @override
  String get addBondTitle => 'Bindung hinzufügen';

  @override
  String get addTitleTitle => 'Titel hinzufügen';

  @override
  String xpAmount(int xp) {
    return '$xp EP';
  }

  @override
  String get criticalStrikeTitle => 'Kritischer Treffer';

  @override
  String get severityLabel => 'Schweregrad (Tödlichkeit der Quelle)';

  @override
  String get razorEdgedLabel => 'Angriff war mit scharfer Klinge';

  @override
  String get ringUsedToResist => 'Ring zum Widerstehen';

  @override
  String get ringResistHelper =>
      'Haltungsring im Konflikt, beliebiger in einer Szene';

  @override
  String get tnFitnessCheck => 'ZW-1-Fitness-Probe geschafft';

  @override
  String get rollOwnDice => 'Würfle selbst und trage das Ergebnis ein';

  @override
  String get bonusSuccessesLabel =>
      'Bonus-Erfolge (je −1 Schweregrad, zusätzlich zu −1)';

  @override
  String finalSeverityLine(int severity, String band) {
    return 'Endgültiger Schweregrad $severity — $band';
  }

  @override
  String get apply => 'Anwenden';

  @override
  String chooseScarTitle(String band, String ring) {
    return '$band: wähle eine Narbe ($ring)';
  }

  @override
  String severityResult(int severity, String band, String effect) {
    return 'Schweregrad $severity: $band — $effect';
  }

  @override
  String get rulesDescriptionsTitle => 'Regelbeschreibungen';

  @override
  String get shortDescriptionLabel => 'Kurzbeschreibung';

  @override
  String get fullDescriptionLabel => 'Vollständige Beschreibung';

  @override
  String get searchHint => 'Suchen…';

  @override
  String get withText => 'Mit Text';

  @override
  String get wizPart1 => 'Teil 1: Klan und Familie';

  @override
  String get wizPart2 => 'Teil 2: Rolle und Schule';

  @override
  String get wizPart3 => 'Teil 3: Ehre und Ruhm';

  @override
  String get wizPart4 => 'Teil 4: Stärken und Schwächen';

  @override
  String get wizPart5 => 'Teil 5: Persönlichkeit und Verhalten';

  @override
  String get wizPart6 => 'Teil 6: Abstammung und Familie';

  @override
  String get wizPart7 => 'Teil 7: Tod';

  @override
  String get wizErrChooseClan => 'Wähle einen Klan (Frage 1).';

  @override
  String get wizErrChooseFamily => 'Wähle eine Familie (Frage 2).';

  @override
  String get wizErrChooseFamilyRing =>
      'Wähle die Ringsteigerung deiner Familie.';

  @override
  String get wizErrChooseRegion => 'Wähle eine Region (Frage 1).';

  @override
  String get wizErrChooseUpbringing => 'Wähle eine Erziehung (Frage 2).';

  @override
  String get wizErrChooseUpbringingRing =>
      'Wähle die Ringsteigerung deiner Erziehung.';

  @override
  String wizErrChooseUpbringingSkill(int n) {
    return 'Wähle Erziehungsfähigkeit $n.';
  }

  @override
  String get wizErrChooseSchool => 'Wähle eine Schule.';

  @override
  String get wizErrInsufficientSkills =>
      'Nicht genügend Fähigkeiten ausgewählt.';

  @override
  String get wizErrSchoolRings => 'Wähle die Ringsteigerungen deiner Schule.';

  @override
  String get wizErrStandoutRing => 'Wähle deinen herausragenden Ring.';

  @override
  String get wizErrStartingTechniques => 'Wähle deine Anfangstechniken.';

  @override
  String get wizErrQ7Option => 'Wähle eine Option für Frage 7.';

  @override
  String get wizErrQ7Skill => 'Wähle eine Fähigkeit für Frage 7.';

  @override
  String get wizErrQ8Option => 'Wähle eine Option für Frage 8.';

  @override
  String get wizErrQ8Skill => 'Wähle eine Fähigkeit für Frage 8.';

  @override
  String get wizErrQ8Item => 'Wähle einen Gegenstand für Frage 8.';

  @override
  String get wizErrDistinction => 'Wähle eine Auszeichnung (Frage 9).';

  @override
  String get wizErrAdversity => 'Wähle eine Widrigkeit (Frage 10).';

  @override
  String get wizErrPassion => 'Wähle eine Leidenschaft (Frage 11).';

  @override
  String get wizErrAnxiety => 'Wähle eine Angst (Frage 12).';

  @override
  String get wizErrQ13Option => 'Wähle eine Option für Frage 13.';

  @override
  String get wizErrQ13Advantage => 'Wähle einen Vorteil für Frage 13.';

  @override
  String get wizErrQ13DisadvSkill =>
      'Wähle einen Nachteil und eine Fähigkeit für Frage 13.';

  @override
  String get wizErrQ16Item => 'Wähle ein Andenken für Frage 16.';

  @override
  String get wizErrReplacementRings => 'Bitte wähle Ersatzring(e).';

  @override
  String get wizErrReplacementSkills => 'Bitte wähle Ersatzfähigkeit(en).';

  @override
  String get wizDiscardTitle => 'Diesen Charakter verwerfen?';

  @override
  String get wizDiscardBody => 'Deine bisherigen Antworten gehen verloren.';

  @override
  String get wizSummaryTooltip => 'Bisherige Ringe & Fähigkeiten';

  @override
  String get wizNoSkillsYet => 'Noch keine Fähigkeiten.';

  @override
  String wizStepOf(int page, int total) {
    return 'Schritt $page von $total';
  }

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Fertigstellen';

  @override
  String get characterTypeLabel => 'Charaktertyp';

  @override
  String get wizQ1Clan => '1. Welchem Klan gehört dein Charakter an?';

  @override
  String get clanLabel => 'Klan';

  @override
  String clanStatsLine(
    String ring,
    String skill,
    int status,
    String reference,
  ) {
    return '+1 $ring · +1 $skill · Status $status · $reference';
  }

  @override
  String get wizQ2Family => '2. Welcher Familie gehört dein Charakter an?';

  @override
  String familyStatsLine(String skills, int glory, int wealth) {
    return '+1 $skills · Ruhm $glory · Vermögen $wealth Koku';
  }

  @override
  String get familyRingIncrease => 'Ringsteigerung der Familie';

  @override
  String get wizQ1Region => '1. Woher stammt dein Charakter?';

  @override
  String get regionLabel => 'Region';

  @override
  String get wizQ2Upbringing => '2. Wie wurde dein Charakter erzogen?';

  @override
  String get upbringingLabel => 'Erziehung';

  @override
  String get upbringingRingIncrease => 'Ringsteigerung der Erziehung';

  @override
  String upbringingSkillN(int n) {
    return 'Erziehungsfähigkeit $n';
  }

  @override
  String get wizQ3Samurai =>
      '3. Welche Schule besucht dein Charakter, und welchen Rollen ist sie zugeordnet?';

  @override
  String get wizQ3Ronin =>
      '3. Welche Schule besucht dein Charakter, und welche Rollen sind mit ihr verbunden?';

  @override
  String get showSchoolsOutsideClan =>
      'Schulen außerhalb meines Klans anzeigen';

  @override
  String get schoolLabel => 'Schule';

  @override
  String schoolStatsLine(String roles, int honor, String reference) {
    return '$roles · Ehre $honor · $reference';
  }

  @override
  String get kitsuneImpersonate => 'Zu imitierende Schule (Ausrüstungsquelle)';

  @override
  String get additionalBurden => 'Zusätzliche Bürde';

  @override
  String chooseSchoolSkills(int size, int chosen) {
    return 'Wähle $size Schulfähigkeiten ($chosen gewählt)';
  }

  @override
  String get schoolRingIncreases => 'Ringsteigerungen der Schule';

  @override
  String fixedRings(String rings) {
    return 'Fest: +1 $rings';
  }

  @override
  String get ringOfYourChoice => 'Ring deiner Wahl';

  @override
  String get wizQ4Samurai =>
      '4. Wodurch stichst du in deiner Schule hervor? (+1 Ring)';

  @override
  String get wizQ4Ronin =>
      '4. Was bringt dich in Schwierigkeiten und wieder heraus? (+1 Ring)';

  @override
  String get standoutRing => 'Herausragender Ring';

  @override
  String get describeIt => 'Beschreibe es';

  @override
  String startingTechniqueFixed(String name) {
    return 'Anfangstechnik: $name';
  }

  @override
  String get chooseStartingTechnique => 'Wähle eine Anfangstechnik';

  @override
  String get startingOutfit => 'Anfangsausrüstung';

  @override
  String get chooseAnItem => 'Wähle einen Gegenstand';

  @override
  String includedItems(String items) {
    return 'Enthalten: $items';
  }

  @override
  String get wizQ5Samurai =>
      '5. Wer ist dein Herr, und worin besteht deine Pflicht ihm gegenüber? (Giri)';

  @override
  String get wizQ5Ronin =>
      '5. Was ist deine Vergangenheit, und wie beeinflusst sie dich?';

  @override
  String get answerLabel => 'Antwort';

  @override
  String get wizQ6Samurai =>
      '6. Wonach sehnst du dich, und wie könnte das deiner Pflicht im Weg stehen? (Ninjō)';

  @override
  String get wizQ6Ronin =>
      '6. Wonach sehnst du dich, und wie könnte deine Vergangenheit dein Ninjō beeinflussen?';

  @override
  String get wizQ7Samurai =>
      '7. In welchem Verhältnis stehst du zu deinem Klan?';

  @override
  String get wizQ7Ronin => '7. Wofür bist du bekannt?';

  @override
  String get q7Positive => 'Positiv (+5 Ruhm)';

  @override
  String get q7Negative =>
      'Negativ (+1 Rang in einer Fähigkeit, die du nicht besitzt)';

  @override
  String get wizQ8 => '8. Was hältst du von Bushidō?';

  @override
  String get q8Pos => 'Streng orthodoxer Glaube (+10 Ehre)';

  @override
  String get q8Mid =>
      'Pragmatischer Überlebenskünstler (ein Gegenstand mit Seltenheit 5 oder niedriger)';

  @override
  String get q8Neg => 'Weicht vom allgemeinen Glauben ab (+1 Fähigkeitsrang)';

  @override
  String get itemLabel => 'Gegenstand';

  @override
  String get wizQ9 => '9. Was ist bisher deine größte Leistung? (Auszeichnung)';

  @override
  String get distinctionLabel => 'Auszeichnung';

  @override
  String get wizQ10 => '10. Was hält deinen Charakter zurück? (Widrigkeit)';

  @override
  String get adversityLabel => 'Widrigkeit';

  @override
  String get wizQ11 =>
      '11. Bei welcher Tätigkeit findest du inneren Frieden? (Leidenschaft)';

  @override
  String get passionLabel => 'Leidenschaft';

  @override
  String get wizQ12 =>
      '12. Welche Sorge oder Angst raubt dir nachts den Schlaf? (Angst)';

  @override
  String get anxietyLabel => 'Angst';

  @override
  String get wizQ13 =>
      '13. Wem vertraust du am meisten, und welcher Art ist diese Beziehung?';

  @override
  String get q13GainAdvantage => 'Einen Vorteil erhalten';

  @override
  String get q13GainDisadvantage =>
      'Einen Nachteil und +1 Fähigkeitsrang erhalten';

  @override
  String get advantageLabel => 'Vorteil';

  @override
  String get disadvantageLabel => 'Nachteil';

  @override
  String get describeRelationship => 'Beschreibe die Beziehung';

  @override
  String get wizQ14Samurai =>
      '14. Was fällt anderen bei einer Begegnung zuerst an dir auf?';

  @override
  String get wizQ14Ronin =>
      '14. Was ist der wertvollste Besitz deines Charakters?';

  @override
  String get possessionRarity5 => 'Besitz (Seltenheit 5 oder niedriger)';

  @override
  String get wizQ15 => '15. Wie reagierst du auf Stresssituationen?';

  @override
  String get wizQ16Samurai =>
      '16. Welche Beziehungen hast du bereits zu anderen Klans, Familien, Organisationen und Traditionen?';

  @override
  String get wizQ16Ronin =>
      '16. In welchem Verhältnis stehst du zu deiner Familie, den Klans, den Bauern und anderen?';

  @override
  String get mementoRarity7 => 'Andenken (Seltenheit 7 oder niedriger)';

  @override
  String get describeThem => 'Beschreibe sie';

  @override
  String get wizQ17Parents =>
      '17. Wie würden deine Eltern dich beschreiben? (+1 Fähigkeitsrang)';

  @override
  String get wizQ17Raised =>
      '18. Wer hat dich großgezogen? (+1 Fähigkeitsrang)';

  @override
  String get wizQ17Bond => '17. Mit wem teilst du eine Bindung?';

  @override
  String get bondLabel => 'Bindung';

  @override
  String get wizQ18Ancestry =>
      '18. Worin besteht deine Pflicht gegenüber deiner Familie, und welchem deiner Ahnen eiferst du nach?';

  @override
  String get heritageTable => 'Herkunftstabelle';

  @override
  String ancestorN(int n) {
    return 'Ahne $n';
  }

  @override
  String get rollTooltip => 'Würfeln (1W10)';

  @override
  String heritageHeader(String name) {
    return 'Herkunft: $name';
  }

  @override
  String grantedLabel(String name) {
    return 'Erhalten: $name';
  }

  @override
  String get bonusSkill => 'Bonusfähigkeit';

  @override
  String get traitGained => 'Erhaltenes Merkmal';

  @override
  String get heirloomCategory => 'Erbstück-Kategorie';

  @override
  String get lostHeirloomCategory => 'Kategorie des verlorenen Erbstücks';

  @override
  String get techniqueGroupLabel => 'Technikgruppe';

  @override
  String get effectLabel => 'Effekt';

  @override
  String get giftLabel => 'Geschenk';

  @override
  String get ringToRaise => 'Zu erhöhender Ring';

  @override
  String get ringToLower => 'Zu senkender Ring';

  @override
  String get qualityYourChoice => 'Eigenschaft (deine Wahl)';

  @override
  String get qualityGmChoice => 'Eigenschaft (Wahl der SL)';

  @override
  String get wizQ19 => '19. Wie lautet dein Name?';

  @override
  String get personalNameLabel => 'Persönlicher Name';

  @override
  String get wizQ20 => '20. Wie sollte dein Charakter sterben?';

  @override
  String get answerOptional => 'Antwort (optional)';

  @override
  String ringOverflowMsg(int n) {
    return 'Ein Ring übersteigt die Erschaffungsgrenze von 3. Wähle $n Ersatzring(e):';
  }

  @override
  String skillOverflowMsg(int n) {
    return 'Eine Fähigkeit übersteigt die Erschaffungsgrenze von 3. Wähle $n Ersatzfähigkeit(en):';
  }

  @override
  String replacementRingN(int n) {
    return 'Ersatzring $n';
  }

  @override
  String replacementSkillN(int n) {
    return 'Ersatzfähigkeit $n';
  }

  @override
  String get readyHeader => 'Bereit';

  @override
  String get finishCreates =>
      '„Fertigstellen“ erstellt den Charakter und öffnet den Editor.';

  @override
  String get ok => 'OK';

  @override
  String get tapToTypeValue => 'Tippen, um einen Wert einzugeben';

  @override
  String get unlockIdentityTooltip =>
      'Name, Familie, Ninjō und Giri entsperren';

  @override
  String get lockIdentityTooltip => 'Name, Familie, Ninjō und Giri sperren';

  @override
  String get changePortraitTooltip =>
      'Tippen zum Ändern des Porträts, lange drücken zum Entfernen';

  @override
  String get addPortraitTooltip => 'Tippen, um ein Porträt hinzuzufügen';

  @override
  String get pdfFatigueStrifeConditions => 'Erschöpfung, Zwist & Zustände';

  @override
  String get pdfWealthProgress => 'Vermögen & Fortschritt';

  @override
  String pdfWealthLine(
    int koku,
    int bu,
    int zeni,
    int spent,
    int total,
    int inRank,
  ) {
    return 'Vermögen: $koku Koku, $bu Bu, $zeni Zeni    ·    EP: $spent ausgegeben / $total gesamt    ·    EP im Rang: $inRank';
  }

  @override
  String pdfTitlePart(String title, int xp) {
    return '    ·    Titel: $title ($xp EP)';
  }

  @override
  String get pdfTraitsHeader => 'Auszeichnungen & Widrigkeiten';

  @override
  String get colAbility => 'Fertigkeit';

  @override
  String get ninjoHeader => 'Ninjō';

  @override
  String get giriHeader => 'Giri';
}
