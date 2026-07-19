import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether Heroes of Rokugan campaign mode is enabled, persisted across
/// launches. Defaults to off; with it off the app behaves exactly as if
/// the feature did not exist.
class HorController extends ValueNotifier<bool> {
  HorController() : super(false);

  static const _prefsKey = 'hor_enabled';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> set(bool enabled) async {
    value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}

final horController = HorController();
