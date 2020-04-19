import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'flame.dart';

/// sprite atlas with an image and a set of rects and transforms
class SpriteBatch {
  final Image atlas;
  List<Rect> rects = [];
  List<RSTransform> transforms = [];
  List<Color> colors = [];

  static const defaultBlendMode = BlendMode.srcOver;
  static const defaultCullRect = null;
  static final defaultPaint = Paint();
  static final defaultTransform = RSTransform(1, 0, 0, 0);
  static const defaultColor = const Color(0x00000000); // transparent

  SpriteBatch(this.atlas);

  static Future<SpriteBatch> withAsset(String imageName) async {
    return SpriteBatch(await Flame.images.load(imageName));
  }

  int get width => atlas.width;

  int get height => atlas.height;

  Size get size => Size(width.toDouble(), height.toDouble());

  void addTransform({
    @required Rect rect,
    RSTransform transform,
    Color color,
  }) {
    rects.add(rect);
    transforms.add(transform ?? defaultTransform);
    colors.add(color ?? defaultColor);
  }

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
    addTransform(rect: rect, transform: transform, color: color);
  }

  void clear() {
    rects.clear();
    transforms.clear();
    colors.clear();
  }

  void render(
    Canvas canvas, {
    BlendMode blendMode,
    Rect cullRect,
    Paint paint,
  }) {
    canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      colors,
      blendMode ?? defaultBlendMode,
      cullRect ?? defaultCullRect,
      paint ?? defaultPaint,
    );
  }
}
