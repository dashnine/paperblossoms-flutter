import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to system when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = ThemeController();
    await controller.load();
    expect(controller.value, ThemeMode.system);
  });

  test('loads a saved mode', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final controller = ThemeController();
    await controller.load();
    expect(controller.value, ThemeMode.dark);
  });

  test('falls back to system on an unrecognized saved value', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
    final controller = ThemeController();
    await controller.load();
    expect(controller.value, ThemeMode.system);
  });

  test('set updates listeners and persists across a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = ThemeController();
    var notified = false;
    controller.addListener(() => notified = true);
    await controller.set(ThemeMode.light);
    expect(controller.value, ThemeMode.light);
    expect(notified, isTrue);

    final reloaded = ThemeController();
    await reloaded.load();
    expect(reloaded.value, ThemeMode.light);
  });
}
