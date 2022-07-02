import 'dart:ui';

abstract class Decorator {
  Canvas preprocessCanvas(Canvas canvas);
  void postprocessCanvas(Canvas canvas);
}
