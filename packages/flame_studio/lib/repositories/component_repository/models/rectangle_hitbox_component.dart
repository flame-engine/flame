part of 'component.dart';

/// {@template rectangle_hitbox_component}
/// A rectangular hitbox with a position, an anchor, an angle, a size and a
/// collision.
/// {@endtemplate}
final class const RectangleHitboxComponent({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  @override final ComponentCollision collision = const ComponentCollision(),
  super.children,
}) extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent,
        HitboxComponent {
  /// {@macro rectangle_hitbox_component}
  this;

  /// Reads the properties of a [RectangleHitboxComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return RectangleHitboxComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      size: ComponentSize.fromJson(json['size']),
      collision: ComponentCollision.fromJson(json['collision']),
    );
  }

  @override
  ComponentType get type => ComponentType.rectangleHitbox;

  @override
  RectangleHitboxComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  RectangleHitboxComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  RectangleHitboxComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  RectangleHitboxComponent copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  RectangleHitboxComponent copyWithCollision(ComponentCollision collision) {
    return _copyWith(collision: collision);
  }

  @override
  RectangleHitboxComponent copyWithName(String name) => _copyWith(name: name);

  @override
  RectangleHitboxComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  RectangleHitboxComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    ComponentCollision? collision,
    List<Component>? children,
  }) {
    return RectangleHitboxComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      size: size ?? this.size,
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
    'size': size.toJson(),
    'collision': collision.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    size,
    collision,
  ];
}
