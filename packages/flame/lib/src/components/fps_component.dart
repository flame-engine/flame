import 'dart:collection';

import '../../components.dart';

/// The [FPSComponent] is a non-visual component which you can get the current
/// fps of the game with by calling [fps], once the component has been added to
/// the component tree.
class FPSComponent extends Component {
  FPSComponent({
    this.windowSize = 60,
  });

  final int windowSize;
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
