part of 'component.dart';

/// {@template polygon_hitbox_component}
/// A polygonal hitbox with a position, an anchor, an angle, vertices and a
/// collision.
///
/// Its size is the bounding box of its vertices.
/// {@endtemplate}
final class const PolygonHitboxComponent({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentVertices vertices = const ComponentVertices(),
  @override final ComponentCollision collision = const ComponentCollision(),
  super.children,
}) extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        VerticesComponent,
        HitboxComponent {
  /// {@macro polygon_hitbox_component}
  this;

  /// Reads the properties of a [PolygonHitboxComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PolygonHitboxComponent(
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
  PolygonHitboxComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PolygonHitboxComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PolygonHitboxComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PolygonHitboxComponent copyWithVertices(ComponentVertices vertices) {
    return _copyWith(vertices: vertices);
  }

  @override
  PolygonHitboxComponent copyWithCollision(ComponentCollision collision) {
    return _copyWith(collision: collision);
  }

  @override
  PolygonHitboxComponent copyWithName(String name) => _copyWith(name: name);

  @override
  PolygonHitboxComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  PolygonHitboxComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentVertices? vertices,
    ComponentCollision? collision,
    List<Component>? children,
  }) {
    return PolygonHitboxComponent(
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
