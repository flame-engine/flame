import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
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
}
