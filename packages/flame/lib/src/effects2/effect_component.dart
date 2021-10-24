import 'package:meta/meta.dart';

import '../../components.dart';
import 'flame_animation_controller.dart';

/// An Effect's main purpose it to create a change over time in some other
/// component's properties or appearance.
abstract class EffectComponent extends Component {
  EffectComponent({
    required this.controller,
  })  : _removeOnFinish = true,
        _paused = false,
        _started = false,
        _finished = false;

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

  bool _started;
  bool _finished;

  void pause() => _paused = true;
  void resume() => _paused = false;

  @mustCallSuper
  void reset() {
    _paused = false;
    _started = false;
    _finished = false;
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
    if (!_started && controller.started) {
      _started = true;
      onStart();
    }
    apply(controller.progress);
    if (!_finished && controller.completed) {
      _finished = true;
      onFinish();
      if (_removeOnFinish) {
        removeFromParent();
      }
    }
  }

  void onStart() {}
  void onFinish() {}
  void apply(double progress);
}
