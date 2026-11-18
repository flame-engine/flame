import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart' show CullMode;
import 'package:flame_3d/src/input/callbacks_3d.dart';
import 'package:flame_3d/src/input/events_3d.dart';

/// Bridges 2D Flame pointer gestures (and headless imperative dispatches) into
/// 3D raycast hit-testing, ancestor event bubbling, hover enter/move/exit
/// tracking, and 3D ray-plane / 1D axis-constrained dragging.
class PointerRouter3D._({
  final Scene3DComponent? _scene,
  final World3D? _world,
  final CameraComponent3D? _camera,
  Vector3? defaultDragNormal,
  var CullMode? cullMode,
  var bool Function(Object3D object)? filter,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
}) extends PositionComponent with TapCallbacks, DragCallbacks, HoverCallbacks {
  /// Creates a router targeting an embedded [Scene3DComponent] layer.
  factory PointerRouter3D.forScene(
    Scene3DComponent layer, {
    Vector3? defaultDragNormal,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    List<Component>? children,
    int? priority,
    ComponentKey? key,
  }) {
    return PointerRouter3D._(
      scene: layer,
      defaultDragNormal: defaultDragNormal,
      cullMode: cullMode,
      filter: filter,
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
      key: key,
    );
  }

  /// Creates a router targeting a [World3D] observed through [camera].
  factory PointerRouter3D.forCamera({
    required World3D world,
    required CameraComponent3D camera,
    Vector3? defaultDragNormal,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    List<Component>? children,
    int? priority,
    ComponentKey? key,
  }) {
    return PointerRouter3D._(
      world: world,
      camera: camera,
      defaultDragNormal: defaultDragNormal,
      cullMode: cullMode,
      filter: filter,
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
      key: key,
    );
  }

  /// Default world-space drag plane normal used when a [DragCallbacks3D]
  /// target leaves `dragPlaneNormal` unset. When `null`, falls back to the
  /// camera-facing plane normal.
  Vector3? defaultDragNormal = defaultDragNormal?.clone();

  /// Active [World3D] queried by this router.
  World3D get world => _scene != null ? _scene.world : _world!;

  final Map<int, _ActiveTapState> _activeTaps = {};
  final Map<int, _ActiveDragState> _activeDrags = {};
  final Map<int, Vector2> _lastPointerPositions = {};
  List<HoverCallbacks3D> _hoveredChain = [];
  Vector2 _lastHoverPosition = Vector2.zero();
  Ray _lastHoverRay = Ray();

  @override
  bool containsLocalPoint(Vector2 point) {
    if (size.x > 0 && size.y > 0) {
      return super.containsLocalPoint(point);
    }
    if (_scene case final scene? when scene.size.x > 0 && scene.size.y > 0) {
      return scene.containsLocalPoint(point);
    }
    if (_camera case final camera?) {
      final vpSize = camera.viewport.virtualSize;
      if (vpSize.x > 0 && vpSize.y > 0) {
        return point.x >= 0 &&
            point.x <= vpSize.x &&
            point.y >= 0 &&
            point.y <= vpSize.y;
      }
    }
    return true;
  }

  /// Projects [point] into a world-space [Ray].
  Ray pointToWorldRay(Vector2 point, {Ray? output}) {
    if (_scene case final scene?) {
      return scene.localPointToRay(point, output: output);
    }
    return _camera!.viewportPointToRay(point, output: output);
  }

  (Ray ray, RayHit3D? hit) _pick(Vector2 point) {
    final ray = pointToWorldRay(point);
    final hit = world.raycast(ray, cullMode: cullMode, filter: filter);
    return (ray, hit);
  }

  /// Imperatively dispatches a 3D tap-down at [point], returning `true` if at
  /// least one [TapCallbacks3D] received the event.
  bool dispatchTapDown(Vector2 point, {int pointerId = 0}) {
    _lastPointerPositions[pointerId] = point.clone();
    final (ray, hit) = _pick(point);
    if (hit == null) {
      _activeTaps.remove(pointerId);
      return false;
    }

    final event = TapDownEvent3D(
      pointerId: pointerId,
      localPosition: point.clone(),
      worldRay: Ray.copy(ray),
      target: hit.object,
      hit: hit,
    );

    final listeners = <TapCallbacks3D>[];
    for (final node in _selfAndAncestors(hit.object)) {
      if (node is TapCallbacks3D) {
        listeners.add(node);
        node.onTapDown3D(event);
        if (event.handled) {
          break;
        }
      }
    }

    if (listeners.isEmpty) {
      _activeTaps.remove(pointerId);
      return false;
    }

    _activeTaps[pointerId] = _ActiveTapState(
      target: hit.object,
      instanceIndex: event.instanceIndex,
      lastPoint: point.clone(),
      lastRay: Ray.copy(ray),
      listeners: listeners,
    );
    return true;
  }

  /// Imperatively dispatches a 3D tap-up at [point] for [pointerId].
  ///
  /// Listeners from the matching [dispatchTapDown] receive `onTapUp3D` when
  /// [point] still intersects them (or one of their descendants), and
  /// `onTapCancel3D` otherwise.
  bool dispatchTapUp(Vector2 point, {int pointerId = 0}) {
    _lastPointerPositions[pointerId] = point.clone();
    final active = _activeTaps.remove(pointerId);
    if (active == null) {
      return false;
    }

    final (ray, hit) = _pick(point);
    TapUpEvent3D? upEvent;
    TapCancelEvent3D? cancelEvent;

    for (final listener in active.listeners) {
      final stillInside =
          hit != null && _isSameOrDescendant(hit.object, listener);
      if (stillInside) {
        if (upEvent == null || !upEvent.handled) {
          upEvent ??= TapUpEvent3D(
            pointerId: pointerId,
            localPosition: point.clone(),
            worldRay: Ray.copy(ray),
            target: hit.object,
            hit: hit,
            instanceIndex: active.instanceIndex,
          );
          listener.onTapUp3D(upEvent);
        }
      } else {
        cancelEvent ??= TapCancelEvent3D(
          pointerId: pointerId,
          localPosition: point.clone(),
          worldRay: Ray.copy(ray),
          target: active.target,
          hit: hit,
          instanceIndex: active.instanceIndex,
        );
        listener.onTapCancel3D(cancelEvent);
      }
    }
    return true;
  }

  /// Imperatively cancels an active 3D tap for [pointerId].
  bool dispatchTapCancel({int pointerId = 0, Vector2? point}) {
    final active = _activeTaps.remove(pointerId);
    if (active == null) {
      return false;
    }
    final pos =
        point?.clone() ?? _lastPointerPositions[pointerId] ?? active.lastPoint;
    final ray = point != null ? pointToWorldRay(point) : active.lastRay;
    final cancelEvent = TapCancelEvent3D(
      pointerId: pointerId,
      localPosition: pos.clone(),
      worldRay: Ray.copy(ray),
      target: active.target,
      instanceIndex: active.instanceIndex,
    );
    for (final listener in active.listeners) {
      listener.onTapCancel3D(cancelEvent);
      if (cancelEvent.handled) {
        break;
      }
    }
    return true;
  }

  /// Imperatively evaluates 3D hover state at [point], emitting
  /// `onHoverExit3D` before `onHoverEnter3D` when the hovered target changes,
  /// and `onHoverMove3D` when continuing across an already-hovered target.
  void dispatchHover(Vector2 point, {int pointerId = 0}) {
    _lastPointerPositions[pointerId] = point.clone();
    final (ray, hit) = _pick(point);
    _lastHoverPosition = point.clone();
    _lastHoverRay = Ray.copy(ray);

    final candidates = <HoverCallbacks3D>[];
    if (hit != null) {
      for (final node in _selfAndAncestors(hit.object)) {
        if (node is HoverCallbacks3D) {
          candidates.add(node);
        }
      }
    }

    for (final prev in _hoveredChain) {
      if (!candidates.contains(prev)) {
        final exitEvent = HoverExitEvent3D(
          pointerId: pointerId,
          localPosition: point.clone(),
          worldRay: Ray.copy(ray),
          target: prev,
          hit: hit,
        );
        prev.onHoverExit3D(exitEvent);
      }
    }

    final nextHovered = <HoverCallbacks3D>[];
    if (hit != null) {
      HoverEnterEvent3D? enterEvent;
      HoverMoveEvent3D? moveEvent;
      var stopped = false;

      for (final candidate in candidates) {
        if (stopped) {
          if (_hoveredChain.contains(candidate)) {
            candidate.onHoverExit3D(
              HoverExitEvent3D(
                pointerId: pointerId,
                localPosition: point.clone(),
                worldRay: Ray.copy(ray),
                target: candidate,
                hit: hit,
              ),
            );
          }
          continue;
        }

        nextHovered.add(candidate);
        if (_hoveredChain.contains(candidate)) {
          moveEvent ??= HoverMoveEvent3D(
            pointerId: pointerId,
            localPosition: point.clone(),
            worldRay: Ray.copy(ray),
            target: hit.object,
            hit: hit,
          );
          candidate.onHoverMove3D(moveEvent);
          if (moveEvent.handled) {
            stopped = true;
          }
        } else {
          enterEvent ??= HoverEnterEvent3D(
            pointerId: pointerId,
            localPosition: point.clone(),
            worldRay: Ray.copy(ray),
            target: hit.object,
            hit: hit,
          );
          candidate.onHoverEnter3D(enterEvent);
          if (enterEvent.handled) {
            stopped = true;
          }
        }
      }
    }

    _hoveredChain = nextHovered;
  }

  /// Clears any active 3D hovered targets, emitting `onHoverExit3D` on each.
  void dispatchHoverExit({int pointerId = 0, Vector2? point}) {
    if (_hoveredChain.isEmpty) {
      return;
    }
    final pos = point?.clone() ?? _lastHoverPosition.clone();
    final ray = point != null
        ? pointToWorldRay(point)
        : Ray.copy(_lastHoverRay);
    final previous = _hoveredChain;
    _hoveredChain = [];
    for (final prev in previous) {
      prev.onHoverExit3D(
        HoverExitEvent3D(
          pointerId: pointerId,
          localPosition: pos.clone(),
          worldRay: Ray.copy(ray),
          target: prev,
        ),
      );
    }
  }

  /// Imperatively starts a 3D drag at [point] for [pointerId], returning
  /// `true` if at least one [DragCallbacks3D] captured the gesture.
  bool dispatchDragStart(Vector2 point, {int pointerId = 0}) {
    _lastPointerPositions[pointerId] = point.clone();
    final (ray, hit) = _pick(point);
    if (hit == null) {
      _activeDrags.remove(pointerId);
      return false;
    }

    final capturedInstance = hit.object is InstancedGroup3D
        ? hit.surfaceIndex
        : null;
    final entries = <_DragListenerEntry>[];

    for (final node in _selfAndAncestors(hit.object)) {
      if (node is DragCallbacks3D) {
        final entry = _buildDragEntry(node, ray, hit.worldPoint);
        final startEvent = DragStartEvent3D(
          pointerId: pointerId,
          localPosition: point.clone(),
          worldRay: Ray.copy(ray),
          target: hit.object,
          hit: hit,
          instanceIndex: capturedInstance,
          worldPlanePoint: entry.lastPlanePoint.clone(),
        );
        entries.add(entry);
        node.onDragStart3D(startEvent);
        if (startEvent.handled) {
          break;
        }
      }
    }

    if (entries.isEmpty) {
      _activeDrags.remove(pointerId);
      return false;
    }

    _activeDrags[pointerId] = _ActiveDragState(
      target: hit.object,
      instanceIndex: capturedInstance,
      lastLocalPoint: point.clone(),
      lastRay: Ray.copy(ray),
      entries: entries,
    );
    return true;
  }

  /// Imperatively updates an active 3D drag for [pointerId] at [point].
  bool dispatchDragUpdate(Vector2 point, {int pointerId = 0}) {
    _lastPointerPositions[pointerId] = point.clone();
    final active = _activeDrags[pointerId];
    if (active == null) {
      return false;
    }

    final ray = pointToWorldRay(point);
    active
      ..lastLocalPoint = point.clone()
      ..lastRay = Ray.copy(ray);

    for (final entry in active.entries) {
      final nextPoint = entry.projectRay(
        ray,
        isPerspective: _camera?.projection == CameraProjection.perspective,
      );
      final delta = nextPoint - entry.lastPlanePoint;
      entry.lastPlanePoint.setFrom(nextPoint);

      final updateEvent = DragUpdateEvent3D(
        pointerId: pointerId,
        localPosition: point.clone(),
        worldRay: Ray.copy(ray),
        target: active.target,
        instanceIndex: active.instanceIndex,
        worldPlanePoint: nextPoint.clone(),
        worldDelta: delta,
      );
      entry.listener.onDragUpdate3D(updateEvent);
      if (updateEvent.handled) {
        break;
      }
    }
    return true;
  }

  /// Imperatively finishes (or cancels) an active 3D drag for [pointerId].
  bool dispatchDragEnd({
    int pointerId = 0,
    Vector2? point,
    bool wasCancelled = false,
  }) {
    final active = _activeDrags.remove(pointerId);
    if (active == null) {
      return false;
    }

    final pos = point?.clone() ?? active.lastLocalPoint.clone();
    final ray = point != null ? pointToWorldRay(point) : active.lastRay;

    for (final entry in active.entries) {
      final finalPoint = point != null
          ? entry.projectRay(
              ray,
              isPerspective:
                  _camera?.projection == CameraProjection.perspective,
            )
          : entry.lastPlanePoint.clone();
      final delta = finalPoint - entry.lastPlanePoint;

      final endEvent = DragEndEvent3D(
        pointerId: pointerId,
        localPosition: pos.clone(),
        worldRay: Ray.copy(ray),
        target: active.target,
        instanceIndex: active.instanceIndex,
        worldPlanePoint: finalPoint,
        worldDelta: delta,
        wasCancelled: wasCancelled,
      );
      entry.listener.onDragEnd3D(endEvent);
      if (endEvent.handled) {
        break;
      }
    }
    return true;
  }

  _DragListenerEntry _buildDragEntry(
    DragCallbacks3D listener,
    Ray startRay,
    Vector3 grabPoint,
  ) {
    final axis = listener.dragAxisConstraint;
    if (axis != null && axis.length2 > 1e-12) {
      final unitAxis = axis.normalized();
      final initialS = _closestAxisParam(grabPoint, unitAxis, startRay) ?? 0.0;
      return _DragListenerEntry.axis(
        listener: listener,
        anchorPoint: grabPoint.clone(),
        unitAxis: unitAxis,
        initialAxisParam: initialS,
      );
    }

    final planeNormal = _resolvePlaneNormal(listener, startRay);
    return _DragListenerEntry.plane(
      listener: listener,
      anchorPoint: grabPoint.clone(),
      planeNormal: planeNormal,
    );
  }

  Vector3 _resolvePlaneNormal(DragCallbacks3D listener, Ray ray) {
    final explicit = listener.dragPlaneNormal;
    if (explicit != null && explicit.length2 > 1e-12) {
      return explicit.normalized();
    }
    final fallback = defaultDragNormal;
    if (fallback != null && fallback.length2 > 1e-12) {
      return fallback.normalized();
    }
    if (_camera case final camera?) {
      final viewBack = camera.position - camera.target;
      if (viewBack.length2 > 1e-12) {
        return viewBack..normalize();
      }
    }
    if (ray.direction.length2 > 1e-12) {
      return (-ray.direction)..normalize();
    }
    return Vector3(0, 1, 0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!dispatchTapDown(event.localPosition, pointerId: event.pointerId)) {
      event.continuePropagation = true;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!dispatchTapUp(event.localPosition, pointerId: event.pointerId)) {
      event.continuePropagation = true;
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    dispatchTapCancel(pointerId: event.pointerId);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!dispatchDragStart(event.localPosition, pointerId: event.pointerId)) {
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final pos = event.renderingTrace.isNotEmpty
        ? event.localEndPosition
        : event.canvasEndPosition;
    dispatchDragUpdate(pos, pointerId: event.pointerId);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dispatchDragEnd(
      pointerId: event.pointerId,
      point: _lastPointerPositions[event.pointerId],
    );
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    dispatchDragEnd(
      pointerId: event.pointerId,
      point: _lastPointerPositions[event.pointerId],
      wasCancelled: true,
    );
  }

  @override
  void onMouseMove(MouseMoveEvent event) {
    super.onMouseMove(event);
    final pos = event.localPosition;
    if (!pos.x.isNaN && !pos.y.isNaN && containsLocalPoint(pos)) {
      dispatchHover(pos, pointerId: event.pointerId);
    } else {
      dispatchHoverExit(pointerId: event.pointerId);
    }
  }

  @override
  void onMouseMoveStop(MouseMoveEvent event) {
    super.onMouseMoveStop(event);
    dispatchHoverExit(pointerId: event.pointerId);
  }

  @override
  void onHoverExit() {
    dispatchHoverExit();
  }

  @override
  void onHoverCancel() {
    dispatchHoverExit();
  }

  @override
  void onRemove() {
    dispatchHoverExit();
    _activeTaps.clear();
    _activeDrags.clear();
    _lastPointerPositions.clear();
    super.onRemove();
  }

  static Iterable<Component> _selfAndAncestors(Object3D leaf) sync* {
    yield leaf;
    yield* leaf.ancestors();
  }

  static bool _isSameOrDescendant(Object3D candidate, Component ancestor) {
    if (identical(candidate, ancestor)) {
      return true;
    }
    for (final p in candidate.ancestors()) {
      if (identical(p, ancestor)) {
        return true;
      }
    }
    return false;
  }

  static double? _closestAxisParam(Vector3 anchor, Vector3 unitAxis, Ray ray) {
    final dirLen = ray.direction.length;
    if (dirLen <= 1e-12) {
      return null;
    }
    final dx = ray.direction.x / dirLen;
    final dy = ray.direction.y / dirLen;
    final dz = ray.direction.z / dirLen;

    final wx = anchor.x - ray.origin.x;
    final wy = anchor.y - ray.origin.y;
    final wz = anchor.z - ray.origin.z;

    final b = unitAxis.x * dx + unitAxis.y * dy + unitAxis.z * dz;
    final denom = 1.0 - b * b;
    if (denom <= 1e-8) {
      return null;
    }
    final d = unitAxis.x * wx + unitAxis.y * wy + unitAxis.z * wz;
    final e = dx * wx + dy * wy + dz * wz;
    return (b * e - d) / denom;
  }
}

class _ActiveTapState({
  required final Object3D target,
  required final int? instanceIndex,
  required final Vector2 lastPoint,
  required final Ray lastRay,
  required final List<TapCallbacks3D> listeners,
});

class _ActiveDragState({
  required final Object3D target,
  required final int? instanceIndex,
  required var Vector2 lastLocalPoint,
  required var Ray lastRay,
  required final List<_DragListenerEntry> entries,
});

class _DragListenerEntry._({
  required final DragCallbacks3D listener,
  required final Vector3 anchorPoint,
  required final Vector3 lastPlanePoint,
  final Vector3? planeNormal,
  final Vector3? unitAxis,
  final double initialAxisParam = 0.0,
}) {
  factory _DragListenerEntry.plane({
    required DragCallbacks3D listener,
    required Vector3 anchorPoint,
    required Vector3 planeNormal,
  }) {
    return _DragListenerEntry._(
      listener: listener,
      anchorPoint: anchorPoint,
      lastPlanePoint: anchorPoint.clone(),
      planeNormal: planeNormal,
    );
  }

  factory _DragListenerEntry.axis({
    required DragCallbacks3D listener,
    required Vector3 anchorPoint,
    required Vector3 unitAxis,
    required double initialAxisParam,
  }) {
    return _DragListenerEntry._(
      listener: listener,
      anchorPoint: anchorPoint,
      lastPlanePoint: anchorPoint.clone(),
      unitAxis: unitAxis,
      initialAxisParam: initialAxisParam,
    );
  }

  Vector3 projectRay(Ray ray, {required bool isPerspective}) {
    if (unitAxis case final axis?) {
      final s = PointerRouter3D._closestAxisParam(anchorPoint, axis, ray);
      if (s == null) {
        return lastPlanePoint.clone();
      }
      final deltaS = s - initialAxisParam;
      return Vector3(
        anchorPoint.x + axis.x * deltaS,
        anchorPoint.y + axis.y * deltaS,
        anchorPoint.z + axis.z * deltaS,
      );
    }

    final n = planeNormal!;
    final denom =
        n.x * ray.direction.x + n.y * ray.direction.y + n.z * ray.direction.z;
    if (denom.abs() <= 1e-8) {
      return lastPlanePoint.clone();
    }
    final diffX = anchorPoint.x - ray.origin.x;
    final diffY = anchorPoint.y - ray.origin.y;
    final diffZ = anchorPoint.z - ray.origin.z;
    final t = (diffX * n.x + diffY * n.y + diffZ * n.z) / denom;
    if (isPerspective && t < 0.0) {
      return lastPlanePoint.clone();
    }
    return Vector3(
      ray.origin.x + ray.direction.x * t,
      ray.origin.y + ray.direction.y * t,
      ray.origin.z + ray.direction.z * t,
    );
  }
}
