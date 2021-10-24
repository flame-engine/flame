import '../../components.dart';
import '../../game.dart';
import 'effect.dart';
import 'flame_animation_controller.dart';

abstract class Transform2DEffect extends Effect {
  Transform2DEffect({
    required FlameAnimationController controller,
  }) : super(controller: controller);

  late Transform2D target;

  @override
  void onMount() {
    super.onMount();
    assert(parent != null);
    if (parent is PositionComponent) {
      target = (parent! as PositionComponent).transform;
    }
    // TODO: add Camera support once it uses Transform2D
    else {
      throw UnsupportedError(
        'Can only apply a Transform2DEffect to a PositionComponent class',
      );
    }
  }
}
