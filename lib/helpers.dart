import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'l10n/l10n.dart';

/// Saves [bytes] through the system save dialog. saveFile writes the bytes
/// itself only on iOS/Android; on desktop it returns the chosen path (and
/// macOS rejects a bytes argument outright), so the file is written here.
/// Returns true once the file exists on disk, false if the user cancelled.
Future<bool> exportBytesToFile(String fileName, Uint8List bytes) async {
  final isDesktop =
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['json'],
    bytes: isDesktop ? null : bytes,
  );
  if (path == null) return false;
  if (isDesktop) await File(path).writeAsBytes(bytes);
  return true;
}

/// Opens the system file picker and returns the chosen file decoded as
/// UTF-8, or null if cancelled. Proper UTF-8 decode (String.fromCharCodes
/// garbles multibyte characters, e.g. accented names); malformed bytes
/// degrade to replacement characters instead of failing the import.
Future<String?> pickTextFile({List<String> extensions = const ['json']}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: extensions,
    withData: true,
  );
  final bytes = result?.files.single.bytes;
  if (bytes == null) return null;
  return utf8.decode(bytes, allowMalformed: true);
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// Cancel/confirm AlertDialog; the confirm button is error-tinted when
/// [destructive]. Returns true only on confirm. [cancelLabel] defaults to
/// the localized "Cancel".
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? context.l10n.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// A confirm dialog carrying one checkbox (e.g. "also remove its rules
/// text"). Returns null when cancelled, otherwise the checkbox's final value.
Future<bool?> confirmWithCheckbox(
  BuildContext context, {
  required String title,
  String? body,
  required String checkboxLabel,
  String? checkboxSubtitle,
  required String confirmLabel,
  bool initialValue = true,
  bool destructive = true,
}) async {
  var checked = initialValue;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (body != null) Text(body),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(checkboxLabel),
              subtitle:
                  checkboxSubtitle == null ? null : Text(checkboxSubtitle),
              value: checked,
              onChanged: (value) =>
                  setDialogState(() => checked = value ?? initialValue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
  return confirmed == true ? checked : null;
}
