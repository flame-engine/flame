import 'dart:math';

import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/repeated_effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// An effect that runs multiple effects simultaneously.
///
/// The [CombinedEffect] is finished when all the effects are finished.
///
/// If the `alternate` flag is provided, then all effects will run in the
/// reverse after they ran forward.
///
/// Parameter `repeatCount` will make the combination of effects repeat a
/// certain number of times. If `alternate` is also true, then the effects will
/// first run forward, then back, and then repeat this pattern `repeatCount`
/// times in total.
///
/// The flag `infinite = true` makes the combination of effects repeat
/// infinitely. This is equivalent to setting `repeatCount = infinity`. If both
/// the `infinite` and the `repeatCount` parameters are given, then `infinite`
/// takes precedence.
class CombinedEffect extends Effect {
  CombinedEffect(
    List<Effect> effects, {
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
    super.onComplete,
    super.key,
  }) : assert(effects.isNotEmpty, 'The list of effects cannot be empty'),
       assert(
         !(infinite && repeatCount != 1),
         'Parameters infinite and repeatCount cannot be specified '
         'simultaneously',
       ),
       super(
         _createController(
           effects: effects,
           alternate: alternate,
           infinite: infinite,
           repeatCount: repeatCount,
         ),
       ) {
    addAll(effects);
  }

  @override
  void onMount() {
    super.onMount();
    if (children.isEmpty) {
      removeFromParent();
    }
  }

  @override
  void apply(double progress) {}

  @override
  void updateTree(double dt) {
    update(dt);
    // Do not update children: the controller will take care of it
  }
}

EffectController _createController({
  required List<Effect> effects,
  required bool alternate,
  required bool infinite,
  required int repeatCount,
}) {
  final controller = _CombinedEffectController(
    effects,
    alternate: alternate,
  );
  for (final effect in effects) {
    effect.removeOnFinish = false;
  }
  if (infinite) {
    return InfiniteEffectController(controller);
  }
  if (repeatCount > 1) {
    return RepeatedEffectController(controller, repeatCount);
  }
  return controller;
}

class _CombinedEffectController extends EffectController {
  _CombinedEffectController(
    this.effects, {
    required this.alternate,
  }) : _duration = _calculateDuration(effects, alternate),
       super.empty();

  final List<Effect> effects;
  final bool alternate;
  final double _duration;

  double t = 0;

  static double _calculateDuration(List<Effect> effects, bool alternate) {
    var duration = 0.0;
    for (final effect in effects) {
      duration = max(duration, effect.controller.duration ?? 0);
    }
    if (alternate) {
      duration *= 2;
    }
    return duration;
  }

  @override
  double? get duration => _duration;

  @override
  double get progress =>
      alternate ? (_duration - t) / _duration : t / _duration;

  @override
  bool get completed => t >= _duration;

  @override
  double advance(double dt) {
    if (completed) {
      return dt;
    }
    final t0 = t;
    t += dt;

    if (alternate && t > _duration / 2 && t0 <= _duration / 2) {
      // Transition from forward to backward
      final tInForward = _duration / 2 - t0;
      final tInBackward = t - _duration / 2;
      for (final effect in effects) {
        effect.advance(tInForward);
        if (tInBackward > 0) {
          effect.recede(tInBackward);
        }
      }
    } else if (!alternate || t <= _duration / 2) {
      // Forward
      for (final effect in effects) {
        final effectDuration = effect.controller.duration ?? 0;
        if (t0 < effectDuration) {
          final t1 = min(t, effectDuration);
          effect.advance(t1 - t0);
        }
      }
    } else {
      // Backward
      for (final effect in effects) {
        final effectDuration = effect.controller.duration ?? 0;
        final timeInAlt = t0 - _duration / 2;
        if (timeInAlt < effectDuration) {
          final t1 = min(t - _duration / 2, effectDuration);
          effect.recede(t1 - timeInAlt);
        }
      }
    }

    if (t >= _duration) {
      final surplus = t - _duration;
      t = _duration;
      return surplus;
    }
    return 0;
  }

  @override
  double recede(double dt) {
    if (t <= 0) {
      return dt;
    }
    final t0 = t;
    t -= dt;

    if (alternate && t < _duration / 2 && t0 >= _duration / 2) {
      final tInBackward = t0 - _duration / 2;
      final tInForward = _duration / 2 - t;
      for (final effect in effects) {
        if (tInBackward > 0) {
          effect.recede(tInBackward);
        }
        effect.advance(tInForward);
      }
    } else if (!alternate || t >= _duration / 2) {
      // Backward
      for (final effect in effects) {
        final effectDuration = effect.controller.duration ?? 0;
        final timeInAlt = t0 - _duration / 2;
        if (timeInAlt < effectDuration) {
          final t1 = max(t - _duration / 2, 0.0);
          effect.recede(timeInAlt - t1);
        }
      }
    } else {
      // Forward
      for (final effect in effects) {
        final effectDuration = effect.controller.duration ?? 0;
        if (t0 < effectDuration) {
          final t1 = max(t, 0.0);
          effect.recede(t0 - t1);
        }
      }
    }

    if (t <= 0) {
      final surplus = -t;
      t = 0;
      return surplus;
    }
    return 0;
  }

  @override
  void setToEnd() {
    t = _duration;
    for (final effect in effects) {
      effect.resetToEnd();
    }
  }

  @override
  void setToStart() {
    t = 0;
    for (final effect in effects) {
      effect.reset();
    }
  }
}
