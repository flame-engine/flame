import 'dart:math';
import 'dart:ui';

import '../../components.dart';
import 'effects.dart';

/// The [CombinedEffect] is just a container for multiple effects, all settings
/// are handled on each individual effect. [CombinedEffect] is not an effect
/// itself.
class CombinedEffect extends ComponentEffect with EffectsHelper {
  /// A [CombinedEffect] is infinite if any of its children has [isInfinite] set
  /// to true.
  @override
  bool get isInfinite => effects.any((effect) => effect.isInfinite);

  /// A [CombinedEffect] can't alternate, but it can have alternating children.
  @override
  final bool isAlternating = false;

  @override
  final double preOffset = 0.0;

  @override
  final double postOffset = 0.0;

  CombinedEffect({
    List<ComponentEffect> effects = const [],
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          false,
          false,
          removeOnFinish: removeOnFinish,
          onComplete: onComplete,
        ) {
    effects.forEach(add);
  }

  @override
  Future<void> add(Component component) async {
    await super.add(component);
    if (component is ComponentEffect && component.isPrepared) {
      final effect = component;
      final effects = children.query<ComponentEffect>();
      final types = effects.map((e) => e.runtimeType);
      assert(
        !types.contains(effect.runtimeType),
        "All effect types have to be different so that they don't clash",
      );
      peakTime = max(peakTime, effect.iterationTime);
    }
  }

  @override
  void update(double dt) {
    if (isPaused) {
      return;
    }
    super.update(dt);
  }

  @override
  void setComponentToEndState() {
    effects.forEach((effect) => effect.setComponentToEndState());
  }

  @override
  void setComponentToOriginalState() {
    effects.forEach((effect) => effect.setComponentToOriginalState());
  }

  @override
  void setEndToOriginalState() {
    // No-op, since children handle this
  }
}
