import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/hor_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to off when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = HorController();
    await controller.load();
    expect(controller.value, isFalse);
  });

  test('loads a saved value', () async {
    SharedPreferences.setMockInitialValues({'hor_enabled': true});
    final controller = HorController();
    await controller.load();
    expect(controller.value, isTrue);
  });

  test('set updates listeners and persists across a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = HorController();
    var notified = false;
    controller.addListener(() => notified = true);
    await controller.set(true);
    expect(controller.value, isTrue);
    expect(notified, isTrue);

    final reloaded = HorController();
    await reloaded.load();
    expect(reloaded.value, isTrue);
  });
}
