import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show CachingAssetBundle;

class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({
    required this.imageNames,
    required this.mapPath,
  });

  final List<String> imageNames;
  final String mapPath;

  @override
  Future<ByteData> load(String key) async {
    final pattern = RegExp(r'assets/images/(\.\./)*');
    final split = key.split('/');
    final imgName = split.isNotEmpty ? key.replaceFirst(pattern, '') : key;

    var toLoadName = key.replaceFirst(pattern, '');
    if (!imageNames.contains(imgName) && imageNames.isNotEmpty) {
      toLoadName = imageNames.first;
    }
    return File('test/assets/$toLoadName')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    var toLoad = mapPath;
    if (key.endsWith('tsx')) {
      toLoad = key.replaceFirst('assets/tiles/', 'test/assets/');
    }
    return File(toLoad).readAsString();
  }
}
