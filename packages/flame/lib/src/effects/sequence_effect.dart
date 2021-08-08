import 'dart:ui';

import 'effects.dart';

class SequenceEffect extends PositionComponentEffect {
  final List<PositionComponentEffect> effects;
  late PositionComponentEffect currentEffect;
  late bool _currentWasAlternating;

  static const int _initialIndex = 0;
  static const double _initialDriftModifier = 0.0;

  int _currentIndex = _initialIndex;
  double _driftModifier = _initialDriftModifier;

  SequenceEffect({
    required this.effects,
    bool isInfinite = false,
    bool isAlternating = false,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          modifiesPosition: effects.any((e) => e.modifiesPosition),
          modifiesAngle: effects.any((e) => e.modifiesAngle),
          modifiesSize: effects.any((e) => e.modifiesSize),
          removeOnFinish: removeOnFinish,
          onComplete: onComplete,
        ) {
    assert(
      effects.every((effect) => effect.parent == null),
      'Each effect can only be added once',
    );
    assert(
      effects.every((effect) => !effect.isInfinite),
      'No effects added to the sequence can be infinite',
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _currentIndex = _initialIndex;
    _driftModifier = _initialDriftModifier;

    effects.forEach((effect) async {
      effect.reset();
      affectedComponent!.position.setFrom(endPosition!);
      affectedComponent!.angle = endAngle!;
      affectedComponent!.size.setFrom(endSize!);
      if (effect.affectedComponent == null) {
        await add(effect);
      } else {
        await effect.onLoad();
      }
      endPosition = effect.endPosition;
      endAngle = effect.endAngle;
      endSize = effect.endSize;
    });
    // Add all the effects iteration time since they can alternate within the
    // sequence effect
    peakTime = effects.fold(
      0,
      (time, effect) => time + effect.iterationTime,
    );
    if (isAlternating) {
      endPosition = originalPosition;
      endAngle = originalAngle;
      endSize = originalSize;
    }
    affectedComponent!.position.setFrom(originalPosition!);
    affectedComponent!.angle = originalAngle!;
    affectedComponent!.size.setFrom(originalSize!);
    currentEffect = effects.first;
    _currentWasAlternating = currentEffect.isAlternating;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If the last effect's time to completion overshot its total time, add that
    // time to the first time step of the next effect.
    currentEffect.update(dt + _driftModifier);
    _driftModifier = 0.0;
    if (currentEffect.hasCompleted()) {
      currentEffect.setComponentToEndState();
      _driftModifier = currentEffect.driftTime;
      _currentIndex++;
      final orderedEffects =
          curveDirection.isNegative ? effects.reversed.toList() : effects;
      // Make sure the current effect has the `isAlternating` value it
      // initially started with
      currentEffect.isAlternating = _currentWasAlternating;
      // Get the next effect that should be executed
      currentEffect = orderedEffects[_currentIndex % effects.length];
      // Keep track of what value of `isAlternating` the effect had from the
      // start
      _currentWasAlternating = currentEffect.isAlternating;
      if (isAlternating &&
          !currentEffect.isAlternating &&
          curveDirection.isNegative) {
        // Make the effect go in reverse
        currentEffect.isAlternating = true;
      }
    }
  }

  @override
  void reset() {
    super.reset();
    effects.forEach((e) => e.reset());
    if (affectedComponent != null) {
      onLoad();
    }
  }
}
