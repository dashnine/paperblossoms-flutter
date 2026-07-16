import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/locale_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleController', () {
    test('defaults to system (null) when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, isNull);
    });

    test('loads a saved locale', () async {
      SharedPreferences.setMockInitialValues({'ui_locale': 'fr'});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, const Locale('fr'));
    });

    test('falls back to system on an unsupported saved value', () async {
      SharedPreferences.setMockInitialValues({'ui_locale': 'tlh'});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, isNull);
    });

    test('set updates listeners and persists across a reload', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = LocaleController();
      var notified = false;
      controller.addListener(() => notified = true);
      await controller.set(const Locale('fr'));
      expect(controller.value, const Locale('fr'));
      expect(notified, isTrue);

      final reloaded = LocaleController();
      await reloaded.load();
      expect(reloaded.value, const Locale('fr'));
    });

    test('set(null) clears the persisted choice', () async {
      SharedPreferences.setMockInitialValues({'ui_locale': 'fr'});
      final controller = LocaleController();
      await controller.load();
      await controller.set(null);

      final reloaded = LocaleController();
      await reloaded.load();
      expect(reloaded.value, isNull);
    });
  });

  group('ContentLocaleController', () {
    test('defaults to match-interface (null) and follows the UI locale',
        () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ContentLocaleController();
      await controller.load();
      expect(controller.value, isNull);
      expect(controller.effectiveCode(const Locale('fr')), 'fr');
      expect(controller.effectiveCode(const Locale('en')), 'en');
    });

    test('an explicit choice overrides the UI locale', () async {
      SharedPreferences.setMockInitialValues({'content_locale': 'en'});
      final controller = ContentLocaleController();
      await controller.load();
      expect(controller.effectiveCode(const Locale('fr')), 'en');
    });

    test('unsupported saved or resolved codes collapse to English', () async {
      SharedPreferences.setMockInitialValues({'content_locale': 'tlh'});
      final controller = ContentLocaleController();
      await controller.load();
      expect(controller.value, isNull);
      expect(controller.effectiveCode(const Locale('tlh')), 'en');
    });

    test('persists across a reload', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ContentLocaleController();
      await controller.set('fr');

      final reloaded = ContentLocaleController();
      await reloaded.load();
      expect(reloaded.value, 'fr');
    });
  });
}
