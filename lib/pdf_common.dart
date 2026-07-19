import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'character.dart';
import 'data_l10n.dart';
import 'game_data.dart';
import 'item.dart';
import 'l10n/app_localizations.dart';
import 'rules_constants.dart';

const pdfAccent = PdfColor.fromInt(0xFFB03060); // sakuraDeep
const pdfLight = PdfColor.fromInt(0xFFF3E3EA);

/// The app's canonical element colors, matching _ringColors in
/// widgets/ring_viewer.dart — keep the two in sync.
const pdfRingColors = {
  ringAir: PdfColor.fromInt(0xFFB59ED1), // lavender
  ringEarth: PdfColor.fromInt(0xFF5B8C5A), // green
  ringFire: PdfColor.fromInt(0xFFC94F3D), // red
  ringWater: PdfColor.fromInt(0xFF4A7BA6), // blue
  ringVoid: PdfColor.fromInt(0xFF54495E), // dark violet
};

/// The embedded font set shared by both sheet styles. [bold] and [fallback]
/// are exposed separately so decorative styles (the structured header's
/// Caveat name) can reuse them as fontFallback.
typedef SheetFonts = ({pw.ThemeData theme, pw.Font bold, pw.Font fallback});

/// The pdf package's built-in Helvetica is Latin-1 only, which strips the
/// macrons from Ninjō, rōnin, etc. — embed Roboto for full Unicode support.
/// Loaded one by one: rootBundle can hand back SynchronousFutures, which
/// violate the Future contract and make Future.wait return an empty list.
Future<SheetFonts> loadSheetTheme() async {
  final fontData = [
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
    await rootBundle.load('assets/fonts/Roboto-BoldItalic.ttf'),
  ];
  // DejaVu catches the symbols Roboto lacks (→ and friends in user
  // descriptions).
  final fallback =
      pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
  final bold = pw.Font.ttf(fontData[1]);
  return (
    theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(fontData[0]),
      bold: bold,
      italic: pw.Font.ttf(fontData[2]),
      boldItalic: pw.Font.ttf(fontData[3]),
      fontFallback: [fallback],
    ),
    bold: bold,
    fallback: fallback,
  );
}

/// The character's portrait as a pdf image, or null when hidden or absent.
pw.MemoryImage? decodePortrait(bool showPortrait) {
  final portraitBytes = showPortrait ? character.portraitBytes : null;
  if (portraitBytes == null) return null;
  try {
    return pw.MemoryImage(portraitBytes);
  } catch (_) {
    // Undecodable image data (e.g. a truncated save) — drop the portrait
    // here; letting it fail asynchronously double-reports the error to the
    // zone even when caught, because the font loads above resume the
    // function synchronously off SynchronousFutures.
    return null;
  }
}

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
              text: '${trData(item.name)} — ',
              style:
                  pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: desc, style: const pw.TextStyle(fontSize: 8.5)),
        ]),
      ),
    ));
  }
  return blocks;
}

// A named entry with its full description, as the original render dialog
// lays out abilities, techniques and advantages/disadvantages. [name] is
// the canonical English key (descriptions stay keyed by it); display is
// translated here.
pw.Widget entryBlock(String name, String meta) {
  final desc = longDescFor(name);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
                text: trData(name),
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

// A ruled blank line to write conditions/notes on by hand.
pw.Widget writeInLine() => pw.Container(
      height: 13,
      margin: const pw.EdgeInsets.only(bottom: 3),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.7)),
      ),
    );

// A pen-and-paper tracking row: one empty tick box per point up to
// [limit], then a few grey overflow boxes for the state past the limit
// (Incapacitated / Compromised). Current in-app values are deliberately
// not printed — a printout is filled in by hand at the table.
pw.Widget tickRow(String label, int limit, String overflowLabel,
    {double labelWidth = 80}) {
  pw.Widget box({bool grey = false}) => pw.Container(
        width: 9,
        height: 9,
        margin: const pw.EdgeInsets.only(right: 2),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
              color: grey ? PdfColors.grey500 : PdfColors.grey800, width: 0.8),
        ),
      );
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(
            width: labelWidth,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
        for (var i = 0; i < limit; i++) box(),
        pw.SizedBox(width: 6),
        for (var i = 0; i < 4; i++) box(grey: true),
        pw.SizedBox(width: 4),
        pw.Text('→ $overflowLabel',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
      ],
    ),
  );
}

pw.Widget sheetTable(List<String> columns, List<List<String>> rows,
        {PdfColor headerColor = pdfAccent,
        Map<int, pw.TableColumnWidth>? columnWidths}) =>
    pw.TableHelper.fromTextArray(
      headers: columns,
      data: rows,
      columnWidths: columnWidths,
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );

/// Column sizing for the stance table: without it the auto-width squeezes
/// the stance column until its localized header wraps mid-word.
final stanceColumnWidths = <int, pw.TableColumnWidth>{
  0: const pw.FixedColumnWidth(60),
  1: const pw.FlexColumnWidth(),
};

/// A row of [total] rank bubbles, filled up to [rank] (clamped) — the
/// pen-and-paper advancement convention from the official sheet.
pw.Widget rankBubbles(int rank,
        {int total = 5, double size = 5, PdfColor color = PdfColors.grey800}) =>
    pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          pw.Container(
            width: size,
            height: size,
            margin: const pw.EdgeInsets.only(right: 1.5),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: color, width: 0.6),
              color: i < rank.clamp(0, total) ? color : null,
            ),
          ),
      ],
    );

/// Buckets known techniques by data category, in canonical data order
/// (first appearance in gameData.techniques). Unknown/empty category → ''
/// bucket, which callers render as l10n.pdfOtherCategory, always last.
/// Order within a bucket = order in [names]; duplicates kept.
List<MapEntry<String, List<String>>> groupTechniques(List<String> names) {
  final order = <String>[];
  for (final t in gameData.techniques) {
    if (t.category.isNotEmpty && !order.contains(t.category)) {
      order.add(t.category);
    }
  }
  final buckets = <String, List<String>>{};
  for (final name in names) {
    buckets
        .putIfAbsent(gameData.techniqueByName(name)?.category ?? '', () => [])
        .add(name);
  }
  return [
    for (final cat in order)
      if (buckets.containsKey(cat)) MapEntry(cat, buckets[cat]!),
    if (buckets.containsKey('')) MapEntry('', buckets['']!),
  ];
}

/// Meta line for one technique listed under its category sub-header — rank
/// and reference only; the category itself is the sub-header.
String techniqueMeta(String name, AppLocalizations l10n) {
  final technique = gameData.techniqueByName(name);
  return [
    if (technique?.rank != null) l10n.rankN(technique!.rank),
    if ('${technique?.reference ?? ''}'.isNotEmpty) '${technique!.reference}',
  ].join(' · ');
}

/// The five stance rows for the conflict quick reference: [stance, effect].
/// Ring names go through the data overlay; effects are interface strings.
List<List<String>> stanceRows(AppLocalizations l10n) => [
      [trData(ringAir), l10n.pdfStanceAir],
      [trData(ringEarth), l10n.pdfStanceEarth],
      [trData(ringFire), l10n.pdfStanceFire],
      [trData(ringWater), l10n.pdfStanceWater],
      [trData(ringVoid), l10n.pdfStanceVoid],
    ];
