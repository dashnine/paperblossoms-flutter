import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locales the interface can render. Anything else resolves to English.
const supportedUiLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('de'),
  Locale('es'),
];

/// Language codes with a game-data overlay available ('en' means none).
const supportedContentCodes = ['en', 'fr', 'de', 'es'];

/// The data-overlay code to use for an interface locale: the same language
/// when an overlay ships for it, else English. Game data thus follows the
/// single language setting, degrading per-string to English via the
/// overlay's identity fallback when translations are missing.
String contentCodeFor(Locale locale) =>
    supportedContentCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';

/// User-selected app language, persisted across launches. A null value
/// means "follow the system locale", resolved against [supportedUiLocales]
/// with English as the fallback.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  static const _prefsKey = 'ui_locale';

  // Pre-single-control releases persisted a separate game-content language
  // under this key; it now seeds the unified setting once, then goes away.
  static const _legacyContentKey = 'content_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    var saved = prefs.getString(_prefsKey);
    final legacy = prefs.getString(_legacyContentKey);
    if (saved == null && legacy != null && legacy != 'en') {
      saved = legacy;
      await prefs.setString(_prefsKey, legacy);
    }
    if (legacy != null) await prefs.remove(_legacyContentKey);
    value = supportedUiLocales
        .cast<Locale?>()
        .firstWhere((l) => l!.languageCode == saved, orElse: () => null);
  }

  Future<void> set(Locale? locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final localeController = LocaleController();
