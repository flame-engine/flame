import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// In this [PathComponent], hitboxes are added to emulate a hitbox
/// that is a composition of other hitboxes.
class PathHitbox extends PathComponent with ShapeHitbox {
  PathHitbox({
    required super.path,
    super.filter,
    super.sampling,
    super.tolerance,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.paint,
    super.paintLayers,
    super.isSolid = false,
  }) {
    // TODO(adario): convenience...
    addHitboxes();
  }

  /// Our polygon hitboxes.
  Iterable<PolygonHitbox> get polygonHitboxes =>
      children.query<PolygonHitbox>();

  /// Returns information about how the ray intersects the shape.
  ///
  /// If you are only interested in the intersection point use
  /// [RaycastResult.intersectionPoint] of the result.
  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    for (final hitbox in polygonHitboxes) {
      final result = hitbox.rayIntersection(ray, out: out);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// This determines how the shape should scale if it should try to fill its
  /// parents boundaries.
  @override
  void fillParent() {
    // TODO(adario): is this correct?
    throw UnsupportedError('PathHitbox already fills its parent');
  }

  @override
  @protected
  void computeAabb(Aabb2 aabb) {
    aabb.min.setValues(aabb.max.x, aabb.max.y);
    for (final box in polygonHitboxes) {
      aabb.hull(box.aabb);
    }
  }

  /// Ensure we can perform queries quickly.
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    children.register<PolygonHitbox>();
  }

  /// Add all the hitboxes and return them.
  List<PolygonHitbox> addHitboxes() {
    final boxes = createHitboxes(this, sampling, tolerance);
    addAll(PathComponent.preparePolygons(boxes, filterPolygons: filter));
    return boxes;
  }

  /// Create a hitbox for each path contour with at least three vertices.
  @internal
  static List<PolygonHitbox> createHitboxes(
    PathComponent path,
    double sampling,
    double? tolerance,
  ) {
    final contours = path.contours;
    final boxes = <PolygonHitbox>[];
    for (var index = 0; index < contours.length; index++) {
      final contour = contours[index];
      if (contour.length > 2) {
        boxes.add(PolygonHitbox(contour.vertices));
      }
    }
    return boxes;
  }
}
