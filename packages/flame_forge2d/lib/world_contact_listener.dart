import 'package:forge2d/forge2d.dart';

/// Listens to the entire [World] contacts events.
///
/// It propagates contact events (begin, end, preSolve, postSolve) to other
/// [ContactListener]s when a [Body] or at least one of its fixtures `userData`
/// is set to a [ContactListener].
///
/// If the [Body] `userData` is set to a [ContactListener] the contact events
/// of this will be called to when any [Body]'s fixture contacts another
/// [Fixture].
///
/// If instead you wish to be more specific and only trigger contact events
/// when a specific [Body]'s fixture contacts with another [Fixture] you can
/// set the fixture `userData` to a [ContactListener].
// TODO(alestiago): Make this class protected to the package.
class WorldContactListener extends ContactListener {
  Iterable<ContactListener> _contactListeners(Contact contact) => {
        contact.bodyA.userData,
        contact.fixtureA.userData,
        contact.bodyB.userData,
        contact.fixtureB.userData,
      }.whereType<ContactListener>();

  @override
  void beginContact(Contact contact) {
    _contactListeners(contact).forEach(
      (contactCallback) => contactCallback.beginContact(contact),
    );
  }

  @override
  void endContact(Contact contact) {
    _contactListeners(contact).forEach(
      (contactCallback) => contactCallback.endContact(contact),
    );
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    _contactListeners(contact).forEach(
      (contactCallback) => contactCallback.preSolve(contact, oldManifold),
    );
  }

  @override
  void postSolve(Contact contact, ContactImpulse contactImpulse) {
    _contactListeners(contact).forEach(
      (contactCallback) => contactCallback.postSolve(contact, contactImpulse),
    );
  }
}
