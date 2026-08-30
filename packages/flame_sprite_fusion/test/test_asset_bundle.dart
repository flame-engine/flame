import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show CachingAssetBundle;

/// An asset bundle that serves the fixtures under `test/assets/`.
///
/// Keys are full asset paths, exactly as they would be declared in a
/// `pubspec.yaml`, and are mapped onto the fixture directory. For example,
/// `assets/map.json` resolves to `test/assets/map.json`.
class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({
    required this.imageNames,
    required this.stringNames,
  });

  final List<String> imageNames;
  final List<String> stringNames;

  String _resolve(String key, List<String> known) {
    final name = key.startsWith('assets/')
        ? key.substring('assets/'.length)
        : key;
    if (!known.contains(name)) {
      throw StateError(
        'No $key found in the TestAssetBundle. Did you forget to add it?',
      );
    }
    return 'test/assets/$name';
  }

  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(_resolve(key, imageNames)).readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return File(_resolve(key, stringNames)).readAsString();
  }
}
