import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';

class PathComponent extends ShapeComponent
    with CollisionCallbacks, CollisionPassthrough {
  PathComponent({
    required this.path,
    this.addHitboxes = false,
    this.loadHitboxes = true,
    this.hasHitboxes = true,
    this.renderHitboxes = false,
    this.filterHitboxes = true,
    this.hitboxesPaint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.paint,
    super.paintLayers,
  }) {
    if (addHitboxes) {
      _addHitboxes();
    }
  }

  final Path path;
  final bool hasHitboxes;
  final bool renderHitboxes;
  final bool filterHitboxes;
  final Paint? hitboxesPaint;

  List<PolygonHitbox> get hitboxes => _hitboxes;

  late bool addHitboxes;
  late bool loadHitboxes;

  var _hitboxesAdded = false;
  late final _hitboxes = _hitboxesFor(path);
  late final whiteStroke = BasicPalette.white.paint()..style = .stroke;

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
    addAll(_filterHitboxes(hitboxes));
    _hitboxesAdded = true;
  }

  List<PolygonHitbox> _filterHitboxes(List<PolygonHitbox> hitboxes) {
    if (hitboxes.length < 2) {
      return hitboxes;
    }
    // Sort the hitboxes by size in ascending order: we will use the largest
    // area in order to approximate full inclusion.
    hitboxes.sort((a, b) => (b.size.length2 - a.size.length2).toInt());
    final first = hitboxes.first;
    final area = Rect.fromCenter(
      center: Offset(first.x, first.y),
      width: first.width,
      height: first.height,
    );

    // We always keep the first hitbox (the largest one): the others
    // are discarded if they fit entirely within it.
    if (filterHitboxes) {
      hitboxes.removeWhere((element) {
        if (element == first) {
          return false;
        }
        final bounds = Rect.fromCenter(
          center: Offset(element.x, element.y),
          width: element.width,
          height: element.height,
        );
        return area.expandToInclude(bounds) == area;
      });
    }
    return hitboxes;
  }

  List<PolygonHitbox> _hitboxesFor(Path path) {
    final hitboxes = <PolygonHitbox>[];
    final contours = path.walkContours();
    for (final contour in contours) {
      final rectangle = contour.rectangle;
      hitboxes.add(
        PolygonHitbox(
            contour.vertices,
            anchor: .center,
            position: rectangle.center.toVector2(),
          )
          ..priority = priority + 1
          ..paint = hitboxesPaint ?? whiteStroke
          ..renderShape = renderHitboxes,
      );
    }
    return hitboxes;
  }
}
