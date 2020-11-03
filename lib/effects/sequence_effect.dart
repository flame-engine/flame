import 'package:meta/meta.dart';

import '../components/position_component.dart';
import 'effects.dart';

class SequenceEffect extends PositionComponentEffect {
  final List<PositionComponentEffect> effects;
  int _currentIndex;
  PositionComponentEffect currentEffect;
  bool _currentWasAlternating;
  double _driftModifier;

  SequenceEffect({
    @required this.effects,
    bool isInfinite = false,
    bool isAlternating = false,
    void Function() onComplete,
  }) : super(isInfinite, isAlternating, onComplete: onComplete) {
    assert(
      effects.every((effect) => effect.component == null),
      'Each effect can only be added once',
    );
    assert(
      effects.every((effect) => !effect.isInfinite),
      'No effects added to the sequence can be infinite',
    );
  }

  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    _currentIndex = 0;
    _driftModifier = 0.0;

    effects.forEach((effect) {
      effect.reset();
      component.position = endPosition;
      component.angle = endAngle;
      component.size = endSize;
      effect.initialize(component);
      endPosition = effect.endPosition;
      endAngle = effect.endAngle;
      endSize = effect.endSize;
    });
    peakTime = effects.fold(
      0,
      (time, effect) => time + effect.peakTime,
    );
    if (isAlternating) {
      endPosition = originalPosition;
      endAngle = originalAngle;
      endSize = originalSize;
    }
    component.position = originalPosition;
    component.angle = originalAngle;
    component.size = originalSize;
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
    if (currentEffect.hasFinished()) {
      _driftModifier = currentEffect.driftTime;
      _currentIndex++;
      final iterationSize = isAlternating ? effects.length * 2 : effects.length;
      if (_currentIndex != 0 &&
          _currentIndex == iterationSize &&
          (currentEffect.isAlternating ||
              currentEffect.isAlternating == isAlternating)) {
        isInfinite ? reset() : dispose();
        return;
      }
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
    component?.position = originalPosition;
    component?.angle = originalAngle;
    component?.size = originalSize;
    effects.forEach((e) => e.reset());
    initialize(component);
  }
}
