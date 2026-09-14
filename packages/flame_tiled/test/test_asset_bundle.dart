import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show CachingAssetBundle;

/// An asset bundle that serves the fixtures under `test/assets/`.
///
/// Keys are full asset paths, exactly as they would be declared in a
/// `pubspec.yaml`, and are mapped onto the fixture directory. Both
/// `assets/images/map.png` and `assets/tiles/map.tmx` resolve to
/// `test/assets/...`, so fixtures can be laid out flat regardless of the
/// directory a test addresses them through.
class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({
    required this.imageNames,
    required this.stringNames,
  });

  final List<String> imageNames;
  final List<String> stringNames;

  static const _roots = ['assets/images/', 'assets/tiles/', 'assets/'];

  /// Collapses `..` segments, the way a real asset layout would already have
  /// them resolved. Tiled writes tileset image sources relative to the `.tsx`
  /// file, so `tiles/../images/green.png` is normal and must land on
  /// `images/green.png`.
  static String _normalize(String path) {
    final segments = <String>[];
    for (final segment in path.split('/')) {
      if (segment == '..' && segments.isNotEmpty && segments.last != '..') {
        segments.removeLast();
      } else if (segment != '.') {
        segments.add(segment);
      }
    }
    return segments.join('/');
  }

  String _resolve(String key, List<String> known) {
    var name = _normalize(key);
    for (final root in _roots) {
      if (name.startsWith(root)) {
        name = name.substring(root.length);
        break;
      }
    }
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
