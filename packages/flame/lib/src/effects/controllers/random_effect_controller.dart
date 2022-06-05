import 'dart:math';

import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/effect.dart';

/// An [EffectController] that wraps another effect controller [child] and
/// randomizes its duration after each reset.
///
/// This effect controller works best in contexts were it has a chance to be
/// executed multiple times, such as within a `RepeatedEffectController`, or
/// `InfiniteEffectController`, etc.
///
/// The child's duration is randomized first at construction, and then at each
/// reset (`setToStart`). Thus, the child has a concrete well-defined duration
/// at any point in time.
class RandomEffectController extends EffectController {
  RandomEffectController(this.child, this.randomGenerator)
      : assert(!child.isInfinite, 'Child cannot be infinite'),
        super.empty() {
    _initializeDuration();
  }

  /// Factory constructor that uses a random variable uniformly distributed on
  /// `[min, max)`.
  factory RandomEffectController.uniform(
    DurationEffectController child, {
    required double min,
    required double max,
    Random? random,
  }) {
    assert(min >= 0, 'Min value cannot be negative: $min');
    assert(min < max, 'Max value must exceed min: max=$max, min=$min');
    return RandomEffectController(
      child,
      _UniformRandomVariable(min, max, random),
    );
  }

  /// Factory constructor that employs a random variable distributed
  /// exponentially with rate parameter `beta`. The produced random values will
  /// have the average duration of `beta`.
  factory RandomEffectController.exponential(
    DurationEffectController child, {
    required double beta,
    Random? random,
  }) {
    assert(beta > 0, 'Beta must be positive: $beta');
    return RandomEffectController(
      child,
      _ExponentialRandomVariable(beta, random),
    );
  }

  final DurationEffectController child;
  final RandomVariable randomGenerator;

  @override
  bool get isRandom => true;

  @override
  bool get completed => child.completed;

  @override
  double? get duration => child.duration;

  @override
  double get progress => child.progress;

  @override
  double advance(double dt) => child.advance(dt);

  @override
  double recede(double dt) => child.recede(dt);

  @override
  void setToEnd() => child.setToEnd();

  @override
  void setToStart() {
    child.setToStart();
    _initializeDuration();
  }

  @override
  void onMount(Effect parent) => child.onMount(parent);

  void _initializeDuration() {
    final duration = randomGenerator.nextValue();
    assert(
      duration >= 0,
      'Random generator produced a negative value: $duration',
    );
    child.duration = duration;
  }
}

/// [RandomVariable] is an object capable of producing random values with the
/// prescribed distribution function. Each distribution is implemented within
/// its own derived class.
abstract class RandomVariable {
  RandomVariable(Random? random) : _random = random ?? _defaultRandom;

  /// Internal random number generator.
  final Random _random;
  static final Random _defaultRandom = Random();

  /// Produces the next value for this random variable.
  double nextValue();
}

/// Random variable distributed uniformly between [min] and [max].
class _UniformRandomVariable extends RandomVariable {
  _UniformRandomVariable(this.min, this.max, Random? random) : super(random);

  final double min;
  final double max;

  @override
  double nextValue() => _random.nextDouble() * (max - min) + min;
}

/// Exponentially distributed random variable with rate parameter [beta].
class _ExponentialRandomVariable extends RandomVariable {
  _ExponentialRandomVariable(this.beta, Random? random) : super(random);

  /// Rate parameter of the exponential distribution. This will be the average
  /// of all returned values
  final double beta;

  @override
  double nextValue() => -log(1 - _random.nextDouble()) * beta;
}
