import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show CachingAssetBundle;

class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({
    required this.imageNames,
    required this.stringNames,
  });

  final List<String> imageNames;
  final List<String> stringNames;

  @override
  Future<ByteData> load(String key) async {
    late String imgName;
    late String fileName;
    if (key.contains('..')) {
      final parts = key.split('/');

      final index = parts.indexOf('..');

      imgName = parts.sublist(index + 1).join('/');

      fileName = key.replaceFirst('assets/images/', 'test/assets/');
    } else {
      final pattern = RegExp(r'assets/images/(\.\./)*');
      final split = key.split('/');
      imgName = split.isNotEmpty ? key.replaceFirst(pattern, '') : key;

      final toLoadName = key.replaceFirst(pattern, '');
      fileName = 'test/assets/$toLoadName';
    }

    if (!imageNames.contains(imgName)) {
      throw StateError(
        'No $fileName found in the TestAssetBundle. Did you forget to add it?',
      );
    }
    return File(fileName)
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    final pattern = RegExp(r'assets/tiles/(\.\./)*');
    final split = key.split('/');
    final mapName = split.isNotEmpty ? key.replaceFirst(pattern, '') : key;

    final toLoadName = key.replaceFirst(pattern, '');
    final fileName = 'test/assets/$toLoadName';

    if (!stringNames.contains(mapName)) {
      throw StateError(
        'No $fileName found in the TestAssetBundle. Did you forget to add it?',
      );
    }

    return File(fileName).readAsString();
  }
}
