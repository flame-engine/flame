import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'circle_component.dart';
part 'circle_hitbox_component.dart';
part 'polygon_component.dart';
part 'polygon_hitbox_component.dart';
part 'position_component.dart';
part 'rectangle_component.dart';
part 'rectangle_hitbox_component.dart';

/// {@template component}
/// A Flame component definition that belongs to a project.
///
/// Each subclass is one [ComponentType]. The properties a component has are
/// declared through capability interfaces such as [SizedComponent] and
/// [PaintedComponent], so that editors can be shared between types.
///
/// Like in Flame, a component can have [children]; see [ComponentTree] to
/// navigate and edit them.
/// {@endtemplate}
sealed class const Component({
  /// The component name.
  ///
  /// The root component name is used as its class name.
  required final String name,

  /// The components added to this one.
  final List<Component> children = const [],
}) extends Equatable {
  /// {@macro component}
  this;

  /// Creates a component of [type] called [name] with default properties.
  ///
  /// Polygons and polygon hitboxes start with the vertices of
  /// [polygonShape].
  factory create(
    String name,
    ComponentType type, {
    PolygonShape polygonShape = PolygonShape.triangle,
  }) {
    return switch (type) {
      ComponentType.rectangle => RectangleComponent(name: name),
      ComponentType.position => PositionComponent(name: name),
      ComponentType.circle => CircleComponent(name: name),
      ComponentType.polygon => PolygonComponent(
        name: name,
        vertices: ComponentVertices(polygonShape.vertices),
      ),
      ComponentType.rectangleHitbox => RectangleHitboxComponent(name: name),
      ComponentType.circleHitbox => CircleHitboxComponent(name: name),
      ComponentType.polygonHitbox => PolygonHitboxComponent(
        name: name,
        vertices: ComponentVertices(polygonShape.vertices),
      ),
    };
  }

  /// Creates a [Component] from its JSON representation.
  ///
  /// Components saved without a type are read as rectangles. The children
  /// are read here, for every type, so subtypes only read their own
  /// properties.
  factory fromJson(Map<String, dynamic> json) {
    final type = ComponentType.fromKey(json['type']) ?? ComponentType.rectangle;
    final component = switch (type) {
      ComponentType.rectangle => RectangleComponent._fromJson(json),
      ComponentType.position => PositionComponent._fromJson(json),
      ComponentType.circle => CircleComponent._fromJson(json),
      ComponentType.polygon => PolygonComponent._fromJson(json),
      ComponentType.rectangleHitbox => RectangleHitboxComponent._fromJson(json),
      ComponentType.circleHitbox => CircleHitboxComponent._fromJson(json),
      ComponentType.polygonHitbox => PolygonHitboxComponent._fromJson(json),
    };
    return component.copyWithChildren(_childrenFromJson(json['children']));
  }

  static List<Component> _childrenFromJson(Object? json) {
    return [
      if (json is List)
        for (final child in json)
          if (child is Map<String, dynamic>) Component.fromJson(child),
    ];
  }

  /// The type of this component.
  ComponentType get type;

  /// Returns a copy of this component called [name].
  Component copyWithName(String name);

  /// Returns a copy of this component with [children] replaced.
  Component copyWithChildren(List<Component> children);

  /// Converts this component to its JSON representation.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.key,
    'children': [for (final child in children) child.toJson()],
  };

  @override
  List<Object> get props => [name, type, children];
}
