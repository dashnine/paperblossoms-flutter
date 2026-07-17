import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/i18n_harvest.dart';

/// Guards the data-translation overlays against drifting out of sync with
/// the game data: a data-audit rename must update the overlay in the same
/// commit, or this fails. Missing translations (coverage gaps) are
/// deliberately NOT failures — new content simply shows in English until an
/// overlay entry arrives.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Set<String> harvest;

  setUpAll(() async {
    await gameData.load();
    harvest = translatableDataStrings();
    // Side effect for scripts/import_i18n_fr.py: the authoritative list of
    // translatable strings, one source of truth for tooling and CI.
    File('build/l10n_harvest.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(harvest.toList()..sort()));
  });

  for (final locale in ['fr', 'de', 'es']) {
    group('data_$locale.json', () {
      late Map<String, dynamic> overlay;

      setUpAll(() async {
        overlay = jsonDecode(
                await rootBundle.loadString('assets/i18n/data_$locale.json'))
            as Map<String, dynamic>;
      });

      test('every key matches a current translatable data string', () {
        final orphans = [
          for (final key in overlay.keys)
            if (!harvest.contains(key)) key
        ]..sort();
        expect(orphans, isEmpty,
            reason: 'Orphaned overlay keys (likely renamed in a data audit); '
                'update assets/i18n/data_$locale.json in the same commit: '
                '$orphans');
      });

      test('entries are non-empty strings without stray whitespace', () {
        for (final entry in overlay.entries) {
          expect(entry.value, isA<String>(),
              reason: '"${entry.key}" has a non-string value');
          final value = entry.value as String;
          expect(value.trim(), isNotEmpty,
              reason: '"${entry.key}" has an empty translation '
                  '(omit the key instead)');
          expect(value, value.trim(),
              reason: '"${entry.key}" has surrounding whitespace');
          expect(entry.key, entry.key.trim(),
              reason: 'key "${entry.key}" has surrounding whitespace');
        }
      });

      test('coverage report (informational)', () {
        final translated = overlay.keys.where(harvest.contains).length;
        final pct = (translated / harvest.length * 100).toStringAsFixed(1);
        // ignore: avoid_print
        print('[$locale] $translated / ${harvest.length} data strings '
            'translated ($pct%)');
      });
    });
  }
}
