import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'extensions/vector2.dart';
import 'flame.dart';

/// sprite atlas with an image and a set of rects and transforms
class SpriteBatch {
  final Image atlas;
  List<Rect> rects = [];
  List<RSTransform> transforms = [];
  List<Color> colors = [];
  List<Matrix4> matrices = [];

  static const defaultBlendMode = BlendMode.srcOver;
  static const defaultColor = const Color(0x00000000); // transparent
  static final defaultPaint = Paint();
  static final defaultTransform = RSTransform(1, 0, 0, 0);

  SpriteBatch(this.atlas);

  static Future<SpriteBatch> withAsset(String imageName) async {
    return SpriteBatch(await Flame.images.load(imageName));
  }

  int get width => atlas.width;

  int get height => atlas.height;

  Vector2 get size => Vector2Extension.fromInts(width, height);

  /// Add a new sprite using a RSTransform.
  ///
  /// The [add] method may be a simpler way to add a sprite to the batch. However,
  /// if there is a way to factor out the computations of the sine and cosine of the
  /// rotation so that they can be reused over multiple calls to this constructor,
  /// it may be more efficient to directly use this method instead.
  ///
  /// The [rect] parameter is the source location on the [atlas]. You can position it
  /// on the canvas using the [offset] parameter.
  ///
  /// The [color] paramater allows you to render a color behind the sprite, as a background color.
  void addTransform({
    @required Rect rect,
    RSTransform transform,
    Color color,
  }) {
    transform ??= defaultTransform;
    rects.add(rect);
    transforms.add(transform ?? defaultTransform);
    colors.add(color ?? defaultColor);

    matrices.add(Matrix4(
      transform.scos,
      transform.ssin,
      0,
      0,
      -transform.ssin,
      transform.scos,
      0,
      0,
      0,
      0,
      // This is the scale, we can't determine this from a RSTransform,
      //but we also don't need to because it is already calculated inside the transform values.
      1,
      0,
      transform.tx,
      transform.ty,
      0,
      1,
    ));
  }

  /// Add a new sprite.
  ///
  /// The [rect] parameter is the source location on the [atlas]. You can position it
  /// on the canvas using the [offset] parameter.
  ///
  /// You can transform the sprite from its [offset] using [scale], [rotation] and [anchor].
  ///
  /// The [color] paramater allows you to render a color behind the sprite, as a background color.
  void add({
    @required Rect rect,
    double scale = 1.0,
    Offset anchor = Offset.zero,
    double rotation = 0,
    Offset offset = Offset.zero,
    Color color,
  }) {
    final transform = RSTransform.fromComponents(
      scale: scale,
      anchorX: anchor.dx,
      anchorY: anchor.dy,
      rotation: rotation,
      translateX: offset.dx,
      translateY: offset.dy,
    );

    addTransform(
      rect: rect,
      transform: transform,
      color: color,
    );
  }

  /// Clear the SpriteBatch so it can be reused.
  void clear() {
    rects.clear();
    transforms.clear();
    colors.clear();
    matrices.clear();
  }

  void render(
    Canvas canvas, {
    BlendMode blendMode,
    Rect cullRect,
    Paint paint,
  }) {
    paint ??= Paint();

    if (kIsWeb) {
      for (var i = 0; i < matrices.length; i++) {
        final matrix = matrices[i];
        final rect = rects[i];
        final color = colors[i];
        paint..blendMode = blendMode ?? paint.blendMode ?? defaultBlendMode;

        canvas
          ..save()
          ..transform(matrix.storage)
          ..drawRect(Offset.zero & rect.size, Paint()..color = color)
          ..drawImageRect(
            atlas,
            rect,
            Offset.zero & rect.size,
            paint,
          )
          ..restore();
      }
    } else {
      canvas.drawAtlas(
        atlas,
        transforms,
        rects,
        colors,
        blendMode ?? defaultBlendMode,
        cullRect,
        paint,
      );
    }
  }
}
