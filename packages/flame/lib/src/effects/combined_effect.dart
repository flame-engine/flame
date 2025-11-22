import 'package:flame/effects.dart';

/// An effect that runs multiple effects simultaneously.
///
/// The [CombinedEffect] is finished when all the effects are finished.
///
/// If the `alternate` flag is provided, then all effects will run in the
/// reverse after they ran forward.
///
/// Parameter `repeatCount` will make the combination of effects repeat a
/// certain number of times. If `alternate` is also true, then the effects will
/// first run forward, then back, and then repeat this pattern `repeatCount`
/// times in total.
///
/// The flag `infinite = true` makes the combination of effects repeat
/// infinitely. This is equivalent to setting `repeatCount = infinity`. If both
/// the `infinite` and the `repeatCount` parameters are given, then `infinite`
/// takes precedence.
class CombinedEffect extends Effect {
  CombinedEffect(
    List<Effect> effects, {
    bool alternate = false,
    bool infinite = false,
    int repeatCount = 1,
    super.onComplete,
    super.key,
  }) : assert(effects.isNotEmpty, 'The list of effects cannot be empty'),
       assert(
         !(infinite && repeatCount != 1),
         'Parameters infinite and repeatCount cannot be specified '
         'simultaneously',
       ),
       super(
         _createController(
           effects: effects,
           alternate: alternate,
           infinite: infinite,
           repeatCount: repeatCount,
         ),
       ) {
    addAll(effects);
  }

  @override
  void onMount() {
    super.onMount();
    if (children.isEmpty) {
      removeFromParent();
    }
  }

  @override
  void apply(double progress) {}

  @override
  void updateTree(double dt) {
    update(dt);
    // Do not update children: the controller will take care of it
  }
}

EffectController _createController({
  required List<Effect> effects,
  required bool alternate,
  required bool infinite,
  required int repeatCount,
}) {
  final controller = CombinedEffectController(
    effects,
    alternate: alternate,
  );
  for (final effect in effects) {
    effect.removeOnFinish = false;
  }
  if (infinite) {
    return InfiniteEffectController(controller);
  }
  if (repeatCount > 1) {
    return RepeatedEffectController(controller, repeatCount);
  }
  return controller;
}
