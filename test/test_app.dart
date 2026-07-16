import 'package:flutter/material.dart';
import 'package:paperblossoms/l10n/l10n.dart';
import 'package:paperblossoms/locale_controllers.dart';

/// Standard test harness: a MaterialApp with localization delegates and the
/// locale pinned (English by default) so `find.text(...)` assertions are
/// independent of the machine running the tests.
Widget testApp(Widget home,
    {Locale locale = const Locale('en'), ThemeData? theme}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: supportedUiLocales,
    theme: theme,
    home: home,
  );
}
