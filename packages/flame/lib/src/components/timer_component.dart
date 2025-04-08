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
  final bool tickWhenLoaded;
  final int? tickCount;
  int _currentTick = 0;

  /// Creates a [TimerComponent]
  ///
  /// [period] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [period] is reached
  /// [autoStart] When true, will start upon instantiation (default is true)
  /// [onTick] When provided, will be called every time [period] is reached.
  /// This overrides the [onTick] method
  /// [tickWhenLoaded] When true, will call [onTick] when the component is first
  /// loaded (default is false).
  /// [tickCount] The number of time the timer will tick before stopping.
  /// This is is only used when [repeat] is true. If null,
  /// the timer will run indefinitely.
  TimerComponent({
    required double period,
    bool repeat = false,
    bool autoStart = true,
    this.removeOnFinish = false,
    VoidCallback? onTick,
    this.tickWhenLoaded = false,
    this.tickCount,
    super.key,
  })  : assert(
          tickCount == null || tickCount > 0,
          'tickCount must be null or bigger than 0',
        ),
        _onTick = onTick {
    timer = Timer(
      period,
      repeat: repeat,
      onTick: this.onTick,
      autoStart: autoStart,
    );
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    await super.onLoad();

    if (tickWhenLoaded) {
      onTick();
    }
  }

  /// Called every time the [timer] reached a tick.
  /// The default implementation calls the closure received on the
  /// constructor and can be overridden to add custom logic.
  void onTick() {
    _currentTick = _currentTick + 1;
    _onTick?.call();

    if (tickCount != null && _currentTick >= tickCount!) {
      timer.stop();
      if (removeOnFinish) {
        removeFromParent();
      }
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
