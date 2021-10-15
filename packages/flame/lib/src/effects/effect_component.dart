
import 'package:flutter/cupertino.dart';

import '../../components.dart';
import 'flame_animation_controller.dart';

/// An Effect's main purpose it to create a change over time in some other
/// component's properties or appearance.
abstract class EffectComponent extends Component {
  EffectComponent({
    required this.controller,
  })  : _removeOnFinish = true,
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

  /// Whether the effect should be removed from its parent once it is completed.
  bool get removeOnFinish => _removeOnFinish;
  bool _removeOnFinish;
  set removeOnFinish(bool value) {
    if (controller.isInfinite) {
      assert(value == false,
        'Infinitely repeating effect cannot have removeOnFinish=true');
    }
    _removeOnFinish = value;
  }

  /// Whether the effect is paused or not.
  bool get isPaused => _paused;
  bool _paused;

  void pause() => _paused = true;
  void resume() => _paused = false;

  @mustCallSuper
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
    if (controller.completed && _removeOnFinish) {
      removeFromParent();
    }
  }

  void onStart() {}
  void apply(double progress);
}
