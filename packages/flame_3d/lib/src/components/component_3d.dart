import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/components.dart' show Component, HasWorldRef;
import 'package:flame/extensions.dart' show Matrix4Extension;
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
abstract class Component3D({
  Vector3? position,
  Vector3? scale,
  Quaternion? rotation,
  List<Component3D> children = const [],

  /// 32-bit layer bitmask filtering which cameras and `Scene3DComponent`s
  /// render this component.
  var int cameraMask = 0xFFFFFFFF,
}) extends Component with HasWorldRef<World3D> {
  final Transform3D transform = Transform3D()
    ..position = position ?? Vector3.zero()
    ..rotation = rotation ?? Quaternion.euler(0, 0, 0)
    ..scale = scale ?? Vector3.all(1);

  /// {@macro component_3d}
  this : super(children: children) {
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

  // The union of bounds this component is part of, see [ComponentBounds].
  ComponentBounds? _boundsOwner;
  // Whether this component waits in its owner's list of changed bounds.
  bool _boundsQueued = false;
  // The slot of this component in its owner.
  int _boundsSlot = 0;

  World3D? _cachedWorld;

  /// Enclosing [World3D], or `null` when mounted outside of one (e.g. in
  /// standalone component tests).
  @internal
  World3D? get worldOrNull => _cachedWorld;

  /// Compute the local-space AABB for this component's own geometry.
  ///
  /// The base implementation returns `null` (no geometry). Subclasses with
  /// geometry should override this to return their mesh/model AABB.
  @protected
  Aabb3? computeLocalAabb() => null;

  @override
  void onMount() {
    super.onMount();
    _cachedWorld = null;
    for (final ancestor in ancestors()) {
      if (ancestor is World3D) {
        _cachedWorld = ancestor;
        break;
      }
    }
    _markWorldTransformDirty();
    if (parent case final Component3D parent) {
      parent.markAabbDirty();
    }
    _cachedWorld?.markSceneDirty(shadows: this is! LightComponent);
  }

  @override
  void onRemove() {
    _cachedWorld?.markSceneDirty(shadows: this is! LightComponent);
    _cachedWorld = null;
    if (parent case final Component3D parent) {
      parent.markAabbDirty();
    }
    super.onRemove();
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
      // No geometry and no children, so degenerate to point at the world
      // position.
      final world = worldTransformMatrix;
      _cachedAabb
        ..min.setValues(world.m41, world.m42, world.m43)
        ..max.setValues(world.m41, world.m42, world.m43);
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
    } else {
      _boundsOwner?._changed(this);
    }
  }

  /// Mark this component's world transform, and therefore its AABB, as
  /// needing recomputation.
  ///
  /// This propagates down to child [Component3D]s so the entire subtree
  /// stays consistent.
  void _markWorldTransformDirty() {
    // The world transform and the AABB are recomputed independently, so one
    // can be dirty while the other is not. Only stop when both already are.
    if (_worldTransformDirty && _aabbDirty) {
      return;
    }
    _worldTransformDirty = true;
    _aabbDirty = true;
    for (final child in _childComponents) {
      child._markWorldTransformDirty();
    }
  }

  void _onTransformChanged() {
    _markWorldTransformDirty();
    if (parent case final Component3D parent) {
      parent.markAabbDirty();
    } else {
      _boundsOwner?._changed(this);
    }
    _cachedWorld?.markSceneDirty();
  }
}

/// {@template component_bounds}
/// The union of the world-space bounds ([Component3D.aabb]) of a set of
/// components that have no [Component3D] parent, such as the components of a
/// [World3D] (see [World3D.sceneBounds]), kept up to date incrementally.
///
/// Components tell their set when their bounds change: when they or one of
/// their descendants move, or when a descendant is added or removed. The set
/// keeps the bounds of its components in a binary tree whose nodes hold the
/// union of their children, so that reading [value] after `k` of `n`
/// components changed costs at most `k * log2(n)` unions (and nothing when
/// none did), instead of `n`. The union is always exactly that of the
/// current bounds of the components.
/// {@endtemplate}
@internal
class ComponentBounds() {
  // The components, by slot.
  final List<Component3D> _components = [];
  final List<Component3D> _changedComponents = [];

