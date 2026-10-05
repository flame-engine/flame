import 'dart:convert';
import 'dart:developer';

import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [ImageCacheConnector] reports the contents of the game's image cache to
/// the devtools extension, and lets it trigger an eviction.
class ImageCacheConnector() extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getImageCache',
      (method, parameters) async {
        final images = game.images;
        final entries = images.keys.map((key) {
          return ImageCacheEntry(
            key: key,
            sizeBytes: images.sizeBytesOf(key),
            retainCount: images.retainCount(key),
          );
        }).toList();
        final info = ImageCacheInfo(
          sizeBytes: images.sizeBytes,
          maxSizeBytes: images.maxSizeBytes,
          entries: entries,
        );
        return ServiceExtensionResponse.result(json.encode(info.toJson()));
      },
    );

    registerExtension(
      'ext.flame_devtools.evictUnusedImages',
      (method, parameters) async {
        final freedBytes = game.images.evictUnused();
        return ServiceExtensionResponse.result(
          json.encode({'freed_bytes': freedBytes}),
        );
      },
    );
  }
}

/// A snapshot of the state of an `Images` cache, as reported to the devtools
/// extension.
class ImageCacheInfo({
  /// The estimated size of all the images in the cache.
  required final int sizeBytes,

  /// The configured budget of the cache, if any.
  required final int? maxSizeBytes,

  /// One entry per image in the cache.
  required final List<ImageCacheEntry> entries,
}) {
  factory ImageCacheInfo.fromJson(Map<String, dynamic> json) {
    return ImageCacheInfo(
      sizeBytes: json['size_bytes'] as int,
      maxSizeBytes: json['max_size_bytes'] as int?,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => ImageCacheEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'size_bytes': sizeBytes,
    'max_size_bytes': maxSizeBytes,
    'entries': entries.map((e) => e.toJson()).toList(),
  };
}

/// One image in an `Images` cache, as reported to the devtools extension.
class ImageCacheEntry({
  /// The key that the image is cached under.
  required final String key,

  /// The estimated size of the image.
  required final int sizeBytes,

  /// How many times the image is currently retained.
  required final int retainCount,
}) {
  factory ImageCacheEntry.fromJson(Map<String, dynamic> json) {
    return ImageCacheEntry(
      key: json['key'] as String,
      sizeBytes: json['size_bytes'] as int,
      retainCount: json['retain_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'size_bytes': sizeBytes,
    'retain_count': retainCount,
  };
}
