part of 'component_data.dart';

/// {@template polygon_hitbox_data}
/// A polygonal hitbox with a position, an anchor, an angle, vertices and a
/// collision.
///
/// Its size is the bounding box of its vertices.
/// {@endtemplate}
final class const PolygonHitboxData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentVertices vertices = const ComponentVertices(),
  @override final ComponentCollision collision = const ComponentCollision(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        VerticesComponent,
        HitboxComponent {
  /// {@macro polygon_hitbox_data}
  this;

  /// Reads the properties of a [PolygonHitboxData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PolygonHitboxData(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      vertices: ComponentVertices.fromJson(json['vertices']),
      collision: ComponentCollision.fromJson(json['collision']),
    );
  }

  @override
  ComponentType get type => ComponentType.polygonHitbox;

  @override
  PolygonHitboxData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PolygonHitboxData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PolygonHitboxData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PolygonHitboxData copyWithVertices(ComponentVertices vertices) {
    return _copyWith(vertices: vertices);
  }

  @override
  PolygonHitboxData copyWithCollision(ComponentCollision collision) {
    return _copyWith(collision: collision);
  }

  @override
  PolygonHitboxData copyWithName(String name) => _copyWith(name: name);

  @override
  PolygonHitboxData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  PolygonHitboxData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentVertices? vertices,
    ComponentCollision? collision,
    List<ComponentData>? children,
  }) {
    return PolygonHitboxData(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      vertices: vertices ?? this.vertices,
      collision: collision ?? this.collision,
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
    'collision': collision.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    vertices,
    collision,
  ];
}
