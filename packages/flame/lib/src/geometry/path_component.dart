import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';

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
       super(size: path.getBounds().size.toVector2());

  /// The path to display, already rooted at the origin.
  final Path path;

  /// The step used when sampling the path contours that generate
  /// the hitboxes.
  final double sampling;

  /// The tolerance used when sampling the path contours; if not specified,
  /// it defaults to half the [sampling].
  final double? tolerance;

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
}
