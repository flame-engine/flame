import 'dart:ui';

import '../../components.dart';

/// Simple component which wraps a [Timer] instance allowing it to be easily
/// used inside a FlameGame game.
class TimerComponent extends Component {
  late final Timer timer;
  final bool removeOnFinish;

  /// Creates a [TimerComponent]
  ///
  /// [limit] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [limit] is reached
  /// [autoStart] When true, will start upon instantiation
  /// [callback] When provided, will be called everytime [limit] is reached. This
  /// overrides the [tick] method
  TimerComponent({
    required double limit,
    bool repeat = false,
    bool autoStart = false,
    this.removeOnFinish = false,
    VoidCallback? callback,
  }) {
    timer = Timer(
      limit,
      repeat: repeat,
      callback: callback ?? tick,
    );

    if (autoStart) {
      timer.start();
    }
  }

  /// Called everytime the [timer] reached a tick and
  /// no callback is provided on the component instantiation
  /// default implementaiton is a no-op, override this
  /// to add custom logic.
  void tick() {}

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

    if (removeOnFinish && timer.finished) {
      removeFromParent();
    }
  }
}
