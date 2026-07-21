import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'helpers/mocks.dart';

class _CountingDispatcher extends ContactEventsDispatcher {
  int dispatchCount = 0;

  @override
  void dispatch(ContactEvents contactEvents, SensorEvents sensorEvents) {
    dispatchCount++;
    super.dispatch(contactEvents, sensorEvents);
  }
}

void main() {
  // Forge2D has to be initialized before a world can be created, which
  // Forge2DGame does automatically but a bare World does not.
  setUpAll(initializeForge2D);

  group('ContactEventsDispatcher', () {
    late ContactEventsDispatcher dispatcher;
    late ContactCallbacks contactCallback;
    late World world;
    late Body bodyA;
    late Body bodyB;
    late Shape shapeA;
    late Shape shapeB;

    setUp(() {
      dispatcher = ContactEventsDispatcher();
      contactCallback = MockContactCallback();
      world = World();
      bodyA = world.createBody();
      bodyB = world.createBody();
      shapeA = bodyA.createShape(Circle(radius: 1));
      shapeB = bodyB.createShape(Circle(radius: 1));
    });

    tearDown(() {
      world.destroy();
    });

    setUpAll(() {
      registerFallbackValue(Object());
    });

    Contact beginContact() => Contact.begin(
      shapeA: shapeA,
      shapeB: shapeB,
      normal: Vector2(0, 1),
      points: [],
    );

    group('beginContact', () {
      test("doesn't callback if other userData are null", () {
        bodyA.userData = contactCallback;

        final contact = beginContact();
        dispatcher.beginContact(contact);

        verifyNever(
          () => contactCallback.beginContact(any(), contact),
        );
      });

      test('callbacks for userData when not null', () {
        bodyA.userData = contactCallback;
        bodyB.userData = Object();
        shapeA.userData = Object();
        shapeB.userData = Object();

        final contact = beginContact();
        dispatcher.beginContact(contact);

        verify(
          () => contactCallback.beginContact(bodyB.userData!, contact),
        ).called(1);
        verify(
          () => contactCallback.beginContact(shapeA.userData!, contact),
        ).called(1);
        verify(
          () => contactCallback.beginContact(shapeB.userData!, contact),
        ).called(1);
      });

      test("doesn't callback itself", () {
        bodyA.userData = contactCallback;
        bodyB.userData = contactCallback;

        final contact = beginContact();
        dispatcher.beginContact(contact);

        verifyNever(
          () => contactCallback.beginContact(any(), contact),
        );
      });
    });

    group('endContact', () {
      test("doesn't callback if other userData are null", () {
        bodyA.userData = contactCallback;

        final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);
        dispatcher.endContact(contact);

        verifyNever(
          () => contactCallback.endContact(any(), contact),
        );
      });

      test('callbacks for userData when not null', () {
        bodyA.userData = contactCallback;
        bodyB.userData = Object();
        shapeA.userData = Object();
        shapeB.userData = Object();

        final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);
        dispatcher.endContact(contact);

        verify(
          () => contactCallback.endContact(bodyB.userData!, contact),
        ).called(1);
        verify(
          () => contactCallback.endContact(shapeA.userData!, contact),
        ).called(1);
        verify(
          () => contactCallback.endContact(shapeB.userData!, contact),
        ).called(1);
      });

      test('skips shapes that have already been destroyed', () {
        bodyA.userData = contactCallback;
        shapeA.userData = Object();
        final otherUserData = Object();
        bodyB.userData = otherUserData;
        bodyB.destroy();

        final contact = Contact.end(shapeA: shapeA, shapeB: shapeB);
        expect(() => dispatcher.endContact(contact), returnsNormally);

        verify(
          () => contactCallback.endContact(shapeA.userData!, contact),
        ).called(1);
        verifyNever(
          () => contactCallback.endContact(otherUserData, contact),
        );
      });
    });

    group('sensor contacts', () {
      test('sensor and visitor are exposed through the contact', () {
        final contact = Contact.sensor(sensor: shapeA, visitor: shapeB);

        expect(contact.isSensorEvent, isTrue);
        expect(contact.sensor, shapeA);
        expect(contact.visitor, shapeB);
        expect(contact.normal, isNull);
        expect(contact.points, isNull);
      });

      test('dispatches to the involved userData', () {
        bodyA.userData = contactCallback;
        bodyB.userData = Object();

        final contact = Contact.sensor(sensor: shapeA, visitor: shapeB);
        dispatcher.beginContact(contact);

        verify(
          () => contactCallback.beginContact(bodyB.userData!, contact),
        ).called(1);
      });
    });
  });

  group('ContactEventsDispatcher in a Forge2DGame', () {
    testWithGame(
      'begin and end contacts are dispatched for contact events',
      Forge2DGame.new,
      (game) async {
        final contactCallbacks = ContactCallbacks();
        var beginCount = 0;
        var endCount = 0;
        contactCallbacks.onBeginContact = (_, contact) {
          expect(contact.isSensorEvent, isFalse);
          beginCount++;
        };
        contactCallbacks.onEndContact = (_, _) => endCount++;

        final world = game.world;
        final ground = world.createBody(
          BodyDef(position: Vector2(0, 2), userData: Object()),
        );
        ground.createShape(
          Polygon.box(10, 1),
          ShapeDef(enableContactEvents: true),
        );
        final ball = world.createBody(
          BodyDef(type: BodyType.dynamic, userData: contactCallbacks),
        );
        ball.createShape(
          Circle(radius: 1),
          ShapeDef(enableContactEvents: true),
        );

        await game.ready();
        for (var i = 0; i < 30; i++) {
          game.update(1 / 60);
        }
        // The ball may bounce before it settles, so a begin can be followed
        // by an end and a new begin, but the counts always end on a live
        // contact.
        expect(beginCount, greaterThanOrEqualTo(1));
        expect(endCount, beginCount - 1);

        // The resting ball may have fallen asleep, and a sleeping body's
        // contacts are not updated, so wake it up alongside the teleport.
        ball.setTransform(Vector2(100, 0), const Rot.identity());
        ball.isAwake = true;
        game.update(1 / 60);
        expect(endCount, equals(beginCount));
      },
    );

    testWithGame(
      'begin and end contacts are dispatched for sensor events',
      Forge2DGame.new,
      (game) async {
        final contactCallbacks = ContactCallbacks();
        var beginCount = 0;
        var endCount = 0;
        contactCallbacks.onBeginContact = (_, contact) {
          expect(contact.isSensorEvent, isTrue);
          beginCount++;
        };
        contactCallbacks.onEndContact = (_, _) => endCount++;

        final world = game.world;
        final sensorBody = world.createBody(
          BodyDef(userData: contactCallbacks),
        );
        sensorBody.createShape(
          Circle(radius: 2),
          ShapeDef(isSensor: true, enableSensorEvents: true),
        );
        final visitor = world.createBody(
          BodyDef(type: BodyType.dynamic, userData: Object()),
        );
        visitor.createShape(
          Circle(radius: 1),
          ShapeDef(enableSensorEvents: true),
        );

        await game.ready();
        game.update(1 / 60);
        expect(beginCount, equals(1));
        expect(endCount, equals(0));

        visitor.setTransform(Vector2(100, 0), const Rot.identity());
        game.update(1 / 60);
        expect(endCount, equals(1));
      },
    );
  });

  group('custom ContactEventsDispatcher', () {
    testWithGame(
      'a dispatcher passed to Forge2DGame is used by the created world',
      () => Forge2DGame(contactEventsDispatcher: _CountingDispatcher()),
      (game) async {
        final dispatcher =
            game.world.contactEventsDispatcher as _CountingDispatcher;

        await game.ready();
        final countBefore = dispatcher.dispatchCount;
        game.update(1 / 60);

        expect(dispatcher.dispatchCount, equals(countBefore + 1));
      },
    );

    testWithGame(
      'a dispatcher passed to Forge2DWorld is used by that world',
      () => Forge2DGame(
        world: Forge2DWorld(contactEventsDispatcher: _CountingDispatcher()),
      ),
      (game) async {
        final dispatcher =
            game.world.contactEventsDispatcher as _CountingDispatcher;

        await game.ready();
        final countBefore = dispatcher.dispatchCount;
        game.update(1 / 60);

        expect(dispatcher.dispatchCount, equals(countBefore + 1));
      },
    );

    test(
      'Forge2DGame asserts when both a world and a dispatcher are given',
      () {
        expect(
          () => Forge2DGame(
            world: Forge2DWorld(),
            contactEventsDispatcher: ContactEventsDispatcher(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });
}
