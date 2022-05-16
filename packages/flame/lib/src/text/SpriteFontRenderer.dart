
import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/text.dart';
import 'package:vector_math/vector_math_64.dart';

class SpriteFontRenderer extends TextRenderer {
  Map<String, Rect> glyphs = {};

  @override
  double measureTextHeight(String text) {
    // TODO: implement measureTextHeight
    throw UnimplementedError();
  }

  @override
  double measureTextWidth(String text) {
    // TODO: implement measureTextWidth
    throw UnimplementedError();
  }

  @override
  void render(Canvas canvas, String text, Vector2 position, {Anchor anchor = Anchor.topLeft}) {
    // TODO: implement render
    canvas.drawAtlas(atlas, transforms, rects, colors, blendMode, cullRect, paint);
    canvas.drawRawAtlas(atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);
  }
}
