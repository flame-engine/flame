
import '../../components.dart';
import '../../game.dart';
import 'flame_animation_controller.dart';

abstract class EffectComponent extends Component {
  EffectComponent({
    required this.controller,
    bool? removeOnFinish,
  })  : assert(controller.isInfinite ? removeOnFinish != true : true,
            'Infinitely repeating effect cannot have removeOnFinish=true'),
        removeOnFinish = removeOnFinish ?? true,
        _paused = false
  {
    if (controller.onStart == null) {
      controller.onStart = onStart;
    } else {
      final callback = controller.onStart!;
      controller.onStart = () {
        onStart();
        callback();
      };
    }
  }

  final FlameAnimationController controller;

  /// Whether the effect should be removed from its parent once it has
  /// completed.
  final bool removeOnFinish;

  /// Whether the effect is paused or not.
  bool get isPaused => _paused;
  bool _paused;

  void pause() => _paused = true;
  void resume() => _paused = false;

  void reset() {
    _paused = false;
    controller.reset();
    apply(0);
  }

  @override
  void update(double dt) {
    if (_paused) {
      return;
    }
    super.update(dt);
    controller.update(dt);
    apply(controller.progress);
    if (controller.completed && removeOnFinish) {
      removeFromParent();
    }
  }

  void onStart();
  void apply(double progress);
}

abstract class Transform2DEffect extends EffectComponent {
  Transform2DEffect({
    required FlameAnimationController controller,
    bool? removeOnFinish,
  }) : super(controller: controller, removeOnFinish: removeOnFinish);

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
        'Can apply a Transform2DEffect to a PositionComponent class',
      );
    }
  }
}
