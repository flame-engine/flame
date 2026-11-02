part of 'component_data.dart';

/// {@template polygon_component_data}
/// A polygon with a position, an anchor, an angle, vertices and a paint.
///
/// Its size is the bounding box of its vertices.
/// {@endtemplate}
final class const PolygonComponentData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentVertices vertices = const ComponentVertices(),
  @override final ComponentPaint paint = const ComponentPaint(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        VerticesComponent,
        PaintedComponent {
  /// {@macro polygon_component_data}
  this;

  /// Reads the properties of a [PolygonComponentData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PolygonComponentData(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      vertices: ComponentVertices.fromJson(json['vertices']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.polygon;

  @override
  PolygonComponentData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PolygonComponentData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PolygonComponentData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PolygonComponentData copyWithVertices(ComponentVertices vertices) {
    return _copyWith(vertices: vertices);
  }

  @override
  PolygonComponentData copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  PolygonComponentData copyWithName(String name) => _copyWith(name: name);

  @override
  PolygonComponentData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  PolygonComponentData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentVertices? vertices,
    ComponentPaint? paint,
    List<ComponentData>? children,
  }) {
    return PolygonComponentData(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      vertices: vertices ?? this.vertices,
      paint: paint ?? this.paint,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'position': position.toJson(),
    'anchor': anchor.toJson(),
    'angle': angle.toJson(),
    'vertices': vertices.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    vertices,
    paint,
  ];
}
