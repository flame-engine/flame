import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  // Forge2D has to be initialized before a world can be created, which
  // Forge2DGame does automatically but a bare World does not.
  setUpAll(initializeForge2D);

  group('ContactCallbacks', () {
    late Object other;
    late World world;
    late Contact contact;

    setUp(() {
      other = Object();
      world = World();
      final bodyA = world.createBody();
      final bodyB = world.createBody();
      contact = Contact.end(
        shapeA: bodyA.createShape(Circle(radius: 1)),
        shapeB: bodyB.createShape(Circle(radius: 1)),
      );
    });

    tearDown(() {
      world.destroy();
    });

    test('beginContact calls onBeginContact', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onBeginContact = (_, _) => called++;

      contactCallbacks.beginContact(other, contact);

      expect(called, equals(1));
    });

    test('endContact calls onEndContact', () {
      final contactCallbacks = ContactCallbacks();
      var called = 0;
      contactCallbacks.onEndContact = (_, _) => called++;

      contactCallbacks.endContact(other, contact);

      expect(called, equals(1));
    });
  });

  group('ContactCallbacks in a Forge2DGame', () {
    testWithGame(
      'a BodyComponent with ContactCallbacks userData receives contact '
      'events without enabling the event flags manually',
      Forge2DGame.new,
      (game) async {
        final contactCallbacks = ContactCallbacks();
        Object? contactedWith;
        contactCallbacks.onBeginContact = (other, _) => contactedWith = other;

        final groundUserData = Object();
        final ground = BodyComponent(
          bodyDef: BodyDef(position: Vector2(0, 3), userData: groundUserData),
          shapeSpecs: [ShapeSpec(Polygon.box(10, 1))],
        );
        final ball = BodyComponent(
          bodyDef: BodyDef(type: BodyType.dynamic, userData: contactCallbacks),
          shapeSpecs: [ShapeSpec(Circle(radius: 1))],
        );
        await game.world.ensureAdd(ground);
        await game.world.ensureAdd(ball);

        for (var i = 0; i < 60 && contactedWith == null; i++) {
          game.update(1 / 60);
        }

        expect(contactedWith, equals(groundUserData));
      },
    );
  });
}
