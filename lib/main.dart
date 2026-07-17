import 'package:flutter/material.dart';

import 'data_l10n.dart';
import 'game_data.dart';
import 'l10n/l10n.dart';
import 'locale_controllers.dart';
import 'screens/character_chooser.dart';
import 'theme.dart';
import 'user_data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await gameData.load();
  await userDataStore.loadDescriptions();
  await userDataStore.loadHomebrew();
  await themeController.load();
  await localeController.load();
  await dataL10n.setLocale(contentCodeFor(resolvedUiLocale()));
  localeController.addListener(_syncDataLocale);
  runApp(const PaperBlossomsApp());
}

/// The interface locale in effect: the user's explicit choice, else the
/// system locale resolved against the supported list, else English.
Locale resolvedUiLocale() {
  final explicit = localeController.value;
  if (explicit != null) return explicit;
  final system = WidgetsBinding.instance.platformDispatcher.locale;
  return supportedUiLocales.firstWhere(
      (l) => l.languageCode == system.languageCode,
      orElse: () => const Locale('en'));
}

void _syncDataLocale() {
  dataL10n.setLocale(contentCodeFor(resolvedUiLocale()));
}

class PaperBlossomsApp extends StatelessWidget {
  const PaperBlossomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([themeController, localeController, dataL10n]),
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeController.value,
        locale: localeController.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedUiLocales,
        localeResolutionCallback: (device, supported) =>
            supported.firstWhere((l) => l.languageCode == device?.languageCode,
                orElse: () => const Locale('en')),
        debugShowCheckedModeBanner: false,
        home: const CharacterChooser(),
      ),
    );
  }
}
