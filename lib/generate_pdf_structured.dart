import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'character.dart';
import 'data_l10n.dart';
import 'derived_stats.dart';
import 'game_data.dart';
import 'item.dart';
import 'l10n/app_localizations.dart';
import 'pdf_common.dart';
import 'rules_constants.dart';

/// The structured sheet follows the official character sheet's conventions —
/// ring circles with rank bubbles, skills in group columns, empty tracking
/// boxes for fatigue/strife/Void points, the four-way trait split — while
/// keeping the app's sakura identity in the header. Like the minimalist
/// sheet, tracked values print blank: the printout is filled in by hand.
Future<Uint8List> buildStructuredSheet({
  required bool showSkills,
  required bool showPortrait,
  required AppLocalizations l10n,
}) async {
  final c = character;

  // Sequential awaits, same as loadSheetTheme: rootBundle can hand back
  // SynchronousFutures, which break Future.wait.
  final fonts = await loadSheetTheme();
  final caveat =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Caveat-Bold.ttf'));
  final sakura = pw.MemoryImage(
      (await rootBundle.load('assets/images/sakura.png')).buffer.asUint8List());
  final portrait = decodePortrait(showPortrait);

  final doc = pw.Document(
    title: 'Paper Blossoms — ${c.family} ${c.name}',
    theme: fonts.theme,
  );

  final rings = effectiveRingRanks(c);
  final skills = effectiveSkillRanks(c);
  final rank = recalcRank(c);
  final title = recalcTitle(c);
  final abilityList = abilities(c, rank.rank, title.currentTitle);
  final techniqueNames = knownTechniques(c);

  pw.Widget boxedHeader(String text) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
        decoration: pw.BoxDecoration(
          color: pdfLight,
          border: pw.Border.all(color: pdfAccent, width: 0.8),
        ),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: pdfAccent,
                fontSize: 11)),
      );

  pw.Widget valueBox(String label, String value, {double width = 58}) =>
      pw.Column(children: [
        pw.Container(
          width: width,
          height: 22,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey800, width: 0.8),
          ),
          child: pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 1),
        pw.Text(label, style: const pw.TextStyle(fontSize: 7.5)),
      ]);

  pw.Widget checkboxRow(int count, {double size = 8}) => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            pw.Container(
              width: size,
              height: size,
              margin: const pw.EdgeInsets.only(right: 2),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey800, width: 0.8),
              ),
            ),
        ],
      );

  pw.Widget ringCircle(String ring) {
    final color = pdfRingColors[ring] ?? PdfColors.grey800;
    return pw.Column(children: [
      pw.Container(
        width: 56,
        height: 56,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: color, width: 1.5),
        ),
        child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.Text(trData(ring),
              style: pw.TextStyle(fontSize: 7, color: color)),
          pw.Text('${rings[ring] ?? 0}',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ]),
      ),
      pw.SizedBox(height: 3),
      rankBubbles(rings[ring] ?? 0, size: 6, color: color),
    ]);
  }

  // Skill-group column cell: group name over one name+bubbles row per skill.
  pw.Widget skillGroupCell(String groupName, List<String> shownSkills) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(right: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(trData(groupName),
                style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfAccent)),
            pw.SizedBox(height: 2),
            for (final skill in shownSkills)
              pw.Row(children: [
                pw.Expanded(
                    child: pw.Text(trData(skill),
                        style: const pw.TextStyle(fontSize: 7.5))),
                pw.SizedBox(width: 2),
                rankBubbles(skills[skill] ?? 0),
              ]),
          ],
        ),
      );

  // Groups with the skills each should show, honoring the skills toggle.
  final skillColumns = <MapEntry<String, List<String>>>[
    for (final group in gameData.skillGroups)
      if (showSkills)
        MapEntry(group.name, group.skills)
      else if (group.skills.any((skill) => (skills[skill] ?? 0) > 0))
        MapEntry(group.name,
            [for (final s in group.skills) if ((skills[s] ?? 0) > 0) s]),
  ];

  // Traits bucketed into the official four-way split; anything homebrew
  // outside those categories keeps its own bucket at the end.
  const traitOrder = ['Distinctions', 'Passions', 'Adversities', 'Anxieties'];
  final traitBuckets = {for (final cat in traitOrder) cat: <String>[]};
  final otherTraits = <String>[];
  for (final name in c.advDisadv) {
    final cat = gameData.advDisadvByName(name)?.category ?? '';
    (traitBuckets[cat] ?? otherTraits).add(name);
  }

  String traitMeta(String name) => [
        if ((gameData.advDisadvByName(name)?.ring ?? '').isNotEmpty)
          trData(gameData.advDisadvByName(name)!.ring),
        if ('${gameData.advDisadvByName(name)?.reference ?? ''}'.isNotEmpty)
          '${gameData.advDisadvByName(name)!.reference}',
      ].join(' · ');

  final displayName = '${c.family} ${c.name}'.trim();
  final footerName = displayName.isEmpty ? l10n.unnamedSamurai : displayName;

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(28),
    footer: (context) => pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
          '$footerName · ${l10n.pdfPageOf(context.pageNumber, context.pagesCount)}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
    ),
    build: (context) => [
      // ---- Header / branding ----
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Opacity(
              opacity: 0.35, child: pw.Image(sakura, width: 52, height: 52)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(displayName,
                    style: pw.TextStyle(
                        font: caveat,
                        fontSize: 30,
                        fontFallback: [fonts.bold, fonts.fallback])),
                pw.Text([
                  if (c.clan.isNotEmpty) trData(c.clan),
                  if (c.school.isNotEmpty) trData(c.school),
                  l10n.rankN(rank.rank),
                  if (c.heritage.isNotEmpty && c.heritage != 'None')
                    l10n.heritageHeader(trData(c.heritage)),
                ].join(' · ')),
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
      boxedHeader(l10n.ringsSection),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          for (final ring
              in [ringAir, ringEarth, ringFire, ringWater, ringVoid])
            ringCircle(ring),
        ],
      ),

      // ---- Derived attributes with their tracks ----
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 10),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey800, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              valueBox(l10n.endurance, '${endurance(rings)}'),
              pw.SizedBox(width: 8),
              pw.Expanded(
                  child: tickRow(l10n.fatigueOf(endurance(rings)),
                      endurance(rings), trData('Incapacitated'),
                      labelWidth: 70)),
            ]),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              valueBox(l10n.composure, '${composure(rings)}'),
              pw.SizedBox(width: 8),
              pw.Expanded(
                  child: tickRow(l10n.strifeOf(composure(rings)),
                      composure(rings), trData('Compromised'),
                      labelWidth: 70)),
            ]),
            pw.SizedBox(height: 4),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              valueBox(l10n.focusStat, '${focus(rings)}'),
              pw.SizedBox(width: 8),
              valueBox(l10n.vigilance, '${vigilance(rings)}'),
              pw.SizedBox(width: 16),
              pw.Text(l10n.pdfVoidPoints,
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(width: 6),
              checkboxRow(rings[ringVoid] ?? 0),
            ]),
            pw.SizedBox(height: 6),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.SizedBox(
                  width: 70,
                  child: pw.Text(l10n.conditionsSection,
                      style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(child: writeInLine()),
            ]),
            pw.Row(children: [
              pw.SizedBox(width: 70),
              pw.Expanded(child: writeInLine()),
            ]),
          ],
        ),
      ),

      // ---- Social standing, wealth & progress ----
      boxedHeader(l10n.pdfWealthProgress),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          valueBox(l10n.honor, '${c.honor}', width: 50),
          valueBox(l10n.glory, '${c.glory}', width: 50),
          valueBox(l10n.statusLabel, '${c.status}', width: 50),
          valueBox(l10n.koku, '${c.koku}', width: 44),
          valueBox(l10n.bu, '${c.bu}', width: 44),
          valueBox(l10n.zeni, '${c.zeni}', width: 44),
          valueBox(l10n.xpSpentLabel, '${xpSpent(c)}', width: 54),
          valueBox(l10n.pdfXpTotalLabel, '${c.totalXP}', width: 54),
          valueBox(l10n.xpInRank, '${rank.curriculumXP}', width: 54),
        ],
      ),
      if (title.currentTitle.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
              l10n.pdfTitleBox(trData(title.currentTitle), title.titleXP),
              style: const pw.TextStyle(fontSize: 9)),
        ),

      // ---- Abilities ----
      if (abilityList.isNotEmpty) boxedHeader(l10n.abilitiesSection),
      for (final ability in abilityList) entryBlock(ability, ''),

      // ---- Skills, in columns by group ----
      if (skillColumns.isNotEmpty) boxedHeader(l10n.skillsSection),
      for (var i = 0; i < skillColumns.length; i += 5)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final column in skillColumns.skip(i).take(5))
                pw.Expanded(child: skillGroupCell(column.key, column.value)),
            ],
          ),
        ),

      // ---- Techniques, grouped by category ----
      if (techniqueNames.isNotEmpty) boxedHeader(l10n.techniquesSection),
      for (final group in groupTechniques(techniqueNames)) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2, bottom: 3),
          child: pw.Text(
              group.key.isEmpty ? l10n.pdfOtherCategory : trData(group.key),
              style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfAccent)),
        ),
        for (final name in group.value)
          entryBlock(name, techniqueMeta(name, l10n)),
      ],

      // ---- Traits, split the official way ----
      for (final cat in traitOrder)
        if (traitBuckets[cat]!.isNotEmpty) ...[
          boxedHeader(trData(cat)),
          for (final name in traitBuckets[cat]!)
            entryBlock(name, traitMeta(name)),
        ],
      if (otherTraits.isNotEmpty) ...[
        boxedHeader(l10n.pdfOtherCategory),
        for (final name in otherTraits) entryBlock(name, traitMeta(name)),
      ],

      // ---- Bonds ----
      if (c.bonds.isNotEmpty) boxedHeader(l10n.bondsSection),
      if (c.bonds.isNotEmpty)
        sheetTable(
          [l10n.bondLabel, l10n.rankLabel, l10n.colAbility],
          [
            for (final bond in c.bonds)
              [
                trData(bond.name),
                '${bond.rank}',
                trData(gameData.bondByName(bond.name)?.ability ?? ''),
              ]
          ],
        ),

      // ---- Equipment ----
      if (c.equipment.any((item) => item.isWeapon))
        boxedHeader(l10n.weaponsSection),
      if (c.equipment.any((item) => item.isWeapon))
        sheetTable(
          [
            l10n.colName,
            l10n.colCategory,
            l10n.colSkill,
            l10n.colGrip,
            l10n.colRange,
            l10n.colDamage,
            l10n.colDeadliness,
            l10n.colQualities
          ],
          [
            for (final group in Item.gripGroups(
                c.equipment.where((item) => item.isWeapon)))
              for (var i = 0; i < group.length; i++)
                [
                  i == 0 ? trData(group.first.name) : '',
                  i == 0 ? trData(group.first.category) : '',
                  i == 0 ? trData(group.first.skill) : '',
                  trData(group[i].grip),
                  '${group[i].rangeMin}-${group[i].rangeMax}',
                  '${group[i].damage}',
                  '${group[i].deadliness}',
                  i == 0 ? group.first.qualities.map(trData).join(', ') : '',
                ]
          ],
        ),
      ...itemDescriptions(c.equipment.where((item) => item.isWeapon)),
      if (c.equipment.any((item) => item.isArmor))
        boxedHeader(l10n.armorSection),
      if (c.equipment.any((item) => item.isArmor))
        sheetTable(
          [
            l10n.colName,
            l10n.colPhysical,
            l10n.colSupernatural,
            l10n.colQualities
          ],
          [
            for (final item in c.equipment)
              if (item.isArmor)
                [
                  trData(item.name),
                  '${item.physicalResistance}',
                  '${item.supernaturalResistance}',
                  item.qualities.map(trData).join(', '),
                ]
          ],
        ),
      ...itemDescriptions(c.equipment.where((item) => item.isArmor)),
      if (c.equipment.any((item) => !item.isWeapon && !item.isArmor))
        boxedHeader(l10n.personalEffectsSection),
      if (c.equipment.any((item) => !item.isWeapon && !item.isArmor))
        pw.Text(
            [
              for (final item in c.equipment)
                if (!item.isWeapon && !item.isArmor) trData(item.name)
            ].join(', '),
            style: const pw.TextStyle(fontSize: 9)),
      ...itemDescriptions(
          c.equipment.where((item) => !item.isWeapon && !item.isArmor)),

      // ---- Story ----
      if (c.ninjo.isNotEmpty) boxedHeader(l10n.ninjoHeader),
      if (c.ninjo.isNotEmpty)
        pw.Text(c.ninjo, style: const pw.TextStyle(fontSize: 9)),
      if (c.giri.isNotEmpty) boxedHeader(l10n.giriHeader),
      if (c.giri.isNotEmpty)
        pw.Text(c.giri, style: const pw.TextStyle(fontSize: 9)),

      // ---- Conflict quick reference ----
      boxedHeader(l10n.pdfStancesHeader),
      sheetTable([l10n.colStance, l10n.colEffect], stanceRows(l10n),
          columnWidths: stanceColumnWidths),

      // ---- Notes, last so table jottings stay next to blank paper ----
      if (c.notes.isNotEmpty) boxedHeader(l10n.notesSection),
      if (c.notes.isNotEmpty)
        pw.Text(c.notes, style: const pw.TextStyle(fontSize: 8)),
    ],
  ));

  return doc.save();
}
