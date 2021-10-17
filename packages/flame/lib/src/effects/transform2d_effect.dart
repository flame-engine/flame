import '../../components.dart';
import '../../game.dart';
import 'effect_component.dart';
import 'flame_animation_controller.dart';

abstract class Transform2DEffect extends EffectComponent {
  Transform2DEffect({
    required FlameAnimationController controller,
  }) : super(controller: controller);

  late final Transform2D target;

  @override
  Future<void>? onLoad() async {
    super.onLoad();
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
