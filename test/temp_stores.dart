import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/user_data_store.dart';

/// Points both stores at a fresh temp directory for the whole suite so tests
/// never touch the real documents folder. Registers setUpAll/tearDownAll;
/// call once at the top of main() (or inside a group). Returns a getter for
/// tests that need the directory itself.
Directory Function() useTempStores(String prefix) {
  late Directory tempDir;
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(prefix);
    userDataStore.documentsDirectory = () async => tempDir;
    characterStore.documentsDirectory = () async => tempDir;
  });
  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });
  return () => tempDir;
}
