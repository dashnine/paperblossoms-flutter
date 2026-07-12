import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../character.dart';
import '../character_store.dart';
import '../generate_pdf.dart';
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
  static const _tabs = [
    (icon: Icons.badge_outlined, label: 'Character'),
    (icon: Icons.history_edu_outlined, label: 'Background'),
    (icon: Icons.theater_comedy_outlined, label: 'Traits'),
    (icon: Icons.handshake_outlined, label: 'Bonds'),
    (icon: Icons.auto_awesome_outlined, label: 'Techniques'),
    (icon: Icons.shield_outlined, label: 'Equipment'),
    (icon: Icons.trending_up_outlined, label: 'Advancement'),
  ];

  bool _pdfShowSkills = true;
  bool _pdfShowPortrait = true;

  Future<void> _save() async {
    await characterStore.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _exportPdf() async {
    final name = '${character.family} ${character.name}'.trim();
    await Printing.layoutPdf(
      name: name.isEmpty ? 'character' : name,
      onLayout: (format) => buildCharacterSheetPdf(
        showSkills: _pdfShowSkills,
        showPortrait: _pdfShowPortrait,
      ),
    );
  }

  Future<void> _exportJson() async {
    final name = '${character.family} ${character.name}'.trim();
    await Share.share(
      characterStore.exportJson(),
      subject: name.isEmpty ? 'character' : name,
    );
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
      },
      // Without focus inside the subtree, key events never reach the
      // bindings on a freshly opened editor.
      child: Focus(autofocus: true, child: _buildEditor(context)),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: widget.initialTab,
      child: ListenableBuilder(
        listenable: character,
        builder: (context, _) {
          final title = '${character.family} ${character.name}'.trim();
          return Scaffold(
            appBar: AppBar(
              title: Text(title.isEmpty ? 'Unnamed Samurai' : title),
              actions: [
                IconButton(
                  tooltip: 'Save',
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _save,
                ),
                PopupMenuButton<String>(
                  tooltip: 'Export',
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
                    const PopupMenuItem(
                        value: 'pdf',
                        child: Text('Print / export PDF sheet…')),
                    const PopupMenuItem(
                        value: 'json', child: Text('Share character JSON…')),
                    const PopupMenuDivider(),
                    CheckedPopupMenuItem(
                        value: 'skills',
                        checked: _pdfShowSkills,
                        child: const Text('Full skill table on sheet')),
                    CheckedPopupMenuItem(
                        value: 'portrait',
                        checked: _pdfShowPortrait,
                        child: const Text('Portrait on sheet')),
                  ],
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final tab in _tabs)
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
        },
      ),
    );
  }
}
