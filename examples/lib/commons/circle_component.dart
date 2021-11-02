import 'package:flame/components.dart';

class ExampleCircleComponent extends CircleComponent {
  ExampleCircleComponent({
    double radius = 10,
    Vector2? position,
    int priority = 0,
  }) : super(
          radius,
          position: position,
          priority: priority,
        ) {
    anchor = Anchor.center;
  }
}
