import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:vector_math/vector_math.dart';

/// Between Flame's screen and the 3D camera: where a point of the scene is
/// drawn, and which point of a [BridgePlane] is under a touch.
///
/// **What a Flame overlay and a Flame pointer need from a perspective 3D
/// layer.** A label over a craft, a "+30" where a target went down, lives
/// in Flame's viewport, in screen pixels; the craft lives in the scene. A
/// crosshair a finger puts on the ground is a screen point that has to
/// become a point on the plane the game plays on. With an orthographic
/// camera the two are one scale apart; with a perspective one they are a
/// projection apart, and every game that wanted either wrote it by hand.
///
/// [viewSize] is read on every call, so it follows a resize: pass the Flame
/// game's own `size`, which is the canvas both layers share.
///
/// **One view of several.** [viewport] is the part of the canvas [camera]
/// is drawn into, as a `RenderView.viewportFraction` says: the left half of
/// a split screen. Screen points stay the canvas's, and the camera's lens
/// is that part's shape. Null is the whole canvas.
final class BridgeProjector {
  BridgeProjector({
    required this.camera,
    required this.viewSize,
    this.viewport,
  });

  final CameraNode camera;
  final Vector2 Function() viewSize;

  /// The part of the canvas [camera] draws into, read on every call; null
  /// for all of it.
  final ViewportRect Function()? viewport;

  /// Where [camera]'s picture is on the canvas, in logical pixels, or null
  /// while the canvas has no size.
  ({double x, double y, double width, double height})? _area() {
    final size = viewSize();
    if (size.x <= 0.0 || size.y <= 0.0) {
      return null;
    }
    final part = viewport?.call();
    if (part == null) {
      return (x: 0.0, y: 0.0, width: size.x, height: size.y);
    }
    return (
      x: part.x * size.x,
      y: part.y * size.y,
      width: part.width * size.x,
      height: part.height * size.y,
    );
  }

  /// Where [point] is drawn, in logical pixels from the top left, or null
  /// when it is behind the camera.
  ///
  /// **Behind an orthographic camera too.** A perspective projection
  /// divides by depth and sends a point behind the eye away; an orthographic
  /// one does not, and a point behind it came back drawn as if in front.
  /// It is asked of the camera's own space.
  Vector2? toScreen(Vector3 point) {
    final area = _area();
    if (area == null) {
      return null;
    }
    if (camera.projection is OrthographicProjection &&
        camera.viewMatrix.transformed3(point).z > 0.0) {
      return null;
    }
    final at = projectPoint(
      camera.viewProjection(area.width / area.height),
      point,
      width: area.width,
      height: area.height,
    );
    return at == null ? null : Vector2(at.x + area.x, at.y + area.y);
  }

  /// The rectangle on the screen [box] covers, in logical pixels, or null
  /// when all of it is behind the camera. A box partly behind it covers the
  /// whole view, as `screenBoundsOfBox` explains.
  ScreenBounds? boundsOf(Aabb3 box) {
    final area = _area();
    if (area == null) {
      return null;
    }
    final bounds = screenBoundsOfBox(
      camera.viewProjection(area.width / area.height),
      box,
      width: area.width,
      height: area.height,
    );
    if (bounds == null) {
      return null;
    }
    return (
      left: bounds.left + area.x,
      top: bounds.top + area.y,
      right: bounds.right + area.x,
      bottom: bounds.bottom + area.y,
    );
  }

  /// The point of [plane] under [screen], in Flame's coordinates on that
  /// plane, or null when the ray from the camera through it never meets
  /// the plane in front of the camera: a touch on the sky.
  Vector2? onPlane(Vector2 screen, BridgePlane plane) {
    final ray = rayThrough(screen);
    if (ray == null) {
      return null;
    }
    final (near, far) = ray;
    final normal = plane.normal;
    final start = near.dot(normal);
    final run = far.dot(normal) - start;
    if (run.abs() < 1e-12) {
      return null;
    }
    final t = (plane.constant - start) / run;
    if (t < 0.0) {
      return null;
    }
    // Parenthesised: a cascade binds to the whole sum, and `near + (far -
    // near)..scale(t)` scaled the far point instead of the step towards it.
    return plane.to2d(near + ((far - near)..scale(t)));
  }

  /// [onPlane], or for a touch on the sky the point of [plane] straight
  /// under where the ray leaves the view: out at the horizon, in the
  /// direction the finger points. Finite either way, for what cannot take a
  /// NaN, a drag that strays above the horizon say.
  Vector2? onPlaneOrHorizon(Vector2 screen, BridgePlane plane) {
    final hit = onPlane(screen, plane);
    if (hit != null) {
      return hit;
    }
    final ray = rayThrough(screen);
    return ray == null ? null : plane.to2d(ray.$2);
  }

  /// The near and far ends of the ray from the camera through [screen]:
  /// where a tap enters the scene, and where it leaves the view.
  (Vector3, Vector3)? rayThrough(Vector2 screen) {
    final area = _area();
    if (area == null) {
      return null;
    }
    final inverse = Matrix4.copy(
      camera.viewProjection(area.width / area.height),
    );
    if (inverse.invert() == 0.0) {
      return null;
    }
    final ndcX = (screen.x - area.x) / area.width * 2.0 - 1.0;
    final ndcY = 1.0 - (screen.y - area.y) / area.height * 2.0;
    // Clip-space depth runs 0 at the near plane to 1 at the far one in this
    // engine; see `projectPoint`.
    final near = _unproject(inverse, ndcX, ndcY, 0.0);
    final far = _unproject(inverse, ndcX, ndcY, 1.0);
    if (near == null || far == null) {
      return null;
    }
    return (near, far);
  }

  static Vector3? _unproject(Matrix4 inverse, double x, double y, double z) {
    final v = inverse.transform(Vector4(x, y, z, 1.0));
    if (v.w.abs() < 1e-12) {
      return null;
    }
    return Vector3(v.x / v.w, v.y / v.w, v.z / v.w);
  }
}
