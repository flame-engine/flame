import 'dart:ui';

import '../image_composition.dart';
import 'anchor.dart';
import 'assets/images.dart';
import 'extensions/offset.dart';
import 'extensions/vector2.dart';
import 'flame.dart';
import 'palette.dart';

/// A [Sprite] is a region of an [Image] that can be rendered in the Canvas.
///
/// It might represent the entire image or be one of the pieces a spritesheet is composed of.
/// It holds a reference to the source image from which the region is extracted, and the [src]
/// rectangle is the portion inside that image that is to be rendered (not to be confused with the
/// `dest` rect, which is where in the Canvas the sprite is rendered).
/// It also has a [paint] field that can be overwritten to apply a tint to this [Sprite] (default is
/// white, meaning no tint).
class Sprite {
  Paint paint = BasicPalette.white.paint();
  Image image;
  Rect src = Rect.zero;

  Sprite(
    this.image, {
    Vector2? srcPosition,
    Vector2? srcSize,
  }) {
    this.srcSize = srcSize;
    this.srcPosition = srcPosition;
  }

  /// Takes a path of an image, a [srcPosition] and [srcSize] and loads the sprite animation
  /// When the [images] is omitted, the global [Flame.images] is used
  static Future<Sprite> load(
    String src, {
    Vector2? srcPosition,
    Vector2? srcSize,
    Images? images,
  }) async {
    final _images = images ?? Flame.images;
    final image = await _images.load(src);
    return Sprite(image, srcPosition: srcPosition, srcSize: srcSize);
  }

  double get _imageWidth => image.width.toDouble();

  double get _imageHeight => image.height.toDouble();

  Vector2 get originalSize => Vector2(_imageWidth, _imageHeight);

  Vector2 get srcSize => Vector2(src.width, src.height);

  set srcSize(Vector2? size) {
    final actualSize = size ?? image.size;
    src = srcPosition.toPositionedRect(actualSize);
  }

  Vector2 get srcPosition => src.topLeft.toVector2();

  set srcPosition(Vector2? position) {
    src = (position ?? Vector2.zero()).toPositionedRect(srcSize);
  }

  /// Same as [render], but takes both the position and the size as a single
  /// [Rect].
  ///
  /// **Note**: only use this if you are already using [Rect]'s to represent both the position and
  /// dimension of your [Sprite]. If you are using [Vector2]s, prefer the other method.
  void renderRect(
    Canvas canvas,
    Rect rect, {
    Paint? overridePaint,
  }) {
    render(
      canvas,
      position: rect.topLeft.toVector2(),
      size: rect.size.toVector2(),
      overridePaint: overridePaint,
    );
  }

  /// Renders this sprite onto the [canvas].
  ///
  /// * [position]: x,y coordinates where it will be drawn; default to origin.
  /// * [size]: width/height dimensions; it can be bigger or smaller than the original size -- but it
  ///   defaults to the original texture size.
  /// * [anchor]: where in the sprite the x/y coordinates refer to; defaults to topLeft.
  /// * [overridePaint]: paint to use. You can also change the paint on your Sprite instance. Default
  ///   is white.
  void render(
    Canvas canvas, {
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
    Paint? overridePaint,
  }) {
    final drawPosition = position ?? Vector2.zero();
    final drawSize = size ?? srcSize;

    final delta = anchor.toVector2()..multiply(drawSize);
    final drawRect = (drawPosition + delta).toPositionedRect(drawSize);

    final drawPaint = overridePaint ?? paint;

    canvas.drawImageRect(image, src, drawRect, drawPaint);
  }

  /// Return a new Image based on the [src] of the Sprite.
  ///
  /// **Note:** This is a heavy async operation and should not be called inside the game loop.
  Future<Image> toImage() async {
    final composition = ImageComposition()
      ..add(image, Vector2.zero(), source: src);
    return composition.compose();
  }
}
