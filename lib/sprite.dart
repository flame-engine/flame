import 'dart:ui';
import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/palette.dart';

class Sprite {
  Paint paint = BasicPalette.white.paint;
  Image image;
  Rect src;

  Sprite(
    Image image,
    {
      int x = 0,
      int y = 0,
      int width,
      int height,
    }
  ) : this.fromImage(image, x: x, y: y, width: width, height: height);

  Sprite.empty();

  Sprite.fromImage(
    this.image,
    {
      int x = 0,
      int y = 0,
      int width,
      int height,
    }
  ) {
    width ??= image.width;
    height ??= image.height;
    src = Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
  }

  Sprite.fromImageCache(
    String fileName,
    {
      int x = 0,
      int y = 0,
      int width,
      int height,
    }
  ) : this.fromImage(Flame.images.fromCache(fileName), x: x, y: y, width: width, height: height);

  static Future<Sprite> fromFile(
    String fileName,
    {
      int x = 0,
      int y = 0,
      int width,
      int height,
    }
  ) async {
    final Image image = await Flame.images.load(fileName);
    return Sprite.fromImage(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  bool loaded() {
    return image != null && src != null;
  }

  double get _imageWidth => image.width.toDouble();

  double get _imageHeight => image.height.toDouble();

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
    canvas.drawImageRect(image, src, dst, overridePaint ?? paint);
  }
}
