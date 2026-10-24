import 'dart:convert';
import 'dart:typed_data';

/// A two dimensional vector, such as a position, a size or a scale.
typedef Vector2 = ({double x, double y});

/// A rectangle in world coordinates, with its top left corner at `x` and `y`.
typedef WorldRect = ({double x, double y, double width, double height});

/// What a key event that is sent to the game does with the key.
enum KeyAction() {
  /// Presses the key down and releases it again.
  press,

  /// Only presses the key down.
  down,

  /// Only releases the key.
  up,
}

/// The attributes that the game reports for a component.
///
/// Every component has a [priority], and a `PositionComponent` additionally
/// has its [position], [size], [angle], [scale] and [anchor].
class const ComponentAttributes({
  final int? priority,
  final Vector2? position,
  final Vector2? size,
  final double? angle,
  final Vector2? scale,
  final String? anchor,
}) {
  factory ComponentAttributes.fromJson(Map<String, dynamic> json) {
    return ComponentAttributes(
      priority: (json['priority'] as num?)?.toInt(),
      position: _vectorFromJson(json['position']),
      size: _vectorFromJson(json['size']),
      angle: (json['angle'] as num?)?.toDouble(),
      scale: _vectorFromJson(json['scale']),
      anchor: json['anchor'] as String?,
    );
  }

  Map<String, Object> toJson() {
    return {
      'priority': ?priority,
      if (position case final position?) 'position': _vectorToJson(position),
      if (size case final size?) 'size': _vectorToJson(size),
      'angle': ?angle,
      if (scale case final scale?) 'scale': _vectorToJson(scale),
      'anchor': ?anchor,
    };
  }
}

/// A component in the tree that the `getComponentTree` service extension
/// returns, together with its [children].
class const ComponentNode({
  required final int id,
  required final String name,
  required final String toStringText,
  required final bool isPositionComponent,
  final ComponentAttributes attributes = const ComponentAttributes(),
  final List<ComponentNode> children = const [],
}) {
  factory ComponentNode.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    return ComponentNode(
      id: json['id'] as int,
      name: json['name'] as String,
      toStringText: json['toString'] as String? ?? '',
      isPositionComponent: json['isPositionComponent'] as bool? ?? false,
      attributes: attributes == null
          ? const ComponentAttributes()
          : ComponentAttributes.fromJson(attributes),
      children: [
        for (final child in json['children'] as List? ?? const [])
          ComponentNode.fromJson(child as Map<String, dynamic>),
      ],
    );
  }

  /// A copy of this node with other [children].
  ComponentNode withChildren(List<ComponentNode> children) {
    return ComponentNode(
      id: id,
      name: name,
      toStringText: toStringText,
      isPositionComponent: isPositionComponent,
      attributes: attributes,
      children: children,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'toString': toStringText,
      'isPositionComponent': isPositionComponent,
      'attributes': attributes.toJson(),
      'children': [for (final child in children) child.toJson()],
    };
  }
}

/// The details of a single component that the `getComponentInfo` service
/// extension returns.
class const ComponentInfo({
  required final int id,
  required final String name,
  required final String toStringText,
  required final int? parent,
  required final int childCount,
  required final bool debugMode,
  final ComponentAttributes attributes = const ComponentAttributes(),
}) {
  factory ComponentInfo.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    return ComponentInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      toStringText: json['toString'] as String? ?? '',
      parent: json['parent'] as int?,
      childCount: json['childCount'] as int? ?? 0,
      debugMode: json['debugMode'] as bool? ?? false,
      attributes: attributes == null
          ? const ComponentAttributes()
          : ComponentAttributes.fromJson(attributes),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'toString': toStringText,
      'parent': parent,
      'childCount': childCount,
      'debugMode': debugMode,
      'attributes': attributes.toJson(),
    };
  }
}

/// The overlays that are registered in the game, and the [active] ones that
/// are shown.
class const Overlays({
  required final List<String> registered,
  required final List<String> active,
}) {
  factory Overlays.fromJson(Map<String, dynamic> json) {
    return Overlays(
      registered: (json['overlays'] as List? ?? const []).cast<String>(),
      active: (json['active'] as List? ?? const []).cast<String>(),
    );
  }

  Map<String, Object> toJson() => {'overlays': registered, 'active': active};
}

/// A PNG image that the snapshot service extensions rendered.
class const Snapshot(
  /// The encoded PNG image.
  final Uint8List bytes,
) {
  factory Snapshot.fromJson(Map<String, dynamic> json) {
    return Snapshot(base64Decode(json['snapshot'] as String? ?? ''));
  }
}

Vector2? _vectorFromJson(Object? json) {
  if (json is! List || json.length != 2) {
    return null;
  }
  return (x: (json[0] as num).toDouble(), y: (json[1] as num).toDouble());
}

List<double> _vectorToJson(Vector2 vector) => [vector.x, vector.y];
