import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flame/cache.dart';
import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Function signature used by Flame Network Assets to fetch assets.
typedef GetAssetFunction =
    Future<FlameAssetResponse> Function(
      String url, {
      Map<String, String>? headers,
    });

/// Function signature used by Flame Network Assets to decode assets from a
/// raw format.
typedef DecodeAssetFunction<T> = Future<T> Function(Uint8List);

/// Function signature used by Flame Network Assets to encode assets to a
/// raw format.
typedef EncodeAssetFunction<T> = Future<Uint8List> Function(T);

/// Function signature by Flame Network Assets to get the app directory
/// which is used for the local storage caching.
typedef GetAppDirectoryFunction = Future<Directory> Function();

/// {@template flame_network_assets}
///
/// [FlameNetworkAssets] is a class similar to Flame's assets classes (like
/// [Images] for example), but instead of loading assets from the assets bundle,
/// it loads from networks urls.
///
/// By default, [FlameNetworkAssets] uses the [http.get] method to make the
/// requests. It can be customized by passing a different [GetAssetFunction] to
/// the `get` argument on the constructor.
///
/// [FlameNetworkAssets] also will automatically cache files in a two layer
/// system.
///
/// The first layer is an in-memory cache, handled by an internal [MemoryCache],
/// while the second one is the device's own file system, where images are
/// cached in the application document directory, which by default is provided
/// by path_providers' [getApplicationDocumentsDirectory] method, and can
/// be customized using the `getAppDirectory` argument in the constructor.
///
/// When an asset is requested, [FlameAssetResponse] will first check on its
/// cache layers before making the http request, if both layer are cache miss,
/// then the request is made and both layers set with the response.
///
/// Another important note about the cache layers is that the first layer, is a
/// per instance cache, while the local storage is an app global cache. This
/// means that two different [FlameAssetResponse] instances will have the same
/// local storage cache, but not the same memory cache.
///
/// Note that the local storage layer is not present when running on web since
/// that platform doesn't really have a file system. The browser caching will
/// work as a similar replacement for this layer, though that can't be
/// controlled by this package, make sure that the server where the images
/// are being fetched returns the correct cache header to make the browser
/// cache the assets.
///
/// Each cache layer can be disabled by the [cacheInMemory] or [cacheInStorage]
/// argument on the constructor.
///
/// {@endtemplate}
abstract class FlameNetworkAssets<T> {
  /// {@macro flame_network_assets}
  ///
  /// - [decodeAsset] a [DecodeAssetFunction] responsible for decoding the asset
  /// from its raw format.
  /// - [encodeAsset] a [EncodeAssetFunction] responsible for encoding the asset
  /// to its raw format.
  /// - [get] is an optional [GetAssetFunction], if omitted [http.get] is used
  /// by default.
  /// - [getAppDirectory] is an optional [GetAppDirectoryFunction], if omitted
  /// [getApplicationDocumentsDirectory] is used by default.
  /// - [cacheInMemory] will not cache assets in the memory when false,
  /// (true by default).
  /// - [cacheInStorage] will not cache assets in the file system when false,
  /// (true by default).
  FlameNetworkAssets({
    required DecodeAssetFunction<T> decodeAsset,
    required EncodeAssetFunction<T> encodeAsset,
    GetAssetFunction? get,
    GetAppDirectoryFunction? getAppDirectory,
    this.cacheInMemory = true,
    this.cacheInStorage = true,
  }) : _isWeb = kIsWeb,
       _decode = decodeAsset,
       _encode = encodeAsset {
    _get =
        get ??
        (
          String url, {
          Map<String, String>? headers,
        }) => http.get(Uri.parse(url), headers: headers).then((response) {
          return FlameAssetResponse(
            statusCode: response.statusCode,
            bytes: response.bodyBytes,
          );
        });

    _getAppDirectory = getAppDirectory ?? getApplicationDocumentsDirectory;
  }

  late final GetAssetFunction _get;
  late final GetAppDirectoryFunction _getAppDirectory;
  final DecodeAssetFunction<T> _decode;
  final EncodeAssetFunction<T> _encode;

  /// Flag indicating if files will be cached in memory.
  final bool cacheInMemory;

  /// Flag indicating if files will be cached in the local storage.
  final bool cacheInStorage;

  final bool _isWeb;

  final _memoryCache = MemoryCache<String, T>();

  String _urlToId(String url) {
    final bytes = utf8.encode(url);
    return base64.encode(bytes);
  }

  /// Loads the asset from the given url.
  Future<T> load(
    String url, {
    Map<String, String>? headers,
  }) async {
    final id = _urlToId(url);

    final memoryCacheValue = _memoryCache.getValue(id);
    if (memoryCacheValue != null) {
      return memoryCacheValue;
    }

    if (!_isWeb && cacheInStorage) {
      final storageAsset = await _fetchAssetFromStorageCache(id);
      if (storageAsset != null) {
        if (cacheInMemory) {
          _memoryCache.setValue(id, storageAsset);
        }
        return storageAsset;
      }
    }

    final response = await _get(url, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      final image = await _decode(response.bytes);

      if (cacheInMemory) {
        _memoryCache.setValue(id, image);
      }

      if (!_isWeb && cacheInStorage) {
        unawaited(_saveAssetInLocalStorage(id, image));
      }

      return image;
    } else {
      throw Exception(
        'Error fetching asset from $url, response return status code '
        '${response.statusCode}',
      );
    }
  }

  Future<T?> _fetchAssetFromStorageCache(String id) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File(path.join(appDir.path, id));

      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        return await _decode(bytes);
      }
    } on Exception catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _saveAssetInLocalStorage(String id, T asset) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File(path.join(appDir.path, id));

      await file.writeAsBytes(await _encode(asset));
    } on Exception catch (_) {}
  }
}
