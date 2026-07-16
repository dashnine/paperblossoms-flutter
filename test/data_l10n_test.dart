import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/data_l10n.dart';

void main() {
  test('identity fallback when no overlay is loaded', () {
    final l10n = DataL10n();
    expect(l10n.tr('Sixth Sense'), 'Sixth Sense');
    expect(l10n.tr(''), '');
  });

  test('translates loaded entries and falls back for the rest', () async {
    final l10n = DataL10n(
        loader: (_) async => '{"Sixth Sense": "Sixième Sens", "Air": "Air"}');
    await l10n.setLocale('fr');
    expect(l10n.tr('Sixth Sense'), 'Sixième Sens');
    expect(l10n.tr('Homebrew Thing'), 'Homebrew Thing');
  });

  test('setLocale back to en clears the overlay', () async {
    final l10n = DataL10n(loader: (_) async => '{"Water": "Eau"}');
    await l10n.setLocale('fr');
    expect(l10n.tr('Water'), 'Eau');
    await l10n.setLocale('en');
    expect(l10n.tr('Water'), 'Water');
  });

  test('malformed JSON yields pure English, no throw', () async {
    final l10n = DataL10n(loader: (_) async => '{"Water": "Eau"');
    await l10n.setLocale('fr');
    expect(l10n.tr('Water'), 'Water');
  });

  test('a missing asset yields pure English, no throw', () async {
    final l10n = DataL10n(loader: (_) async => throw Exception('no asset'));
    await l10n.setLocale('fr');
    expect(l10n.tr('Water'), 'Water');
  });

  test('non-string and empty values are dropped, valid entries kept',
      () async {
    final l10n = DataL10n(
        loader: (_) async =>
            '{"Water": "Eau", "Fire": 7, "Earth": "", "Void": "  ", "Air": " Air ", "Ranged": null}');
    await l10n.setLocale('fr');
    expect(l10n.tr('Water'), 'Eau');
    expect(l10n.tr('Fire'), 'Fire');
    expect(l10n.tr('Earth'), 'Earth');
    expect(l10n.tr('Void'), 'Void');
    expect(l10n.tr('Air'), 'Air', reason: 'values are trimmed');
    expect(l10n.tr('Ranged'), 'Ranged');
  });

  test('a top-level JSON array yields pure English, no throw', () async {
    final l10n = DataL10n(loader: (_) async => '["Water", "Eau"]');
    await l10n.setLocale('fr');
    expect(l10n.tr('Water'), 'Water');
  });

  test('trCondition translates base and ring qualifier separately', () async {
    final l10n = DataL10n(
        loader: (_) async =>
            '{"Lightly Wounded": "Légèrement Blessé", "Fire": "Feu", "Bleeding": "Hémorragie"}');
    await l10n.setLocale('fr');
    expect(l10n.trCondition('Lightly Wounded (Fire)'),
        'Légèrement Blessé (Feu)');
    expect(l10n.trCondition('Bleeding'), 'Hémorragie');
    expect(l10n.trCondition('Something Custom'), 'Something Custom');
    expect(l10n.trCondition('Oddly (Shaped'), 'Oddly (Shaped');
  });

  test('sortKey strips case and diacritics', () {
    final l10n = DataL10n();
    expect(l10n.sortKey('Sixième Sens'), 'sixieme sens');
    expect(l10n.sortKey('Rōnin'), 'ronin');
    expect(l10n.sortKey('Œil'), 'oeil');
    expect(l10n.sortKey('L’Épée'), "l'epee");
  });

  test('notifies listeners on locale change', () async {
    final l10n = DataL10n(loader: (_) async => '{}');
    var notified = 0;
    l10n.addListener(() => notified++);
    await l10n.setLocale('fr');
    expect(notified, 1);
    await l10n.setLocale('fr');
    expect(notified, 1, reason: 'no reload for the same locale');
  });
}
