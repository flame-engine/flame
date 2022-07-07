import 'dart:ui';

abstract class BackgroundElement {
  void layout() {}
  void translate(double dx, double dy);
  void render(Canvas canvas);
}
