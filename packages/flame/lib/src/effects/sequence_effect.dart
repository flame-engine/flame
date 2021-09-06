import 'dart:ui';

import 'effects.dart';

class SequenceEffect extends PositionComponentEffect {
  final List<ComponentEffect> effects;
  late ComponentEffect currentEffect;

  static const int _initialIndex = 0;
  static const double _initialDriftModifier = 0.0;

  int _currentIndex = _initialIndex;
  double _driftModifier = _initialDriftModifier;

  SequenceEffect({
    this.effects = const [],
    bool isInfinite = false,
    bool isAlternating = false,
    double? initialDelay,
    double? peakDelay,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          duration: 0.0,
          initialDelay: initialDelay,
          peakDelay: peakDelay,
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
    peakTime = initialDelay + peakDelay;

    for (final effect in effects) {
      effect.removeOnFinish = false;
      if (effect is PositionComponentEffect) {
        // We set the affected parent to the current peak position on the
        // sequence effect so that it can continue from where the last effect
        // ended.
        affectedParent.position.setFrom(peakPosition!);
        affectedParent.angle = peakAngle!;
        affectedParent.size.setFrom(peakSize!);
        affectedParent.scale.setFrom(peakScale!);
        await add(effect);
        peakPosition!.setFrom(effect.endPosition!);
        peakAngle = effect.endAngle;
        peakSize!.setFrom(effect.endSize!);
        peakScale!.setFrom(effect.endScale!);
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

    currentEffect = effects[0];
    currentEffect.resume();
  }

  @override
  void update(double dt) {
    if (isPaused || hasCompleted()) {
      return;
    }
    super.update(dt);

    _driftModifier = 0.0;
    if (currentEffect.hasCompleted()) {
      _driftModifier = currentEffect.driftTime;
      // Reset the effect if it was alternating so that it can repeat when the
      // SequenceEffect alternates.
      if (currentEffect.isAlternating && isAlternating) {
        currentEffect.resetEffect();
      }
      // Pause the current effect so that the next effect can continue.
      currentEffect.pause();

      _currentIndex++;
      // Whether the effects should start to go in reverse in this time step.
      final shouldReverse =
          isAlternating && (curveDirection.isNegative || isMax());
      final orderedEffects =
          shouldReverse ? effects.reversed.toList() : effects;
      // Get the next effect that should be executed.
      currentEffect = orderedEffects[_currentIndex % effects.length];
      // If the last effect's time to completion overshot its total time, add that
      // time to the first time step of the next effect.
      currentEffect.driftTime = _driftModifier;
      if (shouldReverse && !currentEffect.isAlternating) {
        // Make the current upcoming effect go in reverse.
        currentEffect.isAlternating = true;
      }
      currentEffect.resume();
    }
  }

  @override
  void reset() {
    super.reset();
    effects.forEach((e) => e.resetEffect());
  }
}
