import 'package:flutter/material.dart';

import '../character.dart';

/// Toggles [Character.identityLocked]: while locked, the rarely-changing
/// identity fields (name, family, ninjō, giri) are read-only so they can't
/// be edited accidentally. Listens to the character itself because call
/// sites construct it const, which would otherwise skip icon rebuilds.
class IdentityLockButton extends StatelessWidget {
  const IdentityLockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: character,
      builder: (context, _) {
        final locked = character.identityLocked;
        return IconButton(
          tooltip: locked
              ? 'Unlock name, family, ninjō, and giri'
              : 'Lock name, family, ninjō, and giri',
          icon: Icon(locked ? Icons.lock_outline : Icons.lock_open_outlined),
          onPressed: () {
            character.identityLocked = !locked;
            character.touch();
          },
        );
      },
    );
  }
}
