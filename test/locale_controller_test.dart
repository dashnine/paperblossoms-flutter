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

  group('contentCodeFor', () {
    test('follows the locale when an overlay ships for it', () {
      expect(contentCodeFor(const Locale('fr')), 'fr');
      expect(contentCodeFor(const Locale('de')), 'de');
      expect(contentCodeFor(const Locale('es')), 'es');
      expect(contentCodeFor(const Locale('en')), 'en');
    });

    test('collapses locales without an overlay to English', () {
      expect(contentCodeFor(const Locale('tlh')), 'en');
    });
  });

  group('legacy content_locale migration', () {
    test('seeds the unified setting when no ui_locale was saved', () async {
      SharedPreferences.setMockInitialValues({'content_locale': 'fr'});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, const Locale('fr'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('content_locale'), isNull);
      expect(prefs.getString('ui_locale'), 'fr');
    });

    test('never overrides an explicit ui_locale, but still cleans up',
        () async {
      SharedPreferences.setMockInitialValues(
          {'ui_locale': 'de', 'content_locale': 'fr'});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, const Locale('de'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('content_locale'), isNull);
    });

    test('a legacy explicit-English choice does not pin the interface',
        () async {
      SharedPreferences.setMockInitialValues({'content_locale': 'en'});
      final controller = LocaleController();
      await controller.load();
      expect(controller.value, isNull);
    });
  });
}
