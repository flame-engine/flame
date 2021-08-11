import 'dart:math';
import 'dart:ui';

import 'effects.dart';

class CombinedEffect extends PositionComponentEffect {
  final List<PositionComponentEffect> effects;
  final double offset;

  CombinedEffect({
    required this.effects,
    this.offset = 0.0,
    bool isInfinite = false,
    bool isAlternating = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          removeOnFinish: removeOnFinish,
          modifiesPosition: effects.any((e) => e.modifiesPosition),
          modifiesAngle: effects.any((e) => e.modifiesAngle),
          modifiesSize: effects.any((e) => e.modifiesSize),
          preOffset: preOffset,
          postOffset: postOffset,
          onComplete: onComplete,
        ) {
    assert(
      effects.every((effect) => effect.parent == null),
      'Each effect can only be added once',
    );
    final types = effects.map((e) => e.runtimeType);
    assert(
      types.toSet().length == types.length,
      "All effect types have to be different so that they don't clash",
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    effects.forEach((effect) async {
      final indexOffset = effects.indexOf(effect) * offset;
      effect.preOffset += preOffset + indexOffset;
      await add(effect);
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
        // TODO(spydon): Should this really be iteration time?
        effect.iterationTime,
      );
    });
    effects.forEach((effect) {
      effect.postOffset = peakTime - effect.peakTime;
    });
    if (isAlternating) {
      endPosition = originalPosition;
      endAngle = originalAngle;
      endSize = originalSize;
    }
  }

  @override
  void reset() {
    super.reset();
    effects.forEach((effect) => effect.reset());
    if (affectedParent != null) {
      onLoad();
    }
  }

  @override
  void onRemove() {
    super.onRemove();
  }
}
