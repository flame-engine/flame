part of 'component_data.dart';

/// {@template position_component_data}
/// A plain component with a position, an anchor and a size, that draws
/// nothing itself: a container for its children.
/// {@endtemplate}
final class const PositionComponentData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent {
  /// {@macro position_component_data}
  this;

  /// Reads the properties of a [PositionComponentData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PositionComponentData(
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
  PositionComponentData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PositionComponentData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PositionComponentData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PositionComponentData copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  PositionComponentData copyWithName(String name) => _copyWith(name: name);

  @override
  PositionComponentData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  PositionComponentData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    List<ComponentData>? children,
  }) {
    return PositionComponentData(
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
