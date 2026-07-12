import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../character.dart';
import '../character_store.dart';
import '../wizard/wizard_shell.dart';
import 'character_editor.dart';
import 'tools_page.dart';

/// Startup screen: list of saved characters with load/delete/import/new.
class CharacterChooser extends StatefulWidget {
  const CharacterChooser({super.key});

  @override
  State<CharacterChooser> createState() => _CharacterChooserState();
}

class _CharacterChooserState extends State<CharacterChooser> {
  List<CharacterSummary> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final summaries = await characterStore.list();
    if (!mounted) return;
    setState(() {
      _summaries = summaries;
      _loading = false;
    });
  }

  Future<void> _openCharacter(String uuid) async {
    await characterStore.load(uuid);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CharacterEditor()),
    );
    _refresh();
  }

  Future<void> _newCharacter() async {
    character.clear();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCharacterWizard()),
    );
    _refresh();
  }

  Future<void> _importCharacter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    await characterStore.importJson(String.fromCharCodes(bytes));
    _refresh();
  }

  Future<void> _deleteCharacter(CharacterSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${summary.name}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await characterStore.delete(summary.uuid);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Blossoms'),
        actions: [
          IconButton(
            tooltip: 'Import character',
            icon: const Icon(Icons.file_open_outlined),
            onPressed: _importCharacter,
          ),
          IconButton(
            tooltip: 'Tools',
            icon: const Icon(Icons.handyman_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolsPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newCharacter,
        icon: const Icon(Icons.add),
        label: const Text('New Character'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
              ? _buildEmptyState(context)
              : _buildList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/sakura.png', width: 120),
          const SizedBox(height: 16),
          Text(
            'No characters yet.\nCreate one to begin your story.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(summary.name),
          onTap: () => _openCharacter(summary.uuid),
          trailing: IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteCharacter(summary),
          ),
        );
      },
    );
  }
}
