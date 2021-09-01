import 'dart:ui';

import 'effects.dart';

class SequenceEffect extends PositionComponentEffect {
  final List<ComponentEffect> effects;
  late ComponentEffect currentEffect;
  late bool _currentWasAlternating;

  static const int _initialIndex = 0;
  static const double _initialDriftModifier = 0.0;

  int _currentIndex = _initialIndex;
  double _driftModifier = _initialDriftModifier;

  SequenceEffect({
    this.effects = const [],
    bool isInfinite = false,
    bool isAlternating = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          preOffset: preOffset,
          postOffset: postOffset,
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
    final types = effects.map((e) => e.runtimeType);
    assert(
      types.toSet().length == types.length,
      "All effect types have to be different so that they don't clash",
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _currentIndex = _initialIndex;
    _driftModifier = _initialDriftModifier;
    peakTime = preOffset + postOffset;

    for (final effect in effects) {
      effect.removeOnFinish = false;
      if (effect is PositionComponentEffect) {
        affectedParent.position.setFrom(endPosition!);
        affectedParent.angle = endAngle!;
        affectedParent.size.setFrom(endSize!);
        affectedParent.scale.setFrom(endScale!);
        await add(effect);
        endPosition!.setFrom(effect.endPosition!);
        endAngle = effect.endAngle;
        endSize!.setFrom(effect.endSize!);
        endScale!.setFrom(effect.endScale!);
        // Since only the parent effect will reset the affected component we
        // need to check what properties the child effects affect.
        modifiesPosition |= effect.modifiesPosition;
        modifiesAngle |= effect.modifiesAngle;
        modifiesSize |= effect.modifiesSize;
        modifiesScale |= effect.modifiesScale;
      }
      effect.pause();
      // Add the full effects iteration time since they can alternate within the
      // sequence effect
      peakTime += effect.iterationTime;
    }

    // Set the parent to the state that it should have before the effects are
    // executed
    affectedParent.position.setFrom(originalPosition!);
    affectedParent.angle = originalAngle!;
    affectedParent.size.setFrom(originalSize!);
    affectedParent.scale.setFrom(originalScale!);

    if (isAlternating) {
      endPosition = originalPosition;
      endAngle = originalAngle;
      endSize = originalSize;
      endScale = originalScale;
    }

    currentEffect = effects[0];
    currentEffect.resume();
    _currentWasAlternating = currentEffect.isAlternating;
  }

  @override
  void update(double dt) {
    if (isPaused || hasCompleted()) {
      print('Sequence thinks that it is done or paused');
      return;
    }
    super.update(dt);

    _driftModifier = 0.0;
    if (currentEffect.hasCompleted()) {
      _driftModifier = currentEffect.driftTime;
      // Make sure the current effect has the `isAlternating` value it
      // initially started with.
      currentEffect.isAlternating = _currentWasAlternating;
      // Reset the effect if it was initially alternating so that it can repeat
      // when the CombinedEffect alternates.
      if (currentEffect.isAlternating && isAlternating) {
        print('alternation reset sequence');
        currentEffect.resetEffect();
      }
      // Pause the current effect so that the next effect can continue.
      currentEffect.pause();

      _currentIndex++;
      final orderedEffects =
          curveDirection.isNegative ? effects.reversed.toList() : effects;
      // Get the next effect that should be executed.
      currentEffect = orderedEffects[_currentIndex % effects.length];
      // If the last effect's time to completion overshot its total time, add that
      // time to the first time step of the next effect.
      currentEffect.driftTime = _driftModifier;
      // Keep track of what value of `isAlternating` the effect had from the
      // start.
      _currentWasAlternating = currentEffect.isAlternating;
      if (isAlternating &&
          !currentEffect.isAlternating &&
          curveDirection.isNegative) {
        // Make the effect go in reverse.
        currentEffect.isAlternating = true;
        currentEffect.setEndToOriginalState();
      }
      currentEffect.resume();
    }
  }

  @override
  bool hasCompleted() {
    return super.hasCompleted() &&
        effects.every((element) => element.hasCompleted());
  }

  @override
  void reset() {
    super.reset();
    effects.forEach((e) => e.resetEffect());
  }

  @override
  void setEndToOriginalState() {
    // No-op since children handle this.
  }
}
