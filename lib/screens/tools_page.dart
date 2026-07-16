import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../game_data.dart';
import '../l10n/l10n.dart';
import '../locale_controllers.dart';
import '../theme.dart';
import '../user_data_store.dart';
import 'descriptions_editor.dart';

/// Tools: rules descriptions and homebrew content (the original's Tools
/// menu, minus the SQLite-era CSV round trips).
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  String _homebrewPath = '';

  @override
  void initState() {
    super.initState();
    userDataStore.homebrewDir().then((dir) {
      if (mounted) setState(() => _homebrewPath = dir.path);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _importDescriptions() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null || !mounted) return;
    try {
      final count =
          await userDataStore.importDescriptions(utf8.decode(bytes));
      if (!mounted) return;
      _showMessage(context.l10n.importedDescriptions(count));
    } on FormatException {
      if (!mounted) return;
      _showMessage(context.l10n.couldNotReadDescriptionsFile);
    }
  }

  Future<void> _exportDescriptions() async {
    final count = gameData.descriptions.length;
    if (count == 0) {
      _showMessage(context.l10n.noDescriptionsToExport);
      return;
    }
    final bytes = utf8.encode(userDataStore.exportDescriptionsJson());
    // saveFile writes the bytes itself only on iOS/Android; on desktop it
    // returns the chosen path (and macOS rejects a bytes argument outright).
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final path = await FilePicker.platform.saveFile(
      fileName: 'user_descriptions.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: isDesktop ? null : bytes,
    );
    if (path == null || !mounted) return;
    if (isDesktop) {
      await File(path).writeAsBytes(bytes);
      if (!mounted) return;
    }
    _showMessage(context.l10n.exportedDescriptions(count));
  }

  Future<void> _reloadHomebrew() async {
    await userDataStore.loadHomebrew();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(userDataStore.loadedHomebrewFiles.isEmpty
            ? context.l10n.noHomebrewFilesFound
            : context.l10n
                .mergedFiles(userDataStore.loadedHomebrewFiles.join(', ')))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(l10n.appearanceSection),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListenableBuilder(
              listenable: themeController,
              builder: (context, _) => SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto_outlined)),
                ],
                selected: {themeController.value},
                onSelectionChanged: (selection) =>
                    themeController.set(selection.single),
              ),
            ),
          ),
          SectionHeader(l10n.languageSection),
          // Interface and game-content languages are deliberately
          // independent: a table can play with a French interface and the
          // English terms of their printed books, or vice versa. Either can
          // revert to English with one tap.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListenableBuilder(
              listenable: localeController,
              builder: (context, _) => Row(
                children: [
                  SizedBox(
                      width: 110, child: Text(l10n.languageInterface)),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: [
                        const ButtonSegment(
                            value: 'en', label: Text('English')),
                        const ButtonSegment(
                            value: 'fr', label: Text('Français')),
                        const ButtonSegment(
                            value: 'de', label: Text('Deutsch')),
                        ButtonSegment(
                            value: 'system', label: Text(l10n.themeSystem)),
                      ],
                      selected: {
                        localeController.value?.languageCode ?? 'system'
                      },
                      onSelectionChanged: (selection) => localeController.set(
                          selection.single == 'system'
                              ? null
                              : Locale(selection.single)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListenableBuilder(
              listenable: contentLocaleController,
              builder: (context, _) => Row(
                children: [
                  SizedBox(width: 110, child: Text(l10n.languageContent)),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: [
                        const ButtonSegment(
                            value: 'en', label: Text('English')),
                        const ButtonSegment(
                            value: 'fr', label: Text('Français')),
                        const ButtonSegment(
                            value: 'de', label: Text('Deutsch')),
                        ButtonSegment(
                            value: 'match',
                            label: Text(l10n.languageMatchInterface)),
                      ],
                      selected: {contentLocaleController.value ?? 'match'},
                      onSelectionChanged: (selection) =>
                          contentLocaleController.set(
                              selection.single == 'match'
                                  ? null
                                  : selection.single),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(l10n.rulesTextSection),
          ListTile(
            leading: const Icon(Icons.notes_outlined),
            title: Text(l10n.editRulesDescriptions),
            subtitle: Text(l10n.editRulesDescriptionsSubtitle),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DescriptionsEditor()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: Text(l10n.importDescriptions),
            subtitle: Text(l10n.importDescriptionsSubtitle),
            onTap: _importDescriptions,
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: Text(l10n.exportDescriptions),
            subtitle: Text(l10n.exportDescriptionsSubtitle),
            onTap: _exportDescriptions,
          ),
          SectionHeader(l10n.homebrewSection),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(l10n.homebrewFolder),
            subtitle: Text(l10n.homebrewFolderSubtitle(_homebrewPath)),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.reloadHomebrew),
            subtitle: Text(userDataStore.loadedHomebrewFiles.isEmpty
                ? l10n.nothingMergedThisSession
                : l10n.mergedFiles(
                    userDataStore.loadedHomebrewFiles.join(', '))),
            onTap: _reloadHomebrew,
          ),
        ],
      ),
    );
  }
}
