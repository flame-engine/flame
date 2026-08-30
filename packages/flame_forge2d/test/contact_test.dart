import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  // Forge2D has to be initialized before a world can be created, which
  // Forge2DGame does automatically but a bare World does not.
  setUpAll(initializeForge2D);

  group('Contact', () {
    late World world;
    late Body bodyA;
    late Body bodyB;
    late Shape shapeA;
    late Shape shapeB;

    setUp(() {
      world = World();
      bodyA = world.createBody();
      bodyB = world.createBody(BodyDef(position: Vector2(10, 0)));
      shapeA = bodyA.createShape(Circle(radius: 1));
      shapeB = bodyB.createShape(Circle(radius: 1));
    });

    tearDown(() {
      world.destroy();
    });

    test('bodyA and bodyB return the owning bodies', () {
      final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);

      expect(contact.bodyA, bodyA);
      expect(contact.bodyB, bodyB);
    });

    test('isValid reflects the validity of both shapes', () {
      final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);
      expect(contact.isValid, isTrue);

      bodyB.destroy();
      expect(contact.isValid, isFalse);
    });

    test('begin contacts carry the normal and points', () {
      final contact = Contact.begin(
        shapeA: shapeA,
        shapeB: shapeB,
        normal: Vector2(0, 1),
        points: [ContactPoint(point: Vector2(5, 0), separation: -0.1)],
      );

      expect(contact.isSensorEvent, isFalse);
      expect(contact.normal, Vector2(0, 1));
      expect(contact.points, hasLength(1));
    });

    test('userDatas keeps the body A, shape A, body B, shape B order', () {
      final firstUserData = Object();
      final secondUserData = Object();
      final thirdUserData = Object();
      final fourthUserData = Object();
      bodyA.userData = firstUserData;
      shapeA.userData = secondUserData;
      bodyB.userData = thirdUserData;
      shapeB.userData = fourthUserData;

      final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);

      expect(
        contact.userDatas.toList(),
        [firstUserData, secondUserData, thirdUserData, fourthUserData],
      );
    });

    test('userDatas skips destroyed shapes', () {
      bodyA.userData = Object();
      shapeA.userData = Object();
      bodyB.userData = Object();
      bodyB.destroy();

      final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);

      expect(
        contact.userDatas.toList(),
        [bodyA.userData, shapeA.userData],
      );
    });

    test('deduplicates userData shared between a body and its shape', () {
      final sharedUserData = Object();
      bodyA.userData = sharedUserData;
      shapeA.userData = sharedUserData;

      final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);

      expect(contact.userDatas.toList(), [sharedUserData]);
    });
  });
}
