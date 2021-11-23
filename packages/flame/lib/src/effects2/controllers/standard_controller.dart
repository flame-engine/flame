import 'package:flutter/animation.dart';

import 'curved_effect_controller.dart';
import 'delayed_effect_controller.dart';
import 'effect_controller.dart';
import 'infinite_effect_controller.dart';
import 'linear_effect_controller.dart';
import 'pause_effect_controller.dart';
import 'repeated_effect_controller.dart';
import 'reverse_curved_effect_controller.dart';
import 'reverse_linear_effect_controller.dart';
import 'sequence_effect_controller.dart';

/// Factory function for producing common [EffectController]s.
///
/// In the simplest case, [StandardEffectController] will have a positive
/// `duration` and will change its [progress] linearly from 0 to 1 over the
/// period of that duration.
///
/// More generally, a [StandardEffectController] allows to add a delay before
/// the beginning of the animation, to animate both forward and in reverse,
/// to iterate several times (or infinitely), to apply an arbitrary [Curve]
/// making the effect progression non-linear, etc.
///
/// In the most general case, the animation proceeds through the following
/// steps:
///   1. wait for [startDelay] seconds,
///   2. repeat the following steps [repeatCount] times (or infinitely):
///       a. progress from 0 to 1 over the [forwardDuration] seconds,
///       b. wait for [atMaxDuration] seconds,
///       c. progress from 1 to 0 over the [backwardDuration] seconds,
///       d. wait for [atMinDuration] seconds,
///   3. mark the animation as [completed].
///
/// If the animation is finite and there are no `backward` or `atMin` stages
/// then the animation will complete at `progress == 1`, otherwise it will
/// complete at `progress == 0`.
///
/// The animation is "sticky" at the end of the `forward` and `backward` stages.
/// This means that within a single [update()] call the animation may complete
/// these stages but will not move on to the next ones. Thus, you're guaranteed
/// to be able to observe `progress == 1` and `progress == 0` at least once
/// within each iteration cycle.
EffectController standardController({
  required double duration,
  Curve? curve,
  double reverseDuration = 0.0,
  Curve? reverseCurve,
  bool infinite = false,
  int? repeatCount,
  double startDelay = 0.0,
  double atMaxDuration = 0.0,
  double atMinDuration = 0.0,
}) {
  final items = [
    if (curve == null)
      LinearEffectController(duration)
    else
      CurvedEffectController(duration, curve),
    if (atMaxDuration > 0)
      PauseEffectController(duration, level: 1),
    if (reverseDuration > 0 && reverseCurve == null)
      ReverseLinearEffectController(reverseDuration),
    if (reverseDuration > 0 && reverseCurve != null)
      ReverseCurvedEffectController(reverseDuration, reverseCurve),
    if (atMinDuration > 0)
      PauseEffectController( atMinDuration, level: 0),
  ];
  assert(items.isNotEmpty);
  var ec = items.length == 1? items[0] : SequenceEffectController(items);
  if (infinite) {
    assert(repeatCount == null,
      'An infinite animation cannot have a repeat count',
    );
    ec = InfiniteEffectController(ec);
  }
  if (repeatCount != null && repeatCount != 1) {
    assert(repeatCount > 0, 'repeatCount must be positive');
    ec = RepeatedEffectController(ec, repeatCount);
  }
  if (startDelay > 0) {
    ec = DelayedEffectController(ec, delay: startDelay);
  }
  return ec;
}
