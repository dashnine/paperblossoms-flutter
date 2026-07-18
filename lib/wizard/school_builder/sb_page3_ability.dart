import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_data.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 3: the school ability (PoW pp. 77-78, Table 2-4). The name goes in
/// the school record; the rules text becomes a user description entry, so
/// the app itself never ships book text.
class SbPage3Ability extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage3Ability({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  State<SbPage3Ability> createState() => _SbPage3AbilityState();
}

class _SbPage3AbilityState extends State<SbPage3Ability> {
  late final _name = TextEditingController(text: widget.state.abilityName);
  late final _text = TextEditingController(text: widget.state.abilityText);
  late final _short = TextEditingController(text: widget.state.abilityShort);
  AbilityTemplate? _template;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    _short.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final templates = [
      for (final t in schoolAbilityTemplates)
        if (t.roles.isEmpty || t.roles.any(state.roles.contains)) t,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbAbilityQuestion),
        Text(l10n.sbAbilityHelp, style: Theme.of(context).textTheme.bodySmall),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<AbilityTemplate>(
            value: _template,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.sbAbilityTemplate,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final t in templates)
                DropdownMenuItem(
                  value: t,
                  child: Text(
                    t.roles.isEmpty
                        ? t.label
                        : '${t.label} (${t.roles.join(', ')})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (t) {
              setState(() => _template = t);
              if (t == null) return;
              // Picking a template is an explicit choice: fill the rules
              // text with the book's template (freely editable after).
              _text.text = t.text;
              state.abilityText = t.text;
              widget.onChanged();
            },
          ),
        ),
        if (_template != null) SoftWarning(l10n.sbSeeBook(_template!.page)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.sbAbilityName,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              state.abilityName = value;
              widget.onChanged();
            },
          ),
        ),
        WizTextArea(
          label: l10n.sbAbilityText,
          controller: _text,
          minLines: 4,
          onChanged: (value) {
            state.abilityText = value;
            widget.onChanged();
          },
        ),
        if (state.abilityText.trim().isEmpty)
          SoftWarning(l10n.sbWarnNoAbilityText),
        WizTextArea(
          label: l10n.sbShortDescLabel,
          controller: _short,
          minLines: 1,
          onChanged: (value) {
            state.abilityShort = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
