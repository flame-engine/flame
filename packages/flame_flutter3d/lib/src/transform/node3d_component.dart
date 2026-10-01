import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_flutter3d/src/transform/bridged3d.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart'
    show shownInFlame;
import 'package:flutter3d/flutter3d.dart' hide Material;

/// A Flame component that stands in full 3D: a place in the scene, a turn
/// about any axis and a scale on each, with no plane under it. A starfighter
/// in Star Raiders, a tank on the plain of Battlezone seen from its turret, a
/// ship of Solaris.
///
/// **Flame's tree, the scene's space.** Everything else in this bridge is a
/// Flame `PositionComponent` on a plane, two numbers made three. A game that
/// flies needs all three and a turn about any axis, and Flame has no such
/// component; this is one, kept a Flame component so the game's logic, its
/// timers, its collision of its own and its effects are Flame's.
/// [position3], [rotation3] and [scale3] are written into [node] when they
/// change, and only then.
///
/// **Nested as the scene nests.** Under another [Node3dComponent], [node]
/// hangs under the parent's node, so a turret turns with its tank and a
/// cockpit's camera, added to a ship's [node], flies with it. Anywhere
/// else, it is added to [scene]'s root.
///
/// **Moved by Flame's effects.** [Move3dEffect], [Rotate3dEffect] and
/// [Scale3dEffect] take any `EffectController`: eased, repeated,
/// alternating, in sequence. [TintEffect] and `OpacityEffect` colour and
/// fade it, and `Tap3dCallbacks` hear a tap on it.
class Node3dComponent extends Component
    with CustomTraversal, HasVisibility
    implements OpacityProvider, Drawn3d {
  Node3dComponent({
    required this.node,
    required this.scene,
    Vector3? position,
    Quaternion? rotation,
    Vector3? scale,
    super.children,
    super.priority,
    super.key,
  }) : position3 = position?.clone() ?? Vector3.zero(),
       rotation3 = rotation?.clone() ?? Quaternion.identity(),
       scale3 = scale?.clone() ?? Vector3.all(1.0);

  /// What is drawn.
  final SceneNode node;

  /// The scene [node] is added to when it has no 3D parent.
  final Scene scene;

  /// Where it is, in its parent's space: the parent's node's, or the
  /// scene's.
  final Vector3 position3;

  /// How it is turned, in its parent's space.
  final Quaternion rotation3;

  /// How it is scaled, along each of its own axes.
  final Vector3 scale3;

  @override
  double opacity = 1.0;

  @override
  final Vector4 tint = Vector4.all(1.0);

  final Vector3 _writtenPosition = Vector3.all(double.nan);
  final Quaternion _writtenRotation = Quaternion(
    double.nan,
    double.nan,
    double.nan,
    double.nan,
  );
  final Vector3 _writtenScale = Vector3.all(double.nan);
  bool? _visibleWritten;
  bool _tintWritten = false;

  @override
  Aabb3? get drawnBounds3d => node.subtreeBounds;

  @override
  void onMount() {
    super.onMount();
    final above = _parentNode();
    if (above != null) {
      above.add(node);
    } else if (node.parent == null) {
      scene.add(node);
    }
    _visibleWritten = null;
    _write();
  }

  SceneNode? _parentNode() {
    for (var at = parent; at != null; at = at.parent) {
      if (at is Node3dComponent) {
        return at.node;
      }
    }
    return null;
  }

  @override
  void onRemove() {
    node.removeFromParent();
    super.onRemove();
  }

  /// After the effects under it have moved it this frame.
  @override
  void updateSubtree(double dt) {
    super.updateSubtree(dt);
    _write();
  }

  void _write() {
    if (position3 != _writtenPosition) {
      _writtenPosition.setFrom(position3);
      node.setPositionFrom(position3);
    }
    final r = rotation3;
    final w = _writtenRotation;
    if (r.x != w.x || r.y != w.y || r.z != w.z || r.w != w.w) {
      w.setFrom(r);
      node.setRotation(r);
    }
    if (scale3 != _writtenScale) {
      _writtenScale.setFrom(scale3);
      node.setScale(scale3.x, scale3.y, scale3.z);
    }
    final shown = shownInFlame(this);
    if (_visibleWritten != shown) {
      node.visible = shown;
      _visibleWritten = shown;
    }
    final alpha = tint.w * opacity;
    final plain =
        tint.x == 1.0 && tint.y == 1.0 && tint.z == 1.0 && alpha == 1.0;
    if (plain && !_tintWritten) {
      return;
    }
    _tintWritten = !plain;
    _paint(node, alpha);
  }

  /// Its own meshes; a [Node3dComponent] under it paints its own.
  void _paint(SceneNode at, double alpha) {
    if (at is MeshNode) {
      at.tint.setValues(tint.x, tint.y, tint.z, alpha);
    }
    for (final child in at.children) {
      if (_isOwnNode(child)) {
        continue;
      }
      _paint(child, alpha);
    }
  }

  bool _isOwnNode(SceneNode child) => children.whereType<Node3dComponent>().any(
    (c) => identical(c.node, child),
  );
}

/// Moves a [Node3dComponent] by an offset in its parent's space, or to a
/// place, on any `EffectController`: Flame's `MoveEffect`, in three
/// dimensions.
class Move3dEffect extends ComponentEffect<Node3dComponent> {
  /// Moves it by [offset].
  Move3dEffect.by(
    Vector3 offset,
    super.controller, {
    super.onComplete,
    super.key,
  }) : _offset = offset.clone(),
       _to = null;

  /// Moves it to [destination], from wherever it is when the effect starts.
  Move3dEffect.to(
    Vector3 destination,
    super.controller, {
    super.onComplete,
    super.key,
  }) : _offset = Vector3.zero(),
       _to = destination.clone();

  final Vector3 _offset;
  final Vector3? _to;

  @override
  void onStart() {
    super.onStart();
    final to = _to;
    if (to != null) {
      _offset.setFrom(to - target.position3);
    }
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position3.addScaled(_offset, dProgress);
  }
}

/// Turns a [Node3dComponent] by [angle] radians about [axis], in its own
/// frame, on any `EffectController`: Flame's `RotateEffect`, about any
/// axis.
class Rotate3dEffect extends ComponentEffect<Node3dComponent> {
  Rotate3dEffect.by(
    Vector3 axis,
    this.angle,
    super.controller, {
    super.onComplete,
    super.key,
  }) : axis = axis.normalized();

  /// About what, in its own frame.
  final Vector3 axis;

  /// How far, in radians.
  final double angle;

  final Quaternion _step = Quaternion.identity();

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    _step.setAxisAngle(axis, angle * dProgress);
    target.rotation3.setFrom(target.rotation3 * _step);
  }
}

/// Scales a [Node3dComponent] to a scale, from wherever it is when the
/// effect starts, on any `EffectController`: Flame's `ScaleEffect`, on
/// each axis.
class Scale3dEffect extends ComponentEffect<Node3dComponent> {
  Scale3dEffect.to(
    Vector3 scale,
    super.controller, {
    super.onComplete,
    super.key,
  }) : _to = scale.clone();

  final Vector3 _to;
  final Vector3 _offset = Vector3.zero();

  @override
  void onStart() {
    super.onStart();
    _offset.setFrom(_to - target.scale3);
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.scale3.addScaled(_offset, dProgress);
  }
}
