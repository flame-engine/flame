import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A [Svg] to be rendered on a Flame [Game].
class Svg {
  /// The [PictureInfo] that this [Svg] represents.
  final PictureInfo pictureInfo;

  /// The pixel ratio that this [Svg] is rendered based on.
  final double pixelRatio;

  /// Creates an [Svg] with the received [pictureInfo].
  /// Default [pixelRatio] is the device pixel ratio.
  Svg(this.pictureInfo, {double? pixelRatio})
      : pixelRatio = pixelRatio ??
            PlatformDispatcher.instance.views.first.devicePixelRatio;

  final MemoryCache<Size, Image> _imageCache = MemoryCache();

  final _paint = Paint()..filterQuality = FilterQuality.medium;

  final List<Size> _lock = [];

  /// Loads an [Svg] with the received [cache]. When no [cache] is provided,
  /// the global [Flame.assets] is used.
  static Future<Svg> load(
    String fileName, {
    AssetsCache? cache,
    double? pixelRatio,
  }) async {
    cache ??= Flame.assets;
    final svgString = await cache.readFile(fileName);
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    return Svg(
      pictureInfo,
      pixelRatio: pixelRatio,
    );
  }

  /// Renders the svg on the [canvas] using the dimensions provided by [size].
  void render(
    Canvas canvas,
    Vector2 size, {
    Paint? overridePaint,
  }) {
    final localSize = size.toSize();
    final image = _getImage(localSize);

    if (image != null) {
      canvas.save();
      canvas.scale(1 / pixelRatio);
      final drawPaint = overridePaint ?? _paint;
      canvas.drawImage(image, Offset.zero, drawPaint);
      canvas.restore();
    } else {
      _render(canvas, localSize);
    }
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

  Image? _getImage(Size size) {
    final image = _imageCache.getValue(size);

    if (image == null && !_lock.contains(size)) {
      _lock.add(size);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.scale(pixelRatio);
      _render(canvas, size);
      final picture = recorder.endRecording();
      picture
          .toImageSafe(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      )
          .then((image) {
        _imageCache.setValue(size, image);
        _lock.remove(size);
      });
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
    _imageCache.keys.forEach((key) {
      _imageCache.getValue(key)?.dispose();
    });
    _imageCache.clearCache();
  }
}

/// Provides a loading method for [Svg] on the [Game] class.
extension SvgLoader on Game {
  /// Loads an [Svg] using the [Game]'s own asset loader.
  Future<Svg> loadSvg(String fileName) => Svg.load(fileName, cache: assets);
}
