import 'dart:ui';

import '../timer.dart';
import 'component.dart';

/// Simple component which wraps a [Timer] instance allowing it to be easily used inside a [BaseGame] game.
class TimerComponent extends Component {
  Timer timer;

  TimerComponent(this.timer);

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }

  @override
  void render(Canvas canvas) {}

  @override
  bool shouldRemove() => timer.finished;
}
