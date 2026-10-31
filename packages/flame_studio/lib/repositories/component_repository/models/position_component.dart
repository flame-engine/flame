part of 'component.dart';

/// {@template position_component}
/// A plain component with a position, an anchor and a size, that draws
/// nothing itself: a container for its children.
/// {@endtemplate}
final class const PositionComponent({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  super.children,
}) extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent {
  /// {@macro position_component}
  this;

  /// Reads the properties of a [PositionComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PositionComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      size: ComponentSize.fromJson(json['size']),
    );
  }

  @override
  ComponentType get type => ComponentType.position;

  @override
  PositionComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PositionComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PositionComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PositionComponent copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  PositionComponent copyWithName(String name) => _copyWith(name: name);

  @override
  PositionComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  PositionComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    List<Component>? children,
  }) {
    return PositionComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      size: size ?? this.size,
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
  };

  @override
  List<Object> get props => [...super.props, position, anchor, angle, size];
}
