part of 'component_data.dart';

/// {@template circle_component_data}
/// A circle with a position, an anchor, an angle, a radius and a paint.
/// {@endtemplate}
final class const CircleComponentData({
  required super.name,
  @override final ComponentPosition position = const ComponentPosition(),
  @override final ComponentAnchor anchor = ComponentAnchor.topLeft,
  @override final ComponentAngle angle = ComponentAngle.zero,
  @override final ComponentRadius radius = const ComponentRadius(),
  @override final ComponentPaint paint = const ComponentPaint(),
  super.children,
}) extends ComponentData
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        RadiusComponent,
        PaintedComponent {
  /// {@macro circle_component_data}
  this;

  /// Reads the properties of a [CircleComponentData] from its JSON
  /// representation. Use [ComponentData.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return CircleComponentData(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      radius: ComponentRadius.fromJson(json['radius']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.circle;

  @override
  CircleComponentData copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  CircleComponentData copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  CircleComponentData copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  CircleComponentData copyWithRadius(ComponentRadius radius) {
    return _copyWith(radius: radius);
  }

  @override
  CircleComponentData copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  CircleComponentData copyWithName(String name) => _copyWith(name: name);

  @override
  CircleComponentData copyWithChildren(List<ComponentData> children) {
    return _copyWith(children: children);
  }

  CircleComponentData _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentRadius? radius,
    ComponentPaint? paint,
    List<ComponentData>? children,
  }) {
    return CircleComponentData(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      radius: radius ?? this.radius,
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
    'radius': radius.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    radius,
    paint,
  ];
}
