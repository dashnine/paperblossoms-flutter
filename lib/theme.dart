import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected theme mode, persisted across launches. Defaults to
/// following the system appearance until the user picks light or dark on
/// the Tools page.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _prefsKey = 'theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    value = ThemeMode.values.firstWhere((m) => m.name == saved,
        orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

final themeController = ThemeController();

// Sakura-inspired palette to match the original app's branding.
const sakuraPink = Color(0xFFE8749E);
const sakuraDeep = Color(0xFFB03060);
const inkDark = Color(0xFF2B2B33);

ThemeData lightTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: sakuraDeep),
      appBarTheme: const AppBarTheme(centerTitle: false),
      snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
      useMaterial3: true,
    );

ThemeData darkTheme() {
  final seeded =
      ColorScheme.fromSeed(seedColor: sakuraPink, brightness: Brightness.dark);
  // Charcoal surface ramp built on [inkDark] instead of Material's
  // near-black: warmer to sit with the sakura accents, ~8 lightness points
  // between container levels so elevation still reads.
  final scheme = seeded.copyWith(
    surface: inkDark, // 0xFF2B2B33
    surfaceDim: const Color(0xFF26262D),
    surfaceBright: const Color(0xFF4A4A54),
    surfaceContainerLowest: const Color(0xFF232329),
    surfaceContainerLow: const Color(0xFF2F2F37),
    surfaceContainer: const Color(0xFF33333B),
    surfaceContainerHigh: const Color(0xFF3A3A42),
    surfaceContainerHighest: const Color(0xFF41414A),
  );
  return ThemeData(
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(centerTitle: false),
    snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
    useMaterial3: true,
  );
}

/// Section header used across tabs and dialogs: primary-tinted title over a
/// full-width hairline rule, so sections read as breaks in the page rather
/// than another line of body text.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 2),
          Divider(
              height: 1, thickness: 1, color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

/// Muted placeholder shown where a list has no entries yet, so empty
/// sections read as intentional guidance rather than a rendering glitch.
class EmptyHint extends StatelessWidget {
  final String text;

  const EmptyHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.outline),
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
