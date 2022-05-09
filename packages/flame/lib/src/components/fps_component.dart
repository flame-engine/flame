import 'dart:collection';

import '../../components.dart';

/// The [FPSComponent] is a non-visual component which you can get the current
/// fps of the game with by calling [fps], once the component has been added to
/// the component tree.
class FPSComponent extends Component {
  FPSComponent({
    this.windowSize = 60,
  });

  /// The number of game ticks over which the fps measure will be averaged.
  final int windowSize;
  /// The queue of the recent game tick durations. The length of this queue will not exceed [windowSize].
  final Queue<double> _window = Queue();
  /// The sum of all values in the [_window] queue.
  double _sum = 0;

  @override
  void update(double dt) {
    _window.addLast(dt);
    _sum += dt;
    if (_window.length > windowSize) {
      _sum -= _window.removeFirst();
    }
  }

  /// Get the current average FPS over the last [windowSize] frames.
  double get fps {
    return _window.isEmpty ? 0 : _window.length / _sum;
  }
}
