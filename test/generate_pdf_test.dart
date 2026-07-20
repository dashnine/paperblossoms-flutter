import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart' as gm;
import 'package:paperblossoms/generate_pdf.dart';
import 'package:paperblossoms/item.dart';
import 'package:paperblossoms/l10n/app_localizations.dart';
import 'package:paperblossoms/pdf_common.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/sheet_style_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    character.clear();
    character.name = 'Tetsu';
    character.family = 'Hida';
    character.clan = 'Crab';
    character.school = 'Hida Defender School';
    character.baseRings = {
      ringAir: 1,
      ringEarth: 3,
      ringFire: 2,
      ringWater: 1,
      ringVoid: 1,
    };
    character.baseSkills = {'Tactics': 1, 'Command': 1};
    character.techniques = ['Striking as Earth'];
    character.advDisadv = ['Blunt'];
    character.titles = ['Deathseeker'];
    character.bonds = [CharacterBond(name: gameData.bonds.first.name)];
    character.advanceStack = [
      Advance(
          type: advanceTypeSkill,
          name: 'Command',
          track: trackCurriculum,
          cost: 4),
    ];
    final katana = gameData.weaponByName('Katana')!;
    character.equipment = [
      Item.fromWeapon(katana, katana.grips.first),
      Item.fromArmor(gameData.armorByName('Ashigaru Armor')!),
      Item.fromPersonalEffect(gameData.personalEffects.first),
    ];
    character.ninjo = 'Protect the weak';
    character.giri = 'Guard the Wall';
    character.notes = 'Some notes';
    // A 1x1 transparent PNG.
    character.portraitB64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
        'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
  });

  test('character sheet PDF builds with all sections', () async {
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.minimalist);
    expect(bytes.length, greaterThan(1000));
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    // Drop a copy for manual inspection when requested.
    final out = Platform.environment['PDF_PROBE_PATH'];
    if (out != null) await File(out).writeAsBytes(bytes);
  });

  test('toggles produce different documents', () async {
    final full = await buildCharacterSheetPdf(style: SheetStyle.minimalist);
    final trimmed = await buildCharacterSheetPdf(
        style: SheetStyle.minimalist,
        showSkills: false,
        showPortrait: false);
    expect(trimmed.length, isNot(full.length));
  });

  test('an empty character still renders a valid sheet', () async {
    character.clear();
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.minimalist);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('corrupt portrait base64 renders the sheet without a portrait',
      () async {
    character.portraitB64 = 'not valid base64!!';
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.minimalist);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('embeds a Unicode-capable font so diacritics survive', () async {
    character.ninjo = 'Ninjō — protect the rōnin';
    final bytes = await buildCharacterSheetPdf();
    final raw = String.fromCharCodes(bytes);
    // The Type1 built-ins can't draw ō/ū; the sheet must carry Roboto.
    expect(raw, contains('/Roboto-Regular'));
    expect(raw, contains('/Roboto-Bold'));
  });

  test('long descriptions are rendered on the sheet', () async {
    final without = await buildCharacterSheetPdf();
    gameData.descriptions = [
      const gm.Description(
          name: 'Striking as Earth',
          description: 'When you make an unarmed or melee attack, you may '
              'spend an opportunity to increase your physical resistance, '
              'as your stance becomes rōnin-steady → immovable.',
          shortDesc: 'Spend opportunity for resistance.'),
    ];
    addTearDown(() => gameData.descriptions = []);
    final with_ = await buildCharacterSheetPdf();
    expect(with_.length, greaterThan(without.length));
    // The → glyph comes from the DejaVu fallback, which only gets embedded
    // when a glyph actually falls through to it.
    expect(String.fromCharCodes(with_), contains('/DejaVuSans'));
  });

  test('structured style builds a valid sheet with the branding font',
      () async {
    // For visual probes, PDF_PROBE_DESCRIPTIONS can point at a
    // user_descriptions.json; the fixture then also gets enough techniques
    // and traits to exercise the two-up layout across a page break.
    final descPath = Platform.environment['PDF_PROBE_DESCRIPTIONS'];
    if (descPath != null) {
      gameData.descriptions = [
        for (final entry in jsonDecode(await File(descPath).readAsString()))
          gm.Description.fromJson(entry),
      ];
      addTearDown(() => gameData.descriptions = []);
      character.techniques = [
        for (final cat in ['Kata', 'Shūji', 'Invocations'])
          ...gameData.techniques
              .where((t) => t.category == cat)
              .take(5)
              .map((t) => t.name),
      ];
      character.advDisadv = [
        ...gameData.advantagesDisadvantages.take(7).map((a) => a.name),
      ];
    }
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.structured);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    expect(String.fromCharCodes(bytes), contains('/Caveat-Bold'));
    final out = Platform.environment['PDF_PROBE_STRUCTURED_PATH'];
    if (out != null) await File(out).writeAsBytes(bytes);
  });

  test('landscape page format produces a valid landscape sheet', () async {
    final descPath = Platform.environment['PDF_PROBE_DESCRIPTIONS'];
    if (descPath != null) {
      gameData.descriptions = [
        for (final entry in jsonDecode(await File(descPath).readAsString()))
          gm.Description.fromJson(entry),
      ];
      addTearDown(() => gameData.descriptions = []);
      character.techniques = [
        for (final cat in ['Kata', 'Shūji', 'Invocations'])
          ...gameData.techniques
              .where((t) => t.category == cat)
              .take(5)
              .map((t) => t.name),
      ];
      character.advDisadv = [
        ...gameData.advantagesDisadvantages.take(7).map((a) => a.name),
      ];
    }
    final bytes = await buildCharacterSheetPdf(
        style: SheetStyle.structured,
        pageFormat: PdfPageFormat.a4.landscape);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    // The page MediaBox must be wider than tall.
    final match = RegExp(r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)')
        .firstMatch(String.fromCharCodes(bytes));
    expect(match, isNotNull);
    expect(double.parse(match!.group(1)!),
        greaterThan(double.parse(match.group(2)!)));
    final out = Platform.environment['PDF_PROBE_LANDSCAPE_PATH'];
    if (out != null) await File(out).writeAsBytes(bytes);
  });

  test('style parameter changes the document', () async {
    final minimalist =
        await buildCharacterSheetPdf(style: SheetStyle.minimalist);
    final structured =
        await buildCharacterSheetPdf(style: SheetStyle.structured);
    expect(structured.length, isNot(minimalist.length));
  });

  test('an empty character still renders a valid structured sheet', () async {
    character.clear();
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.structured);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('corrupt portrait falls back on the structured sheet too', () async {
    character.portraitB64 = base64Encode(
        base64Decode(character.portraitB64).sublist(0, 20));
    final bytes =
        await buildCharacterSheetPdf(style: SheetStyle.structured);
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('structured toggles change the document', () async {
    final full = await buildCharacterSheetPdf(style: SheetStyle.structured);
    final trimmed = await buildCharacterSheetPdf(
        style: SheetStyle.structured,
        showSkills: false,
        showPortrait: false);
    expect(trimmed.length, isNot(full.length));
  });

  test('groupTechniques buckets by category in data order, unknowns last', () {
    final shuji =
        gameData.techniques.firstWhere((t) => t.category == 'Shūji').name;
    // Character order lists the Shūji first; data order still puts Kata first.
    final grouped =
        groupTechniques([shuji, 'Striking as Earth', 'Totally Homebrew Move']);
    expect(grouped.map((g) => g.key).toList(), ['Kata', 'Shūji', '']);
    expect(grouped.first.value, ['Striking as Earth']);
    expect(grouped.last.value, ['Totally Homebrew Move']);
  });

  test('item patterns bucket under Item Patterns with their reference', () {
    final grouped = groupTechniques(['Striking as Earth', 'Kakita Pattern']);
    expect(grouped.map((g) => g.key).toList(), ['Kata', 'Item Patterns']);
    expect(grouped.last.value, ['Kakita Pattern']);
    final meta = techniqueMeta(
        'Kakita Pattern', lookupAppLocalizations(const Locale('en')));
    expect(meta, 'Rank 1 · SL p.109');
  });

  test('stanceRows lists all five stances with effects', () {
    final rows = stanceRows(lookupAppLocalizations(const Locale('en')));
    expect(rows.length, 5);
    expect(rows.first.first, 'Air');
    for (final row in rows) {
      expect(row.last, isNotEmpty);
    }
  });

  test('valid base64 of a truncated image falls back to a portrait-less sheet',
      () async {
    // Decodes fine but is not a parseable image, so the failure only
    // surfaces inside doc.save() — exercises the retry path.
    character.portraitB64 = base64Encode(
        base64Decode(character.portraitB64).sublist(0, 20));
    final bytes = await buildCharacterSheetPdf();
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    // Identical toggles minus the portrait must match the explicit opt-out.
    final noPortrait = await buildCharacterSheetPdf(showPortrait: false);
    expect(bytes.length, noPortrait.length);
  });
}
