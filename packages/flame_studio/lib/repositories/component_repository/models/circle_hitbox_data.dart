part of 'component_data.dart';

/// {@template circle_hitbox_data}
/// A round hitbox with a position, an anchor, an angle, a radius and a
/// collision.
/// {@endtemplate}
final class const CircleHitboxData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentRadius radius = const ComponentRadius(),
  @override final ComponentCollision collision = const ComponentCollision(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        RadiusComponent,
        HitboxComponent {
  /// {@macro circle_hitbox_data}
  this;

  /// Reads the properties of a [CircleHitboxData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return CircleHitboxData(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      radius: ComponentRadius.fromJson(json['radius']),
      collision: ComponentCollision.fromJson(json['collision']),
    );
  }

  @override
  ComponentType get type => ComponentType.circleHitbox;

  @override
  CircleHitboxData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  CircleHitboxData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  CircleHitboxData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  CircleHitboxData copyWithRadius(ComponentRadius radius) {
    return _copyWith(radius: radius);
  }

  @override
  CircleHitboxData copyWithCollision(ComponentCollision collision) {
    return _copyWith(collision: collision);
  }

  @override
  CircleHitboxData copyWithName(String name) => _copyWith(name: name);

  @override
  CircleHitboxData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  CircleHitboxData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentRadius? radius,
    ComponentCollision? collision,
    List<ComponentData>? children,
  }) {
    return CircleHitboxData(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      radius: radius ?? this.radius,
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
    'radius': radius.toJson(),
    'collision': collision.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    radius,
    collision,
  ];
}
