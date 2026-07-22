import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_svg/flutter_svg.dart';

/// A [Svg] to be rendered on a Flame [Game].
class Svg {
  /// Creates an [Svg] with the received [pictureInfo].
  /// Default [pixelRatio] is the device pixel ratio.
  /// Setting [integralSize] to `true` uses integer dimensions for cache keys.
  /// Setting [fixedRatio] to `true` ensures the cache uses a single entry.
  /// Default [cacheSize] is [defaultCacheSize], which is 10 as previously;
  /// specifying [unlimitedCacheSize] is the same as using a [Map] instead
  /// of a [MemoryCache].
  Svg(
    this.pictureInfo, {
    double? pixelRatio,
    bool integralSize = false,
    bool fixedRatio = false,
    int cacheSize = defaultCacheSize,
  }) : pixelRatio =
           pixelRatio ??
           WidgetsBinding
               .instance
               .platformDispatcher
               .views
               .first
               .devicePixelRatio {
    _integralSize = integralSize;
    _fixedRatio = fixedRatio;
    _cacheSize = cacheSize;
    assert(_cacheSize >= 1, 'The cache size must support at least one slot.');
    _imageCache = MemoryCache(
      cacheSize: _cacheSize >= 1 ? _cacheSize : defaultCacheSize,
    );
  }

  /// The [PictureInfo] that this [Svg] represents.
  final PictureInfo pictureInfo;

  /// The pixel ratio that this [Svg] is rendered based on.
  final double pixelRatio;

  /// Whether we're using integral sizes for the cache keys (default: false).
  bool get integralSize => _integralSize;
  set integralSize(bool integral) {
    _emptyCache();
    _integralSize = integral;
  }

  late bool _integralSize;

  /// Whether we're using a fixed ratio for the cache keys (default: false).
  bool get fixedRatio => _fixedRatio;
  set fixedRatio(bool fixed) {
    _emptyCache();
    _fixedRatio = fixed;
  }

  late bool _fixedRatio;

  /// The current cache size (default 10): changing the size also empties it.
  int get cacheSize => _cacheSize;
  set cacheSize(int size) {
    assert(size >= 1, 'The cache size must support at least one slot.');
    if (size >= 1 && size != cacheSize) {
      _emptyCache();
      _cacheSize = size;
      _imageCache = MemoryCache(cacheSize: _cacheSize);
    }
  }

  late int _cacheSize;

  /// The number of images currently used by the cache.
  int get cacheUsage => _imageCache.size;

  late MemoryCache<Size, Image> _imageCache;

  final _paint = Paint()..filterQuality = FilterQuality.medium;

  /// Loads an [Svg] with the received [cache]. When no [cache] is provided,
  /// the global [Flame.assets] is used.
  static Future<Svg> load(
    String fileName, {
    AssetsCache? cache,
    double? pixelRatio,
    bool integralSize = false,
    bool fixedRatio = false,
    int cacheSize = defaultCacheSize,
    String? package,
  }) async {
    cache ??= Flame.assets;
    final svgString = await cache.readFile(fileName, package: package);
    return Svg.loadFromString(
      svgString,
      pixelRatio: pixelRatio,
      integralSize: integralSize,
      fixedRatio: fixedRatio,
      cacheSize: cacheSize,
    );
  }

  /// Loads an [Svg] from a string.
  static Future<Svg> loadFromString(
    String svgString, {
    double? pixelRatio,
    bool integralSize = false,
    bool fixedRatio = false,
    int cacheSize = defaultCacheSize,
  }) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    return Svg(
      pictureInfo,
      pixelRatio: pixelRatio,
      integralSize: integralSize,
      fixedRatio: fixedRatio,
      cacheSize: cacheSize,
    );
  }

  /// Default memory cache size.
  static const int defaultCacheSize = 10;

  /// Unlimited memory cache size.
  static final int unlimitedCacheSize = double.maxFinite.toInt();

  /// Renders the svg on the [canvas] using the dimensions provided by [size].
  void render(
    Canvas canvas,
    Vector2 size, {
    Paint? overridePaint,
  }) {
    // Scale the canvas to the size of the destination clip bounds
    // This is necessary to avoid blurriness when having a
    // camera.viewfinder.zoom larger than 1.0
    final destinationClipBounds = canvas.getDestinationClipBounds();
    final localClipBounds = canvas.getLocalClipBounds();
    final widthRatio = fixedRatio
        ? 1.0
        : destinationClipBounds.size.width / localClipBounds.size.width;
    final heightRatio = fixedRatio
        ? 1.0
        : destinationClipBounds.size.height / localClipBounds.size.height;

    final localSize = Size(size.x, size.y);
    final image = _getImage(localSize, widthRatio, heightRatio);

    canvas.save();
    canvas.scale(
      1 / (pixelRatio * widthRatio),
      1 / (pixelRatio * heightRatio),
    );
    canvas.drawImage(
      image,
      Offset.zero,
      overridePaint ?? _paint,
    );
    canvas.restore();
  }

  /// Renders the svg on the [canvas] on the given [position] using the
  /// dimensions provided by [size].
  void renderPosition(
    Canvas canvas,
    Vector2 position,
    Vector2 size,
  ) {
    canvas.renderAt(position, (c) => render(c, size));
  }

  Image _getImage(Size size, double widthRatio, double heightRatio) {
    final width = size.width * widthRatio;
    final height = size.height * heightRatio;
    Size cacheKey;
    if (fixedRatio || integralSize) {
      cacheKey = Size(width.ceilToDouble(), height.ceilToDouble());
    } else {
      cacheKey = Size(width, height);
    }
    final image = _imageCache.getValue(cacheKey);

    if (image == null) {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.scale(pixelRatio * widthRatio, pixelRatio * heightRatio);
      _render(canvas, size);
      final picture = recorder.endRecording();
      final image = picture.toImageSync(
        (width * pixelRatio).ceil(),
        (height * pixelRatio).ceil(),
      );

      picture.dispose();
      _imageCache.setValue(cacheKey, image);
      return image;
    }

    return image;
  }

  void _render(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / pictureInfo.size.width,
      size.height / pictureInfo.size.height,
    );
    canvas.translate(
      (size.width - pictureInfo.size.width * scale) / 2,
      (size.height - pictureInfo.size.height * scale) / 2,
    );
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);
  }

  /// Clear all the stored cache from this SVG, be sure to call
  /// this method once the instance is no longer needed to avoid
  /// memory leaks
  void dispose() {
    _emptyCache();
  }

  /// Get rid of all cached images.
  void _emptyCache() {
    _imageCache.keys.forEach((key) {
      _imageCache.getValue(key)?.dispose();
    });
    _imageCache.clearCache();
  }
}

/// Provides a loading method for [Svg] on the [Game] class.
extension SvgLoader on Game {
  /// Loads an [Svg] using the [Game]'s own asset loader.
  Future<Svg> loadSvg(
    String fileName, {
    String? package,
    bool integralSize = false,
    bool fixedRatio = false,
    int cacheSize = Svg.defaultCacheSize,
  }) => Svg.load(
    fileName,
    cache: assets,
    package: package,
    integralSize: integralSize,
    fixedRatio: fixedRatio,
    cacheSize: cacheSize,
  );
}
