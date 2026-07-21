// Development-only entrypoint: opens the editor directly with a seeded demo
// character. Run with: flutter run -d macos -t lib/main_preview.dart
import 'package:flutter/material.dart';

import 'advance.dart';
import 'character.dart';
import 'data_l10n.dart';
import 'encounter.dart';
import 'game_data.dart';
import 'game_data_models.dart';
import 'hor_controller.dart';
import 'item.dart';
import 'l10n/l10n.dart';
import 'locale_controllers.dart';
import 'rules_constants.dart';
import 'screens/add_advance_page.dart';
import 'screens/character_editor.dart';
import 'screens/encounter_editor_page.dart';
import 'screens/homebrew_schools_page.dart';
import 'screens/npc_detail_page.dart';
import 'screens/npc_library_page.dart';
import 'screens/npc_quick_build_page.dart';
import 'screens/tools_page.dart';
import 'theme.dart';
import 'wizard/school_builder/school_builder_shell.dart';
import 'wizard/school_builder/school_builder_state.dart';
import 'wizard/wizard_shell.dart';
import 'wizard/wizard_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await gameData.load();
  await themeController.load();
  // HOR=true previews Heroes of Rokugan mode (Tools switch on, HoR wizard)
  // without touching the persisted preference.
  if (const bool.fromEnvironment('HOR')) horController.value = true;
  // LOCALE=fr also loads the data overlay so previews show translated names.
  await dataL10n
      .setLocale(const String.fromEnvironment('LOCALE', defaultValue: 'en'));
  _seedDemoCharacter();
  // PORTRAIT_LATER=true injects a portrait 5s after launch, mimicking what
  // PortraitPicker does after the (unautomatable) native file dialog returns
  // — for eyeballing that the portrait appears without a tab switch.
  if (const bool.fromEnvironment('PORTRAIT_LATER')) {
    Future.delayed(const Duration(seconds: 5), () {
      // 1×1 pink PNG; BoxFit.cover stretches it to fill the frame visibly.
      character.portraitB64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGN4'
          'UTIPAARCAftSco3yAAAAAElFTkSuQmCC';
      character.touch();
    });
  }
  runApp(const _PreviewApp());
}

