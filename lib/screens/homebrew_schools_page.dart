import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../user_data_store.dart';
import '../wizard/school_builder/school_builder_shell.dart';
import '../wizard/school_builder/school_builder_state.dart';

/// Management surface for homebrew schools: build, edit, delete,
/// import/export. Backed by homebrew/schools.json (hand-authored entries
/// appear and are editable too).
class HomebrewSchoolsPage extends StatefulWidget {
  const HomebrewSchoolsPage({super.key});

  @override
  State<HomebrewSchoolsPage> createState() => _HomebrewSchoolsPageState();
}

class _HomebrewSchoolsPageState extends State<HomebrewSchoolsPage> {
  List<School> _schools = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _schools = List.of(userDataStore.homebrewSchools));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openBuilder({School? school}) async {
    final l10n = context.l10n;
    SchoolBuilderState? initial;
    if (school != null) {
      initial = SchoolBuilderState()
        ..loadFrom(school)
        ..summary = gameData.descriptionFor(school.name)
        ..summaryShort = gameData.shortDescFor(school.name)
        ..abilityText = gameData.descriptionFor(school.schoolAbility)
        ..abilityShort = gameData.shortDescFor(school.schoolAbility)
        ..masteryText = gameData.descriptionFor(school.masteryAbility)
        ..masteryShort = gameData.shortDescFor(school.masteryAbility);
    }
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolBuilderWizard(
          initialState: initial,
          originalName: school?.name,
        ),
      ),
    );
    if (!mounted) return;
    _refresh();
    if (saved != null) _showMessage(l10n.sbSavedSnack(saved));
  }

  Future<void> _delete(School school) async {
    final l10n = context.l10n;
    var alsoText = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.sbDeleteTitle(school.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.sbDeleteBody),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.sbDeleteAlsoText),
                value: alsoText,
                onChanged: (value) =>
                    setDialogState(() => alsoText = value ?? true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    // Delete (and reload) first, THEN clear rules text — but only for names
    // no surviving school still resolves: ability names come from shared
    // templates, and a deleted override's name now belongs to the
    // resurrected bundled school again.
    await userDataStore.deleteHomebrewSchool(school.name);
    if (alsoText) {
      bool stillUsed(String name) => gameData.schools.any(
        (s) =>
            s.name == name ||
            s.schoolAbility == name ||
            s.masteryAbility == name,
      );
      for (final name in {
        school.name,
        school.schoolAbility,
        school.masteryAbility,
      }) {
        if (name.isNotEmpty && !stillUsed(name)) {
          userDataStore.updateDescription(name, '', '');
        }
      }
      await userDataStore.saveDescriptions();
    }
    _refresh();
  }

  Future<void> _deleteAll() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sbDeleteAll),
        content: Text(l10n.sbDeleteAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await userDataStore.deleteAllHomebrewSchools();
    _refresh();
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null || !mounted) return;
    try {
      final count = await userDataStore.importHomebrewSchools(
        utf8.decode(bytes),
      );
      _refresh();
      if (!mounted) return;
      _showMessage(context.l10n.sbImportedSchools(count));
    } on FormatException {
      if (!mounted) return;
      _showMessage(context.l10n.sbCouldNotReadSchoolsFile);
    }
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final count = _schools.length;
    if (count == 0) {
      _showMessage(l10n.sbNoSchoolsToExport);
      return;
    }
    final bytes = utf8.encode(userDataStore.exportHomebrewSchoolsJson());
    if (!mounted) return;
    // saveFile writes the bytes itself only on iOS/Android; on desktop it
    // returns the chosen path (and macOS rejects a bytes argument outright).
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final path = await FilePicker.platform.saveFile(
      fileName: 'schools.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: isDesktop ? null : bytes,
    );
    if (path == null || !mounted) return;
    if (isDesktop) {
      await File(path).writeAsBytes(bytes);
      if (!mounted) return;
    }
    _showMessage(l10n.sbExportedSchools(count));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customSchools),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => switch (value) {
              'import' => _import(),
              'export' => _export(),
              _ => _deleteAll(),
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'import', child: Text(l10n.sbImportSchools)),
              PopupMenuItem(value: 'export', child: Text(l10n.sbExportSchools)),
              PopupMenuItem(
                value: 'deleteAll',
                enabled: _schools.isNotEmpty,
                child: Text(l10n.sbDeleteAll),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.sbBuildNew),
            subtitle: Text(l10n.sbBuildNewSubtitle),
            onTap: () => _openBuilder(),
          ),
          const Divider(),
          if (_schools.isEmpty)
            EmptyHint(l10n.sbEmptyHint)
          else
            for (final school in _schools)
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(trData(school.name)),
                subtitle: Text(
                  [
                    if (school.clan.isNotEmpty) trData(school.clan),
                    school.role.map(trData).join('/'),
                    if ('${school.reference}'.isNotEmpty) '${school.reference}',
                  ].join(' · '),
                ),
                trailing: IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(school),
                ),
                onTap: () => _openBuilder(school: school),
              ),
        ],
      ),
    );
  }
}
