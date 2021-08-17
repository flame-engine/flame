import 'dart:math';
import 'dart:ui';

import '../../components.dart';
import 'effects.dart';

/// The [CombinedEffect] runs several effects in parallel on a component.
///
/// If an underlying effect has [isAlternating] set to true and the
/// [CombinedEffect] also is set to [isAlternating] then it will run the
/// full underlying effect, forward and reverse, on the forward iteration of the
/// curve of the [CombinedEffect] and then it will run it again on the backward
/// direction of the curve.
class CombinedEffect extends PositionComponentEffect {
  final double offset;
  List<PositionComponentEffect> get effects {
    return children.query<PositionComponentEffect>();
  }

  CombinedEffect({
    required List<PositionComponentEffect> effects,
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
    children.register<PositionComponentEffect>();
    effects.forEach(add);
  }

  @override
  Future<void> add(Component component) async {
    await super.add(component);
    if (component is PositionComponentEffect && component.isPrepared) {
      final effects = children.query<PositionComponentEffect>()..add(component);
      final types = effects.map((e) => e.runtimeType);
      assert(
        types.toSet().length == types.length,
        "All effect types have to be different so that they don't clash",
      );
      modifiesPosition = modifiesPosition || component.modifiesPosition;
      modifiesAngle = modifiesAngle || component.modifiesAngle;
      modifiesScale = modifiesScale || component.modifiesScale;
      modifiesSize = modifiesSize || component.modifiesSize;
      final indexOffset = effects.indexOf(component) * offset;
      component.preOffset += preOffset + indexOffset;
      if (component.isPrepared) {
        final iterationTime = component.iterationTime;
        peakTime = max(iterationTime, peakTime);
        print(
          'peakTime is now $peakTime and iteration time ${this.iterationTime}',
        );
        if (!component.isAlternating) {
          component.postOffset += peakTime - iterationTime;
          print('Setting offset $component.postOffset');
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isAlternating && isMax()) {
      print('is alternating');
      for (final effect in effects) {
        if (!effect.isAlternating) {
          effect.isAlternating = true;
        } else if (!hasCompleted()) {
          effect.reset();
        }
      }
    }
  }

  /// No-op, since the child effects handle their own end state
  @override
  void setComponentToEndState() {}

  @override
  void reset() {
    super.reset();
    effects.forEach((effect) => effect.reset());
    if (affectedParent != null) {
      onLoad();
    }
  }
}
