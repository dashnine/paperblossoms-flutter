import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

import '../character.dart';

/// Tappable character portrait (port of the original ClickLabel): tap to pick
/// an image, long-press to clear. Stored on the character as base64 PNG/JPEG
/// bytes so it travels inside the save file.
class PortraitPicker extends StatelessWidget {
  final double size;

  const PortraitPicker({super.key, this.size = 160});

  Future<void> _pick(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    character.portraitB64 = base64Encode(bytes);
    character.touch();
  }

  void _clear() {
    character.portraitB64 = '';
    character.touch();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the character directly: call sites construct this widget
    // const, so parent rebuilds are skipped for the identical instance and
    // a freshly picked portrait would otherwise not appear until the tab is
    // rebuilt from scratch.
    return ListenableBuilder(
      listenable: character,
      builder: (context, _) => _buildPortrait(context),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    final theme = Theme.of(context);
    // hasPortrait keys off the stored string so corrupt data can still be
    // long-pressed away; bytes is null when that data isn't valid base64.
    final hasPortrait = character.portraitB64.isNotEmpty;
    final bytes = character.portraitBytes;
    final placeholder =
        Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.outline);
    return Tooltip(
      message: hasPortrait
          ? context.l10n.changePortraitTooltip
          : context.l10n.addPortraitTooltip,
      child: InkWell(
        onTap: () => _pick(context),
        onLongPress: hasPortrait ? _clear : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: bytes == null
              ? placeholder
              : Image.memory(bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => placeholder),
        ),
      ),
    );
  }
}
