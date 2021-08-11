import 'dart:math';
import 'dart:ui';

import 'effects.dart';

/// The [CombinedEffect] runs several effects in parallel on a component.
///
/// If an underlying effect has [isAlternating] set to true and the
/// [CombinedEffect] also is set to [isAlternating] then it will run the
/// full underlying effect, forward and reverse, on the forward iteration of the
/// curve of the [CombinedEffect] and then it will run it again on the backward
/// direction of the curve.
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
          modifiesScale: effects.any((e) => e.modifiesScale),
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
        effect.iterationTime,
      );
    });
    effects.forEach((effect) {
      // Since the postOffset will run for "double" the time if the effect is
      // alternating we have to divide it by 2.
      effect.postOffset +=
          (peakTime - effect.iterationTime) / (effect.isAlternating ? 2 : 1);
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
