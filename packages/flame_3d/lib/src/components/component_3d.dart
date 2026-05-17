import 'package:flame/components.dart' show Component, HasWorldReference;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:meta/meta.dart';

/// {@template component_3d}
/// [Component3D] is a base class for any concept that lives in 3D space.
///
/// It is a [Component] implementation that represents a 3D object that can be
/// freely moved around in 3D space, rotated, and scaled.
///
/// The main property of this class is the [transform] (which combines
/// the [position], [rotation], and [scale]). Thus, the [Component3D] can be
/// seen as an object in 3D space.
///
/// It is typically not used directly, but rather use one of the following
/// implementations:
/// - [Object3D] for a 3D object that can be bound and rendered by the GPU
/// - [LightComponent] for a light source that affects how objects are rendered
///
/// If you want to have a pure group for several components, you have two
/// options:
/// - Use an [Object3D], the group itself will have some superfluous render
/// logic but should not affect your children.
/// - Extend the abstract class [Component3D] yourself.
///
/// The base [Component3D] class can also be used as a container
/// for several other components. In this case, changing the position,
/// rotating or scaling the [Component3D] will affect the whole
/// group as if it was a single entity.
/// {@endtemplate}
abstract class Component3D extends Component with HasWorldReference<World3D> {
  final Transform3D transform;

  /// {@macro component_3d}
  Component3D({
    Vector3? position,
    Vector3? scale,
    Quaternion? rotation,
    List<Component3D> children = const [],
  }) : transform = Transform3D()
         ..position = position ?? Vector3.zero()
         ..rotation = rotation ?? Quaternion.euler(0, 0, 0)
         ..scale = scale ?? Vector3.all(1),
       super(children: children) {
    this.children.register<Component3D>();
    _childComponents = this.children.query<Component3D>();
    transform.addListener(_onTransformChanged);
  }

  late final Iterable<Component3D> _childComponents;

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
  Matrix4 get transformMatrix => transform.transformMatrix;

  /// The world-space transformation matrix, accounting for all ancestor
  /// [Component3D]s.
  ///
  /// The result is cached and only recomputed when this component's or an
  /// ancestor's transform changes.
  Matrix4 get worldTransformMatrix {
    if (!_worldTransformDirty) {
      return _worldTransformMatrix;
    }
    _worldTransformDirty = false;

    final p = parent;
    if (p is Component3D) {
      return _worldTransformMatrix
        ..setFrom(p.worldTransformMatrix)
        ..multiply(transformMatrix);
    }
    return _worldTransformMatrix..setFrom(transformMatrix);
  }

  final Matrix4 _worldTransformMatrix = Matrix4.identity();
  bool _worldTransformDirty = true;

  /// The position of this component's anchor on the screen.
  NotifyingVector3 get position => transform.position;
  set position(Vector3 position) => transform.position = position;

  /// X position of this component's anchor on the screen.
  double get x => transform.x;
  set x(double x) => transform.x = x;

  /// Y position of this component's anchor on the screen.
  double get y => transform.y;
  set y(double y) => transform.y = y;

  /// Z position of this component's anchor on the screen.
  double get z => transform.z;
  set z(double z) => transform.z = z;

  /// The rotation of this component.
  NotifyingQuaternion get rotation => transform.rotation;
  set rotation(NotifyingQuaternion rotation) => transform.rotation = rotation;

  /// The scale factor of this component. The scale can be different along
  /// the X, Y and Z dimensions. A scale greater than 1 makes the component
  /// bigger along that axis, and less than 1 smaller. The scale can also be
  /// negative, which results in a mirror reflection along the corresponding
  /// axis.
  NotifyingVector3 get scale => transform.scale;
  set scale(Vector3 scale) => transform.scale = scale;

  /// Measure the distance (in parent's coordinate space) between this
  /// component's anchor and the [other] component's anchor.
  double distance(Component3D other) => position.distanceTo(other.position);

  /// The world-space axis-aligned bounding box for this component and all its
  /// [Component3D] children.
  ///
  /// Subclasses with geometry (e.g. [MeshComponent]) override
  /// [computeLocalAabb] to include their own mesh bounds.
  Aabb3 get aabb {
    if (_aabbDirty) {
      _recomputeAabb();
      _aabbDirty = false;
    }
    return _cachedAabb;
  }

  final Aabb3 _cachedAabb = Aabb3();
  bool _aabbDirty = true;

  /// Compute the local-space AABB for this component's own geometry.
  ///
  /// The base implementation returns `null` (no geometry). Subclasses with
  /// geometry should override this to return their mesh/model AABB.
  @protected
  Aabb3? computeLocalAabb() => null;

  @override
  void onMount() {
    super.onMount();
    _markWorldTransformDirty();
  }

  void _recomputeAabb() {
    final localAabb = computeLocalAabb();
    var initialized = false;

    if (localAabb != null) {
      _cachedAabb
        ..setFrom(localAabb)
        ..transform(worldTransformMatrix);
      initialized = true;
    }

    for (final child in _childComponents) {
      if (initialized) {
        _cachedAabb.hull(child.aabb);
      } else {
        _cachedAabb.setFrom(child.aabb);
        initialized = true;
      }
    }

    if (!initialized) {
      // No geometry and no children, so degenerate to point at position.
      _cachedAabb
        ..min.setFrom(position)
        ..max.setFrom(position);
    }
  }

  /// Mark this component's AABB as needing recomputation.
  ///
  /// This propagates up to parent [Component3D]s so the entire hierarchy
  /// stays consistent.
  void markAabbDirty() {
    if (_aabbDirty) {
      return;
    }
    _aabbDirty = true;

    if (parent case final Component3D parent) {
      parent.markAabbDirty();
    }
  }

  /// Mark this component's world transform as needing recomputation.
  ///
  /// This propagates down to child [Component3D]s so the entire subtree
  /// stays consistent.
  void _markWorldTransformDirty() {
    if (_worldTransformDirty) {
      return;
    }
    _worldTransformDirty = true;
    for (final child in _childComponents) {
      child._markWorldTransformDirty();
    }
  }

  void _onTransformChanged() {
    _markWorldTransformDirty();
    markAabbDirty();
  }
}
