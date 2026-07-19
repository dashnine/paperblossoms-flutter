import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../character.dart';
import '../character_store.dart';
import '../generate_pdf.dart';
import '../l10n/l10n.dart';
import '../sheet_style_controller.dart';
import 'tab_advancement.dart';
import 'tab_background.dart';
import 'tab_bonds.dart';
import 'tab_character_data.dart';
import 'tab_equipment.dart';
import 'tab_personal_traits.dart';
import 'tab_techniques.dart';

/// The character sheet editor: 7 tabs matching the original app's main
/// window. Wraps everything in a [ListenableBuilder] on the global
/// [character] so derived stats refresh whenever any tab or dialog mutates it.
class CharacterEditor extends StatefulWidget {
  final int initialTab;

  const CharacterEditor({super.key, this.initialTab = 0});

  @override
  State<CharacterEditor> createState() => _CharacterEditorState();
}

class _CharacterEditorState extends State<CharacterEditor> {
  static List<({IconData icon, String label})> _tabs(AppLocalizations l10n) => [
        (icon: Icons.badge_outlined, label: l10n.tabCharacter),
        (icon: Icons.history_edu_outlined, label: l10n.tabBackground),
        (icon: Icons.theater_comedy_outlined, label: l10n.tabTraits),
        (icon: Icons.handshake_outlined, label: l10n.tabBonds),
        (icon: Icons.auto_awesome_outlined, label: l10n.tabTechniques),
        (icon: Icons.shield_outlined, label: l10n.tabEquipment),
        (icon: Icons.trending_up_outlined, label: l10n.tabAdvancement),
      ];

  bool _pdfShowSkills = true;
  bool _pdfShowPortrait = true;

  Future<void> _save() async {
    await characterStore.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.saved)));
  }

  /// Back with unsaved changes: offer save/discard instead of silently
  /// dropping the edits.
  Future<void> _confirmClose() async {
    final colors = Theme.of(context).colorScheme;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.unsavedChanges),
        content: Text(context.l10n.saveBeforeClosing),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(context.l10n.keepEditing),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(context.l10n.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(context.l10n.saveAndClose),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'save':
        await characterStore.save();
        if (mounted) Navigator.pop(context);
      case 'discard':
        Navigator.pop(context);
    }
  }

  Future<void> _exportPdf() async {
    final name = '${character.family} ${character.name}'.trim();
    final strings = context.l10n;
    await Printing.layoutPdf(
      name: name.isEmpty ? 'character' : name,
      onLayout: (format) => buildCharacterSheetPdf(
        showSkills: _pdfShowSkills,
        showPortrait: _pdfShowPortrait,
        strings: strings,
        style: sheetStyleController.value,
      ),
    );
  }

  Future<void> _exportJson() async {
    final name = '${character.family} ${character.name}'
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final bytes = utf8.encode(characterStore.exportJson());
    // saveFile writes the bytes itself only on iOS/Android; on desktop it
    // returns the chosen path (and macOS rejects a bytes argument outright).
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final path = await FilePicker.platform.saveFile(
      fileName: '${name.isEmpty ? 'character' : name}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: isDesktop ? null : bytes,
    );
    if (path == null || !mounted) return;
    if (isDesktop) {
      await File(path).writeAsBytes(bytes);
      if (!mounted) return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.characterExported)));
  }

  @override
  Widget build(BuildContext context) {
    // Claim ⌘P/Ctrl+P ourselves: on macOS an unhandled key equivalent falls
    // through to AppKit, which answers ⌘P with its own "This application
    // does not support printing." alert.
    final platform = Theme.of(context).platform;
    final apple = platform == TargetPlatform.macOS ||
        platform == TargetPlatform.iOS;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyP,
            meta: apple, control: !apple): _exportPdf,
        SingleActivator(LogicalKeyboardKey.keyS,
            meta: apple, control: !apple): _save,
      },
      // Without focus inside the subtree, key events never reach the
      // bindings on a freshly opened editor.
      child: Focus(autofocus: true, child: _buildEditor(context)),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final tabs = _tabs(context.l10n);
    return DefaultTabController(
      length: tabs.length,
      initialIndex: widget.initialTab,
      child: ListenableBuilder(
        listenable: character,
        builder: (context, _) {
          final title = '${character.family} ${character.name}'.trim();
          final scaffold = Scaffold(
            appBar: AppBar(
              title: Text(title.isEmpty ? context.l10n.unnamedSamurai : title),
              actions: [
                IconButton(
                  tooltip: character.dirty
                      ? context.l10n.saveUnsavedTooltip
                      : context.l10n.save,
                  icon: Badge(
                    isLabelVisible: character.dirty,
                    smallSize: 8,
                    child: const Icon(Icons.save_outlined),
                  ),
                  onPressed: _save,
                ),
                PopupMenuButton<String>(
                  tooltip: context.l10n.exportTooltip,
                  icon: const Icon(Icons.ios_share_outlined),
                  onSelected: (choice) {
                    switch (choice) {
                      case 'pdf':
                        _exportPdf();
                      case 'json':
                        _exportJson();
                      case 'skills':
                        setState(() => _pdfShowSkills = !_pdfShowSkills);
                      case 'portrait':
                        setState(
                            () => _pdfShowPortrait = !_pdfShowPortrait);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: 'pdf',
                        child: Text(context.l10n.printExportPdf)),
                    PopupMenuItem(
                        value: 'json',
                        child: Text(context.l10n.shareCharacterJson)),
                    const PopupMenuDivider(),
                    CheckedPopupMenuItem(
                        value: 'skills',
                        checked: _pdfShowSkills,
                        child: Text(context.l10n.fullSkillTableOnSheet)),
                    CheckedPopupMenuItem(
                        value: 'portrait',
                        checked: _pdfShowPortrait,
                        child: Text(context.l10n.portraitOnSheet)),
                  ],
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final tab in tabs)
                    Tab(icon: Icon(tab.icon), text: tab.label),
                ],
              ),
            ),
            // Deliberately NOT const: identical (const) children would let
            // Flutter skip rebuilding the tabs when the character notifies,
            // freezing derived totals like XP spent.
            // ignore: prefer_const_constructors
            body: TabBarView(
              children: [
                CharacterDataTab(),
                BackgroundTab(),
                PersonalTraitsTab(),
                BondsTab(),
                TechniquesTab(),
                EquipmentTab(),
                AdvancementTab(),
              ],
            ),
          );
          return PopScope(
            canPop: !character.dirty,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) _confirmClose();
            },
            child: scaffold,
          );
        },
      ),
    );
  }
}
