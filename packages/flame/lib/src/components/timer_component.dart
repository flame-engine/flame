import 'dart:ui';

import '../../components.dart';

/// A component that uses a [Timer] instance which you can react to when it has finished.
class TimerComponent extends Component {
  late final Timer timer;
  final bool removeOnFinish;

  /// Creates a [TimerComponent]
  ///
  /// [period] The period of time in seconds that the tick will be called
  /// [repeat] When true, this will continue running after [period] is reached
  /// [autoStart] When true, will start upon instantiation
  /// [onStep] When provided, will be called everytime [period] is reached. This
  /// overrides the [onStep] method
  TimerComponent({
    required double period,
    bool repeat = false,
    bool autoStart = true,
    this.removeOnFinish = false,
    VoidCallback? onStep,
  }) {
    timer = Timer(
      period,
      repeat: repeat,
      onStep: onStep ?? onStep,
    );

    if (autoStart) {
      timer.start();
    }
  }

  /// Called everytime the [timer] reached a tick and
  /// no onStep is provided on the component instantiation
  /// default implementaiton is a no-op, override this
  /// to add custom logic.
  void onStep() {}

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

    if (removeOnFinish && timer.finished) {
      removeFromParent();
    }
  }
}
