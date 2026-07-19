import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'character.dart';
import 'data_l10n.dart';
import 'derived_stats.dart';
import 'game_data.dart';
import 'generate_pdf_structured.dart';
import 'item.dart';
import 'l10n/app_localizations.dart';
import 'pdf_common.dart';
import 'rules_constants.dart';
import 'sheet_style_controller.dart';

/// Renders the character sheet as a PDF in the chosen [style]. The
/// minimalist style mirrors the sections of the original PB_TEMPLATE.html
/// render dialog; toggles match the original's checkboxes for hiding the
/// skill table and portrait.
Future<Uint8List> buildCharacterSheetPdf({
  bool showSkills = true,
  bool showPortrait = true,
  AppLocalizations? strings,
  SheetStyle style = SheetStyle.structured,
}) async {
  // Sheet chrome follows the interface language; callers with a BuildContext
  // pass AppLocalizations.of(context). Data names on the sheet follow the
  // content language separately (via the data overlay at display sites).
  final l10n = strings ?? lookupAppLocalizations(const Locale('en'));
  Future<Uint8List> build(bool portrait) => style == SheetStyle.structured
      ? buildStructuredSheet(
          showSkills: showSkills, showPortrait: portrait, l10n: l10n)
      : buildMinimalistSheet(
          showSkills: showSkills, showPortrait: portrait, l10n: l10n);
  try {
    return await build(showPortrait);
  } catch (_) {
    // The portrait is the sheet's only per-character binary input; corrupt
    // bytes surface as a parse error inside doc.save(). Render the rest of
    // the sheet without it rather than failing the whole export.
    if (!showPortrait || character.portraitB64.isEmpty) rethrow;
    return build(false);
  }
}

Future<Uint8List> buildMinimalistSheet({
  required bool showSkills,
  required bool showPortrait,
  required AppLocalizations l10n,
}) async {
  final c = character;

  final fonts = await loadSheetTheme();
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

  pw.Widget header(String text) => pw.Container(
        width: double.infinity,
        color: pdfLight,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: pdfAccent,
                fontSize: 12)),
      );

  pw.Widget stat(String label, String value) => pw.Column(children: [
        pw.Text(value,
            style:
                pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ]);

  final portrait = decodePortrait(showPortrait);

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
                  if (c.clan.isNotEmpty) trData(c.clan),
                  if (c.school.isNotEmpty) trData(c.school),
                  l10n.rankN(rank.rank),
                  if (c.heritage.isNotEmpty && c.heritage != 'None')
                    l10n.heritageHeader(trData(c.heritage)),
                ].join(' · ')),
                pw.SizedBox(height: 6),
                pw.Row(children: [
                  stat(l10n.honor, '${c.honor}'),
                  pw.SizedBox(width: 14),
                  stat(l10n.glory, '${c.glory}'),
                  pw.SizedBox(width: 14),
                  stat(l10n.statusLabel, '${c.status}'),
                  pw.SizedBox(width: 22),
                  stat(l10n.endurance, '${endurance(rings)}'),
                  pw.SizedBox(width: 14),
                  stat(l10n.composure, '${composure(rings)}'),
                  pw.SizedBox(width: 14),
                  stat(l10n.focusStat, '${focus(rings)}'),
                  pw.SizedBox(width: 14),
                  stat(l10n.vigilance, '${vigilance(rings)}'),
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
      header(l10n.ringsSection),
      pw.Row(children: [
        for (final ring in [ringAir, ringEarth, ringFire, ringWater, ringVoid])
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 18),
            child: stat(trData(ring), '${rings[ring] ?? 0}'),
          ),
      ]),

      // ---- Fatigue / strife / conditions, tracked by hand ----
      header(l10n.pdfFatigueStrifeConditions),
      tickRow(l10n.fatigueOf(endurance(rings)), endurance(rings),
          trData('Incapacitated')),
      tickRow(l10n.strifeOf(composure(rings)), composure(rings),
          trData('Compromised')),
      pw.SizedBox(height: 2),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.SizedBox(
            width: 80,
            child: pw.Text(l10n.conditionsSection,
                style: const pw.TextStyle(fontSize: 9))),
        pw.Expanded(child: writeInLine()),
      ]),
      pw.Row(children: [
        pw.SizedBox(width: 80),
        pw.Expanded(child: writeInLine()),
      ]),

      // ---- Social / wealth ----
      header(l10n.pdfWealthProgress),
      pw.Text(l10n.pdfWealthLine(c.koku, c.bu, c.zeni, xpSpent(c), c.totalXP,
              rank.curriculumXP) +
          (title.currentTitle.isEmpty
              ? ''
              : l10n.pdfTitlePart(trData(title.currentTitle), title.titleXP))),

      // ---- Abilities ----
      if (abilityList.isNotEmpty) header(l10n.abilitiesSection),
      for (final ability in abilityList) entryBlock(ability, ''),

      // ---- Skills ----
      if (showSkills) ...[
        header(l10n.skillsSection),
        sheetTable(
          [l10n.colSkill, l10n.rankLabel, l10n.groupLabel],
          [
            for (final group in gameData.skillGroups)
              for (final skill in group.skills)
                [trData(skill), '${skills[skill] ?? 0}', trData(group.name)]
          ],
        ),
      ] else ...[
        header(l10n.skillsSection),
        pw.Text(
            [
              for (final entry in skills.entries)
                if (entry.value > 0) '${trData(entry.key)} ${entry.value}'
            ].join(', '),
            style: const pw.TextStyle(fontSize: 9)),
      ],

      // ---- Techniques, grouped by category ----
      if (techniqueNames.isNotEmpty) header(l10n.techniquesSection),
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

      // ---- Traits ----
      if (c.advDisadv.isNotEmpty) header(l10n.pdfTraitsHeader),
      for (final name in c.advDisadv)
        entryBlock(
          name,
          [
            if ((gameData.advDisadvByName(name)?.category ?? '').isNotEmpty)
              trData(gameData.advDisadvByName(name)!.category),
            if ((gameData.advDisadvByName(name)?.ring ?? '').isNotEmpty)
              trData(gameData.advDisadvByName(name)!.ring),
            if ('${gameData.advDisadvByName(name)?.reference ?? ''}'
                .isNotEmpty)
              '${gameData.advDisadvByName(name)!.reference}',
          ].join(' · '),
        ),

      // ---- Bonds ----
      if (c.bonds.isNotEmpty) header(l10n.bondsSection),
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
        header(l10n.weaponsSection),
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
      if (c.equipment.any((item) => item.isArmor)) header(l10n.armorSection),
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
        header(l10n.personalEffectsSection),
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
      if (c.ninjo.isNotEmpty) header(l10n.ninjoHeader),
      if (c.ninjo.isNotEmpty)
        pw.Text(c.ninjo, style: const pw.TextStyle(fontSize: 9)),
      if (c.giri.isNotEmpty) header(l10n.giriHeader),
      if (c.giri.isNotEmpty)
        pw.Text(c.giri, style: const pw.TextStyle(fontSize: 9)),

      // ---- Conflict quick reference ----
      header(l10n.pdfStancesHeader),
      sheetTable([l10n.colStance, l10n.colEffect], stanceRows(l10n),
          columnWidths: stanceColumnWidths),

      // ---- Notes, last so table jottings stay next to blank paper ----
      if (c.notes.isNotEmpty) header(l10n.notesSection),
      if (c.notes.isNotEmpty)
        pw.Text(c.notes, style: const pw.TextStyle(fontSize: 8)),
    ],
  ));

  return doc.save();
}
