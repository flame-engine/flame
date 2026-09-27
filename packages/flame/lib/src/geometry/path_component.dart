import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// Renders a [Path].
///
/// The path is moved so that its bounds start at the origin of the component,
/// which gets the size of those bounds, so that the anchor and the transform
/// of the component apply to the path like to any other shape.
class PathComponent extends ShapeComponent {
  PathComponent({
    required Path path,
    this.sampling = 1.0,
    this.tolerance,
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
  }) : path = path.toOrigin,
       super(size: path.getBounds().size.toVector2()) {
    // TODO(adario): convenience
    addPolygons();
  }

  /// The path to display, already rooted at the origin.
  final Path path;

  /// The step used when sampling the path contours that generate
  /// the polygon components.
  final double sampling;

  /// The tolerance used when sampling the path contours; if not specified,
  /// it defaults to half the [sampling].
  final double? tolerance;

  /// The actual contours for this path.
  late final contours = path.walkContours(sampling, tolerance);

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

  /// Add all the polygon components and return them.
  List<PolygonComponent> addPolygons() {
    final polygons = createPolygons(this, sampling, tolerance);
    addAll(preparePolygons(polygons));
    return polygons;
  }

  /// Create a polygon for each path contour with at least three vertices.
  @internal
  static List<PolygonComponent> createPolygons(
    PathComponent path,
    double sampling,
    double? tolerance,
  ) {
    final contours = path.contours;
    final polygons = <PolygonComponent>[];
    for (var index = 0; index < contours.length; index++) {
      final contour = contours[index];
      if (contour.length > 2) {
        polygons.add(PolygonComponent(contour.vertices)..renderShape = false);
      }
    }
    return polygons;
  }

  /// Prepare the polygons by first sorting them by size; then, (potentially)
  /// filter them by keeping only the largest and all disjoint ones.
  @internal
  static List<PolygonComponent> preparePolygons(
    List<PolygonComponent> polygons, {
    bool filterPolygons = true,
  }) {
    if (polygons.length < 2) {
      return polygons;
    }
    // Sort the polygons by size: we will use the largest area in order to
    // approximate full inclusion.
    polygons.sortBy((hitbox) => hitbox.size.length2);
    final largest = polygons.last;
    final area = largest.toRect();

    // We always keep the largest hitbox: the others are discarded if they fit
    // entirely within it.
    if (filterPolygons) {
      polygons.removeWhere((element) {
        if (element == largest) {
          return false;
        }
        return area.expandToInclude(element.toRect()) == area;
      });
    }
    return polygons;
  }
}
