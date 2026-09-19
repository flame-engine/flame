import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';

/// Renders a [Path] and gives it a hitbox for each of its contours.
///
/// The path is moved so that its bounds start at the origin of the component,
/// which gets the size of those bounds, so that the anchor and the transform
/// of the component apply to the path like to any other shape.
class PathComponent extends ShapeComponent
    with CollisionCallbacks, CollisionPassthrough {
  PathComponent({
    required Path path,
    this.addHitboxes = false,
    this.loadHitboxes = true,
    this.renderHitboxes = false,
    this.filterHitboxes = true,
    this.hitboxesPaint,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.paint,
    super.paintLayers,
  }) : path = path.toOrigin,
       super(size: path.getBounds().size.toVector2()) {
    if (addHitboxes) {
      _addHitboxes();
    }
  }

  /// The default paint used to render hitboxes.
  static Paint hitboxStroke = Paint()..style = .stroke;

  /// The path to display, already rooted at the origin.
  final Path path;

  /// Whether the hitboxes are added right away, in the constructor.
  final bool addHitboxes;

  /// Whether the hitboxes are added when the component loads.
  final bool loadHitboxes;

  /// Whether the hitboxes are rendered or not (the default).
  final bool renderHitboxes;

  /// Whether the hitboxes are filtered to include only disjoint ones.
  final bool filterHitboxes;

  /// The paint used to render the hitboxes.
  final Paint? hitboxesPaint;

  var _hitboxesAdded = false;
  late final _hitboxes = _hitboxesFor(path);

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    if (loadHitboxes) {
      _addHitboxes();
    }
  }

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawPath(path, paint);
        }
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawPath(path, debugPaint);
  }

  void _addHitboxes() {
    if (_hitboxesAdded) {
      return;
    }
    addAll(_filterHitboxes(_hitboxes));
    _hitboxesAdded = true;
  }

  List<PolygonHitbox> _filterHitboxes(List<PolygonHitbox> hitboxes) {
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

  List<PolygonHitbox> _hitboxesFor(Path path) {
    final count = path.contours.length;
    return [
      for (var contour = 0; contour < count; contour++)
        PolygonHitbox.fromPath(path, contour: contour)
          ..priority = priority + 1
          ..paint = hitboxesPaint ?? hitboxStroke
          ..renderShape = renderHitboxes,
    ];
  }
}
