// Development-only entrypoint: opens the editor directly with a seeded demo
// character. Run with: flutter run -d macos -t lib/main_preview.dart
import 'package:flutter/material.dart';

import 'advance.dart';
import 'character.dart';
import 'game_data.dart';
import 'game_data_models.dart';
import 'item.dart';
import 'rules_constants.dart';
import 'screens/character_editor.dart';
import 'screens/tools_page.dart';
import 'theme.dart';
import 'wizard/wizard_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await gameData.load();
  await themeController.load();
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
  character.school = 'Hida Defender School';
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
        home: const bool.fromEnvironment('WIZARD')
            ? const NewCharacterWizard()
            : const bool.fromEnvironment('TOOLS')
                ? const ToolsPage()
                : const CharacterEditor(
                    initialTab: int.fromEnvironment('TAB')),
      ),
    );
  }
}
