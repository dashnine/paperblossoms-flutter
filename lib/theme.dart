import 'package:flutter/material.dart';

// Sakura-inspired palette to match the original app's branding.
const sakuraPink = Color(0xFFE8749E);
const sakuraDeep = Color(0xFFB03060);
const inkDark = Color(0xFF2B2B33);

ThemeData lightTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: sakuraDeep),
      appBarTheme: const AppBarTheme(centerTitle: false),
      useMaterial3: true,
    );

ThemeData darkTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: sakuraPink, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(centerTitle: false),
      useMaterial3: true,
    );

/// Section header used across tabs and dialogs.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Small labeled stat value (derived attributes, social stats, wealth).
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
