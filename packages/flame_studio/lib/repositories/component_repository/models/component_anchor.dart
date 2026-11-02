import 'package:equatable/equatable.dart';

/// {@template component_anchor}
/// The anchor property shared by every position based component.
///
/// Mirrors Flame's `Anchor`: the point of the component, relative to its
/// size, that is placed at its position. `(0, 0)` is the top left corner
/// (Flame's default) and `(1, 1)` the bottom right one. Values outside of
/// that range are allowed, like in Flame.
/// {@endtemplate}
class const ComponentAnchor({
  /// The horizontal coordinate, relative to the width.
  final double x = 0,

  /// The vertical coordinate, relative to the height.
  final double y = 0,
}) extends Equatable {
  /// {@macro component_anchor}
  this;

  /// Creates a [ComponentAnchor] from its JSON representation.
  ///
  /// Missing or invalid values fall back to `0`, so components saved without
  /// an anchor are anchored at their top left corner.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    return ComponentAnchor(
      x: _readCoordinate(map['x']),
      y: _readCoordinate(map['y']),
    );
  }

  /// The top left corner, Flame's default anchor.
  static const topLeft = ComponentAnchor();

  /// The center of the top edge.
  static const topCenter = ComponentAnchor(x: 0.5);

  /// The top right corner.
  static const topRight = ComponentAnchor(x: 1);

  /// The center of the left edge.
  static const centerLeft = ComponentAnchor(y: 0.5);

  /// The center of the component.
  static const center = ComponentAnchor(x: 0.5, y: 0.5);

  /// The center of the right edge.
  static const centerRight = ComponentAnchor(x: 1, y: 0.5);

  /// The bottom left corner.
  static const bottomLeft = ComponentAnchor(y: 1);

  /// The center of the bottom edge.
  static const bottomCenter = ComponentAnchor(x: 0.5, y: 1);

  /// The bottom right corner.
  static const bottomRight = ComponentAnchor(x: 1, y: 1);

  /// Flame's named anchors by name, row by row from the top left corner.
  static const Map<String, ComponentAnchor> presets = {
    'topLeft': topLeft,
    'topCenter': topCenter,
    'topRight': topRight,
    'centerLeft': centerLeft,
    'center': center,
    'centerRight': centerRight,
    'bottomLeft': bottomLeft,
    'bottomCenter': bottomCenter,
    'bottomRight': bottomRight,
  };

  /// The name of the Flame anchor equal to this one (such as `center`), or
  /// `null` for a custom anchor.
  String? get presetName {
    for (final MapEntry(:key, :value) in presets.entries) {
      if (value == this) {
        return key;
      }
    }
    return null;
  }

  /// Returns a copy of this anchor with the given fields replaced.
  ComponentAnchor copyWith({double? x, double? y}) {
    return ComponentAnchor(x: x ?? this.x, y: y ?? this.y);
  }

  /// Converts this anchor to its JSON representation.
  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  static double _readCoordinate(Object? value) {
    return value is num ? value.toDouble() : 0;
  }

  @override
  List<Object> get props => [x, y];
}
