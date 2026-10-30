part of 'component.dart';

/// {@template sprite_component}
/// A sprite with a position, an anchor, an angle and a size.
///
/// The size is the one the sprite is drawn with, whatever the size of its
/// region of the image is.
/// {@endtemplate}
final class const SpriteComponent({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  @override final ComponentSprite sprite = const ComponentSprite(),
  super.children,
}) extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent,
        SpritedComponent {
  /// {@macro sprite_component}
  this;

  /// Reads the properties of a [SpriteComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return SpriteComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      size: ComponentSize.fromJson(json['size']),
      sprite: ComponentSprite.fromJson(json['sprite']),
    );
  }

  @override
  ComponentType get type => ComponentType.sprite;

  @override
  SpriteComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  SpriteComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  SpriteComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  SpriteComponent copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  SpriteComponent copyWithSprite(ComponentSprite sprite) {
    return _copyWith(sprite: sprite);
  }

  @override
  SpriteComponent copyWithName(String name) => _copyWith(name: name);

  @override
  SpriteComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  SpriteComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    ComponentSprite? sprite,
    List<Component>? children,
  }) {
    return SpriteComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      sprite: sprite ?? this.sprite,
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
    'sprite': sprite.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    size,
    sprite,
  ];
}
