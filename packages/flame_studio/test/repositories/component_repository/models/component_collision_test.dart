import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentCollision, () {
    test('defaults to an active hitbox that is not solid', () {
      const collision = ComponentCollision();

      expect(collision.type, equals(HitboxCollisionType.active));
      expect(collision.isSolid, isFalse);
    });

    test('round-trips through JSON', () {
      const collision = ComponentCollision(
        type: HitboxCollisionType.inactive,
        isSolid: true,
      );

      expect(collision.toJson(), equals({'type': 'inactive', 'isSolid': true}));
      expect(
        ComponentCollision.fromJson(collision.toJson()),
        equals(collision),
      );
    });

    test('fromJson falls back to the defaults', () {
      expect(ComponentCollision.fromJson(null), const ComponentCollision());
      expect(
        ComponentCollision.fromJson(const {'type': 'bouncy', 'isSolid': 1}),
        const ComponentCollision(),
      );
    });

    test('copyWith replaces only the given fields', () {
      const collision = ComponentCollision(type: HitboxCollisionType.passive);

      expect(
        collision.copyWith(isSolid: true),
        const ComponentCollision(
          type: HitboxCollisionType.passive,
          isSolid: true,
        ),
      );
      expect(
        collision.copyWith(type: HitboxCollisionType.active),
        const ComponentCollision(),
      );
    });
  });

  group(HitboxCollisionType, () {
    test('fromName returns the matching type', () {
      expect(
        HitboxCollisionType.fromName('passive'),
        equals(HitboxCollisionType.passive),
      );
    });

    test('fromName returns null for unknown names', () {
      expect(HitboxCollisionType.fromName('bouncy'), isNull);
    });
  });
}
