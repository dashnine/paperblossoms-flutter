import 'package:flutter/material.dart';

import 'game_data.dart';
import 'screens/character_chooser.dart';
import 'theme.dart';
import 'user_data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await gameData.load();
  await userDataStore.loadDescriptions();
  await userDataStore.loadHomebrew();
  await themeController.load();
  runApp(const PaperBlossomsApp());
}

class PaperBlossomsApp extends StatelessWidget {
  const PaperBlossomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Paper Blossoms',
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeController.value,
        debugShowCheckedModeBanner: false,
        home: const CharacterChooser(),
      ),
    );
  }
}
