import 'package:flame/components.dart' show Component;
import 'package:flame/effects.dart' show ComponentEffect;
import 'package:flame_flutter3d/src/transform/bridge_space.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:vector_math/vector_math.dart' show Aabb3, Vector4;

/// What a bridged component is to the parts of the bridge that find it or
/// draw round it: a tap, a debug outline of its hitboxes. Both
/// `Object3dComponent` and `InstancedObject3dComponent` are one.
///
/// **An instance is a bridged component too.** Taps and hitbox outlines
/// asked for an `Object3dComponent`, and an invader drawn as one instance of
/// fifty-five could neither be tapped nor have its hitbox seen.
abstract interface class Bridged3d implements Drawn3d {
  /// The plane its Flame point is on.
  BridgePlane get plane;

  /// Metres off [plane] along its normal.
  double get elevation;

  /// Where its Flame point is placed instead of flat on [plane], if bent.
  BridgeSpace? get space;

  /// The linear colour what it draws is multiplied by: what a
  /// [TintEffect] moves.
  @override
  Vector4 get tint;
}

/// What a tap asks of anything drawn in the scene: where it is drawn, and
/// its colour. Every [Bridged3d] is one, and so is a `Node3dComponent`,
/// which stands in full 3D rather than on a plane.
abstract interface class Drawn3d {
  /// The box in the scene round what it draws, or null when it draws
  /// nothing: what a tap is tested against.
  Aabb3? get drawnBounds3d;

  /// The linear colour what it draws is multiplied by.
  Vector4 get tint;
}

/// Moves a bridged component's [Bridged3d.tint] to a colour, as Flame's
/// `ColorEffect` moves a sprite's paint: a hit flash, a wreck charring.
///
/// **Flame's own `ColorEffect` cannot reach it.** That effect wants a
/// component with a paint, and a bridged component draws in 3D, with none;
/// a hit flash was a timer and two assignments in the game. This moves the
/// tint from wherever it is when the effect starts to `colour`, on any
/// `EffectController`: alternating for a flash, one way for a fade.
class TintEffect extends ComponentEffect<Component> {
  TintEffect(Vector4 colour, super.controller, {super.onComplete, super.key})
    : _to = colour.clone();

  final Vector4 _to;
  final Vector4 _from = Vector4.zero();

  Vector4 get _tint => switch (target) {
    final Drawn3d drawn => drawn.tint,
    _ => throw UnsupportedError('A TintEffect is for a bridged component.'),
  };

  @override
  void onStart() {
    super.onStart();
    _from.setFrom(_tint);
  }

  @override
  void apply(double progress) => Vector4.mix(_from, _to, progress, _tint);
}
