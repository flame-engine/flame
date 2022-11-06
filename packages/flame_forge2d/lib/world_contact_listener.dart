import 'package:flame_forge2d/flame_forge2d.dart';

/// Listens to the entire [World]'s contact events.
///
/// It propagates the contact events ([beginContact], [endContact], [preSolve],
/// [postSolve]) to [ContactCallbacks]s when a [Body] or at least one of its
// fixtures' `userData` is set to a [ContactCallbacks].
///
/// {@template flame_forge2d.world_contact_listener.algorithm}
/// If the [Body] `userData` is set to a [ContactCallbacks] the contact events
/// of this will be called when any [Body]'s fixture contacts another [Fixture].
///
/// If instead you wish to be more specific and only trigger contact events
/// when a specific [Body]'s fixture contacts another [Fixture], you can
/// set the fixture `userData` to a [ContactCallbacks].
///
/// If the colliding [Fixture] `userData` and [Body] `userData` are `null`, then
/// the contact events are not called.
///
/// The described behavior is a simple out of the box solution to propagate
/// contact events. If you wish to implement your own logic you can subclass
/// [ContactListener] and provide it to your [Forge2DGame].
/// {@endtemplate}
class WorldContactListener extends ContactListener {
  void _callback(
    Contact contact,
    void Function(ContactCallbacks contactCallback, Object other) callback,
  ) {
    final userData = {
      contact.bodyA.userData,
      contact.fixtureA.userData,
      contact.bodyB.userData,
      contact.fixtureB.userData,
    }.whereType<Object>();

    for (final contactCallback in userData.whereType<ContactCallbacks>()) {
      for (final object in userData) {
        if (object != contactCallback) {
          callback(contactCallback, object);
        }
      }
    }
  }

  @override
  void beginContact(Contact contact) {
    _callback(
      contact,
      (contactCallback, other) => contactCallback.beginContact(other, contact),
    );
  }

  @override
  void endContact(Contact contact) {
    _callback(
      contact,
      (contactCallback, other) => contactCallback.endContact(other, contact),
    );
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    _callback(
      contact,
      (contactCallback, other) =>
          contactCallback.preSolve(other, contact, oldManifold),
    );
  }

  @override
  void postSolve(Contact contact, ContactImpulse contactImpulse) {
    _callback(
      contact,
      (contactCallback, other) =>
          contactCallback.postSolve(other, contact, contactImpulse),
    );
  }
}
