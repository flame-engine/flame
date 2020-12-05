import 'dart:ui';

import 'anchor.dart';
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

  /// Renders this sprite onto the canvas.
  ///
  /// * position: x,y coordinates where it will be drawn; default to origin.
  /// * size: width/height dimensions; it can be bigger or smaller than the original size -- but it defaults to the original texture size.
  /// * overridePaint: paint to use. You can also change the paint on your Sprite instance. Default is white.
  /// * anchor: where in the sprite the x/y coordinates refer to; defaults to topLeft.
  void render(
    Canvas canvas, {
    Vector2 position,
    Vector2 size,
    Anchor anchor = Anchor.topLeft,
    Paint overridePaint,
  }) {
    final drawPosition = position ?? Vector2.zero();
    final drawSize = size ?? srcSize;

    final delta = -anchor.relativePosition
      ..multiply(drawSize);
    final drawRect = (drawPosition + delta).toPositionedRect(drawSize);

    final drawPaint = overridePaint ?? paint;

    canvas.drawImageRect(image, src, drawRect, drawPaint);
  }
}
