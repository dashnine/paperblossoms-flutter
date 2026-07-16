import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Display-time translation overlay for game-data strings.
///
/// English names from assets/data/ are the canonical identifiers everywhere
/// (lookups, rules logic, save files); this class only maps them to a
/// localized display string at render time. A missing entry — homebrew
/// content, untranslated additions, or a whole missing overlay — falls back
/// to the English string itself, so a partial or absent translation can
/// never break anything.
class DataL10n extends ChangeNotifier {
  DataL10n({Future<String> Function(String asset)? loader})
      : _loadAsset = loader ?? rootBundle.loadString;

  final Future<String> Function(String asset) _loadAsset;
  Map<String, String> _map = const {};
  String _code = 'en';

  /// Loads the overlay for [code], or clears it for 'en'. Any failure
  /// (missing asset, malformed JSON, wrong types) leaves the app in pure
  /// English rather than throwing.
  Future<void> setLocale(String code) async {
    if (code == _code) return;
    _code = code;
    var next = const <String, String>{};
    if (code != 'en') {
      try {
        final raw =
            jsonDecode(await _loadAsset('assets/i18n/data_$code.json'));
        next = {
          for (final e in (raw as Map).entries)
            if (e.key is String &&
                e.value is String &&
                (e.value as String).trim().isNotEmpty)
              e.key as String: (e.value as String).trim(),
        };
      } catch (_) {
        next = const {};
      }
    }
    _map = next;
    notifyListeners();
  }

  /// Localized display form of a canonical English data string.
  String tr(String english) => _map[english] ?? english;

  /// Localizes a stored condition display string such as
  /// 'Lightly Wounded (Fire)': a whole-string overlay entry wins, otherwise
  /// the base condition and the parenthesized qualifier are translated
  /// separately. Unrecognized shapes fall through via [tr]'s identity
  /// fallback, so this is safe for any display string.
  String trCondition(String condition) {
    final whole = _map[condition];
    if (whole != null) return whole;
    final m = RegExp(r'^(.*) \((.*)\)$').firstMatch(condition);
    if (m == null) return tr(condition);
    return '${tr(m.group(1)!)} (${tr(m.group(2)!)})';
  }

  /// Case- and diacritic-insensitive key for sorting and search matching.
  String sortKey(String display) {
    final buffer = StringBuffer();
    for (final rune in display.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_diacritics[ch] ?? ch);
    }
    return buffer.toString();
  }

  static const _diacritics = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
    'ç': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ó': 'o', 'ô': 'o', 'ö': 'o', 'ō': 'o', 'õ': 'o',
    'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u',
    'œ': 'oe', 'æ': 'ae',
    '’': "'",
  };
}

final dataL10n = DataL10n();

/// Shorthand used at name-display sites throughout the UI.
String trData(String english) => dataL10n.tr(english);
