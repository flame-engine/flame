import 'package:forge2d/forge2d.dart';

import 'body_component.dart';

/// Listens to contacts events.
mixin ContactCallback on BodyComponent {
  void begin(Contact contact) {}
  void end(Contact contact) {}
  void preSolve(Contact contact, Manifold oldManifold) {}
  void postSolve(Contact contact, ContactImpulse contactImpulse) {}
}

class ContactCallbacks extends ContactListener {
  @override
  void beginContact(Contact contact) {
    final userDataA = contact.fixtureA.body.userData;
    final userDataB = contact.fixtureB.body.userData;

    if (userDataA is ContactCallback) {
      userDataA.begin(contact);
    }
    if (userDataB is ContactCallback) {
      userDataB.begin(contact);
    }
  }

  @override
  void endContact(Contact contact) {
    final userDataA = contact.fixtureA.body.userData;
    final userDataB = contact.fixtureB.body.userData;

    if (userDataA is ContactCallback) {
      userDataA.end(contact);
    }
    if (userDataB is ContactCallback) {
      userDataB.end(contact);
    }
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    final userDataA = contact.fixtureA.body.userData;
    final userDataB = contact.fixtureB.body.userData;

    if (userDataA is ContactCallback) {
      userDataA.preSolve(contact, oldManifold);
    }
    if (userDataB is ContactCallback) {
      userDataB.preSolve(contact, oldManifold);
    }
  }

  @override
  void postSolve(Contact contact, ContactImpulse contactImpulse) {
    final userDataA = contact.fixtureA.body.userData;
    final userDataB = contact.fixtureB.body.userData;

    if (userDataA is ContactCallback) {
      userDataA.postSolve(contact, contactImpulse);
    }
    if (userDataB is ContactCallback) {
      userDataB.postSolve(contact, contactImpulse);
    }
  }
}
