import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// A component that uses a [Timer] instance which you can react to when it has
/// finished.
class TimerComponent({
  required double period,
  bool repeat = false,
  bool autoStart = true,
  final bool removeOnFinish = false,
  VoidCallback? onTick,
  final bool tickWhenLoaded = false,
  int? tickCount,
  super.key,
}) extends Component {
  late final Timer timer;

  /// Creates a [TimerComponent]
  ///
  /// [period] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [period] is reached
  /// [autoStart] When true, will start upon instantiation (default is true)
  /// [onTick] When provided, will be called every time [period] is reached.
  /// It can be changed later through [Timer.onTick] on [timer].
  /// [tickWhenLoaded] When true, will call [onTick] when the component is
  /// first loaded (default is false).
  /// [tickCount] The number of time the timer will tick before stopping.
  /// This is is only used when [repeat] is true. If null,
  /// the timer will run indefinitely.
  this {
    timer = Timer(
      period: period,
      repeat: repeat,
      onTick: onTick,
      autoStart: autoStart,
      tickCount: tickCount,
    );
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    await super.onLoad();

    if (tickWhenLoaded) {
      timer.onTick?.call();
    }
  }

  @override
  void update(double dt) {
    timer.update(dt);

    if (removeOnFinish && timer.finished) {
      removeFromParent();
    }
  }
}
