import '../../components.dart';

/// Simple component which wraps a [Timer] instance allowing it to be easily
/// used inside a FlameGame game.
class TimerComponent extends Component {
  late final Timer timer;
  final bool removeOnFinish;

  TimerComponent({
    required double limit,
    bool repeat = false,
    bool autoStart = false,
    this.removeOnFinish = false,
  }) {
    timer = Timer(limit, repeat: repeat, callback: tick);

    if (autoStart) {
      timer.start();
    }
  }

  /// Called everytime the [timer] reached a tick
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
