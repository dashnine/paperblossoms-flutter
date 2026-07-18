import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../game_data.dart';
import '../l10n/l10n.dart';
import '../locale_controllers.dart';
import '../theme.dart';
import '../user_data_store.dart';
import 'descriptions_editor.dart';
import 'homebrew_schools_page.dart';

/// Tools: rules descriptions and homebrew content (the original's Tools
/// menu, minus the SQLite-era CSV round trips).
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, this.openAboutOnLaunch = false});

  /// Preview-only (main_preview ABOUT=true): opens the About dialog after
  /// the first frame, since native taps can't be automated during verify.
  final bool openAboutOnLaunch;

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
    if (widget.openAboutOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAbout());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      final count = await userDataStore.importDescriptions(utf8.decode(bytes));
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
    // Full reload, not just loadHomebrew(): merging is append-only for most
    // kinds, so re-merging onto already-merged data would duplicate entries.
    await userDataStore.reloadAll();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          userDataStore.loadedHomebrewFiles.isEmpty
              ? context.l10n.noHomebrewFilesFound
              : context.l10n.mergedFiles(
                  userDataStore.loadedHomebrewFiles.join(', '),
                ),
        ),
      ),
    );
  }

  Future<void> _showAbout() async {
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } on Exception {
      // Platform channel unavailable (tests); show the dialog without one.
    }
    if (!mounted) return;
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: version,
      applicationIcon: Image.asset(
        'assets/images/sakura.png',
        width: 48,
        height: 48,
      ),
      applicationLegalese: l10n.aboutLegalese,
      children: [
        const SizedBox(height: 16),
        Text(l10n.aboutTagline),
        const SizedBox(height: 8),
        Text(l10n.aboutPortNote),
        const SizedBox(height: 8),
        const SelectableText(
          'https://github.com/dashnine/paperblossoms-flutter',
        ),
      ],
    );
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
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                ],
                selected: {themeController.value},
                onSelectionChanged: (selection) =>
                    themeController.set(selection.single),
              ),
            ),
          ),
          SectionHeader(l10n.languageSection),
          // One language setting for interface and game content alike; data
          // names degrade per-string to English when a translation is
          // missing. A dropdown scales to any number of locales without the
          // silent label squeezing SegmentedButton exhibited.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListenableBuilder(
              listenable: localeController,
              builder: (context, _) => Row(
                children: [
                  DropdownButton<String>(
                    value: localeController.value?.languageCode ?? 'system',
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(l10n.themeSystem),
                      ),
                      const DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const DropdownMenuItem(
                        value: 'fr',
                        child: Text('Français'),
                      ),
                      const DropdownMenuItem(
                        value: 'de',
                        child: Text('Deutsch'),
                      ),
                      const DropdownMenuItem(
                        value: 'es',
                        child: Text('Español'),
                      ),
                    ],
                    onChanged: (code) => localeController.set(
                      code == null || code == 'system' ? null : Locale(code),
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
                builder: (context) => const DescriptionsEditor(),
              ),
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
            leading: const Icon(Icons.school_outlined),
            title: Text(l10n.customSchools),
            subtitle: Text(l10n.customSchoolsSubtitle),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomebrewSchoolsPage(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(l10n.homebrewFolder),
            // The documents sandbox is app-private on mobile: show how to
            // reach the folder instead of a path the user cannot visit.
            subtitle: Text(
              Platform.isIOS
                  ? l10n.homebrewFolderIos
                  : Platform.isAndroid
                  ? l10n.homebrewFolderAndroid
                  : l10n.homebrewFolderSubtitle(_homebrewPath),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.reloadHomebrew),
            subtitle: Text(
              userDataStore.loadedHomebrewFiles.isEmpty
                  ? l10n.nothingMergedThisSession
                  : l10n.mergedFiles(
                      userDataStore.loadedHomebrewFiles.join(', '),
                    ),
            ),
            onTap: _reloadHomebrew,
          ),
          SectionHeader(l10n.aboutSection),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutApp),
            subtitle: Text(l10n.aboutAppSubtitle),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }
}
