import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'data_l10n.dart';
import 'encounter.dart';
import 'game_data.dart';
import 'l10n/app_localizations.dart';
import 'npc_math.dart';
import 'npc_models.dart';
import 'pdf_common.dart';

/// Printable stat block for one NPC.
Future<Uint8List> buildNpcPdf(
  Npc npc, {
  required AppLocalizations strings,
  PdfPageFormat pageFormat = PdfPageFormat.a4,
}) async {
  final fonts = await loadSheetTheme();
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      theme: fonts.theme,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => _statBlock(npc, strings),
    ),
  );
  return doc.save();
}

/// Printable encounter: summary card (roster, encounter ranks, party
/// group-rank thresholds) followed by one stat block per unique NPC.
Future<Uint8List> buildEncounterPdf(
  Encounter encounter,
  List<({Npc npc, int count})> roster, {
  required AppLocalizations strings,
  PdfPageFormat pageFormat = PdfPageFormat.a4,
}) async {
  final fonts = await loadSheetTheme();
  final rank = encounterRank(roster);
  final combat = groupRankThresholds(rank.combat);
  final intrigue = groupRankThresholds(rank.intrigue);
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      theme: fonts.theme,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        _titleBar(encounter.name),
        pw.SizedBox(height: 6),
        sheetTable(
          [strings.nameLabel, '×', strings.npcConflictRank],
          [
            for (final e in roster)
              [
                trData(e.npc.name),
                '${e.count}',
                strings.npcCombatIntrigue(e.npc.crCombat, e.npc.crIntrigue),
              ],
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(strings.encCombatRank(rank.combat),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        _thresholdLines(combat, strings),
        pw.SizedBox(height: 4),
        pw.Text(strings.encIntrigueRank(rank.intrigue),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        _thresholdLines(intrigue, strings),
        pw.SizedBox(height: 2),
        pw.Text(strings.encGroupRankHint,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        if (encounter.notes.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text(encounter.notes, style: const pw.TextStyle(fontSize: 9)),
        ],
        pw.SizedBox(height: 12),
        for (final e in roster) ...[
          ..._statBlock(e.npc, strings,
              countSuffix: e.count > 1 ? ' ×${e.count}' : ''),
          pw.SizedBox(height: 14),
        ],
      ],
    ),
  );
  return doc.save();
}

pw.Widget _thresholdLines(
        ({int even, int easy, int hard}) t, AppLocalizations strings) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(strings.encEven(t.even),
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(strings.encEasy(t.easy),
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(strings.encHard(t.hard),
              style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );

pw.Widget _titleBar(String title) => pw.Container(
      width: double.infinity,
      color: pdfAccent,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );

List<pw.Widget> _statBlock(Npc npc, AppLocalizations strings,
    {String countSuffix = ''}) {
  pw.Widget label(String text) => pw.Text(text,
      style: pw.TextStyle(
          fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: pdfAccent));
  return [
    // Header + core numbers travel as one unbreakable unit so a page break
    // never orphans a title bar.
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _titleBar('${trData(npc.name)}$countSuffix'),
        pw.SizedBox(height: 3),
        pw.Text(
          '${npc.isMinion ? strings.npcTypeMinion : strings.npcTypeAdversary}'
          ' · ${strings.npcConflictRank}: '
          '${strings.npcCombatIntrigue(npc.crCombat, npc.crIntrigue)}',
          style: const pw.TextStyle(fontSize: 9.5),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            for (final e in npc.rings.entries)
              pw.Container(
                margin: const pw.EdgeInsets.only(right: 4),
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: pdfRingColors[e.key] ?? PdfColors.grey700,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  '${trData(e.key)} ${e.value}',
                  style: const pw.TextStyle(
                      fontSize: 8.5, color: PdfColors.white),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          [
            '${strings.endurance} ${npc.derived.endurance}',
            '${strings.composure} ${npc.derived.composure}',
            '${strings.focusStat} ${npc.derived.focus}',
            '${strings.vigilance} ${npc.derived.vigilance}',
            if (npc.social != null) ...[
              '${strings.honor} ${npc.social!.honor}',
              '${strings.glory} ${npc.social!.glory}',
              '${strings.statusLabel} ${npc.social!.status}',
            ],
          ].join(' · '),
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '${strings.npcDemeanorLabel}: ${trData(npc.demeanor)}'
          '${_demeanorMeta(npc.demeanor, strings)}',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Text(
          [
            for (final e in npc.skillGroups.entries)
              '${trData(e.key)} ${e.value}'
          ].join(' · '),
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    ),
    pw.SizedBox(height: 5),
    if (npc.advantages.isNotEmpty || npc.disadvantages.isNotEmpty)
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                label(strings.npcAdvantagesLabel),
                for (final a in npc.advantages) _traitLine(a),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                label(strings.npcDisadvantagesLabel),
                for (final d in npc.disadvantages) _traitLine(d),
              ],
            ),
          ),
        ],
      ),
    pw.SizedBox(height: 5),
    label(strings.npcWeaponsGear),
    for (final w in npc.weapons)
      pw.Text(
        '${trData(w.name)}: ${strings.colRange} ${w.range}, '
        '${strings.damageLabel} ${w.damage}, '
        '${strings.deadlinessLabel} ${w.deadliness}'
        '${w.qualities.isEmpty ? '' : ', ${w.qualities.map(trData).join(', ')}'}',
        style: const pw.TextStyle(fontSize: 9),
      ),
    if (npc.gearEquipped.isNotEmpty)
      pw.Text(
        '${strings.npcGearEquipped}: '
        '${npc.gearEquipped.map(trData).join(', ')}',
        style: const pw.TextStyle(fontSize: 9),
      ),
    if (npc.gearOther.isNotEmpty)
      pw.Text(
        '${strings.npcGearOther}: ${npc.gearOther.map(trData).join(', ')}',
        style: const pw.TextStyle(fontSize: 9),
      ),
    if (npc.abilities.isNotEmpty) ...[
      pw.SizedBox(height: 5),
      label(strings.abilitiesSection),
      for (final a in npc.abilities)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(trData(a.name),
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text(trData(a.text), style: const pw.TextStyle(fontSize: 9)),
              if ('${a.reference}'.isNotEmpty)
                pw.Text('${a.reference}',
                    style: const pw.TextStyle(
                        fontSize: 7.5, color: PdfColors.grey600)),
            ],
          ),
        ),
    ],
    if (npc.techniques.isNotEmpty) ...[
      pw.SizedBox(height: 2),
      label(strings.npcTechniquesLabel),
      for (final name in npc.techniques)
        entryBlock(name, techniqueMeta(name, strings)),
    ],
    if (npc.isMinion) ...[
      pw.SizedBox(height: 4),
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          color: pdfLight,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(strings.npcMinionRules,
            style: const pw.TextStyle(fontSize: 7.5)),
      ),
    ],
    if ('${npc.reference}'.isNotEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3),
        child: pw.Text('${npc.reference}',
            style:
                const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
      ),
  ];
}

String _demeanorMeta(String name, AppLocalizations strings) {
  final demeanor = gameData.npc.demeanorByName(name);
  if (demeanor == null || demeanor.modifiers.isEmpty) return '';
  return ' — ${strings.npcDemeanorTnMods(demeanor.modifierLine(trData))}';
}

pw.Widget _traitLine(NpcTrait trait) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '${trData(trait.name)} (${trData(trait.ring)}): ',
              style:
                  pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: '${trait.groups.map(trData).join(', ')}; '
                  '${trait.types.map(trData).join(', ')}',
              style: const pw.TextStyle(
                  fontSize: 8.5, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
