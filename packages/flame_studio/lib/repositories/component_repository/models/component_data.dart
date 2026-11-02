import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'circle_component_data.dart';
part 'circle_hitbox_data.dart';
part 'polygon_component_data.dart';
part 'polygon_hitbox_data.dart';
part 'position_component_data.dart';
part 'rectangle_component_data.dart';
part 'rectangle_hitbox_data.dart';
part 'sprite_component_data.dart';

/// {@template component_data}
/// A Flame component definition that belongs to a project.
///
/// Each subclass is one [ComponentType]. The properties a component has are
/// declared through capability interfaces such as [SizedComponent] and
/// [PaintedComponent], so that editors can be shared between types.
///
/// Like in Flame, a component can have [children]; see [ComponentTree] to
/// navigate and edit them.
/// {@endtemplate}
sealed class const ComponentData({
  /// The component name.
  ///
  /// The root component name is used as its class name.
  required final String name,

  /// The components added to this one.
  final List<ComponentData> children = const [],
}) extends Equatable {
  /// {@macro component_data}
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
      ComponentType.rectangle => RectangleComponentData(name: name),
      ComponentType.position => PositionComponentData(name: name),
      ComponentType.circle => CircleComponentData(name: name),
      ComponentType.polygon => PolygonComponentData(
        name: name,
        vertices: ComponentVertices(polygonShape.vertices),
      ),
      ComponentType.sprite => SpriteComponentData(name: name),
      ComponentType.rectangleHitbox => RectangleHitboxData(name: name),
      ComponentType.circleHitbox => CircleHitboxData(name: name),
      ComponentType.polygonHitbox => PolygonHitboxData(
        name: name,
        vertices: ComponentVertices(polygonShape.vertices),
      ),
    };
  }

  /// Creates a [ComponentData] from its JSON representation.
  ///
  /// Components saved without a type are read as rectangles. The children
  /// are read here, for every type, so subtypes only read their own
  /// properties.
  factory fromJson(Map<String, dynamic> json) {
    final type = ComponentType.fromKey(json['type']) ?? ComponentType.rectangle;
    final component = switch (type) {
      ComponentType.rectangle => RectangleComponentData._fromJson(json),
      ComponentType.position => PositionComponentData._fromJson(json),
      ComponentType.circle => CircleComponentData._fromJson(json),
      ComponentType.polygon => PolygonComponentData._fromJson(json),
      ComponentType.sprite => SpriteComponentData._fromJson(json),
      ComponentType.rectangleHitbox => RectangleHitboxData._fromJson(json),
      ComponentType.circleHitbox => CircleHitboxData._fromJson(json),
      ComponentType.polygonHitbox => PolygonHitboxData._fromJson(json),
    };
    return component.copyWithChildren(_childrenFromJson(json['children']));
  }

  static List<ComponentData> _childrenFromJson(Object? json) {
    return [
      if (json is List)
        for (final child in json)
          if (child is Map<String, dynamic>) ComponentData.fromJson(child),
    ];
  }

  /// The type of this component.
  ComponentType get type;

  /// Returns a copy of this component called [name].
  ComponentData copyWithName(String name);

  /// Returns a copy of this component with [children] replaced.
  ComponentData copyWithChildren(List<ComponentData> children);

  /// Converts this component to its JSON representation.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.key,
    'children': [for (final child in children) child.toJson()],
  };

  @override
  List<Object> get props => [name, type, children];
}
