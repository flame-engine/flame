import 'dart:math';

import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

class CombinedEffectController extends EffectController {
  CombinedEffectController(
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
