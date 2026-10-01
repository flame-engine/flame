import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:flame/camera.dart';
import 'package:flame/components.dart' show Vector2;

import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flame_flutter3d/src/transform/projector.dart';

/// A Flame [Viewfinder] that maps the screen to the game's plane through the
/// 3D camera, so Flame's own events land where the player sees things.
///
/// **What Flame gets wrong under a perspective camera.** A `CameraComponent`
/// turns a point on the screen into a world point with its viewfinder's
/// affine transform: an offset, a zoom, a turn. A perspective 3D camera does
/// not draw the plane that way, so a tap on a craft reached Flame as a
/// point metres away from it, and a component's `TapCallbacks`, a
/// `camera.globalToLocal` in the game's own code, and Flame's hit test all
/// missed. Here a screen point becomes the point of [plane] under it, found
/// by [projector], and a plane point becomes where it is drawn.
///
/// **The sky is the horizon.** A point that meets no plane came back as NaN,
/// and Flame's `World` takes every point: its tap handlers were handed NaN,
/// and a drag that strayed above the horizon moved its component to NaN for
/// good. It now comes back as the plane point out at the horizon in that
/// direction, which is far, finite, and where a drag would have been going.
///
/// **Any viewport.** Flame hands a viewfinder points in its viewport's own
/// frame, and the projector works in the canvas both layers share; a
/// `FixedResolutionViewport`, or one placed off the corner, put every tap
/// somewhere else. Points are brought into the canvas first, and back.
///
/// **Events and conversions, not drawing.** Flame still draws its world
/// through the affine transform; a bridged game draws its world in 3D and
/// keeps Flame's drawing to the viewport, where this changes nothing.
///
///     camera = CameraComponent(
///       world: world,
///       viewfinder: ProjectedViewfinder(projector: projector, plane: plane),
///     );
class ProjectedViewfinder extends Viewfinder {
  ProjectedViewfinder({required this.projector, required this.plane});

  /// The plane the game plays on.
  final BridgePlane plane;

  /// Between the 3D camera and the screen.
  final BridgeProjector projector;

  Viewport? get _viewport => switch (parent) {
    final CameraComponent camera => camera.viewport,
    _ => null,
  };

  @override
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final canvas = _viewport?.localToGlobal(point) ?? point;
    final onPlane = projector.onPlaneOrHorizon(canvas, plane);
    final result = output ?? Vector2.zero();
    if (onPlane == null) {
      return result..setValues(double.nan, double.nan);
    }
    return result..setFrom(onPlane);
  }

  /// **What the 3D camera shows, not what the affine transform would.**
  /// Flame's `visibleWorldRect`, which `canSee` and a `setBounds` that
  /// minds the viewport read, came from the viewfinder's offset and zoom,
  /// and under a perspective lens was a rectangle nobody was looking at.
  /// Here it is the box round the plane points under the viewport's four
  /// corners, the horizon standing in for the sky.
  @override
  Rect computeVisibleRect() {
    final size = _viewport?.virtualSize ?? projector.viewSize();
    final corners = <Vector2>[
      for (final (x, y) in <(double, double)>[
        (0.0, 0.0),
        (size.x, 0.0),
        (0.0, size.y),
        (size.x, size.y),
      ])
        globalToLocal(Vector2(x, y)),
    ].where((p) => p.x.isFinite && p.y.isFinite).toList();
    if (corners.isEmpty) {
      return Rect.zero;
    }
    return Rect.fromPoints(
      Offset(
        corners.map((p) => p.x).reduce(math.min),
        corners.map((p) => p.y).reduce(math.min),
      ),
      Offset(
        corners.map((p) => p.x).reduce(math.max),
        corners.map((p) => p.y).reduce(math.max),
      ),
    );
  }

  /// Worked out afresh every frame: the 3D camera moves without Flame's
  /// transform changing, and Flame keeps the rectangle until it does.
  @override
  void update(double dt) {
    super.update(dt);
    // ignore: invalid_use_of_internal_member, the cache Flame keeps for it.
    visibleRect = null;
  }

  @override
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final screen = projector.toScreen(plane.to3d(point));
    final result = output ?? Vector2.zero();
    if (screen == null) {
      return result..setValues(double.nan, double.nan);
    }
    return result..setFrom(_viewport?.globalToLocal(screen) ?? screen);
  }
}
