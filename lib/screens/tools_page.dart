import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../game_data.dart';
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
      _showMessage('Imported $count description${count == 1 ? '' : 's'}.');
    } on FormatException {
      if (!mounted) return;
      _showMessage("Couldn't read that file as descriptions JSON or CSV.");
    }
  }

  Future<void> _exportDescriptions() async {
    final count = gameData.descriptions.length;
    if (count == 0) {
      _showMessage('No descriptions to export.');
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
    _showMessage('Exported $count description${count == 1 ? '' : 's'}.');
  }

  Future<void> _reloadHomebrew() async {
    await userDataStore.loadHomebrew();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(userDataStore.loadedHomebrewFiles.isEmpty
            ? 'No homebrew files found.'
            : 'Merged: ${userDataStore.loadedHomebrewFiles.join(', ')}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListenableBuilder(
              listenable: themeController,
              builder: (context, _) => SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined)),
                ],
                selected: {themeController.value},
                onSelectionChanged: (selection) =>
                    themeController.set(selection.single),
              ),
            ),
          ),
          const SectionHeader('Rules text'),
          ListTile(
            leading: const Icon(Icons.notes_outlined),
            title: const Text('Edit rules descriptions'),
            subtitle: const Text(
                'The bundled data ships no rules text. If you own the '
                'books, enter your own descriptions here; they appear in '
                'the editor and on the PDF sheet.'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DescriptionsEditor()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Import descriptions…'),
            subtitle: const Text(
                'Merge descriptions from an exported JSON file or the '
                'original Paper Blossoms user_descriptions.csv; imported '
                'entries overwrite same-name ones.'),
            onTap: _importDescriptions,
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: const Text('Export descriptions…'),
            subtitle: const Text(
                'Save all descriptions to a JSON file for backup or '
                'sharing.'),
            onTap: _exportDescriptions,
          ),
          const SectionHeader('Homebrew content'),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Homebrew folder'),
            subtitle: Text(
                '$_homebrewPath\n\nDrop JSON files named like the bundled '
                'data (weapons.json, titles.json, techniques.json, …) with '
                'the same structure; entries are merged after the official '
                'content on launch.'),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reload homebrew now'),
            subtitle: Text(userDataStore.loadedHomebrewFiles.isEmpty
                ? 'Nothing merged this session.'
                : 'Merged: ${userDataStore.loadedHomebrewFiles.join(', ')}'),
            onTap: _reloadHomebrew,
          ),
        ],
      ),
    );
  }
}
