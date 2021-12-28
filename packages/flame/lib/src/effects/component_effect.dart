import 'package:flutter/cupertino.dart';

import '../../components.dart';
import 'controllers/effect_controller.dart';
import 'effect.dart';

/// Base class for effects that target a [Component] of type [T].
///
/// A general abstraction for creating effects targeting [Component]s, currently
/// used by `SizeEffect`, `OpacityEffect` and `Transform2DEffect`.
abstract class ComponentEffect<T extends Component> extends Effect {
  ComponentEffect(EffectController controller) : super(controller);

  late T target;

  /// The effect's `progress` variable as it was the last time that the
  /// `apply()` method was called. Mostly used by the derived classes.
  double get previousProgress => _lastProgress;
  double _lastProgress = 0;

  @override
  void onMount() {
    super.onMount();
    assert(parent != null);
    var p = parent;
    while (p is Effect) {
      p = p.parent;
    }
    if (p is T) {
      target = p;
    } else {
      throw UnsupportedError('Can only apply this effect to $T');
    }
  }

  // In the derived class, call `super.apply()` last.
  @mustCallSuper
  @override
  void apply(double progress) {
    _lastProgress = progress;
  }

  @override
  void reset() {
    super.reset();
    _lastProgress = 0;
  }

  @override
  void resetToEnd() {
    super.resetToEnd();
    _lastProgress = 1;
  }
}
