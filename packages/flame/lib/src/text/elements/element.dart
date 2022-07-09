import 'dart:ui';

abstract class Element {
  void translate(double dx, double dy);
  void render(Canvas canvas);
}
