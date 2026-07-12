import 'package:flutter/material.dart';

import '../character.dart';
import '../theme.dart';
import '../widgets/identity_lock_button.dart';

/// Tab 2: heritage, ninjō, giri, and personal notes.
class BackgroundTab extends StatefulWidget {
  const BackgroundTab({super.key});

  @override
  State<BackgroundTab> createState() => _BackgroundTabState();
}

class _BackgroundTabState extends State<BackgroundTab> {
  late final TextEditingController _ninjoController;
  late final TextEditingController _giriController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _ninjoController = TextEditingController(text: character.ninjo);
    _giriController = TextEditingController(text: character.giri);
    _notesController = TextEditingController(text: character.notes);
  }

  @override
  void dispose() {
    _ninjoController.dispose();
    _giriController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (character.heritage.isNotEmpty) ...[
          const SectionHeader('Heritage'),
          Text(character.heritage),
        ],
        const SectionHeader('Ninjō (personal desire)',
            trailing: IdentityLockButton()),
        TextField(
          controller: _ninjoController,
          enabled: !character.identityLocked,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) {
            character.ninjo = value;
            character.touch();
          },
        ),
        const SectionHeader('Giri (duty)'),
        TextField(
          controller: _giriController,
          enabled: !character.identityLocked,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) {
            character.giri = value;
            character.touch();
          },
        ),
        const SectionHeader('Notes'),
        TextField(
          controller: _notesController,
          maxLines: 12,
          minLines: 6,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) {
            character.notes = value;
            character.touch();
          },
        ),
      ],
    );
  }
}
