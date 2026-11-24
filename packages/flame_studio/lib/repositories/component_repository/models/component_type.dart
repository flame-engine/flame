/// The kinds of components the editor can create.
///
/// Each value maps to a Flame component class.
enum ComponentType({
  /// The value stored in the component JSON.
  required final String key,

  /// Human readable name.
  required final String label,
}) {
  /// A rectangle, backed by Flame's `RectangleComponent`.
  rectangle(key: 'rectangle', label: 'Rectangle'),

  /// A plain component that draws nothing itself, backed by Flame's
  /// `PositionComponent`.
  position(key: 'position', label: 'Position'),

  /// A circle, backed by Flame's `CircleComponent`.
  circle(key: 'circle', label: 'Circle'),

  /// A polygon, backed by Flame's `PolygonComponent`.
  polygon(key: 'polygon', label: 'Polygon'),

  /// A region of an image, backed by Flame's `SpriteComponent`.
  sprite(key: 'sprite', label: 'Sprite'),

  /// A rectangular hitbox, backed by Flame's `RectangleHitbox`.
  rectangleHitbox(key: 'rectangleHitbox', label: 'Rectangle hitbox'),

  /// A round hitbox, backed by Flame's `CircleHitbox`.
  circleHitbox(key: 'circleHitbox', label: 'Circle hitbox'),

  /// A polygonal hitbox, backed by Flame's `PolygonHitbox`.
  polygonHitbox(key: 'polygonHitbox', label: 'Polygon hitbox');

  /// Returns the type stored under [key], or `null` if there is none.
  static ComponentType? fromKey(Object? key) {
    for (final type in values) {
      if (type.key == key) {
        return type;
      }
    }
    return null;
  }

  /// Whether components of this type are hitboxes, which can only be
  /// children and have no children of their own (see `HitboxComponent`).
  bool get isHitbox => switch (this) {
    rectangleHitbox || circleHitbox || polygonHitbox => true,
    rectangle || position || circle || polygon || sprite => false,
  };

  /// Whether components of this type are shaped by vertices, and start
  /// with a `PolygonShape`.
  bool get hasVertices => this == polygon || this == polygonHitbox;
}
