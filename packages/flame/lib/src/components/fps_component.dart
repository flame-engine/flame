import 'dart:collection';

import 'package:flame/components.dart';

/// The [FpsComponent] is a non-visual component which you can get the current
/// fps of the game with by calling [fps], once the component has been added to
/// the component tree.
class FpsComponent extends Component {
  FpsComponent({
    this.windowSize = 60,
  });

  /// The sliding window size, i.e. the number of game ticks over which the fps
  /// measure will be averaged.
  final int windowSize;

  /// The queue of the recent game tick durations.
  /// The length of this queue will not exceed [windowSize].
  final Queue<double> window = Queue();

  /// The sum of all values in the [window] queue.
  double _sum = 0;

  @override
  void update(double dt) {
    window.addLast(dt);
    _sum += dt;
    if (window.length > windowSize) {
      _sum -= window.removeFirst();
    }
  }

  /// Get the current average FPS over the last [windowSize] frames.
  double get fps {
    return window.isEmpty ? 0 : window.length / _sum;
  }
}
