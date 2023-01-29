import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// {@template flame_image_response}
/// A class containg the relevant http attributes to
/// Flame Images Network package.
/// {@endtemplate}
class FlameImageResponse {
  /// {@macro flame_image_response}
  const FlameImageResponse({
    required this.statusCode,
    required this.bytes,
  });

  /// Http status code.
  final int statusCode;

  /// response bytes.
  final Uint8List bytes;
}

/// Function signature used by Flame Networks Images to fetch images.
typedef GetImagefunction = Future<FlameImageResponse> Function(
  String url, {
  Map<String, String>? headers,
});

/// {@template flame_network_images}
///
/// [FlameNetworkImages] is a class similar to Flame's [Images], but instead of
/// loading images from the assets bundle, it loads from networks urls.
///
/// By default, [FlameNetworkImages] uses [http.get] method to make the requests
/// ,that can be custumized by passing a different [GetImagefunction] to the get
/// argument on the constructor.
///
/// [FlameNetworkImages] also will also automatically cache files in a two layer
/// system.
///
/// The first layer is an in memory cache, handled by an internal [MemoryCache],
/// while the second is the device own's file system, where images are cached in
/// the application document directoy.
///
/// When an image is requested, [FlameImageResponse] will first check on its
/// cache layers before making the http request, if both layer are cache miss,
/// then the request is made and both layers set with the response.
///
/// Another important note about the cache layers is that the first layer, is a
/// per instance cache, while the local storage is a app global cache. This
/// means that two different [FlameImageResponse] instances will have the same
/// local storage cache, but not the memory cache.
///
/// Note that the local storage layer is not present when running on web since
/// that platform doesn't really have a file system. The Browse caching will
/// work as similar replacemente for this layer, though that can't be controlled
/// this package, make sure that the server where the images are being fetched
/// returns the correct cache header to make the browser cache the assets.
///
/// Each cache layer can be disabled by the [cacheInMemory] or [cacheInStorage]
/// argument on the constructor.
///
/// {@endtemplate}
class FlameNetworkImages {
  /// {@macro flame_network_images}
  FlameNetworkImages({
    GetImagefunction? get,
    this.cacheInMemory = true,
    this.cacheInStorage = true,
  }) : _isWeb = kIsWeb {
    _get = get ??
        (
          String url, {
          Map<String, String>? headers,
        }) =>
            http.get(Uri.parse(url), headers: headers).then((response) {
              return FlameImageResponse(
                statusCode: response.statusCode,
                bytes: response.bodyBytes,
              );
            });
  }

  late final GetImagefunction _get;

  /// Flag indicating if files will be cached in memory.
  final bool cacheInMemory;

  /// Flag indicating if files will be cached in the local storage.
  final bool cacheInStorage;

  final bool _isWeb;

  late final _memoryCache = MemoryCache<String, Image>();

  String _urlToId(String url) {
    final bytes = utf8.encode(url);
    return base64.encode(bytes);
  }

  /// Loads the given an image from the given url.
  Future<Image> load(
    String url, {
    Map<String, String>? headers,
  }) async {
    final id = _urlToId(url);

    final memoryCacheValue = _memoryCache.getValue(id);
    if (memoryCacheValue != null) {
      return memoryCacheValue;
    }

    if (!_isWeb) {
      final storageImage = await _fetchFileFromStorageCache(id);
      if (storageImage != null) {
        if (cacheInMemory) {
          _memoryCache.setValue(id, storageImage);
        }
        return storageImage;
      }
    }

    final response = await _get(url, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      final image = await decodeImageFromList(response.bytes);

      if (cacheInMemory) {
        _memoryCache.setValue(id, image);
      }

      if (!_isWeb && cacheInStorage) {
        unawaited(_saveImageInLocalStorage(id, image));
      }

      return image;
    } else {
      throw Exception(
        'Error fetching image $url, response return status code '
        '${response.statusCode}',
      );
    }
  }

  Future<Image?> _fetchFileFromStorageCache(String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(path.join(appDir.path, id));

    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      return decodeImageFromList(bytes);
    }

    return null;
  }

  Future<void> _saveImageInLocalStorage(String id, Image image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(path.join(appDir.path, id));

    final data = await image.toByteData();

    if (data != null) {
      unawaited(file.writeAsBytes(data.buffer.asUint8List()));
    }
  }
}
