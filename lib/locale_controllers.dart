import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locales the interface can render. Anything else resolves to English.
const supportedUiLocales = [Locale('en'), Locale('fr')];

/// Language codes with a game-data overlay available ('en' means none).
const supportedContentCodes = ['en', 'fr'];

/// User-selected interface language, persisted across launches. A null value
/// means "follow the system locale", resolved against [supportedUiLocales]
/// with English as the fallback.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  static const _prefsKey = 'ui_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
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

/// User-selected game-content language, persisted across launches. A null
/// value means "match the interface language". Kept independent of
/// [LocaleController] so a table can run a localized interface with English
/// game terms (or vice versa).
class ContentLocaleController extends ValueNotifier<String?> {
  ContentLocaleController() : super(null);

  static const _prefsKey = 'content_locale';

  /// The content language code to actually use, given the interface locale
  /// the app resolved to.
  String effectiveCode(Locale resolvedUiLocale) {
    final code = value ?? resolvedUiLocale.languageCode;
    return supportedContentCodes.contains(code) ? code : 'en';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    value = supportedContentCodes.contains(saved) ? saved : null;
  }

  Future<void> set(String? code) async {
    value = code;
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, code);
    }
  }
}

final localeController = LocaleController();
final contentLocaleController = ContentLocaleController();
