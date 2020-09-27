import 'dart:ui';

import './component.dart';
import '../time.dart';

/// Simple component which wraps a [Timer] instance allowing it to be easily used inside a [BaseGame] game.
class TimerComponent extends Component {
  Timer timer;

  TimerComponent(this.timer);

  @override
  void update(double dt) => timer.update(dt);

  @override
  void render(Canvas canvas) {}

  @override
  bool destroy() => timer.isFinished();
}
