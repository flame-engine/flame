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
    isInfinite = false,
    isAlternating = false,
    Function onComplete,
  }) : super(isInfinite, isAlternating, onComplete: onComplete) {
    assert(
      effects.every((effect) => effect.component == null),
      "No effects can be added to components from the start",
    );
  }

  @override
  void initialize(PositionComponent _comp) {
    super.initialize(_comp);
    _currentIndex = 0;
    _driftModifier = 0.0;
    effects.forEach((effect) {
      effect.reset();
      _comp.size = endSize;
      _comp.position = endPosition;
      _comp.angle = endAngle;
      effect.initialize(_comp);
      endSize = effect.endSize;
      endPosition = effect.endPosition;
      endAngle = effect.endAngle;
    });
    travelTime = effects.fold(
      0,
      (time, effect) => time + effect.totalTravelTime,
    );
    component.position = originalPosition;
    component.angle = originalAngle;
    component.size = originalSize;
    currentEffect = effects.first;
    _currentWasAlternating = currentEffect.isAlternating;
  }

  @override
  void update(double dt) {
    if (hasFinished()) {
      return;
    }
    super.update(dt);

    // If the last effect's time to completion overshot its total time, add that
    // time to the first time step of the next effect.
    currentEffect.update(dt + _driftModifier);
    _driftModifier = 0.0;
    if (currentEffect.hasFinished()) {
      _driftModifier = currentEffect.driftTime;
      _currentIndex++;
      final iterationSize = isAlternating ? effects.length * 2 : effects.length;
      if (_currentIndex != 0
          && _currentIndex == iterationSize
          && (currentEffect.isAlternating ||
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
    component.position = originalPosition;
    component.angle = originalAngle;
    component.size = originalSize;
    initialize(component);
    //effects.forEach((e) => e.reset());
  }
}
