import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/world_contact_listener.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/scaffolding.dart';

import 'helpers/helpers.dart';

void main() {
  group(
    'WorldContactListener',
    () {
      late ContactCallbacks contactCallback;
      late Contact contact;
      late Body bodyA;
      late Body bodyB;
      late Fixture fixtureA;
      late Fixture fixtureB;

      setUp(() {
        contactCallback = MockContactCallback();
        contact = MockContact();
        bodyA = MockBody();
        bodyB = MockBody();
        fixtureA = MockFixture();
        fixtureB = MockFixture();

        when(() => contact.bodyA).thenReturn(bodyA);
        when(() => contact.bodyB).thenReturn(bodyB);
        when(() => contact.fixtureA).thenReturn(fixtureA);
        when(() => contact.fixtureB).thenReturn(fixtureB);
      });

      setUpAll(() {
        registerFallbackValue(Object());
      });

      group(
        'beginContact',
        () {
          test(
            "doesn't callback if userData are null",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(null);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.beginContact(contact);

              verifyNever(
                () => contactCallback.beginContact(any(), contact),
              );
            },
          );

          test(
            'callbacks for userData when not null',
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(Object());
              when(() => fixtureA.userData).thenReturn(Object());
              when(() => fixtureB.userData).thenReturn(Object());

              contactListener.beginContact(contact);

              verify(
                () => contactCallback.beginContact(bodyB.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.beginContact(fixtureA.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.beginContact(fixtureB.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.beginContact(any(), contact),
              ).called(3);
            },
          );

          test(
            "doesn't callback itself",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(contactCallback);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.beginContact(contact);

              verifyNever(
                () => contactCallback.beginContact(any(), contact),
              );
            },
          );
        },
      );

      group(
        'endContact',
        () {
          test(
            "doesn't callback if userData are null",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(null);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.endContact(contact);

              verifyNever(
                () => contactCallback.endContact(any(), contact),
              );
            },
          );

          test(
            'callbacks for userData when not null',
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(Object());
              when(() => fixtureA.userData).thenReturn(Object());
              when(() => fixtureB.userData).thenReturn(Object());

              contactListener.endContact(contact);

              verify(
                () => contactCallback.endContact(bodyB.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.endContact(fixtureA.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.endContact(fixtureB.userData!, contact),
              ).called(1);
              verify(
                () => contactCallback.endContact(any(), contact),
              ).called(3);
            },
          );

          test(
            "doesn't callback itself",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(contactCallback);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.endContact(contact);

              verifyNever(
                () => contactCallback.endContact(any(), contact),
              );
            },
          );
        },
      );

      group(
        'preSolve',
        () {
          late Manifold manifold;

          setUp(() {
            manifold = MockManifold();
          });

          test(
            "doesn't callback if userData are null",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(null);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.preSolve(contact, manifold);

              verifyNever(
                () => contactCallback.preSolve(any(), contact, manifold),
              );
            },
          );

          test(
            'callbacks for userData when not null',
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(Object());
              when(() => fixtureA.userData).thenReturn(Object());
              when(() => fixtureB.userData).thenReturn(Object());

              contactListener.preSolve(contact, manifold);

              verify(
                () => contactCallback.preSolve(
                  bodyB.userData!,
                  contact,
                  manifold,
                ),
              ).called(1);
              verify(
                () => contactCallback.preSolve(
                  fixtureA.userData!,
                  contact,
                  manifold,
                ),
              ).called(1);
              verify(
                () => contactCallback.preSolve(
                  fixtureB.userData!,
                  contact,
                  manifold,
                ),
              ).called(1);
              verify(
                () => contactCallback.preSolve(
                  any(),
                  contact,
                  manifold,
                ),
              ).called(3);
            },
          );

          test(
            "doesn't callback itself",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(contactCallback);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.preSolve(contact, manifold);

              verifyNever(
                () => contactCallback.preSolve(any(), contact, manifold),
              );
            },
          );
        },
      );

      group(
        'postSolve',
        () {
          late ContactImpulse contactImpulse;

          setUp(() {
            contactImpulse = MockContactImpulse();
          });

          test(
            "doesn't callback if userData are null",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(null);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.postSolve(contact, contactImpulse);

              verifyNever(
                () => contactCallback.postSolve(any(), contact, contactImpulse),
              );
            },
          );

          test(
            'callbacks for userData when not null',
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(Object());
              when(() => fixtureA.userData).thenReturn(Object());
              when(() => fixtureB.userData).thenReturn(Object());

              contactListener.postSolve(contact, contactImpulse);

              verify(
                () => contactCallback.postSolve(
                  bodyB.userData!,
                  contact,
                  contactImpulse,
                ),
              ).called(1);
              verify(
                () => contactCallback.postSolve(
                  fixtureA.userData!,
                  contact,
                  contactImpulse,
                ),
              ).called(1);
              verify(
                () => contactCallback.postSolve(
                  fixtureB.userData!,
                  contact,
                  contactImpulse,
                ),
              ).called(1);
              verify(
                () => contactCallback.postSolve(
                  any(),
                  contact,
                  contactImpulse,
                ),
              ).called(3);
            },
          );

          test(
            "doesn't callback itself",
            () {
              final contactListener = WorldContactListener();

              when(() => bodyA.userData).thenReturn(contactCallback);
              when(() => bodyB.userData).thenReturn(contactCallback);
              when(() => fixtureA.userData).thenReturn(null);
              when(() => fixtureB.userData).thenReturn(null);

              contactListener.postSolve(contact, contactImpulse);

              verifyNever(
                () => contactCallback.postSolve(any(), contact, contactImpulse),
              );
            },
          );
        },
      );
    },
  );
}
