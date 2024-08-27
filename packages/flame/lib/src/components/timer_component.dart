import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// A component that uses a [Timer] instance which you can react to when it has
/// finished.
class TimerComponent extends Component {
  late final Timer timer;
  final bool removeOnFinish;
  final VoidCallback? _onTick;
  final bool tickOnLoad;

  /// Creates a [TimerComponent]
  ///
  /// [period] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [period] is reached
  /// [autoStart] When true, will start upon instantiation (default is true)
  /// [onTick] When provided, will be called every time [period] is reached.
  /// This overrides the [onTick] method
  /// [tickOnLoad] When true, will call [onTick] when the component is first
  /// loaded (default is false).
  TimerComponent({
    required double period,
    bool repeat = false,
    bool autoStart = true,
    this.removeOnFinish = false,
    VoidCallback? onTick,
    this.tickOnLoad = false,
    super.key,
  }) : _onTick = onTick {
    timer = Timer(
      period,
      repeat: repeat,
      onTick: this.onTick,
      autoStart: autoStart,
    );
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() {

    if (tickOnLoad) {
      onTick();
    }

    return super.onLoad();
  }

  /// Called every time the [timer] reached a tick.
  /// The default implementation calls the closure received on the
  /// constructor and can be overridden to add custom logic.
  void onTick() {
    _onTick?.call();
  }

  @override
  void update(double dt) {
    timer.update(dt);

    if (removeOnFinish && timer.finished) {
      removeFromParent();
    }
  }
}
