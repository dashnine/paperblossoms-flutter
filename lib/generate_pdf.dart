import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'character.dart';
import 'derived_stats.dart';
import 'game_data.dart';
import 'item.dart';
import 'rules_constants.dart';

const _accent = PdfColor.fromInt(0xFFB03060); // sakuraDeep
const _light = PdfColor.fromInt(0xFFF3E3EA);

/// Renders the character sheet as a PDF, mirroring the sections of the
/// original PB_TEMPLATE.html render dialog. Toggles match the original's
/// checkboxes for hiding the skill table and portrait.
Future<Uint8List> buildCharacterSheetPdf({
  bool showSkills = true,
  bool showPortrait = true,
}) async {
  try {
    return await _buildSheet(showSkills: showSkills, showPortrait: showPortrait);
  } catch (_) {
    // The portrait is the sheet's only per-character binary input; corrupt
    // bytes surface as a parse error inside doc.save(). Render the rest of
    // the sheet without it rather than failing the whole export.
    if (!showPortrait || character.portraitB64.isEmpty) rethrow;
    return _buildSheet(showSkills: showSkills, showPortrait: false);
  }
}

Future<Uint8List> _buildSheet({
  required bool showSkills,
  required bool showPortrait,
}) async {
  final c = character;

  // The pdf package's built-in Helvetica is Latin-1 only, which strips the
  // macrons from Ninjō, rōnin, etc. — embed Roboto for full Unicode support.
  // Loaded one by one: rootBundle can hand back SynchronousFutures, which
  // violate the Future contract and make Future.wait return an empty list.
  final fontData = [
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
    await rootBundle.load('assets/fonts/Roboto-BoldItalic.ttf'),
  ];
  // DejaVu catches the symbols Roboto lacks (→ and friends in user
  // descriptions).
  final fallback = pw.Font.ttf(
      await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
  final doc = pw.Document(
    title: 'Paper Blossoms — ${c.family} ${c.name}',
    theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(fontData[0]),
      bold: pw.Font.ttf(fontData[1]),
      italic: pw.Font.ttf(fontData[2]),
      boldItalic: pw.Font.ttf(fontData[3]),
      fontFallback: [fallback],
    ),
  );

  final rings = effectiveRingRanks(c);
  final skills = effectiveSkillRanks(c);
  final rank = recalcRank(c);
  final title = recalcTitle(c);
  final abilityList = abilities(c, rank.rank, title.currentTitle);
  final techniqueNames = knownTechniques(c);

  pw.Widget header(String text) => pw.Container(
        width: double.infinity,
        color: _light,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: _accent, fontSize: 12)),
      );

  pw.Widget stat(String label, String value) => pw.Column(children: [
        pw.Text(value,
            style:
                pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ]);

  // A pen-and-paper tracking row: one empty tick box per point up to
  // [limit], then a few grey overflow boxes for the state past the limit
  // (Incapacitated / Compromised). Current in-app values are deliberately
  // not printed — a printout is filled in by hand at the table.
  pw.Widget tickRow(String label, int limit, String overflowLabel) {
    pw.Widget box({bool grey = false}) => pw.Container(
          width: 9,
          height: 9,
          margin: const pw.EdgeInsets.only(right: 2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
                color: grey ? PdfColors.grey500 : PdfColors.grey800,
                width: 0.8),
          ),
        );
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
              width: 80,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
          for (var i = 0; i < limit; i++) box(),
          pw.SizedBox(width: 6),
          for (var i = 0; i < 4; i++) box(grey: true),
          pw.SizedBox(width: 4),
          pw.Text('→ $overflowLabel',
              style: const pw.TextStyle(
                  fontSize: 7.5, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  // A ruled blank line to write conditions/notes on by hand.
  pw.Widget writeInLine() => pw.Container(
        height: 13,
        margin: const pw.EdgeInsets.only(bottom: 3),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.7)),
        ),
      );

  pw.Widget table(List<String> columns, List<List<String>> rows) =>
      pw.TableHelper.fromTextArray(
        headers: columns,
        data: rows,
        headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: _accent),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellPadding:
            const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      );

  // Long description if the user has one, falling back to the short one.
  String longDescFor(String name) {
    final full = gameData.descriptionFor(name);
    return full.isNotEmpty ? full : gameData.shortDescFor(name);
  }

  // Item description: a per-item override wins, then the user descriptions.
  String itemDescFor(Item item) =>
      item.description.isNotEmpty ? item.description : longDescFor(item.name);

  // Compact "Name — description" paragraphs under an equipment table, one
  // per described item (deduped by name; empty when none are described).
  List<pw.Widget> itemDescriptions(Iterable<Item> items) {
    final seen = <String>{};
    final blocks = <pw.Widget>[];
    for (final item in items) {
      if (!seen.add(item.name)) continue;
      final desc = itemDescFor(item);
      if (desc.isEmpty) continue;
      blocks.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3),
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: '${item.name} — ',
                style: pw.TextStyle(
                    fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(
                text: desc, style: const pw.TextStyle(fontSize: 8.5)),
          ]),
        ),
      ));
    }
    return blocks;
  }

  // A named entry with its full description, as the original render dialog
  // lays out abilities, techniques and advantages/disadvantages.
  pw.Widget entry(String name, String meta) {
    final desc = longDescFor(name);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                  text: name,
                  style: pw.TextStyle(
                      fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              if (meta.isNotEmpty)
                pw.TextSpan(
                    text: '   $meta',
                    style: const pw.TextStyle(
                        fontSize: 8.5, color: PdfColors.grey700)),
            ]),
          ),
          if (desc.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1),
              child: pw.Text(desc, style: const pw.TextStyle(fontSize: 9)),
            ),
        ],
      ),
    );
  }

  final portraitBytes = showPortrait ? c.portraitBytes : null;
  pw.MemoryImage? portrait;
  if (portraitBytes != null) {
    try {
      portrait = pw.MemoryImage(portraitBytes);
    } catch (_) {
      // Undecodable image data (e.g. a truncated save) — drop the portrait
      // here; letting it fail asynchronously double-reports the error to the
      // zone even when caught, because the font loads above resume the
      // function synchronously off SynchronousFutures.
      portrait = null;
    }
  }

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(28),
    build: (context) => [
      // ---- Identity ----
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${c.family} ${c.name}'.trim(),
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text([
                  if (c.clan.isNotEmpty) c.clan,
                  if (c.school.isNotEmpty) c.school,
                  'Rank ${rank.rank}',
                  if (c.heritage.isNotEmpty && c.heritage != 'None')
                    'Heritage: ${c.heritage}',
                ].join(' · ')),
                pw.SizedBox(height: 6),
                pw.Row(children: [
                  stat('Honor', '${c.honor}'),
                  pw.SizedBox(width: 14),
                  stat('Glory', '${c.glory}'),
                  pw.SizedBox(width: 14),
                  stat('Status', '${c.status}'),
                  pw.SizedBox(width: 22),
                  stat('Endurance', '${endurance(rings)}'),
                  pw.SizedBox(width: 14),
                  stat('Composure', '${composure(rings)}'),
                  pw.SizedBox(width: 14),
                  stat('Focus', '${focus(rings)}'),
                  pw.SizedBox(width: 14),
                  stat('Vigilance', '${vigilance(rings)}'),
                ]),
              ],
            ),
          ),
          if (portrait != null)
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(portrait, fit: pw.BoxFit.cover),
            ),
        ],
      ),

      // ---- Rings ----
      header('Rings'),
      pw.Row(children: [
        for (final ring in [ringAir, ringEarth, ringFire, ringWater, ringVoid])
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 18),
            child: stat(ring, '${rings[ring] ?? 0}'),
          ),
      ]),

      // ---- Fatigue / strife / conditions, tracked by hand ----
      header('Fatigue, Strife & Conditions'),
      tickRow('Fatigue / ${endurance(rings)}', endurance(rings),
          'Incapacitated'),
      tickRow('Strife / ${composure(rings)}', composure(rings),
          'Compromised'),
      pw.SizedBox(height: 2),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.SizedBox(
            width: 80,
            child: pw.Text('Conditions',
                style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: writeInLine()),
      ]),
      pw.Row(children: [
        pw.SizedBox(width: 80),
        pw.Expanded(child: writeInLine()),
      ]),

      // ---- Social / wealth ----
      header('Wealth & Progress'),
      pw.Text('Wealth: ${c.koku} koku, ${c.bu} bu, ${c.zeni} zeni    ·    '
          'XP: ${xpSpent(c)} spent / ${c.totalXP} total    ·    '
          'XP in rank: ${rank.curriculumXP}'
          '${title.currentTitle.isEmpty ? '' : '    ·    Title: ${title.currentTitle} (${title.titleXP} XP)'}'),

      // ---- Abilities ----
      if (abilityList.isNotEmpty) header('Abilities'),
      for (final ability in abilityList) entry(ability, ''),

      // ---- Skills ----
      if (showSkills) ...[
        header('Skills'),
        table(
          ['Skill', 'Rank', 'Group'],
          [
            for (final group in gameData.skillGroups)
              for (final skill in group.skills)
                [skill, '${skills[skill] ?? 0}', group.name]
          ],
        ),
      ] else ...[
        header('Skills'),
        pw.Text(
            [
              for (final entry in skills.entries)
                if (entry.value > 0) '${entry.key} ${entry.value}'
            ].join(', '),
            style: const pw.TextStyle(fontSize: 9)),
      ],

      // ---- Techniques ----
      if (techniqueNames.isNotEmpty) header('Techniques'),
      for (final name in techniqueNames)
        entry(
          name,
          [
            if ((gameData.techniqueByName(name)?.category ?? '').isNotEmpty)
              gameData.techniqueByName(name)!.category,
            if (gameData.techniqueByName(name)?.rank != null)
              'Rank ${gameData.techniqueByName(name)!.rank}',
            if ('${gameData.techniqueByName(name)?.reference ?? ''}'
                .isNotEmpty)
              '${gameData.techniqueByName(name)!.reference}',
          ].join(' · '),
        ),

      // ---- Traits ----
      if (c.advDisadv.isNotEmpty) header('Distinctions & Adversities'),
      for (final name in c.advDisadv)
        entry(
          name,
          [
            if ((gameData.advDisadvByName(name)?.category ?? '').isNotEmpty)
              gameData.advDisadvByName(name)!.category,
            if ((gameData.advDisadvByName(name)?.ring ?? '').isNotEmpty)
              gameData.advDisadvByName(name)!.ring,
            if ('${gameData.advDisadvByName(name)?.reference ?? ''}'
                .isNotEmpty)
              '${gameData.advDisadvByName(name)!.reference}',
          ].join(' · '),
        ),

      // ---- Bonds ----
      if (c.bonds.isNotEmpty) header('Bonds'),
      if (c.bonds.isNotEmpty)
        table(
          ['Bond', 'Rank', 'Ability'],
          [
            for (final bond in c.bonds)
              [
                bond.name,
                '${bond.rank}',
                gameData.bondByName(bond.name)?.ability ?? '',
              ]
          ],
        ),

      // ---- Equipment ----
      if (c.equipment.any((item) => item.isWeapon)) header('Weapons'),
      if (c.equipment.any((item) => item.isWeapon))
        table(
          ['Name', 'Category', 'Skill', 'Grip', 'Range', 'Dmg', 'Dls',
              'Qualities'],
          [
            for (final group in Item.gripGroups(
                c.equipment.where((item) => item.isWeapon)))
              for (var i = 0; i < group.length; i++)
                [
                  i == 0 ? group.first.name : '',
                  i == 0 ? group.first.category : '',
                  i == 0 ? group.first.skill : '',
                  group[i].grip,
                  '${group[i].rangeMin}-${group[i].rangeMax}',
                  '${group[i].damage}',
                  '${group[i].deadliness}',
                  i == 0 ? group.first.qualities.join(', ') : '',
                ]
          ],
        ),
      ...itemDescriptions(c.equipment.where((item) => item.isWeapon)),
      if (c.equipment.any((item) => item.isArmor)) header('Armor'),
      if (c.equipment.any((item) => item.isArmor))
        table(
          ['Name', 'Physical', 'Supernatural', 'Qualities'],
          [
            for (final item in c.equipment)
              if (item.isArmor)
                [
                  item.name,
                  '${item.physicalResistance}',
                  '${item.supernaturalResistance}',
                  item.qualities.join(', '),
                ]
          ],
        ),
      ...itemDescriptions(c.equipment.where((item) => item.isArmor)),
      if (c.equipment.any((item) => !item.isWeapon && !item.isArmor))
        header('Personal Effects'),
      if (c.equipment.any((item) => !item.isWeapon && !item.isArmor))
        pw.Text(
            [
              for (final item in c.equipment)
                if (!item.isWeapon && !item.isArmor) item.name
            ].join(', '),
            style: const pw.TextStyle(fontSize: 9)),
      ...itemDescriptions(
          c.equipment.where((item) => !item.isWeapon && !item.isArmor)),

      // ---- Story ----
      if (c.ninjo.isNotEmpty) header('Ninjō'),
      if (c.ninjo.isNotEmpty)
        pw.Text(c.ninjo, style: const pw.TextStyle(fontSize: 9)),
      if (c.giri.isNotEmpty) header('Giri'),
      if (c.giri.isNotEmpty)
        pw.Text(c.giri, style: const pw.TextStyle(fontSize: 9)),
      if (c.notes.isNotEmpty) header('Notes'),
      if (c.notes.isNotEmpty)
        pw.Text(c.notes, style: const pw.TextStyle(fontSize: 8)),
    ],
  ));

  return doc.save();
}
