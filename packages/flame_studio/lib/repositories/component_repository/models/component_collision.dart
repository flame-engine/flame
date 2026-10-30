import 'package:equatable/equatable.dart';

/// Which other hitboxes a hitbox collides with.
///
/// Mirrors Flame's `CollisionType` without depending on Flame.
enum HitboxCollisionType({
  /// Human readable name.
  required final String label,
}) {
  /// Collides with active and passive hitboxes.
  active(label: 'Active'),

  /// Collides with active hitboxes only.
  passive(label: 'Passive'),

  /// Doesn't collide with any hitbox.
  inactive(label: 'Inactive');

  /// Returns the type called [name], or `null` if there is none.
  static HitboxCollisionType? fromName(Object? name) {
    for (final type in values) {
      if (type.name == name) {
        return type;
      }
    }
    return null;
  }
}

/// {@template component_collision}
/// The collision property shared by every hitbox: its collision [type] and
/// whether it [isSolid].
/// {@endtemplate}
class const ComponentCollision({
  /// Which other hitboxes the hitbox collides with.
  final HitboxCollisionType type = HitboxCollisionType.active,

  /// Whether the hitbox also collides with hitboxes fully inside it, rather
  /// than only with those crossing its edges.
  final bool isSolid = false,
}) extends Equatable {
  /// {@macro component_collision}
  this;

  /// Creates a [ComponentCollision] from its JSON representation.
  ///
  /// Missing or invalid values fall back to their defaults.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final isSolid = map['isSolid'];
    return ComponentCollision(
      type:
          HitboxCollisionType.fromName(map['type']) ??
          HitboxCollisionType.active,
      isSolid: isSolid is bool && isSolid,
    );
  }

  /// Returns a copy of this collision with the given fields replaced.
  ComponentCollision copyWith({HitboxCollisionType? type, bool? isSolid}) {
    return ComponentCollision(
      type: type ?? this.type,
      isSolid: isSolid ?? this.isSolid,
    );
  }

  /// Converts this collision to its JSON representation.
  Map<String, dynamic> toJson() => {'type': type.name, 'isSolid': isSolid};

  @override
  List<Object> get props => [type, isSolid];
}
