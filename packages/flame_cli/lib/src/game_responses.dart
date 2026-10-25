import 'dart:convert';
import 'dart:typed_data';

/// A two dimensional vector, such as a position, a size or a scale.
typedef Vector2 = ({double x, double y});

/// A rectangle in world coordinates, with its top left corner at `x` and `y`.
typedef WorldRect = ({double x, double y, double width, double height});

/// A rectangle in the pixel coordinates of an image, with its top left corner
/// at `x` and `y`.
typedef PixelRect = ({double x, double y, double width, double height});

/// A component that the game is asked about, either by its [ComponentId] or
/// by the [ComponentKeyName] of its `ComponentKey`.
sealed class const ComponentReference() {
  /// A reference from a command line value, where a number is an id and any
  /// other value the name of a `ComponentKey`.
  factory ComponentReference.parse(String value) {
    final id = int.tryParse(value);
    return id == null ? ComponentKeyName(value) : ComponentId(id);
  }

  /// The arguments that identify the component in a service extension call.
  Map<String, String> get args;

  /// The reference in the JSON output of a command.
  Object toJson();
}

/// A component given by its id, as the tree command prints it.
class const ComponentId(final int id) extends ComponentReference {
  @override
  Map<String, String> get args => {'id': '$id'};

  @override
  Object toJson() => id;

  @override
  String toString() => '$id';
}

/// A component given by the name of its `ComponentKey`.
class const ComponentKeyName(final String name) extends ComponentReference {
  @override
  Map<String, String> get args => {'key': name};

  @override
  Object toJson() => name;

  @override
  String toString() => name;
}

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
  final Uint8List bytes, {

  /// The pixel ratio that the image was rendered with, which is lower than
  /// the requested one when it was scaled down to fit a maximum size. It is
  /// null when the game does not report it.
  final double? pixelRatio,

  /// The width of the image in pixels, when the game reports it.
  final int? width,

  /// The height of the image in pixels, when the game reports it.
  final int? height,

  /// The components that were annotated on the image, or null when the
  /// image was not annotated or the game does not support annotations.
  final List<SnapshotAnnotation>? annotations,
}) {
  factory Snapshot.fromJson(Map<String, dynamic> json) {
    final annotations = json['annotations'] as List?;
    return Snapshot(
      base64Decode(json['snapshot'] as String? ?? ''),
      pixelRatio: (json['pixelRatio'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      annotations: annotations == null
          ? null
          : [
              for (final annotation in annotations)
                SnapshotAnnotation.fromJson(
                  annotation as Map<String, dynamic>,
                ),
            ],
    );
  }
}

/// How a snapshot is annotated and how large it may be.
class const SnapshotOptions({
  /// Whether the visible position components are annotated on the image.
  final bool annotate = false,

  /// Only the components whose type matches this regular expression are
  /// annotated, when it is given.
  final String? annotationFilter,

  /// The maximum length in pixels of the longest side of the image.
  final int? maxSize,
}) {
  /// The arguments of the snapshot service extensions for these options.
  Map<String, String> get args {
    return {
      if (annotate) 'annotate': 'true',
      'annotationFilter': ?annotationFilter,
      if (maxSize case final maxSize?) 'maxSize': '$maxSize',
    };
  }
}

/// A component that was annotated on a snapshot, with its [box] in the pixel
/// coordinates of the image.
class const SnapshotAnnotation({
  required final int id,
  required final String name,
  required final PixelRect box,
}) {
  factory SnapshotAnnotation.fromJson(Map<String, dynamic> json) {
    final box = (json['box'] as List).cast<num>();
    return SnapshotAnnotation(
      id: json['id'] as int,
      name: json['name'] as String,
      box: (
        x: box[0].toDouble(),
        y: box[1].toDouble(),
        width: box[2].toDouble(),
        height: box[3].toDouble(),
      ),
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'box': [box.x, box.y, box.width, box.height],
    };
  }
}

Vector2? _vectorFromJson(Object? json) {
  if (json is! List || json.length != 2) {
    return null;
  }
  return (x: (json[0] as num).toDouble(), y: (json[1] as num).toDouble());
}

List<double> _vectorToJson(Vector2 vector) => [vector.x, vector.y];