  // A complete binary tree of boxes in an array: node `i` has the children
  // `2i` and `2i + 1`, node 1 is the root and the leaves start at
  // `_capacity`, the leaf of slot `s` being node `_capacity + s`. Each node
  // holds six values, its min and max; empty leaves hold an inverted box.
  Float64List _nodes = Float64List(0);
  int _capacity = 0;
  // Whether the inner nodes are out of date: they are recomputed together
  // once few components change again.
  bool _treeStale = false;

  final Aabb3 _union = Aabb3();
  // Whether [_union] is the union of the leaves.
  bool _unionCurrent = false;

  /// The number of components in the set.
  int get length => _components.length;

  /// Adds [component] to the set.
  void add(Component3D component) {
    assert(component._boundsOwner == null, 'Already in a set of bounds');
    final slot = _components.length;
    if (slot == _capacity) {
      _grow();
    }
    _components.add(component);
    component
      .._boundsOwner = this
      .._boundsSlot = slot;
    _changed(component);
  }

  /// Removes [component] from the set.
  void remove(Component3D component) {
    if (!identical(component._boundsOwner, this)) {
      return;
    }
    if (component._boundsQueued) {
      component._boundsQueued = false;
      _changedComponents.remove(component);
    }
    // The last component takes the slot of the removed one.
    final slot = component._boundsSlot;
    final last = _components.removeLast();
    final lastSlot = _components.length;
    if (!identical(last, component)) {
      _components[slot] = last;
      last._boundsSlot = slot;
      _copyNode(_capacity + lastSlot, _capacity + slot);
      _updatePath(slot);
    }
    _setEmpty(_capacity + lastSlot);
    _updatePath(lastSlot);
    component._boundsOwner = null;
    _unionCurrent = false;
  }

  void _changed(Component3D component) {
    if (!component._boundsQueued) {
      component._boundsQueued = true;
      _changedComponents.add(component);
    }
  }

  /// The union of the bounds of the components, or `null` when there are
  /// none.
  ///
  /// The box is owned by this set and changes when it is read again; copy it
  /// to keep it.
  Aabb3? get value {
    final changed = _changedComponents;
    if (changed.isNotEmpty) {
      for (final component in changed) {
        component._boundsQueued = false;
        _writeLeaf(_capacity + component._boundsSlot, component.aabb);
      }
      if (changed.length * _capacity.bitLength > _capacity) {
        // So many changed that updating their paths would cost more than
        // uniting the leaves: the inner nodes wait for calmer times.
        _treeStale = true;
      } else if (_treeStale) {
        _uniteAll();
        _treeStale = false;
      } else {
        for (final component in changed) {
          _updatePath(component._boundsSlot);
        }
      }
      changed.clear();
      _unionCurrent = false;
    }
    if (_components.isEmpty) {
      return null;
    }
    if (!_unionCurrent) {
      _unionCurrent = true;
      if (_treeStale) {
        _uniteLeaves();
      } else {
        final nodes = _nodes;
        _union.min.setValues(nodes[6], nodes[7], nodes[8]);
        _union.max.setValues(nodes[9], nodes[10], nodes[11]);
      }
    }
    return _union;
  }

  /// Sets [_union] to the union of the leaves that hold a component.
  void _uniteLeaves() {
    final nodes = _nodes;
    var o = _capacity * 6;
    var minX = nodes[o];
    var minY = nodes[o + 1];
    var minZ = nodes[o + 2];
    var maxX = nodes[o + 3];
    var maxY = nodes[o + 4];
    var maxZ = nodes[o + 5];
    for (var slot = 1; slot < _components.length; slot++) {
      o += 6;
      minX = math.min(minX, nodes[o]);
      minY = math.min(minY, nodes[o + 1]);
      minZ = math.min(minZ, nodes[o + 2]);
      maxX = math.max(maxX, nodes[o + 3]);
      maxY = math.max(maxY, nodes[o + 4]);
      maxZ = math.max(maxZ, nodes[o + 5]);
    }
    _union.min.setValues(minX, minY, minZ);
    _union.max.setValues(maxX, maxY, maxZ);
  }

