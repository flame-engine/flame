part of 'component_data.dart';

/// {@template rectangle_component_data}
/// A rectangle with a position, an anchor, an angle, a size and a paint.
/// {@endtemplate}
final class const RectangleComponentData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentSize size = const ComponentSize(),
  @override final ComponentPaint paint = const ComponentPaint(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        SizedComponent,
        PaintedComponent {
  /// {@macro rectangle_component_data}
  this;

  /// Reads the properties of a [RectangleComponentData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return RectangleComponentData(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      size: ComponentSize.fromJson(json['size']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.rectangle;

  @override
  RectangleComponentData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  RectangleComponentData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  RectangleComponentData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  RectangleComponentData copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  RectangleComponentData copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  RectangleComponentData copyWithName(String name) => _copyWith(name: name);

  @override
  RectangleComponentData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  RectangleComponentData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentSize? size,
    ComponentPaint? paint,
    List<ComponentData>? children,
  }) {
    return RectangleComponentData(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      size: size ?? this.size,
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
    'size': size.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    size,
    paint,
  ];
}
