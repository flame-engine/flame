import 'dart:math' show max;
import 'dart:ui' show Paint, PaintingStyle;

import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_svg/svg_paths.dart';
import 'package:flame_svg/vector_path.dart';

/// A [PathHitbox] that treats its polygons as a union of solid shapes for
/// rays.
///
/// [PathHitbox] decides what a ray hits from the polygon with the closest
/// edge, which is right for the polygons of a single shape, but not for
/// polygons that overlap or lie inside of each other, as the paths of an SVG
/// file often do: the closest edge may belong to a polygon that does not
/// contain the origin of the ray, even though another one does.
///
/// This hitbox instead considers a ray inside of the hitbox when it starts
/// inside of any of its polygons, and reports the first point where the ray
/// enters the union of the polygons, or leaves it when it starts inside. The
/// edges between polygons that are inside of the union are ignored. Like in
/// [PathHitbox], polygons are solid, so the holes in them count as inside.
///
/// Collisions still come from the edges of all the polygons, like with
/// [PathHitbox], also those inside of the union.
class SvgPathsHitbox({
  required super.path,
  super.sampling,
  super.tolerance,
  super.filter,
  super.position,
  super.angle,
  super.anchor,
  super.isSolid,
  super.collisionType,
}) extends PathHitbox {
  /// With this constructor you create a [SvgPathsHitbox] from all the closed
  /// contours of the [path]. See [PathHitbox.new] for the parameters.
  this;

  /// Creates a hitbox for all the paths of the [svg], see
  /// [VectorPath.hitboxPath], which fits the [area] of the [svg], by default
  /// its bounds, within the [size] of its parent, by default the size of that
  /// area, see [SvgPaths.fit]. When the size of the parent changes, [place]
  /// fits the hitbox within the new size.
  ///
  /// The [sampling] and [tolerance] of the polygons, see [PathComponent.new],
  /// are in the units of the [size], and not in those of the SVG file. With
  /// [renderHitboxes], the polygons are outlined in white.
  factory SvgPathsHitbox.fromSvg(
    SvgPaths svg,
    Vector2? size, {
    Rect? area,
    bool? renderHitboxes,
    bool? filter,
    double sampling = 1.0,
    double? tolerance,
  }) {
    final full = area ?? svg.bounds;
    final fit = svg.fit(size ?? full.size.toVector2(), area: full).scale;
    // A parent without an area shrinks the paths to nothing, so their
    // polygons are only sampled in the units of the SVG file.
    final units = fit > 0 ? fit : 1;
    final combined = Path();
    for (var svgIndex = 0; svgIndex < svg.length; ++svgIndex) {
      combined.addPath(svg.pathAt(svgIndex).hitboxPath, Offset.zero);
    }
    final hitbox = SvgPathsHitbox(
      path: combined,
      sampling: sampling / units,
      tolerance: tolerance == null ? null : tolerance / units,
      filter: filter ?? true,
    );
    hitbox
      .._svg = svg
      .._area = full
      ..place(size ?? full.size.toVector2());
    if (renderHitboxes ?? false) {
      hitbox
        ..renderShape = true
        ..paint = (Paint()
          ..color = const Color(0xffffffff)
          ..style = PaintingStyle.stroke);
    }
    return hitbox;
  }

  /// The SVG file and its area that the hitbox was created for, see
  /// [SvgPathsHitbox.fromSvg].
  SvgPaths? _svg;
  Rect? _area;

  /// Fits the hitbox within the given [size] of its parent, like
  /// [SvgPathsHitbox.fromSvg] does, which it must have been created with.
  ///
  /// The polygons are not made again, so they keep the sampling and the
  /// tolerance of the size that they were made for.
  void place(Vector2 size) {
    final svg = _svg;
    final area = _area;
    assert(
      svg != null && area != null,
      'Only a hitbox from SvgPathsHitbox.fromSvg can be placed',
    );
    if (svg == null || area == null) {
      return;
    }
    final (area: _, scale: fit, :offset) = svg.fit(size, area: area);
    // Closing the contours of the paths for the hitbox keeps their bounds.
    position = (svg.bounds.topLeft - area.topLeft).toVector2() * fit + offset;
    scale.setValues(fit, fit);
  }

  final _normal = Vector2.zero();
  final _crossings = <_Crossing>[];

  /// Whether the origin of the ray is inside of each of the polygons.
  late final _inside = List<bool>.filled(globalPolygons().length, false);

  /// Returns information about where the ray enters the union of the polygons
  /// of the hitbox, or leaves it if the origin of the ray is inside of it.
  ///
  /// If you are only interested in the intersection point use
  /// [RaycastResult.intersectionPoint] of the result.
  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    // A ray that misses the bounding box can not touch any polygon, and this
    // is much cheaper than walking all of their edges.
    if (!ray.intersectsWithAabb2(aabb)) {
      out?.reset();
      return null;
    }
    final polygons = globalPolygons();
    final originX = ray.origin.x;
    final originY = ray.origin.y;
    final directionX = ray.direction.x;
    final directionY = ray.direction.y;
    // Skips the crossings at the origin of the ray, scaled to its magnitude,
    // see PolygonRayIntersection.
    final scale = max(1.0, max(originX.abs(), originY.abs()));
    final epsilon = scale * 1e-4;

    // Collect the crossings of the ray with all of the polygons, using the
    // same rule as PolygonRayIntersection: an edge crosses the line of the ray
    // when its vertices are on opposite sides of it, with a vertex on the
    // line assigned to one side. The parity of the crossings of a polygon
    // tells whether the origin is inside of it.
    _crossings.clear();
    var insideCount = 0;
    for (var index = 0; index < polygons.length; index++) {
      final vertices = polygons[index];
      var from = vertices[vertices.length - 1];
      var fromSide =
          directionX * (from.y - originY) - directionY * (from.x - originX);
      var inside = false;
      for (var i = 0; i < vertices.length; i++) {
        final to = vertices[i];
        final toSide =
            directionX * (to.y - originY) - directionY * (to.x - originX);
        if ((fromSide > 0 && toSide <= 0) || (fromSide <= 0 && toSide > 0)) {
          final edgeX = to.x - from.x;
          final edgeY = to.y - from.y;
          final distance =
              (edgeX * (originY - from.y) - edgeY * (originX - from.x)) /
              (edgeY * directionX - edgeX * directionY);
          if (distance > epsilon) {
            _crossings.add(_Crossing(distance, index, from, to));
            inside = !inside;
          }
        }
        from = to;
        fromSide = toSide;
      }
      _inside[index] = inside;
      if (inside) {
        insideCount++;
      }
    }

    // Walk along the ray, keeping track of how many polygons the ray is
    // inside of. Crossings at the same distance, like the shared edges of
    // adjacent polygons or the vertices that the ray touches, are taken
    // together, within the rounding of the float32 paths that the polygons
    // come from, so that real gaps and thin parts are not skipped. The ray
    // hits the union where that count changes between zero and more than
    // zero.
    _crossings.sort((a, b) => a.distance.compareTo(b.distance));
    final startsInside = insideCount > 0;
    var count = insideCount;
    var i = 0;
    while (i < _crossings.length) {
      final distance = _crossings[i].distance;
      final coincident = (scale + distance) * 1e-6;
      final wasInside = count > 0;
      _Crossing? leaving;
      _Crossing? entering;
      while (i < _crossings.length) {
        final crossing = _crossings[i];
        if (crossing.distance - distance > coincident) {
          break;
        }
        if (_inside[crossing.polygon]) {
          leaving ??= crossing;
          count--;
        } else {
          entering ??= crossing;
          count++;
        }
        _inside[crossing.polygon] = !_inside[crossing.polygon];
        i++;
      }
      final isInside = count > 0;
      if (wasInside != isInside) {
        return _result(
          ray,
          isInside ? entering! : leaving!,
          isInsideHitbox: startsInside,
          out: out,
        );
      }
    }
    out?.reset();
    return null;
  }

  RaycastResult<ShapeHitbox> _result(
    Ray2 ray,
    _Crossing crossing, {
    required bool isInsideHitbox,
    RaycastResult<ShapeHitbox>? out,
  }) {
    final intersectionPoint = ray.point(
      crossing.distance,
      out: out?.intersectionPoint,
    );
    // This is "from" to "to" since it is defined ccw in the canvas
    // coordinate system.
    _normal
      ..setFrom(crossing.from)
      ..sub(crossing.to);
    _normal
      ..setValues(_normal.y, -_normal.x)
      ..normalize();
    if (isInsideHitbox) {
      _normal.invert();
    }
    final reflectionDirection =
        (out?.reflectionRay?.direction ?? Vector2.zero())
          ..setFrom(ray.direction)
          ..reflect(_normal)
          // Reflect() can introduce sub-epsilon drift.
          ..normalize();
    final reflectionRay =
        (out?.reflectionRay?..setWith(
          origin: intersectionPoint,
          direction: reflectionDirection,
        )) ??
        Ray2(origin: intersectionPoint, direction: reflectionDirection);
    return (out ?? RaycastResult<ShapeHitbox>())..setWith(
      hitbox: this,
      reflectionRay: reflectionRay,
      normal: _normal,
      distance: crossing.distance,
      isInsideHitbox: isInsideHitbox,
    );
  }
}

/// The crossing of a ray with an edge of a polygon.
class _Crossing(this.distance, this.polygon, this.from, this.to) {
  final double distance;
  final int polygon;
  final Vector2 from;
  final Vector2 to;
}
