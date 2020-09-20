import 'dart:ui';

import 'position.dart';
import 'palette.dart';

class Sprite {
  Paint paint = BasicPalette.white.paint;
  Image image;
  Rect src;

  Sprite(
    this.image, {
    double x = 0.0,
    double y = 0.0,
    double width,
    double height,
  }) : assert(image != null, "image can't be null") {
    width ??= image.width.toDouble();
    height ??= image.height.toDouble();
    src = Rect.fromLTWH(x, y, width, height);
  }

  double get _imageWidth => image.width.toDouble();

  double get _imageHeight => image.height.toDouble();

  Position get originalSize => Position(_imageWidth, _imageHeight);

  Position get size => Position(src.width, src.height);

  /// Renders this Sprite on the position [p], scaled by the [scale] factor provided.
  ///
  /// It renders with src size multiplied by [scale] in both directions.
  /// Anchor is on top left as default.
  /// If not loaded, does nothing.
  void renderScaled(Canvas canvas, Position p,
      {double scale = 1.0, Paint overridePaint}) {
    renderPosition(canvas, p,
        size: size.times(scale), overridePaint: overridePaint);
  }

  void renderPosition(Canvas canvas, Position p,
      {Position size, Paint overridePaint}) {
    size ??= this.size;
    renderRect(canvas, Position.rectFrom(p, size),
        overridePaint: overridePaint);
  }

  void render(Canvas canvas,
      {double width, double height, Paint overridePaint}) {
    width ??= size.x;
    height ??= size.y;
    renderRect(canvas, Rect.fromLTWH(0.0, 0.0, width, height),
        overridePaint: overridePaint);
  }

  /// Renders this sprite centered in the position [p], i.e., on [p] - [size] / 2.
  ///
  /// If [size] is not provided, the original size of the src image is used.
  /// If the asset is not yet loaded, it does nothing.
  void renderCentered(Canvas canvas, Position p,
      {Position size, Paint overridePaint}) {
    size ??= this.size;
    renderRect(canvas,
        Rect.fromLTWH(p.x - size.x / 2, p.y - size.y / 2, size.x, size.y),
        overridePaint: overridePaint);
  }

  void renderRect(Canvas canvas, Rect dst, {Paint overridePaint}) {
    canvas.drawImageRect(image, src, dst, overridePaint ?? paint);
  }
}
