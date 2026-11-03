import 'package:flame_studio/repositories/repositories.dart';

/// The shapes a new polygon can start with.
enum PolygonShape({
  /// Human readable name.
  required final String label,

  /// The vertices of the shape.
  required final List<ComponentVertex> vertices,
}) {
  /// Three vertices, see [ComponentVertices.triangle].
  triangle(label: 'Triangle', vertices: ComponentVertices.triangle),

  /// Four vertices, see [ComponentVertices.square].
  square(label: 'Square', vertices: ComponentVertices.square),
}
