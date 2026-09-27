import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

/// In this [PathComponent], hitboxes are added to emulate a hitbox
/// that is a composition of other hitboxes.
class PathHitbox extends PathComponent
    with CollisionCallbacks, CollisionPassthrough {
  PathHitbox({
    required super.path,
    this.filterHitboxes = true,
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
    _addHitboxes();
  }

  /// Whether the hitboxes are filtered to include only disjoint ones.
  final bool filterHitboxes;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    children.register<PolygonHitbox>();
  }

  /// Add all the hitboxes and return them.
  List<PolygonHitbox> _addHitboxes() {
    final boxes = _createHitboxes(path, sampling, tolerance);
    addAll(_prepareHitboxes(boxes));
    return boxes;
  }

  // Prepare the hitboxes by first sorting them by size; then, (potentially)
  // filter them by keeping only the largest and all disjoint ones.
  static List<PolygonHitbox> _prepareHitboxes(
    List<PolygonHitbox> hitboxes, {
    bool filterHitboxes = true,
  }) {
    if (hitboxes.length < 2) {
      return hitboxes;
    }
    // Sort the hitboxes by size: we will use the largest area in order to
    // approximate full inclusion.
    hitboxes.sortBy((hitbox) => hitbox.size.length2);
    final largest = hitboxes.last;
    final area = largest.toRect();

    // We always keep the largest hitbox: the others are discarded if they fit
    // entirely within it.
    if (filterHitboxes) {
      hitboxes.removeWhere((element) {
        if (element == largest) {
          return false;
        }
        return area.expandToInclude(element.toRect()) == area;
      });
    }
    return hitboxes;
  }

  // Create a hitbox for each path contour with at least three vertices.
  static List<PolygonHitbox> _createHitboxes(
    Path path,
    double sampling,
    double? tolerance,
  ) {
    final contours = path.walkContours(sampling, tolerance);
    final boxes = <PolygonHitbox>[];
    for (var index = 0; index < contours.length; index++) {
      final contour = contours[index];
      if (contour.length > 2) {
        boxes.add(
          PolygonHitbox(contour.vertices),
          // TODO(adario): support hitboxes paint
          // ..priority = hitboxesPriority ?? priority + 1
          // ..paint = hitboxesPaint ?? hitboxStroke
          // ..renderShape = renderHitboxes,
        );
      }
    }
    return boxes;
  }
}
