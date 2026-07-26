import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_data.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 1: school role(s), primary first (PoW p. 76, Table 2-3).
class SbPage1Roles extends StatelessWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage1Roles({super.key, required this.state, required this.onChanged});

  void _toggle(String role, bool nowSelected) {
    if (nowSelected) {
      state.roles.add(role);
    } else {
      state.roles.remove(role);
    }
    state.applyRoleDefaults();
    onChanged();
  }

  void _makePrimary(String role) {
    state.roles
      ..remove(role)
      ..insert(0, role);
    state.applyRoleDefaults();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbRolesQuestion),
        Text(l10n.sbRolesHelp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: -6,
          children: [
            for (final role in schoolBuilderRoles)
              FilterChip(
                label: Text(trData(role)),
                selected: state.roles.contains(role),
                onSelected: (value) => _toggle(role, value),
              ),
          ],
        ),
        if (state.roles.length > 2) SoftWarning(l10n.sbWarnThreeRoles),
        if (state.roles.isNotEmpty) ...[
          QuestionHeader(l10n.sbRolesOrder),
          for (var i = 0; i < state.roles.length; i++)
            ListTile(
              dense: true,
              leading: Icon(i == 0 ? Icons.star : Icons.star_border),
              title: Text(trData(state.roles[i])),
              subtitle: i == 0 ? Text(l10n.sbPrimaryRole) : null,
              trailing: i == 0
                  ? null
                  : TextButton(
                      onPressed: () => _makePrimary(state.roles[i]),
                      child: Text(l10n.sbMakePrimary),
                    ),
            ),
        ],
      ],
    );
  }
}
