import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flame_flutter3d/src/host/has_flutter3d.dart';
import 'package:flame_flutter3d/src/transform/bridged3d.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flame_flutter3d/src/transform/projector.dart';
import 'package:flame_flutter3d/src/world/wrap_space.dart';

/// A bridged component that hears a tap on what it draws in 3D.
///
/// **Flame's own taps land in the wrong place under a perspective camera.**
/// `TapCallbacks` asks a component whether a point is inside it in Flame's
/// coordinates, which are the plane the game plays on. Seen through a
/// perspective 3D camera, the thing that plane position draws is somewhere
/// else on the screen, larger when near and smaller when far, and a tap on
/// the tanker the player can see missed the tanker Flame thinks is there.
/// This asks instead whether the tap falls on the screen rectangle round
/// what the component draws, through the game's [BridgeProjector]; a
/// [Taps3dComponent] in the game hands the tap to the nearest such
/// component under it.
///
/// **Down, up, and a finger that stays.** [onTap3d] is the tap going down on
/// it; [onTapUp3d] the finger lifting, [onTapCancel3d] the tap given up on,
/// a drag say, and [onLongTap3d] a finger held still: what Flame's own
/// `TapCallbacks` has, for the same component seen in 3D.
///
/// Any bridged component: an `Object3dComponent`, or one instance of a
/// batch drawn as an `InstancedObject3dComponent`.
mixin Tap3dCallbacks on Component, HasVisibility, Drawn3d {
  /// The tap at [screen], in logical pixels from the top left, fell on
  /// this component and on nothing nearer.
  void onTap3d(Vector2 screen) {}

  /// The finger that went down on this component lifted at [screen].
  void onTapUp3d(Vector2 screen) {}

  /// The tap that went down on this component was given up on.
  void onTapCancel3d() {}

  /// The finger that went down on this component stayed down, still.
  void onLongTap3d(Vector2 screen) {}

  /// The boxes in the scene round everything that draws this component:
  /// [drawnBounds3d], and in a `WrapSpace` its ghosts across the seam.
  Iterable<Aabb3> drawnBoxes3d() sync* {
    final box = drawnBounds3d;
    if (box != null) {
      yield box;
    }
    if ((parent, this) case (
      final WrapSpace space,
      final Object3dComponent me,
    )) {
      yield* space.ghostBoundsOf(me);
    }
  }

  /// Whether [screen] falls on what this component draws, as [projector]
  /// sees it: the screen rectangle round one of [drawnBoxes3d]. Override
  /// for a tighter shape.
  bool hitAt3d(Vector2 screen, BridgeProjector projector) =>
      drawnBoxes3d().any((box) => _covers(projector, box, screen));
}

bool _covers(BridgeProjector projector, Aabb3 box, Vector2 screen) {
  final bounds = projector.boundsOf(box);
  return bounds != null &&
      screen.x >= bounds.left &&
      screen.x <= bounds.right &&
      screen.y >= bounds.top &&
      screen.y <= bounds.bottom;
}

/// Covers the game's canvas and hands every tap to the nearest
/// [Tap3dCallbacks] component whose drawing it falls on. Add one to a
/// [HasFlutter3d] game.
///
/// **Nearest to the camera, and one.** Two craft overlapping on the screen
/// are one in front of the other; the tap is for the one in front, and the
/// one behind hears nothing, as a finger on glass would have it. A tap on
/// nothing bridged goes on to whatever else in Flame is under it.
///
/// **Nearest where the tap meets it, not by its middle.** Measured to the
/// middle of each box, a crate standing on a wide field lost the tap to the
/// field, whose middle was nearer the camera. The distance is to where the
/// ray through the tap enters the box, and to its middle only for a box the
/// ray misses although its screen rectangle is hit.
class Taps3dComponent extends PositionComponent
    with TapCallbacks, HasGameRef<HasFlutter3d> {
  Taps3dComponent({super.priority});

  /// The component each finger went down on, until it lifts.
  final Map<int, Tap3dCallbacks> _down = <int, Tap3dCallbacks>{};

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapDown(TapDownEvent event) {
    final hit = nearestAt(event.canvasPosition);
    if (hit == null) {
      event.continuePropagation = true;
      return;
    }
    _down[event.pointerId] = hit;
    hit.onTap3d(event.canvasPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final hit = _down.remove(event.pointerId);
    if (hit == null) {
      event.continuePropagation = true;
      return;
    }
    hit.onTapUp3d(event.canvasPosition);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    final hit = _down.remove(event.pointerId);
    if (hit == null) {
      event.continuePropagation = true;
      return;
    }
    hit.onTapCancel3d();
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    final hit = _down[event.pointerId];
    if (hit == null) {
      event.continuePropagation = true;
      return;
    }
    hit.onLongTap3d(event.canvasPosition);
  }

  /// The nearest [Tap3dCallbacks] component drawn under [screen], or null.
  Tap3dCallbacks? nearestAt(Vector2 screen) {
    final ray = gameRef.projector.rayThrough(screen);
    final eye = ray?.$1 ?? gameRef.camera3d.readWorldPosition();
    Tap3dCallbacks? nearest;
    var nearestDistance = double.infinity;
    for (final candidate in gameRef.descendants().whereType<Tap3dCallbacks>()) {
      if (!shownInFlame(candidate)) {
        continue;
      }
      if (!candidate.hitAt3d(screen, gameRef.projector)) {
        continue;
      }
      // Of its boxes, the nearest the tap is on: a craft and its ghost are
      // never both under one finger, but the one that is decides.
      for (final box in candidate.drawnBoxes3d()) {
        if (!_covers(gameRef.projector, box, screen)) {
          continue;
        }
        final distance = ray == null
            ? eye.distanceTo(box.center)
            : _entry(ray.$1, ray.$2, box) ?? eye.distanceTo(box.center);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = candidate;
        }
      }
    }
    return nearest;
  }

  /// How far from [from] the segment to [to] enters [box], or null when it
  /// misses it: the slab test.
  static double? _entry(Vector3 from, Vector3 to, Aabb3 box) {
    final along = to - from;
    final length = along.length;
    if (length == 0.0) {
      return null;
    }
    along.scale(1.0 / length);
    var enter = 0.0;
    var leave = length;
    for (var axis = 0; axis < 3; axis++) {
      final start = from[axis];
      final step = along[axis];
      final low = box.min[axis];
      final high = box.max[axis];
      if (step.abs() < 1e-12) {
        if (start < low || start > high) {
          return null;
        }
        continue;
      }
      final a = (low - start) / step;
      final b = (high - start) / step;
      final near = a < b ? a : b;
      final far = a < b ? b : a;
      if (near > enter) {
        enter = near;
      }
      if (far < leave) {
        leave = far;
      }
      if (enter > leave) {
        return null;
      }
    }
    return enter;
  }
}
