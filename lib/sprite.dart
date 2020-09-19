import 'dart:ui';

import 'position.dart';
import 'palette.dart';
import 'assets.dart';

class Sprite {
  Paint paint = BasicPalette.white.paint;
  ImageAsset imageAsset;
  Rect src;

  Sprite(
    this.imageAsset, {
    double x = 0.0,
    double y = 0.0,
    double width,
    double height,
  }) {
    imageAsset.onLoad(() => _init(x, y, width, height));
  }

  void _init(double x, double y, double width, double height) {
    final image = imageAsset.image;
    width ??= image.width.toDouble();
    height ??= image.height.toDouble();
    src = Rect.fromLTWH(x, y, width, height);
  }

  bool loaded() {
    return imageAsset.loaded();
  }

  double get _imageWidth => imageAsset.image.width.toDouble();

  double get _imageHeight => imageAsset.image.height.toDouble();

  Position get originalSize {
    if (!loaded()) {
      return null;
    }
    return Position(_imageWidth, _imageHeight);
  }

  Position get size {
    return Position(src.width, src.height);
  }

  /// Renders this Sprite on the position [p], scaled by the [scale] factor provided.
  ///
  /// It renders with src size multiplied by [scale] in both directions.
  /// Anchor is on top left as default.
  /// If not loaded, does nothing.
  void renderScaled(Canvas canvas, Position p,
      {double scale = 1.0, Paint overridePaint}) {
    if (!loaded()) {
      return;
    }
    renderPosition(canvas, p,
        size: size.times(scale), overridePaint: overridePaint);
  }

  void renderPosition(Canvas canvas, Position p,
      {Position size, Paint overridePaint}) {
    if (!loaded()) {
      return;
    }
    size ??= this.size;
    renderRect(canvas, Position.rectFrom(p, size),
        overridePaint: overridePaint);
  }

  void render(Canvas canvas,
      {double width, double height, Paint overridePaint}) {
    if (!loaded()) {
      return;
    }
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
    if (!loaded()) {
      return;
    }
    size ??= this.size;
    renderRect(canvas,
        Rect.fromLTWH(p.x - size.x / 2, p.y - size.y / 2, size.x, size.y),
        overridePaint: overridePaint);
  }

  void renderRect(Canvas canvas, Rect dst, {Paint overridePaint}) {
    if (!loaded()) {
      return;
    }
    canvas.drawImageRect(imageAsset.image, src, dst, overridePaint ?? paint);
  }
}
