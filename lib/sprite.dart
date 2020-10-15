import 'dart:ui';

import 'extensions/offset.dart';
import 'extensions/vector2.dart';
import 'palette.dart';

class Sprite {
  Paint paint = BasicPalette.white.paint;
  Image image;
  Rect src;

  Sprite(
    this.image, {
    Vector2 srcPosition,
    Vector2 srcSize,
  }) : assert(image != null, "image can't be null") {
    this.srcSize = srcSize;
    this.srcPosition = srcPosition;
  }

  double get _imageWidth => image.width.toDouble();

  double get _imageHeight => image.height.toDouble();

  Vector2 get originalSize => Vector2(_imageWidth, _imageHeight);

  Vector2 get srcSize => Vector2(src.width, src.height);

  set srcSize(Vector2 size) {
    size ??= Vector2Extension.fromInts(image.width, image.height);
    src = (srcPosition ?? Vector2.zero()).toPositionedRect(size);
  }

  Vector2 get srcPosition => (src?.topLeft ?? Offset.zero).toVector2();

  set srcPosition(Vector2 position) {
    src = (position ?? Vector2.zero()).toPositionedRect(srcSize);
  }

  /// Renders this Sprite on the position [p], scaled by the [scale] factor provided.
  ///
  /// It renders with src size multiplied by [scale] in both directions.
  /// Anchor is on top left as default.
  /// If not loaded, does nothing.
  void renderScaled(
    Canvas canvas,
    Vector2 p, {
    double scale = 1.0,
    Paint overridePaint,
  }) {
    renderPosition(
      canvas,
      p,
      size: srcSize * scale,
      overridePaint: overridePaint,
    );
  }

  void renderPosition(
    Canvas canvas,
    Vector2 p, {
    Vector2 size,
    Paint overridePaint,
  }) {
    size ??= srcSize;
    renderRect(canvas, p.toPositionedRect(size), overridePaint: overridePaint);
  }

  void render(
    Canvas canvas, {
    Vector2 size,
    Paint overridePaint,
  }) {
    size ??= srcSize;
    renderRect(canvas, size.toRect(), overridePaint: overridePaint);
  }

  /// Renders this sprite centered in the position [p], i.e., on [p] - [size] / 2.
  ///
  /// If [size] is not provided, the original size of the src image is used.
  /// If the asset is not yet loaded, it does nothing.
  void renderCentered(
    Canvas canvas,
    Vector2 p, {
    Vector2 size,
    Paint overridePaint,
  }) {
    size ??= srcSize;
    renderRect(
      canvas,
      (p - size / 2).toPositionedRect(size),
      overridePaint: overridePaint,
    );
  }

  void renderRect(
    Canvas canvas,
    Rect dst, {
    Paint overridePaint,
  }) {
    canvas.drawImageRect(image, src, dst, overridePaint ?? paint);
  }
}
