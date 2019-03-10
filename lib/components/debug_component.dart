import 'dart:ui';

import 'component.dart';
import 'package:flutter/painting.dart';

/// This is a debug component that draws a rect on its position.
///
/// You can add it to your game to find out the position of something that's not normally rendered (like a hitbox or point o interaction).
/// It will render a rectangle of ([width], [height]) on the position([x], [y]), of color [color].
class DebugComponent extends PositionComponent {
  /// The color of the rectangle (defaults to magenta).
  Color color = const Color(0xFFFF00FF);

  /// The actual paint used; by default it paints with stroke only and [color].
  Paint get paint => Paint()
    ..color = color
    ..style = PaintingStyle.stroke;

  /// Don't do anything (change as desired)
  void update(double t) {}

  /// Renders the rectangle
  void render(Canvas c) {
    prepareCanvas(c);
    c.drawRect(Rect.fromLTWH(0.0, 0.0, width, height), paint);
  }

  /// Don't do anything (change as desired)
  void resize(Size size) {}

  bool loaded() => true;
  bool destroy() => false;
  bool isHud() => false;
}