  void _grow() {
    final capacity = _capacity == 0 ? 8 : _capacity * 2;
    final previous = _nodes;
    _nodes = Float64List(capacity * 2 * 6);
    // Every node starts empty: those above empty leaves stay so.
    for (var node = 1; node < capacity * 2; node++) {
      _setEmpty(node);
    }
    for (var slot = 0; slot < _capacity; slot++) {
      _nodes.setRange(
        (capacity + slot) * 6,
        (capacity + slot) * 6 + 6,
        previous,
        (_capacity + slot) * 6,
      );
    }
    _capacity = capacity;
    _treeStale = true;
    _unionCurrent = false;
  }

  /// Recomputes every inner node above a leaf that holds a component.
  void _uniteAll() {
    final nodes = _nodes;
    final count = _components.length;
    if (count == 0) {
      return;
    }
    var level = 1;
    for (var first = _capacity >> 1; first >= 1; first >>= 1) {
      final last = first + ((count - 1) >> level);
      for (var node = first; node <= last; node++) {
        final o = node * 6;
        final a = node * 12;
        final b = a + 6;
        nodes
          ..[o] = math.min(nodes[a], nodes[b])
          ..[o + 1] = math.min(nodes[a + 1], nodes[b + 1])
          ..[o + 2] = math.min(nodes[a + 2], nodes[b + 2])
          ..[o + 3] = math.max(nodes[a + 3], nodes[b + 3])
          ..[o + 4] = math.max(nodes[a + 4], nodes[b + 4])
          ..[o + 5] = math.max(nodes[a + 5], nodes[b + 5]);
      }
      level++;
    }
  }

  void _writeLeaf(int node, Aabb3 box) {
    final o = node * 6;
    final min = box.min;
    final max = box.max;
    _nodes
      ..[o] = min.x
      ..[o + 1] = min.y
      ..[o + 2] = min.z
      ..[o + 3] = max.x
      ..[o + 4] = max.y
      ..[o + 5] = max.z;
  }

  void _setEmpty(int node) {
    final o = node * 6;
    _nodes
      ..[o] = double.infinity
      ..[o + 1] = double.infinity
      ..[o + 2] = double.infinity
      ..[o + 3] = double.negativeInfinity
      ..[o + 4] = double.negativeInfinity
      ..[o + 5] = double.negativeInfinity;
  }

  void _copyNode(int from, int to) {
    _nodes.setRange(to * 6, to * 6 + 6, _nodes, from * 6);
  }

  /// Recomputes the ancestors of the leaf of [slot], up to the first one
  /// that does not change.
  void _updatePath(int slot) {
    if (_treeStale) {
      return;
    }
    for (var node = (_capacity + slot) >> 1; node >= 1; node >>= 1) {
      if (!_unite(node)) {
        return;
      }
    }
  }

  /// Sets [node] to the union of its children; returns whether it changed.
  bool _unite(int node) {
    final nodes = _nodes;
    final o = node * 6;
    final a = node * 12;
    final b = a + 6;
    final minX = math.min(nodes[a], nodes[b]);
    final minY = math.min(nodes[a + 1], nodes[b + 1]);
    final minZ = math.min(nodes[a + 2], nodes[b + 2]);
    final maxX = math.max(nodes[a + 3], nodes[b + 3]);
    final maxY = math.max(nodes[a + 4], nodes[b + 4]);
    final maxZ = math.max(nodes[a + 5], nodes[b + 5]);
    if (nodes[o] == minX &&
        nodes[o + 1] == minY &&
        nodes[o + 2] == minZ &&
        nodes[o + 3] == maxX &&
        nodes[o + 4] == maxY &&
        nodes[o + 5] == maxZ) {
      return false;
    }
    nodes
      ..[o] = minX
      ..[o + 1] = minY
      ..[o + 2] = minZ
      ..[o + 3] = maxX
      ..[o + 4] = maxY
      ..[o + 5] = maxZ;
    return true;
  }
}
