import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

  /// One portrait read per character per refresh; FutureBuilder re-uses these
  /// across rebuilds instead of re-reading the save file.
  final Map<String, Future<Uint8List?>> _portraits = {};

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
      _portraits.clear();
      _loading = false;
    });
  }

  Future<Uint8List?> _portraitOf(String uuid) =>
      _portraits.putIfAbsent(uuid, () => characterStore.portraitOf(uuid));

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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Petal backdrop on both states: prominent when empty, faint
          // behind the list; fades in once loading settles.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _loading ? 0 : (_summaries.isEmpty ? 0.45 : 0.32),
            child: Image.asset(
              'assets/images/sakura_PNG37.png',
              fit: BoxFit.cover,
            ),
          ),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _summaries.isEmpty
              ? _buildEmptyState(context)
              : _buildList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      // Radial halo keeps the flower and text from blending into the
      // petals behind them; surface color adapts to light/dark theme.
      child: Container(
        padding: const EdgeInsets.all(96),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0),
            ],
            stops: const [0.35, 1.0],
          ),
        ),
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
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        // Empty for indexes written by older builds until their next save.
        final detail = [
          if (summary.clan.isNotEmpty) summary.clan,
          if (summary.school.isNotEmpty) summary.school,
          if (summary.rank > 0) 'Rank ${summary.rank}',
        ].join(' · ');
        return ListTile(
          leading: _portraitAvatar(summary.uuid),
          title: Text(summary.name),
          subtitle: detail.isEmpty ? null : Text(detail),
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

  Widget _portraitAvatar(String uuid) {
    final colors = Theme.of(context).colorScheme;
    final fallback = CircleAvatar(
      backgroundColor: colors.surfaceContainerHighest,
      child: Icon(Icons.person_outline, color: colors.onSurfaceVariant),
    );
    return FutureBuilder<Uint8List?>(
      future: _portraitOf(uuid),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return fallback;
        return CircleAvatar(backgroundImage: MemoryImage(bytes));
      },
    );
  }
}
