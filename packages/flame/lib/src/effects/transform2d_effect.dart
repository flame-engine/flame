import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/component_effect.dart';
import 'package:flame/src/game/transform2d.dart';

/// Base class for effects that target a [Transform2D] property.
///
/// Examples of effects of this kind include move effects, rotate effects,
/// shake effects, scale effects, etc. In order to apply such an effect to a
/// component simply add the effect as a child to that component.
///
/// Currently this class only supports being attached to [PositionComponent]s,
/// but in the future it will be extended to work with any [Transform2D]-based
/// classes.
abstract class Transform2DEffect extends ComponentEffect<PositionComponent> {
  Transform2DEffect(
    super.controller, {
    super.onComplete,
  });

  late Transform2D transform;

  @override
  void onMount() {
    super.onMount();
    transform = target.transform;
  }
}
