import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A [Svg] to be rendered on a Flame [Game].
class Svg {
  /// The [DrawableRoot] that this [Svg] represents.
  final DrawableRoot svgRoot;

  /// Creates an [Svg] with the received [svgRoot].
  Svg(this.svgRoot);

  final MemoryCache<Size, Image> _imageCache = MemoryCache();

  final _paint = Paint()..filterQuality = FilterQuality.high;

  final List<Size> _lock = [];

  /// Loads an [Svg] with the received [cache]. When no [cache] is provided,
  /// the global [Flame.assets] is used.
  static Future<Svg> load(String fileName, {AssetsCache? cache}) async {
    cache ??= Flame.assets;
    final svgString = await cache.readFile(fileName);
    return Svg(await svg.fromSvgString(svgString, svgString));
  }

  /// Renders the svg on the [canvas] using the dimensions provided by [size].
  void render(Canvas canvas, Vector2 size) {
    final _size = size.toSize();
    final image = _getImage(_size);

    if (image != null) {
      canvas.drawImage(image, Offset.zero, _paint);
    } else {
      _render(canvas, _size);
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
      _render(canvas, size);
      final _picture = recorder.endRecording();

      _picture.toImage(size.width.toInt(), size.height.toInt()).then((image) {
        _imageCache.setValue(size, image);
        _lock.remove(size);
        _picture.dispose();
      });
    }

    return image;
  }

  void _render(Canvas canvas, Size size) {
    svgRoot.scaleCanvasToViewBox(canvas, size);
    svgRoot.draw(canvas, svgRoot.viewport.viewBoxRect);
  }

  /// Clear all the stored cache from this SVG, be sure to call
  /// this method once the instance is no longer needed to avoid
  /// memory leaks
  void dispose() {
    _imageCache.keys.forEach((key) {
      _imageCache.getValue(key)?.dispose();
    });
  }
}

/// Provides a loading method for [Svg] on the [Game] class.
extension SvgLoader on Game {
  /// Loads an [Svg] using the [Game]'s own asset loader.
  Future<Svg> loadSvg(String fileName) => Svg.load(fileName, cache: assets);
}
