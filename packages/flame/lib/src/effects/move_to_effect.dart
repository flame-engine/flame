
import 'package:vector_math/vector_math_64.dart';
import 'effect_component.dart';
import 'flame_animation_controller.dart';


class MoveToEffect extends Transform2DEffect {
  MoveToEffect({
    required Vector2 destination,
    required FlameAnimationController controller,
    bool? removeOnFinish,
  })  : destination = destination.clone(),
        super(controller: controller, removeOnFinish: removeOnFinish);

  final Vector2 destination;
  late final Vector2 origin;

  @override
  void onStart() {
    origin = target.position.clone();
  }

  @override
  void apply(double progress) {
    target.position.setValues(
      origin.x + (destination.x - origin.x) * progress,
      origin.y + (destination.y - origin.y) * progress,
    );
  }
}
