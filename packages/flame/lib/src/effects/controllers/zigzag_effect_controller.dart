import 'duration_effect_controller.dart';
import 'infinite_effect_controller.dart';
import 'repeated_effect_controller.dart';

/// This effect controller goes from 0 to 1, then back to 0, then to -1, and
/// then again to 0.
///
/// This is similar to an alternating controller, except that it treats the
/// starting position as the "middle ground", and oscillates around it.
///
/// Combine with [RepeatedEffectController] or [InfiniteEffectController] in
/// order to create longer zigzags.
class ZigzagEffectController extends DurationEffectController {
  ZigzagEffectController({required double period})
      : assert(period > 0, 'Period must be positive: $period'),
        _quarterPeriod = period / 4,
        super(period);

  final double _quarterPeriod;

  @override
  double get progress {
    // Assume zigzag's period is 4 units of length. Within that period, there
    // are 3 linear segments: at first it's y = x, for 0 ≤ x ≤ 1, then it's
    // y = -x + 2, for 1 ≤ x ≤ 3, and finally it's y = x + (-4), for 3 ≤ x ≤ 4.
    final x = timer / _quarterPeriod;
    return x <= 1
        ? x
        : x >= 3
            ? x - 4
            : 2 - x;
  }
}
