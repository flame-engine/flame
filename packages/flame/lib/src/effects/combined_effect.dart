import 'dart:math';
import 'dart:ui';

import '../components/position_component.dart';
import 'effects.dart';

class CombinedEffect extends PositionComponentEffect {
  final List<PositionComponentEffect> effects;
  final double offset;

  CombinedEffect({
    required this.effects,
    this.offset = 0.0,
    bool isInfinite = false,
    bool isAlternating = false,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          modifiesPosition: effects.any((e) => e.modifiesPosition),
          modifiesAngle: effects.any((e) => e.modifiesAngle),
          modifiesSize: effects.any((e) => e.modifiesSize),
          onComplete: onComplete,
        ) {
    assert(
      effects.every((effect) => effect.component == null),
      'Each effect can only be added once',
    );
    final types = effects.map((e) => e.runtimeType);
    assert(
      types.toSet().length == types.length,
      "All effect types have to be different so that they don't clash",
    );
  }

  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    effects.forEach((effect) {
      effect.initialize(component);
      // Only change these if the effect modifies these
      endPosition = effect.originalPosition != effect.endPosition
          ? effect.endPosition
          : endPosition;
      endAngle =
          effect.originalAngle != effect.endAngle ? effect.endAngle : endAngle;
      endSize =
          effect.originalSize != effect.endSize ? effect.endSize : endSize;
      peakTime = max(
        peakTime,
        effect.iterationTime + offset * effects.indexOf(effect),
      );
    });
    if (isAlternating) {
      endPosition = originalPosition;
      endAngle = originalAngle;
      endSize = originalSize;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    effects.forEach((effect) => _updateEffect(effect, dt));
    if (effects.every((effect) => effect.hasCompleted())) {
      if (isAlternating && curveDirection.isNegative) {
        effects.forEach((effect) => effect.isAlternating = true);
      }
    }
  }

  @override
  void reset() {
    super.reset();
    effects.forEach((effect) => effect.reset());
    if (component != null) {
      initialize(component!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    effects.forEach((effect) => effect.dispose());
  }

  void _updateEffect(PositionComponentEffect effect, double dt) {
    final isReverse = curveDirection.isNegative;
    final initialOffset = effects.indexOf(effect) * offset;
    final effectOffset =
        isReverse ? peakTime - effect.peakTime - initialOffset : initialOffset;
    final passedOffset = isReverse ? peakTime - currentTime : currentTime;
    if (!effect.hasCompleted() && effectOffset < passedOffset) {
      final time =
          effectOffset < passedOffset - dt ? dt : passedOffset - effectOffset;
      effect.update(time);
    }
    if (isMax()) {
      _maybeReverse(effect);
    }
  }

  void _maybeReverse(PositionComponentEffect effect) {
    if (isAlternating && !effect.isAlternating && effect.isMax()) {
      // Make the effect go in reverse
      effect.isAlternating = true;
    }
  }
}
