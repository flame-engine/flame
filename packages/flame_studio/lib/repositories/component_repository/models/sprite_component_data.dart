part of 'component_data.dart';

/// {@template sprite_component_data}
/// A sprite with a position, an anchor, an angle and a size.
///
/// The size is the one the sprite is drawn with, whatever the size of its
/// region of the image is.
/// {@endtemplate}
final class const SpriteComponentData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  @override final ComponentSprite sprite = const ComponentSprite(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent,
        SpriteBackedComponent {
  /// {@macro sprite_component_data}
  this;

  /// Reads the properties of a [SpriteComponentData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return SpriteComponentData(
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
  SpriteComponentData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  SpriteComponentData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  SpriteComponentData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  SpriteComponentData copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  SpriteComponentData copyWithSprite(ComponentSprite sprite) {
    return _copyWith(sprite: sprite);
  }

  @override
  SpriteComponentData copyWithName(String name) => _copyWith(name: name);

  @override
  SpriteComponentData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  SpriteComponentData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    ComponentSprite? sprite,
    List<ComponentData>? children,
  }) {
    return SpriteComponentData(
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
