import 'package:flame/components.dart';

/// Where Flame draws a component, as the bridge writes it into the scene: a
/// point, a turn and a scale whose signs say which way it is mirrored.
///
/// **Flame's own absolute angle is not this turn.** `absoluteAngle` is
/// reflected for a flipped component, the angle it appears at on screen,
/// and written with the signed absolute scale beside it the mirror was
/// applied twice: a flipped ship nested under anything turned the opposite
/// way to the same ship at the top of the tree. Here the chain is folded
/// the way Flame's matrices compose it, a parent's mirror reversing the
/// turns under it, so a component and its pose agree whatever it hangs
/// from. A scale that differs between the axes under a turned parent
/// shears in Flame, and a node cannot; it keeps the axes' scales and loses
/// the shear.
///
/// Mutable, and read into, because it is read for every bridged component
/// every frame.
final class FlamePose {
  double x = 0.0;
  double y = 0.0;
  double turn = 0.0;
  double scaleX = 1.0;
  double scaleY = 1.0;

  /// Reads [component]'s pose. One with no positioned ancestor is read from
  /// its own fields, which cost nothing; Flame's absolute ones are made
  /// afresh on every read.
  void readFrom(PositionComponent component) {
    if (!hasPlacedAncestor(component)) {
      x = component.position.x;
      y = component.position.y;
      turn = component.angle;
      scaleX = component.scale.x;
      scaleY = component.scale.y;
      return;
    }
    final at = component.absolutePosition;
    x = at.x;
    y = at.y;
    readTurnOf(component);
  }

  /// Reads only [turn] and the scales of [component] and everything above
  /// it: the frame a child's own angle and scale are in, one level down.
  void readTurnOf(Component component) {
    turn = 0.0;
    scaleX = 1.0;
    scaleY = 1.0;
    _fold(component);
  }

  /// Whether what is drawn under this pose is mirrored, and so has its
  /// turns reversed.
  bool get mirrored => (scaleX < 0.0) != (scaleY < 0.0);

  void _fold(Component? at) {
    if (at == null) {
      return;
    }
    _fold(at.parent);
    if (at is! PositionComponent) {
      return;
    }
    turn += mirrored ? -at.angle : at.angle;
    scaleX *= at.scale.x;
    scaleY *= at.scale.y;
  }
}

/// Whether anything above [component] is positioned: then where it is
/// drawn is not its own [PositionComponent.position]. Asked of the whole
/// chain, as Flame's `absolutePositionOf` walks it, not of the parent
/// alone: a plain `Component` between a frog and its log hid the log.
bool hasPlacedAncestor(Component component) {
  for (var at = component.parent; at != null; at = at.parent) {
    if (at is PositionComponent) {
      return true;
    }
  }
  return false;
}

/// The nearest positioned component above [component], whose space its
/// [PositionComponent.position] is in; null when there is none.
PositionComponent? placedAncestor(Component component) {
  for (var at = component.parent; at != null; at = at.parent) {
    if (at is PositionComponent) {
      return at;
    }
  }
  return null;
}
