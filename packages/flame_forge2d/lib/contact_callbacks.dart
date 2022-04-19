import 'flame_forge2d.dart';

class ContactCallbacks {
  void beginContact(Object other, Contact contact) {
    onBeginContact?.call(other, contact);
  }

  void endContact(Object other, Contact contact) {
    onEndContact?.call(other, contact);
  }

  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    onPreSolve?.call(other, contact, oldManifold);
  }

  void postSolve(Object other, Contact contact, ContactImpulse impulse) {
    onPostSolve?.call(other, contact, impulse);
  }

  void Function(Object other, Contact contact)? onBeginContact;

  void Function(Object other, Contact contact)? onEndContact;

  void Function(Object other, Contact contact, Manifold oldManifold)?
      onPreSolve;

  void Function(Object other, Contact contact, ContactImpulse impulse)?
      onPostSolve;
}
