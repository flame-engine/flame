import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// {@template component_vertex}
/// A vertex of a [ComponentVertices], in the local coordinates of its
/// component.
/// {@endtemplate}
class const ComponentVertex(
  /// The horizontal coordinate.
  final double x,

  /// The vertical coordinate.
  final double y,
) extends Equatable {
  /// {@macro component_vertex}
  this;

  /// Converts this vertex to its JSON representation.
  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  List<Object> get props => [x, y];
}

/// {@template component_vertices}
/// The vertices property shared by every polygon based component.
///
/// The vertices are in the local coordinates of the component, and the
/// component size is their bounding box. Like Flame, a polygon needs at
/// least [minLength] vertices.
/// {@endtemplate}
class const ComponentVertices([
  /// The vertices, in order.
  final List<ComponentVertex> vertices = defaultValue,
]) extends Equatable {
  /// {@macro component_vertices}
  this;

  /// Creates a [ComponentVertices] from its JSON representation.
  ///
  /// Missing or invalid values, or fewer than [minLength] valid vertices,
  /// fall back to [defaultValue].
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final list = map['vertices'];
    final vertices = [
      if (list is List)
        for (final Object? vertex in list)
          if (vertex case {'x': final num x, 'y': final num y})
            ComponentVertex(x.toDouble(), y.toDouble()),
    ];
    return ComponentVertices(
      vertices.length >= minLength ? vertices : defaultValue,
    );
  }

  /// The fewest vertices a polygon can have.
  static const minLength = 3;

  /// A triangle as big as a default rectangle.
  static const triangle = [
    ComponentVertex(25, 0),
    ComponentVertex(50, 50),
    ComponentVertex(0, 50),
  ];

  /// A square as big as a default rectangle.
  static const square = [
    ComponentVertex(0, 0),
    ComponentVertex(50, 0),
    ComponentVertex(50, 50),
    ComponentVertex(0, 50),
  ];

  /// The default [vertices], a [triangle].
  static const List<ComponentVertex> defaultValue = triangle;

  /// The width and height of the bounding box of the [vertices].
  ({double width, double height}) get bounds {
    final xs = vertices.map((vertex) => vertex.x);
    final ys = vertices.map((vertex) => vertex.y);
    return (
      width: xs.reduce(math.max) - xs.reduce(math.min),
      height: ys.reduce(math.max) - ys.reduce(math.min),
    );
  }

  /// Returns these vertices moved so that the top left corner of their
  /// bounding box is at the origin, like Flame places them.
  ComponentVertices normalized() {
    final left = vertices.map((vertex) => vertex.x).reduce(math.min);
    final top = vertices.map((vertex) => vertex.y).reduce(math.min);
    if (left == 0 && top == 0) {
      return this;
    }
    return ComponentVertices([
      for (final vertex in vertices)
        ComponentVertex(vertex.x - left, vertex.y - top),
    ]);
  }

  /// Converts these vertices to their JSON representation.
  Map<String, dynamic> toJson() => {
    'vertices': [for (final vertex in vertices) vertex.toJson()],
  };

  @override
  List<Object> get props => [vertices];
}