void _seedDemoCharacter() {
  character.clear();
  character.name = 'Tetsu';
  character.family = 'Hida';
  character.clan = 'Crab';
  // SCHOOL=<name> overrides the demo school (e.g. to preview the Worldly
  // Rōnin Path's bonus curriculum section on the Advancement tab).
  character.school = const String.fromEnvironment('SCHOOL',
      defaultValue: 'Hida Defender School');
  character.ninjo = 'Protect those who cannot protect themselves.';
  character.giri = 'Hold the Wall against the Shadowlands.';
  character.heritage = 'Glorious Sacrifice';
  character.baseRings = {
    ringAir: 1,
    ringEarth: 3,
    ringFire: 2,
    ringWater: 1,
    ringVoid: 1,
  };
  character.baseSkills = {'Tactics': 1, 'Command': 1, 'Fitness': 2};
  character.honor = 40;
  character.glory = 44;
  character.status = 30;
  character.koku = 3;
  character.bu = 2;
  character.techniques = ['Striking as Earth', 'Hida’s Grip'];
  character.advDisadv = ['Blunt', 'Bitter Betrothal'];
  character.titles = ['Deathseeker'];
  character.bonds = [CharacterBond(name: 'Companion', rank: 2)];
  // LOCKED=true previews the identity-lock state on the editor tabs.
  character.identityLocked = const bool.fromEnvironment('LOCKED');
  character.advanceStack = [
    Advance(
        type: advanceTypeSkill,
        name: 'Command',
        track: trackCurriculum,
        cost: 4),
    Advance(
        type: advanceTypeTechnique,
        name: 'Striking as Water',
        track: trackTitle,
        cost: 3),
  ];
  final katana = gameData.weaponByName('Katana')!;
  character.equipment = [
    for (final grip in katana.grips) Item.fromWeapon(katana, grip),
    Item.fromArmor(gameData.armorByName('Ashigaru Armor')!),
    Item.fromPersonalEffect(gameData.personalEffects.first),
  ];
  // Sample item descriptions (normally loaded from user_descriptions.json),
  // for previewing description display on the Equipment tab and PDF.
  gameData.descriptions.addAll(const [
    Description(
        name: 'Katana',
        shortDesc: 'The samurai’s soul: a curved single-edged blade.',
        description:
            'The iconic sword of the samurai, a curved single-edged blade '
            'worn edge-up in the belt. Drawing it in polite company is a '
            'grave insult; striking from the draw is the essence of iaijutsu.'),
    Description(
        name: 'Ashigaru Armor',
        shortDesc: 'Light lacquered infantry armor.'),
    // For previewing the expanded ability tile on the Character Data tab.
    Description(
        name: 'Way of the Crab',
        shortDesc: 'Reduce damage by school rank.',
        description:
            'When you suffer damage, you may reduce the amount you suffer '
            'by your school rank (to a minimum of 0). If you do, you '
            'receive 2 strife.'),
  ]);
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Paper Blossoms (preview)',
        // LOCALE=fr previews the interface in another supported language.
        locale: Locale(const String.fromEnvironment('LOCALE', defaultValue: 'en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedUiLocales,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        // DARK=true forces the dark theme regardless of the user setting or
        // system appearance (System Events automation can't toggle
        // appearance on this machine).
        themeMode: const bool.fromEnvironment('DARK')
            ? ThemeMode.dark
            : themeController.value,
        debugShowCheckedModeBanner: false,
        // WIZARD=true opens the Twenty Questions wizard, TOOLS=true the
        // tools page, instead of the editor.
        home: _home(),
      ),
    );
  }

  /// A filled-in Bushi school for previewing the school-builder pages.
  static SchoolBuilderState _demoSchool() {
    final state = SchoolBuilderState()
      ..roles = ['Bushi']
      ..applyRoleDefaults();
    state
      ..clan = 'Crab'
      ..summary = 'A tradition of wall wardens who outlast any siege, '
          'trading flair for patience and stone-hard discipline.'
      ..summaryShort = 'Patient defenders of the Wall.'
      ..abilityName = 'Way of the Wall'
      ..abilityText = 'Once per scene when you would suffer fatigue, reduce '
          'it by your school rank.'
      ..ringIncrease = ['Earth', 'Water']
      ..masteryName = 'The Wall Endures'
      ..masteryText = 'Increase your endurance by your ranks in Fitness.'
      ..name = 'Wall Warden School'
      ..techniquesAvailable = ['Kata', 'Rituals', 'Shūji']
      ..accessTouched = true;
    state.startingTechniques[0].options = ['Striking as Earth'];
    state.startingTechniques[1].options = [
      'Rushing Avalanche Style',
      'Iron Forest Style'
    ];
    for (var rank = 1; rank <= 5; rank++) {
      final slots = state.curriculum[rank]!;
      slots[0].advance = 'Martial skills';
      slots[1].advance = 'Command';
      slots[2].advance = 'Labor';
      slots[3].advance = 'Survival';
      slots[4].advance = 'Kata';
      slots[5].advance = 'Striking as Water';
      slots[6].advance = 'Rushing Avalanche Style';
    }
    return state;
  }

  /// A mid-flight HoR build for previewing the campaign wizard pages
  /// (WIZARD=true HOR=true WIZARD_PAGE=<1-7>).
  static WizardState _horDemoWizard() {
    final school = gameData.schoolByName('Hida Defender School')!;
    return WizardState()
      ..horMode = true
      ..clan = 'Crab'
      ..family = 'Hida'
      ..familyRing = 'Fire'
      ..school = school.name
      ..schoolSkills = [...school.startingSkills.options]
      ..ringChoices = ['Earth', 'Water']
      ..schoolSpecialRing = 'Void'
      ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
      ..equipChoices = ['Tetsubō']
      ..horService = 'Clan Champion'
      ..horQ5Skill = 'Command'
      ..horQ6Skill = 'Courtesy'
      ..q7Positive = true
      ..q7Skill = 'Commerce'
      ..q8Choice = 'pos'
      ..q8Skill = 'Theology'
      ..distinction = 'Ambidexterity'
      ..adversity = "Bishamon's Curse"
      ..passion = 'Armament'
      ..anxiety = 'Battle Trauma'
      ..q13PickedAdvantage = true
      ..q13Advantage = 'Paragon of Loyalty'
      ..q14Item = 'Calligraphy Set'
      ..q16Item = 'Blanket'
      ..ancestor1 = 'Material Success'
      ..chosenAncestor = 1
      ..horQ19Technique = 'Striking as Water'
      ..personalName = 'Tetsu';
  }

  Widget _home() {
    if (const bool.fromEnvironment('WIZARD')) {
      const wizardPage = int.fromEnvironment('WIZARD_PAGE');
      if (const bool.fromEnvironment('HOR') && wizardPage > 0) {
        return NewCharacterWizard(
            initialState: _horDemoWizard(), initialPage: wizardPage - 1);
      }
      return const NewCharacterWizard();
    }
    // SCHOOL_BUILDER=<1-9> opens the school-builder wizard on that step,
    // preloaded with a demo school; SCHOOLS=true opens the manager page.
    const sbPage = int.fromEnvironment('SCHOOL_BUILDER');
    if (sbPage > 0) {
      return SchoolBuilderWizard(
          initialState: _demoSchool(), initialPage: sbPage - 1);
    }
    if (const bool.fromEnvironment('SCHOOLS')) {
      return const HomebrewSchoolsPage();
    }
    // GM tools previews: NPC_LIBRARY=true opens the NPC library;
    // NPC_DETAIL=<sample name> a stat block; NPC_QUICK=<base name> the
    // quick builder (curriculum taps can't be automated on this machine);
    // ENCOUNTER=true the encounter editor seeded with a bandit ambush.
    if (const bool.fromEnvironment('NPC_LIBRARY')) {
      return const NpcLibraryPage();
    }
    const npcDetail = String.fromEnvironment('NPC_DETAIL');
    if (npcDetail.isNotEmpty) {
      return NpcDetailPage(npc: gameData.npc.sampleByName(npcDetail)!);
    }
    const npcQuick = String.fromEnvironment('NPC_QUICK');
    if (npcQuick.isNotEmpty) {
      return NpcQuickBuildPage(base: gameData.npc.sampleByName(npcQuick));
    }
    if (const bool.fromEnvironment('ENCOUNTER')) {
      return EncounterEditorPage(
        encounter: Encounter(
          name: 'Bandit Ambush',
          entries: [
            EncounterEntry(npc: 'Desperate Bandit', count: 4),
            EncounterEntry(npc: 'Experienced Bandit'),
          ],
        ),
      );
    }
    // TOOLS=true with ABOUT=true also opens the About dialog on launch.
    if (const bool.fromEnvironment('TOOLS')) {
      return const ToolsPage(
          openAboutOnLaunch: bool.fromEnvironment('ABOUT'));
    }
    // ADVANCE_TYPE (Skill/Ring/Technique, plus optional ADVANCE_OPTION and
    // ADVANCE_GROUP) opens the Add Advance page directly — curriculum taps
    // can't be automated on this machine.
    const advanceType = String.fromEnvironment('ADVANCE_TYPE');
    if (advanceType.isNotEmpty) {
      const option = String.fromEnvironment('ADVANCE_OPTION');
      const group = String.fromEnvironment('ADVANCE_GROUP');
      return AddAdvancePage(
        initialType: advanceType,
        initialOption: option.isEmpty ? null : option,
        initialGroup: group.isEmpty ? null : group,
      );
    }
    return const CharacterEditor(initialTab: int.fromEnvironment('TAB'));
  }
}
