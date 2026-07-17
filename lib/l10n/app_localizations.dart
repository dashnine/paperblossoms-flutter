import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Paper Blossoms'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @importCharacterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import character'**
  String get importCharacterTooltip;

  /// No description provided for @newCharacter.
  ///
  /// In en, this message translates to:
  /// **'New Character'**
  String get newCharacter;

  /// No description provided for @noCharactersYet.
  ///
  /// In en, this message translates to:
  /// **'No characters yet.\nCreate one to begin your story.'**
  String get noCharactersYet;

  /// No description provided for @deleteCharacterTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteCharacterTitle(String name);

  /// No description provided for @deleteCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteCannotBeUndone;

  /// No description provided for @rankN.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String rankN(int rank);

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @rulesTextSection.
  ///
  /// In en, this message translates to:
  /// **'Rules text'**
  String get rulesTextSection;

  /// No description provided for @editRulesDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Edit rules descriptions'**
  String get editRulesDescriptions;

  /// No description provided for @editRulesDescriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The bundled data ships no rules text. If you own the books, enter your own descriptions here; they appear in the editor and on the PDF sheet.'**
  String get editRulesDescriptionsSubtitle;

  /// No description provided for @importDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Import descriptions…'**
  String get importDescriptions;

  /// No description provided for @importDescriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Merge descriptions from an exported JSON file or the original Paper Blossoms user_descriptions.csv; imported entries overwrite same-name ones.'**
  String get importDescriptionsSubtitle;

  /// No description provided for @exportDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Export descriptions…'**
  String get exportDescriptions;

  /// No description provided for @exportDescriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all descriptions to a JSON file for backup or sharing.'**
  String get exportDescriptionsSubtitle;

  /// No description provided for @homebrewSection.
  ///
  /// In en, this message translates to:
  /// **'Homebrew content'**
  String get homebrewSection;

  /// No description provided for @homebrewFolder.
  ///
  /// In en, this message translates to:
  /// **'Homebrew folder'**
  String get homebrewFolder;

  /// No description provided for @homebrewFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{path}\n\nDrop JSON files named like the bundled data (weapons.json, titles.json, techniques.json, …) with the same structure; entries are merged after the official content on launch.'**
  String homebrewFolderSubtitle(String path);

  /// No description provided for @reloadHomebrew.
  ///
  /// In en, this message translates to:
  /// **'Reload homebrew now'**
  String get reloadHomebrew;

  /// No description provided for @nothingMergedThisSession.
  ///
  /// In en, this message translates to:
  /// **'Nothing merged this session.'**
  String get nothingMergedThisSession;

  /// No description provided for @mergedFiles.
  ///
  /// In en, this message translates to:
  /// **'Merged: {files}'**
  String mergedFiles(String files);

  /// No description provided for @noHomebrewFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No homebrew files found.'**
  String get noHomebrewFilesFound;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Paper Blossoms'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, credits, and licenses.'**
  String get aboutAppSubtitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'A character generator for Legend of the Five Rings 5th Edition.'**
  String get aboutTagline;

  /// No description provided for @aboutPortNote.
  ///
  /// In en, this message translates to:
  /// **'A Flutter port of the original PaperBlossoms desktop application, by the same developer.'**
  String get aboutPortNote;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Fan-made and unaffiliated with Fantasy Flight Games, Edge Studio, or Asmodee. Legend of the Five Rings and all associated content are property of Fantasy Flight Games.'**
  String get aboutLegalese;

  /// No description provided for @importedDescriptions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 description.} other{Imported {count} descriptions.}}'**
  String importedDescriptions(int count);

  /// No description provided for @exportedDescriptions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 description.} other{Exported {count} descriptions.}}'**
  String exportedDescriptions(int count);

  /// No description provided for @couldNotReadDescriptionsFile.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that file as descriptions JSON or CSV.'**
  String get couldNotReadDescriptionsFile;

  /// No description provided for @noDescriptionsToExport.
  ///
  /// In en, this message translates to:
  /// **'No descriptions to export.'**
  String get noDescriptionsToExport;

  /// No description provided for @tabCharacter.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get tabCharacter;

  /// No description provided for @tabBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get tabBackground;

  /// No description provided for @tabTraits.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get tabTraits;

  /// No description provided for @tabBonds.
  ///
  /// In en, this message translates to:
  /// **'Bonds'**
  String get tabBonds;

  /// No description provided for @tabTechniques.
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get tabTechniques;

  /// No description provided for @tabEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get tabEquipment;

  /// No description provided for @tabAdvancement.
  ///
  /// In en, this message translates to:
  /// **'Advancement'**
  String get tabAdvancement;

  /// No description provided for @unnamedSamurai.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Samurai'**
  String get unnamedSamurai;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveUnsavedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save (unsaved changes)'**
  String get saveUnsavedTooltip;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTooltip;

  /// No description provided for @printExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Print / export PDF sheet…'**
  String get printExportPdf;

  /// No description provided for @shareCharacterJson.
  ///
  /// In en, this message translates to:
  /// **'Share character JSON…'**
  String get shareCharacterJson;

  /// No description provided for @fullSkillTableOnSheet.
  ///
  /// In en, this message translates to:
  /// **'Full skill table on sheet'**
  String get fullSkillTableOnSheet;

  /// No description provided for @portraitOnSheet.
  ///
  /// In en, this message translates to:
  /// **'Portrait on sheet'**
  String get portraitOnSheet;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @saveBeforeClosing.
  ///
  /// In en, this message translates to:
  /// **'Save this character before closing?'**
  String get saveBeforeClosing;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save & close'**
  String get saveAndClose;

  /// No description provided for @characterExported.
  ///
  /// In en, this message translates to:
  /// **'Character exported.'**
  String get characterExported;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @familyLabel.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyLabel;

  /// No description provided for @noClan.
  ///
  /// In en, this message translates to:
  /// **'No clan'**
  String get noClan;

  /// No description provided for @noSchool.
  ///
  /// In en, this message translates to:
  /// **'No school'**
  String get noSchool;

  /// No description provided for @socialStandingSection.
  ///
  /// In en, this message translates to:
  /// **'Social Standing'**
  String get socialStandingSection;

  /// No description provided for @honor.
  ///
  /// In en, this message translates to:
  /// **'Honor'**
  String get honor;

  /// No description provided for @glory.
  ///
  /// In en, this message translates to:
  /// **'Glory'**
  String get glory;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @wealthSection.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get wealthSection;

  /// No description provided for @koku.
  ///
  /// In en, this message translates to:
  /// **'Koku'**
  String get koku;

  /// No description provided for @bu.
  ///
  /// In en, this message translates to:
  /// **'Bu'**
  String get bu;

  /// No description provided for @zeni.
  ///
  /// In en, this message translates to:
  /// **'Zeni'**
  String get zeni;

  /// No description provided for @abilitiesSection.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get abilitiesSection;

  /// No description provided for @noAbilitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No abilities yet.'**
  String get noAbilitiesYet;

  /// No description provided for @ringsSection.
  ///
  /// In en, this message translates to:
  /// **'Rings'**
  String get ringsSection;

  /// No description provided for @derivedAttributesSection.
  ///
  /// In en, this message translates to:
  /// **'Derived Attributes'**
  String get derivedAttributesSection;

  /// No description provided for @endurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// No description provided for @composure.
  ///
  /// In en, this message translates to:
  /// **'Composure'**
  String get composure;

  /// No description provided for @focusStat.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusStat;

  /// No description provided for @vigilance.
  ///
  /// In en, this message translates to:
  /// **'Vigilance'**
  String get vigilance;

  /// No description provided for @schoolRank.
  ///
  /// In en, this message translates to:
  /// **'School Rank'**
  String get schoolRank;

  /// No description provided for @fatigueStrifeSection.
  ///
  /// In en, this message translates to:
  /// **'Fatigue & Strife'**
  String get fatigueStrifeSection;

  /// No description provided for @fatigueOf.
  ///
  /// In en, this message translates to:
  /// **'Fatigue / {max}'**
  String fatigueOf(int max);

  /// No description provided for @strifeOf.
  ///
  /// In en, this message translates to:
  /// **'Strife / {max}'**
  String strifeOf(int max);

  /// No description provided for @clearAllFatigue.
  ///
  /// In en, this message translates to:
  /// **'Clear all fatigue'**
  String get clearAllFatigue;

  /// No description provided for @recover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get recover;

  /// No description provided for @clearAllStrife.
  ///
  /// In en, this message translates to:
  /// **'Clear all strife'**
  String get clearAllStrife;

  /// No description provided for @unmask.
  ///
  /// In en, this message translates to:
  /// **'Unmask'**
  String get unmask;

  /// No description provided for @conditionsSection.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditionsSection;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get addCondition;

  /// No description provided for @noConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions.'**
  String get noConditions;

  /// No description provided for @incapacitatedRule.
  ///
  /// In en, this message translates to:
  /// **'Fatigue exceeds endurance: no actions requiring checks and no defending against damage.'**
  String get incapacitatedRule;

  /// No description provided for @compromisedRule.
  ///
  /// In en, this message translates to:
  /// **'Strife exceeds composure: cannot keep dice showing strife; vigilance counts as 1.'**
  String get compromisedRule;

  /// No description provided for @criticalStrike.
  ///
  /// In en, this message translates to:
  /// **'Critical strike…'**
  String get criticalStrike;

  /// No description provided for @skillsSection.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsSection;

  /// No description provided for @heritageSection.
  ///
  /// In en, this message translates to:
  /// **'Heritage'**
  String get heritageSection;

  /// No description provided for @ninjoSection.
  ///
  /// In en, this message translates to:
  /// **'Ninjō (personal desire)'**
  String get ninjoSection;

  /// No description provided for @giriSection.
  ///
  /// In en, this message translates to:
  /// **'Giri (duty)'**
  String get giriSection;

  /// No description provided for @notesSection.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSection;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @removedName.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedName(String name);

  /// No description provided for @unknownCustomSection.
  ///
  /// In en, this message translates to:
  /// **'Unknown (custom or missing data)'**
  String get unknownCustomSection;

  /// No description provided for @bondsSection.
  ///
  /// In en, this message translates to:
  /// **'Bonds'**
  String get bondsSection;

  /// No description provided for @addBond.
  ///
  /// In en, this message translates to:
  /// **'Add bond'**
  String get addBond;

  /// No description provided for @noBondsYet.
  ///
  /// In en, this message translates to:
  /// **'No bonds formed yet — tap + to add.'**
  String get noBondsYet;

  /// No description provided for @rankLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rankLabel;

  /// No description provided for @techniquesSection.
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get techniquesSection;

  /// No description provided for @noTechniquesYet.
  ///
  /// In en, this message translates to:
  /// **'No techniques known yet.'**
  String get noTechniquesYet;

  /// No description provided for @restrictionLabel.
  ///
  /// In en, this message translates to:
  /// **'Restriction: {restriction}'**
  String restrictionLabel(String restriction);

  /// No description provided for @customOrUnknownTechnique.
  ///
  /// In en, this message translates to:
  /// **'Custom or unknown technique'**
  String get customOrUnknownTechnique;

  /// No description provided for @weaponsSection.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get weaponsSection;

  /// No description provided for @armorSection.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get armorSection;

  /// No description provided for @personalEffectsSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Effects'**
  String get personalEffectsSection;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @noWeaponsYet.
  ///
  /// In en, this message translates to:
  /// **'No weapons yet — tap + to add.'**
  String get noWeaponsYet;

  /// No description provided for @noArmorYet.
  ///
  /// In en, this message translates to:
  /// **'No armor yet — tap + to add.'**
  String get noArmorYet;

  /// No description provided for @noPersonalEffectsYet.
  ///
  /// In en, this message translates to:
  /// **'No personal effects yet — tap + to add.'**
  String get noPersonalEffectsYet;

  /// No description provided for @gripStats.
  ///
  /// In en, this message translates to:
  /// **'{grip}: Range {min}-{max} · Dmg {damage} · Dls {deadliness}'**
  String gripStats(
    String grip,
    int min,
    int max,
    String damage,
    String deadliness,
  );

  /// No description provided for @armorStats.
  ///
  /// In en, this message translates to:
  /// **'Physical {physical} · Supernatural {supernatural}'**
  String armorStats(int physical, int supernatural);

  /// No description provided for @priceLine.
  ///
  /// In en, this message translates to:
  /// **'{price} {unit} · Rarity {rarity}'**
  String priceLine(int price, String unit, int rarity);

  /// No description provided for @colName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get colName;

  /// No description provided for @colCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get colCategory;

  /// No description provided for @colSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get colSkill;

  /// No description provided for @colGrip.
  ///
  /// In en, this message translates to:
  /// **'Grip'**
  String get colGrip;

  /// No description provided for @colRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get colRange;

  /// No description provided for @colDamage.
  ///
  /// In en, this message translates to:
  /// **'Dmg'**
  String get colDamage;

  /// No description provided for @colDeadliness.
  ///
  /// In en, this message translates to:
  /// **'Dls'**
  String get colDeadliness;

  /// No description provided for @colQualities.
  ///
  /// In en, this message translates to:
  /// **'Qualities'**
  String get colQualities;

  /// No description provided for @colPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get colPhysical;

  /// No description provided for @colSupernatural.
  ///
  /// In en, this message translates to:
  /// **'Supernatural'**
  String get colSupernatural;

  /// No description provided for @addedAdvanceRankUp.
  ///
  /// In en, this message translates to:
  /// **'Added {name} — school rank is now {rank}!'**
  String addedAdvanceRankUp(String name, int rank);

  /// No description provided for @addedAdvance.
  ///
  /// In en, this message translates to:
  /// **'Added {name} — {cost} XP ({track})'**
  String addedAdvance(String name, int cost, String track);

  /// No description provided for @xpInRank.
  ///
  /// In en, this message translates to:
  /// **'XP in Rank'**
  String get xpInRank;

  /// No description provided for @xpSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'XP Spent'**
  String get xpSpentLabel;

  /// No description provided for @noTitleInProgress.
  ///
  /// In en, this message translates to:
  /// **'No title in progress'**
  String get noTitleInProgress;

  /// No description provided for @currentTitleLine.
  ///
  /// In en, this message translates to:
  /// **'Current title: {title} — {xp} / {total} XP'**
  String currentTitleLine(String title, int xp, int total);

  /// No description provided for @curriculumSection.
  ///
  /// In en, this message translates to:
  /// **'Curriculum — {school}'**
  String curriculumSection(String school);

  /// No description provided for @noSchoolFallback.
  ///
  /// In en, this message translates to:
  /// **'no school'**
  String get noSchoolFallback;

  /// No description provided for @addAdvance.
  ///
  /// In en, this message translates to:
  /// **'Add advance'**
  String get addAdvance;

  /// No description provided for @noSchoolNoCurriculum.
  ///
  /// In en, this message translates to:
  /// **'No school chosen, so there is no curriculum.'**
  String get noSchoolNoCurriculum;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get currentLabel;

  /// No description provided for @skillRankLabel.
  ///
  /// In en, this message translates to:
  /// **'rank {rank}'**
  String skillRankLabel(int rank);

  /// No description provided for @specialAccess.
  ///
  /// In en, this message translates to:
  /// **'special access'**
  String get specialAccess;

  /// No description provided for @ranksRange.
  ///
  /// In en, this message translates to:
  /// **'ranks {min}-{max}'**
  String ranksRange(int min, int max);

  /// No description provided for @atRank5.
  ///
  /// In en, this message translates to:
  /// **'At rank 5'**
  String get atRank5;

  /// No description provided for @alreadyLearnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Already learned'**
  String get alreadyLearnedLabel;

  /// No description provided for @buyThisAdvance.
  ///
  /// In en, this message translates to:
  /// **'Buy this advance'**
  String get buyThisAdvance;

  /// No description provided for @titlesSection.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get titlesSection;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add title'**
  String get addTitle;

  /// No description provided for @finishCurrentTitleFirst.
  ///
  /// In en, this message translates to:
  /// **'Finish the current title first'**
  String get finishCurrentTitleFirst;

  /// No description provided for @noTitlesYet.
  ///
  /// In en, this message translates to:
  /// **'No titles yet — tap + to add.'**
  String get noTitlesYet;

  /// No description provided for @inProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgressLabel;

  /// No description provided for @completedWithAbility.
  ///
  /// In en, this message translates to:
  /// **'Completed — {ability}'**
  String completedWithAbility(String ability);

  /// No description provided for @maxRankLabel.
  ///
  /// In en, this message translates to:
  /// **'max rank {rank}'**
  String maxRankLabel(int rank);

  /// No description provided for @advancesTakenSection.
  ///
  /// In en, this message translates to:
  /// **'Advances Taken'**
  String get advancesTakenSection;

  /// No description provided for @noAdvancesYet.
  ///
  /// In en, this message translates to:
  /// **'No advances purchased yet — tap + or a curriculum entry.'**
  String get noAdvancesYet;

  /// No description provided for @advanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{type} · {track} · {cost} XP'**
  String advanceSubtitle(String type, String track, int cost);

  /// No description provided for @addAdvanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Advance'**
  String get addAdvanceTitle;

  /// No description provided for @advTypeSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get advTypeSkill;

  /// No description provided for @advTypeRing.
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get advTypeRing;

  /// No description provided for @advTypeTechnique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get advTypeTechnique;

  /// No description provided for @advanceSection.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advanceSection;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All groups'**
  String get allGroups;

  /// No description provided for @mahoWarning.
  ///
  /// In en, this message translates to:
  /// **'Mahō is forbidden. Learning it has consequences.'**
  String get mahoWarning;

  /// No description provided for @typeToFilter.
  ///
  /// In en, this message translates to:
  /// **'Type to filter'**
  String get typeToFilter;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @techSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{subcategory} · Rank {rank} · {xp} XP'**
  String techSubtitle(String subcategory, int rank, int xp);

  /// No description provided for @ignoreRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Ignore restrictions (rank, school access)'**
  String get ignoreRestrictions;

  /// No description provided for @trackSection.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get trackSection;

  /// No description provided for @trackCurriculumLabel.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get trackCurriculumLabel;

  /// No description provided for @trackTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get trackTitleLabel;

  /// No description provided for @trackFreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free (no XP cost)'**
  String get trackFreeLabel;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @halfXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Half XP (school/title discount)'**
  String get halfXpLabel;

  /// No description provided for @chooseAnAdvance.
  ///
  /// In en, this message translates to:
  /// **'Choose an advance.'**
  String get chooseAnAdvance;

  /// No description provided for @alreadyLearnedError.
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' is already learned.'**
  String alreadyLearnedError(String name);

  /// No description provided for @costXp.
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost} XP'**
  String costXp(int cost);

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemTitle;

  /// No description provided for @itemWeapon.
  ///
  /// In en, this message translates to:
  /// **'Weapon'**
  String get itemWeapon;

  /// No description provided for @itemArmor.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get itemArmor;

  /// No description provided for @itemPersonalEffect.
  ///
  /// In en, this message translates to:
  /// **'Personal Effect'**
  String get itemPersonalEffect;

  /// No description provided for @chooseWeapon.
  ///
  /// In en, this message translates to:
  /// **'Choose Weapon'**
  String get chooseWeapon;

  /// No description provided for @chooseArmor.
  ///
  /// In en, this message translates to:
  /// **'Choose Armor'**
  String get chooseArmor;

  /// No description provided for @choosePersonalEffect.
  ///
  /// In en, this message translates to:
  /// **'Choose Personal Effect'**
  String get choosePersonalEffect;

  /// No description provided for @weaponPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} · {skill} · Dmg {damage} · Dls {deadliness}'**
  String weaponPickSubtitle(
    String category,
    String skill,
    String damage,
    String deadliness,
  );

  /// No description provided for @chooseFromBook.
  ///
  /// In en, this message translates to:
  /// **'Choose from book…'**
  String get chooseFromBook;

  /// No description provided for @changeBaseItem.
  ///
  /// In en, this message translates to:
  /// **'Change base item…'**
  String get changeBaseItem;

  /// No description provided for @customItem.
  ///
  /// In en, this message translates to:
  /// **'Custom item'**
  String get customItem;

  /// No description provided for @detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsSection;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @rarityLabel.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get rarityLabel;

  /// No description provided for @qualitiesCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Qualities (comma-separated)'**
  String get qualitiesCommaSeparated;

  /// No description provided for @addNGrips.
  ///
  /// In en, this message translates to:
  /// **'Add ({count} grips)'**
  String addNGrips(int count);

  /// No description provided for @gripEditorLabel.
  ///
  /// In en, this message translates to:
  /// **'Grip: {grip}'**
  String gripEditorLabel(String grip);

  /// No description provided for @minRange.
  ///
  /// In en, this message translates to:
  /// **'Min range'**
  String get minRange;

  /// No description provided for @maxRange.
  ///
  /// In en, this message translates to:
  /// **'Max range'**
  String get maxRange;

  /// No description provided for @damageLabel.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get damageLabel;

  /// No description provided for @deadlinessLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadliness'**
  String get deadlinessLabel;

  /// No description provided for @addTrait.
  ///
  /// In en, this message translates to:
  /// **'Add Trait'**
  String get addTrait;

  /// No description provided for @addCategoryLower.
  ///
  /// In en, this message translates to:
  /// **'Add {category}'**
  String addCategoryLower(String category);

  /// No description provided for @addBondTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Bond'**
  String get addBondTitle;

  /// No description provided for @addTitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Title'**
  String get addTitleTitle;

  /// No description provided for @xpAmount.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpAmount(int xp);

  /// No description provided for @criticalStrikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical strike'**
  String get criticalStrikeTitle;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity (deadliness of the source)'**
  String get severityLabel;

  /// No description provided for @razorEdgedLabel.
  ///
  /// In en, this message translates to:
  /// **'Attack was Razor-Edged'**
  String get razorEdgedLabel;

  /// No description provided for @ringUsedToResist.
  ///
  /// In en, this message translates to:
  /// **'Ring used to resist'**
  String get ringUsedToResist;

  /// No description provided for @ringResistHelper.
  ///
  /// In en, this message translates to:
  /// **'Stance ring in a conflict, any in a narrative'**
  String get ringResistHelper;

  /// No description provided for @tnFitnessCheck.
  ///
  /// In en, this message translates to:
  /// **'TN 1 Fitness check succeeded'**
  String get tnFitnessCheck;

  /// No description provided for @rollOwnDice.
  ///
  /// In en, this message translates to:
  /// **'Roll your own dice; enter the result'**
  String get rollOwnDice;

  /// No description provided for @bonusSuccessesLabel.
  ///
  /// In en, this message translates to:
  /// **'Bonus successes (severity −1 each, on top of −1)'**
  String get bonusSuccessesLabel;

  /// No description provided for @finalSeverityLine.
  ///
  /// In en, this message translates to:
  /// **'Final severity {severity} — {band}'**
  String finalSeverityLine(int severity, String band);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @chooseScarTitle.
  ///
  /// In en, this message translates to:
  /// **'{band}: choose a scar ({ring})'**
  String chooseScarTitle(String band, String ring);

  /// No description provided for @severityResult.
  ///
  /// In en, this message translates to:
  /// **'Severity {severity}: {band} — {effect}'**
  String severityResult(int severity, String band, String effect);

  /// No description provided for @rulesDescriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules Descriptions'**
  String get rulesDescriptionsTitle;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescriptionLabel;

  /// No description provided for @fullDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Full description'**
  String get fullDescriptionLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// No description provided for @withText.
  ///
  /// In en, this message translates to:
  /// **'With text'**
  String get withText;

  /// No description provided for @wizPart1.
  ///
  /// In en, this message translates to:
  /// **'Part 1: Clan and Family'**
  String get wizPart1;

  /// No description provided for @wizPart2.
  ///
  /// In en, this message translates to:
  /// **'Part 2: Role and School'**
  String get wizPart2;

  /// No description provided for @wizPart3.
  ///
  /// In en, this message translates to:
  /// **'Part 3: Honor and Glory'**
  String get wizPart3;

  /// No description provided for @wizPart4.
  ///
  /// In en, this message translates to:
  /// **'Part 4: Strengths and Weaknesses'**
  String get wizPart4;

  /// No description provided for @wizPart5.
  ///
  /// In en, this message translates to:
  /// **'Part 5: Personality and Behavior'**
  String get wizPart5;

  /// No description provided for @wizPart6.
  ///
  /// In en, this message translates to:
  /// **'Part 6: Ancestry and Family'**
  String get wizPart6;

  /// No description provided for @wizPart7.
  ///
  /// In en, this message translates to:
  /// **'Part 7: Death'**
  String get wizPart7;

  /// No description provided for @wizErrChooseClan.
  ///
  /// In en, this message translates to:
  /// **'Choose a clan (Question 1).'**
  String get wizErrChooseClan;

  /// No description provided for @wizErrChooseFamily.
  ///
  /// In en, this message translates to:
  /// **'Choose a family (Question 2).'**
  String get wizErrChooseFamily;

  /// No description provided for @wizErrChooseFamilyRing.
  ///
  /// In en, this message translates to:
  /// **'Choose your family ring increase.'**
  String get wizErrChooseFamilyRing;

  /// No description provided for @wizErrChooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose a region (Question 1).'**
  String get wizErrChooseRegion;

  /// No description provided for @wizErrChooseUpbringing.
  ///
  /// In en, this message translates to:
  /// **'Choose an upbringing (Question 2).'**
  String get wizErrChooseUpbringing;

  /// No description provided for @wizErrChooseUpbringingRing.
  ///
  /// In en, this message translates to:
  /// **'Choose your upbringing ring increase.'**
  String get wizErrChooseUpbringingRing;

  /// No description provided for @wizErrChooseUpbringingSkill.
  ///
  /// In en, this message translates to:
  /// **'Choose upbringing skill {n}.'**
  String wizErrChooseUpbringingSkill(int n);

  /// No description provided for @wizErrChooseSchool.
  ///
  /// In en, this message translates to:
  /// **'Choose a school.'**
  String get wizErrChooseSchool;

  /// No description provided for @wizErrInsufficientSkills.
  ///
  /// In en, this message translates to:
  /// **'Insufficient skills selected.'**
  String get wizErrInsufficientSkills;

  /// No description provided for @wizErrSchoolRings.
  ///
  /// In en, this message translates to:
  /// **'Choose your school ring increases.'**
  String get wizErrSchoolRings;

  /// No description provided for @wizErrStandoutRing.
  ///
  /// In en, this message translates to:
  /// **'Choose your standout ring.'**
  String get wizErrStandoutRing;

  /// No description provided for @wizErrStartingTechniques.
  ///
  /// In en, this message translates to:
  /// **'Choose your starting techniques.'**
  String get wizErrStartingTechniques;

  /// No description provided for @wizErrQ7Option.
  ///
  /// In en, this message translates to:
  /// **'Choose an option for Question 7.'**
  String get wizErrQ7Option;

  /// No description provided for @wizErrQ7Skill.
  ///
  /// In en, this message translates to:
  /// **'Choose a skill for Question 7.'**
  String get wizErrQ7Skill;

  /// No description provided for @wizErrQ8Option.
  ///
  /// In en, this message translates to:
  /// **'Choose an option for Question 8.'**
  String get wizErrQ8Option;

  /// No description provided for @wizErrQ8Skill.
  ///
  /// In en, this message translates to:
  /// **'Choose a skill for Question 8.'**
  String get wizErrQ8Skill;

  /// No description provided for @wizErrQ8Item.
  ///
  /// In en, this message translates to:
  /// **'Choose an item for Question 8.'**
  String get wizErrQ8Item;

  /// No description provided for @wizErrDistinction.
  ///
  /// In en, this message translates to:
  /// **'Choose a distinction (Question 9).'**
  String get wizErrDistinction;

  /// No description provided for @wizErrAdversity.
  ///
  /// In en, this message translates to:
  /// **'Choose an adversity (Question 10).'**
  String get wizErrAdversity;

  /// No description provided for @wizErrPassion.
  ///
  /// In en, this message translates to:
  /// **'Choose a passion (Question 11).'**
  String get wizErrPassion;

  /// No description provided for @wizErrAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Choose an anxiety (Question 12).'**
  String get wizErrAnxiety;

  /// No description provided for @wizErrQ13Option.
  ///
  /// In en, this message translates to:
  /// **'Choose an option for Question 13.'**
  String get wizErrQ13Option;

  /// No description provided for @wizErrQ13Advantage.
  ///
  /// In en, this message translates to:
  /// **'Choose an advantage for Question 13.'**
  String get wizErrQ13Advantage;

  /// No description provided for @wizErrQ13DisadvSkill.
  ///
  /// In en, this message translates to:
  /// **'Choose a disadvantage and skill for Question 13.'**
  String get wizErrQ13DisadvSkill;

  /// No description provided for @wizErrQ16Item.
  ///
  /// In en, this message translates to:
  /// **'Choose a memento item for Question 16.'**
  String get wizErrQ16Item;

  /// No description provided for @wizErrReplacementRings.
  ///
  /// In en, this message translates to:
  /// **'Please select replacement ring(s).'**
  String get wizErrReplacementRings;

  /// No description provided for @wizErrReplacementSkills.
  ///
  /// In en, this message translates to:
  /// **'Please select replacement skill(s).'**
  String get wizErrReplacementSkills;

  /// No description provided for @wizDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this character?'**
  String get wizDiscardTitle;

  /// No description provided for @wizDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers so far will be lost.'**
  String get wizDiscardBody;

  /// No description provided for @wizSummaryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rings & skills so far'**
  String get wizSummaryTooltip;

  /// No description provided for @wizNoSkillsYet.
  ///
  /// In en, this message translates to:
  /// **'No skills yet.'**
  String get wizNoSkillsYet;

  /// No description provided for @wizStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {page} of {total}'**
  String wizStepOf(int page, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @characterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Character type'**
  String get characterTypeLabel;

  /// No description provided for @wizQ1Clan.
  ///
  /// In en, this message translates to:
  /// **'1. What clan does your character belong to?'**
  String get wizQ1Clan;

  /// No description provided for @clanLabel.
  ///
  /// In en, this message translates to:
  /// **'Clan'**
  String get clanLabel;

  /// No description provided for @clanStatsLine.
  ///
  /// In en, this message translates to:
  /// **'+1 {ring} · +1 {skill} · Status {status} · {reference}'**
  String clanStatsLine(String ring, String skill, int status, String reference);

  /// No description provided for @wizQ2Family.
  ///
  /// In en, this message translates to:
  /// **'2. What family does your character belong to?'**
  String get wizQ2Family;

  /// No description provided for @familyStatsLine.
  ///
  /// In en, this message translates to:
  /// **'+1 {skills} · Glory {glory} · Wealth {wealth} koku'**
  String familyStatsLine(String skills, int glory, int wealth);

  /// No description provided for @familyRingIncrease.
  ///
  /// In en, this message translates to:
  /// **'Family ring increase'**
  String get familyRingIncrease;

  /// No description provided for @wizQ1Region.
  ///
  /// In en, this message translates to:
  /// **'1. Where does your character come from?'**
  String get wizQ1Region;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @wizQ2Upbringing.
  ///
  /// In en, this message translates to:
  /// **'2. What was your character\'s upbringing?'**
  String get wizQ2Upbringing;

  /// No description provided for @upbringingLabel.
  ///
  /// In en, this message translates to:
  /// **'Upbringing'**
  String get upbringingLabel;

  /// No description provided for @upbringingRingIncrease.
  ///
  /// In en, this message translates to:
  /// **'Upbringing ring increase'**
  String get upbringingRingIncrease;

  /// No description provided for @upbringingSkillN.
  ///
  /// In en, this message translates to:
  /// **'Upbringing skill {n}'**
  String upbringingSkillN(int n);

  /// No description provided for @wizQ3Samurai.
  ///
  /// In en, this message translates to:
  /// **'3. What is your school, and what roles does that school fall into?'**
  String get wizQ3Samurai;

  /// No description provided for @wizQ3Ronin.
  ///
  /// In en, this message translates to:
  /// **'3. What is your school, and what are its associated roles?'**
  String get wizQ3Ronin;

  /// No description provided for @showSchoolsOutsideClan.
  ///
  /// In en, this message translates to:
  /// **'Show schools outside my clan'**
  String get showSchoolsOutsideClan;

  /// No description provided for @schoolLabel.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get schoolLabel;

  /// No description provided for @schoolStatsLine.
  ///
  /// In en, this message translates to:
  /// **'{roles} · Honor {honor} · {reference}'**
  String schoolStatsLine(String roles, int honor, String reference);

  /// No description provided for @kitsuneImpersonate.
  ///
  /// In en, this message translates to:
  /// **'School to impersonate (outfit source)'**
  String get kitsuneImpersonate;

  /// No description provided for @additionalBurden.
  ///
  /// In en, this message translates to:
  /// **'Additional burden'**
  String get additionalBurden;

  /// No description provided for @chooseSchoolSkills.
  ///
  /// In en, this message translates to:
  /// **'Choose {size} school skills ({chosen} chosen)'**
  String chooseSchoolSkills(int size, int chosen);

  /// No description provided for @schoolRingIncreases.
  ///
  /// In en, this message translates to:
  /// **'School ring increases'**
  String get schoolRingIncreases;

  /// No description provided for @fixedRings.
  ///
  /// In en, this message translates to:
  /// **'Fixed: +1 {rings}'**
  String fixedRings(String rings);

  /// No description provided for @ringOfYourChoice.
  ///
  /// In en, this message translates to:
  /// **'Ring of your choice'**
  String get ringOfYourChoice;

  /// No description provided for @wizQ4Samurai.
  ///
  /// In en, this message translates to:
  /// **'4. How do you stand out within your school? (+1 ring)'**
  String get wizQ4Samurai;

  /// No description provided for @wizQ4Ronin.
  ///
  /// In en, this message translates to:
  /// **'4. What gets you in and out of trouble? (+1 ring)'**
  String get wizQ4Ronin;

  /// No description provided for @standoutRing.
  ///
  /// In en, this message translates to:
  /// **'Standout ring'**
  String get standoutRing;

  /// No description provided for @describeIt.
  ///
  /// In en, this message translates to:
  /// **'Describe it'**
  String get describeIt;

  /// No description provided for @startingTechniqueFixed.
  ///
  /// In en, this message translates to:
  /// **'Starting technique: {name}'**
  String startingTechniqueFixed(String name);

  /// No description provided for @chooseStartingTechnique.
  ///
  /// In en, this message translates to:
  /// **'Choose a starting technique'**
  String get chooseStartingTechnique;

  /// No description provided for @startingOutfit.
  ///
  /// In en, this message translates to:
  /// **'Starting outfit'**
  String get startingOutfit;

  /// No description provided for @chooseAnItem.
  ///
  /// In en, this message translates to:
  /// **'Choose an item'**
  String get chooseAnItem;

  /// No description provided for @includedItems.
  ///
  /// In en, this message translates to:
  /// **'Included: {items}'**
  String includedItems(String items);

  /// No description provided for @wizQ5Samurai.
  ///
  /// In en, this message translates to:
  /// **'5. Who is your lord, and what is your duty to them? (Giri)'**
  String get wizQ5Samurai;

  /// No description provided for @wizQ5Ronin.
  ///
  /// In en, this message translates to:
  /// **'5. What is your past, and how does it affect you?'**
  String get wizQ5Ronin;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answerLabel;

  /// No description provided for @wizQ6Samurai.
  ///
  /// In en, this message translates to:
  /// **'6. What do you long for, and how might this impede your duty? (Ninjō)'**
  String get wizQ6Samurai;

  /// No description provided for @wizQ6Ronin.
  ///
  /// In en, this message translates to:
  /// **'6. What do you long for, and how might your past impact your Ninjō?'**
  String get wizQ6Ronin;

  /// No description provided for @wizQ7Samurai.
  ///
  /// In en, this message translates to:
  /// **'7. What is your relationship with your clan?'**
  String get wizQ7Samurai;

  /// No description provided for @wizQ7Ronin.
  ///
  /// In en, this message translates to:
  /// **'7. What are you known for?'**
  String get wizQ7Ronin;

  /// No description provided for @q7Positive.
  ///
  /// In en, this message translates to:
  /// **'Positive (+5 Glory)'**
  String get q7Positive;

  /// No description provided for @q7Negative.
  ///
  /// In en, this message translates to:
  /// **'Negative (+1 rank in a skill you do not have)'**
  String get q7Negative;

  /// No description provided for @wizQ8.
  ///
  /// In en, this message translates to:
  /// **'8. What do you think of Bushidō?'**
  String get wizQ8;

  /// No description provided for @q8Pos.
  ///
  /// In en, this message translates to:
  /// **'Staunch orthodox belief (+10 Honor)'**
  String get q8Pos;

  /// No description provided for @q8Mid.
  ///
  /// In en, this message translates to:
  /// **'Pragmatic survivor (one item of rarity 5 or lower)'**
  String get q8Mid;

  /// No description provided for @q8Neg.
  ///
  /// In en, this message translates to:
  /// **'Diverges from common beliefs (+1 skill rank)'**
  String get q8Neg;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @wizQ9.
  ///
  /// In en, this message translates to:
  /// **'9. What is your greatest accomplishment so far? (Distinction)'**
  String get wizQ9;

  /// No description provided for @distinctionLabel.
  ///
  /// In en, this message translates to:
  /// **'Distinction'**
  String get distinctionLabel;

  /// No description provided for @wizQ10.
  ///
  /// In en, this message translates to:
  /// **'10. What holds your character back? (Adversity)'**
  String get wizQ10;

  /// No description provided for @adversityLabel.
  ///
  /// In en, this message translates to:
  /// **'Adversity'**
  String get adversityLabel;

  /// No description provided for @wizQ11.
  ///
  /// In en, this message translates to:
  /// **'11. What activity makes you feel at peace? (Passion)'**
  String get wizQ11;

  /// No description provided for @passionLabel.
  ///
  /// In en, this message translates to:
  /// **'Passion'**
  String get passionLabel;

  /// No description provided for @wizQ12.
  ///
  /// In en, this message translates to:
  /// **'12. What concern or fear keeps you up at night? (Anxiety)'**
  String get wizQ12;

  /// No description provided for @anxietyLabel.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get anxietyLabel;

  /// No description provided for @wizQ13.
  ///
  /// In en, this message translates to:
  /// **'13. Who is the person you trust most, and what is the nature of the relationship?'**
  String get wizQ13;

  /// No description provided for @q13GainAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Gain an advantage'**
  String get q13GainAdvantage;

  /// No description provided for @q13GainDisadvantage.
  ///
  /// In en, this message translates to:
  /// **'Gain a disadvantage and +1 skill rank'**
  String get q13GainDisadvantage;

  /// No description provided for @advantageLabel.
  ///
  /// In en, this message translates to:
  /// **'Advantage'**
  String get advantageLabel;

  /// No description provided for @disadvantageLabel.
  ///
  /// In en, this message translates to:
  /// **'Disadvantage'**
  String get disadvantageLabel;

  /// No description provided for @describeRelationship.
  ///
  /// In en, this message translates to:
  /// **'Describe the relationship'**
  String get describeRelationship;

  /// No description provided for @wizQ14Samurai.
  ///
  /// In en, this message translates to:
  /// **'14. What do people notice first upon encountering you?'**
  String get wizQ14Samurai;

  /// No description provided for @wizQ14Ronin.
  ///
  /// In en, this message translates to:
  /// **'14. What is your character\'s most prized possession?'**
  String get wizQ14Ronin;

  /// No description provided for @possessionRarity5.
  ///
  /// In en, this message translates to:
  /// **'Possession (rarity 5 or lower)'**
  String get possessionRarity5;

  /// No description provided for @wizQ15.
  ///
  /// In en, this message translates to:
  /// **'15. How do you react to stressful situations?'**
  String get wizQ15;

  /// No description provided for @wizQ16Samurai.
  ///
  /// In en, this message translates to:
  /// **'16. What are your preexisting relationships with other clans, families, organizations, and traditions?'**
  String get wizQ16Samurai;

  /// No description provided for @wizQ16Ronin.
  ///
  /// In en, this message translates to:
  /// **'16. What are your relationships to your family, the clans, peasants, and others?'**
  String get wizQ16Ronin;

  /// No description provided for @mementoRarity7.
  ///
  /// In en, this message translates to:
  /// **'Memento item (rarity 7 or lower)'**
  String get mementoRarity7;

  /// No description provided for @describeThem.
  ///
  /// In en, this message translates to:
  /// **'Describe them'**
  String get describeThem;

  /// No description provided for @wizQ17Parents.
  ///
  /// In en, this message translates to:
  /// **'17. How would your parents describe you? (+1 skill rank)'**
  String get wizQ17Parents;

  /// No description provided for @wizQ17Raised.
  ///
  /// In en, this message translates to:
  /// **'18. Who raised you? (+1 skill rank)'**
  String get wizQ17Raised;

  /// No description provided for @wizQ17Bond.
  ///
  /// In en, this message translates to:
  /// **'17. With whom do you share a bond?'**
  String get wizQ17Bond;

  /// No description provided for @bondLabel.
  ///
  /// In en, this message translates to:
  /// **'Bond'**
  String get bondLabel;

  /// No description provided for @wizQ18Ancestry.
  ///
  /// In en, this message translates to:
  /// **'18. What is your duty to your family, and who among your ancestors do you exemplify?'**
  String get wizQ18Ancestry;

  /// No description provided for @heritageTable.
  ///
  /// In en, this message translates to:
  /// **'Heritage table'**
  String get heritageTable;

  /// No description provided for @ancestorN.
  ///
  /// In en, this message translates to:
  /// **'Ancestor {n}'**
  String ancestorN(int n);

  /// No description provided for @rollTooltip.
  ///
  /// In en, this message translates to:
  /// **'Roll (1d10)'**
  String get rollTooltip;

  /// No description provided for @heritageHeader.
  ///
  /// In en, this message translates to:
  /// **'Heritage: {name}'**
  String heritageHeader(String name);

  /// No description provided for @grantedLabel.
  ///
  /// In en, this message translates to:
  /// **'Granted: {name}'**
  String grantedLabel(String name);

  /// No description provided for @bonusSkill.
  ///
  /// In en, this message translates to:
  /// **'Bonus skill'**
  String get bonusSkill;

  /// No description provided for @traitGained.
  ///
  /// In en, this message translates to:
  /// **'Trait gained'**
  String get traitGained;

  /// No description provided for @heirloomCategory.
  ///
  /// In en, this message translates to:
  /// **'Heirloom category'**
  String get heirloomCategory;

  /// No description provided for @lostHeirloomCategory.
  ///
  /// In en, this message translates to:
  /// **'Lost heirloom category'**
  String get lostHeirloomCategory;

  /// No description provided for @techniqueGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Technique group'**
  String get techniqueGroupLabel;

  /// No description provided for @effectLabel.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get effectLabel;

  /// No description provided for @giftLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get giftLabel;

  /// No description provided for @ringToRaise.
  ///
  /// In en, this message translates to:
  /// **'Ring to raise'**
  String get ringToRaise;

  /// No description provided for @ringToLower.
  ///
  /// In en, this message translates to:
  /// **'Ring to lower'**
  String get ringToLower;

  /// No description provided for @qualityYourChoice.
  ///
  /// In en, this message translates to:
  /// **'Quality (your choice)'**
  String get qualityYourChoice;

  /// No description provided for @qualityGmChoice.
  ///
  /// In en, this message translates to:
  /// **'Quality (GM\'s choice)'**
  String get qualityGmChoice;

  /// No description provided for @wizQ19.
  ///
  /// In en, this message translates to:
  /// **'19. What is your name?'**
  String get wizQ19;

  /// No description provided for @personalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal name'**
  String get personalNameLabel;

  /// No description provided for @wizQ20.
  ///
  /// In en, this message translates to:
  /// **'20. How should your character die?'**
  String get wizQ20;

  /// No description provided for @answerOptional.
  ///
  /// In en, this message translates to:
  /// **'Answer (optional)'**
  String get answerOptional;

  /// No description provided for @ringOverflowMsg.
  ///
  /// In en, this message translates to:
  /// **'A ring exceeds the creation cap of 3. Choose {n} replacement ring(s):'**
  String ringOverflowMsg(int n);

  /// No description provided for @skillOverflowMsg.
  ///
  /// In en, this message translates to:
  /// **'A skill exceeds the creation cap of 3. Choose {n} replacement skill(s):'**
  String skillOverflowMsg(int n);

  /// No description provided for @replacementRingN.
  ///
  /// In en, this message translates to:
  /// **'Replacement ring {n}'**
  String replacementRingN(int n);

  /// No description provided for @replacementSkillN.
  ///
  /// In en, this message translates to:
  /// **'Replacement skill {n}'**
  String replacementSkillN(int n);

  /// No description provided for @readyHeader.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyHeader;

  /// No description provided for @finishCreates.
  ///
  /// In en, this message translates to:
  /// **'Finish creates the character and opens the editor.'**
  String get finishCreates;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @tapToTypeValue.
  ///
  /// In en, this message translates to:
  /// **'Tap to type a value'**
  String get tapToTypeValue;

  /// No description provided for @unlockIdentityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unlock name, family, ninjō, and giri'**
  String get unlockIdentityTooltip;

  /// No description provided for @lockIdentityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lock name, family, ninjō, and giri'**
  String get lockIdentityTooltip;

  /// No description provided for @changePortraitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap to change portrait, long-press to remove'**
  String get changePortraitTooltip;

  /// No description provided for @addPortraitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a portrait'**
  String get addPortraitTooltip;

  /// No description provided for @pdfFatigueStrifeConditions.
  ///
  /// In en, this message translates to:
  /// **'Fatigue, Strife & Conditions'**
  String get pdfFatigueStrifeConditions;

  /// No description provided for @pdfWealthProgress.
  ///
  /// In en, this message translates to:
  /// **'Wealth & Progress'**
  String get pdfWealthProgress;

  /// No description provided for @pdfWealthLine.
  ///
  /// In en, this message translates to:
  /// **'Wealth: {koku} koku, {bu} bu, {zeni} zeni    ·    XP: {spent} spent / {total} total    ·    XP in rank: {inRank}'**
  String pdfWealthLine(
    int koku,
    int bu,
    int zeni,
    int spent,
    int total,
    int inRank,
  );

  /// No description provided for @pdfTitlePart.
  ///
  /// In en, this message translates to:
  /// **'    ·    Title: {title} ({xp} XP)'**
  String pdfTitlePart(String title, int xp);

  /// No description provided for @pdfTraitsHeader.
  ///
  /// In en, this message translates to:
  /// **'Distinctions & Adversities'**
  String get pdfTraitsHeader;

  /// No description provided for @colAbility.
  ///
  /// In en, this message translates to:
  /// **'Ability'**
  String get colAbility;

  /// No description provided for @ninjoHeader.
  ///
  /// In en, this message translates to:
  /// **'Ninjō'**
  String get ninjoHeader;

  /// No description provided for @giriHeader.
  ///
  /// In en, this message translates to:
  /// **'Giri'**
  String get giriHeader;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
