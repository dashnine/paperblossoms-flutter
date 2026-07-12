import 'package:flutter/material.dart';

/// Labeled integer value with -/+ buttons; works with mouse and touch.
/// Tapping the number opens a dialog to type a value directly, so large
/// jumps (e.g. Glory 0 → 44) don't need dozens of taps.
class IntSpinner extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const IntSpinner({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  Future<void> _editValue(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) =>
          _IntEntryDialog(label: label, value: value, min: min, max: max),
    );
    if (result != null) onChanged(result.clamp(min, max));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Tooltip(
              message: 'Tap to type a value',
              child: InkWell(
                onTap: () => _editValue(context),
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 36,
                  child: Text('$value',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// Owns the text controller so it outlives the dialog's exit animation.
class _IntEntryDialog extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;

  const _IntEntryDialog({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  State<_IntEntryDialog> createState() => _IntEntryDialogState();
}

class _IntEntryDialogState extends State<_IntEntryDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(helperText: '${widget.min}–${widget.max}'),
        onSubmitted: (text) => Navigator.pop(context, int.tryParse(text)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(_controller.text)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
