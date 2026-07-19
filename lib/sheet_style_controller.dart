import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which layout the PDF character sheet uses.
enum SheetStyle { minimalist, structured }

/// The chosen PDF sheet style, persisted across launches. Defaults to the
/// structured layout; the original minimalist sheet is the opt-in.
class SheetStyleController extends ValueNotifier<SheetStyle> {
  SheetStyleController() : super(SheetStyle.structured);

  static const _prefsKey = 'sheet_style';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_prefsKey) == SheetStyle.minimalist.name
        ? SheetStyle.minimalist
        : SheetStyle.structured;
  }

  Future<void> set(SheetStyle style) async {
    value = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, style.name);
  }
}

final sheetStyleController = SheetStyleController();
