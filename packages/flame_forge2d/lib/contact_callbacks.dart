import 'package:flame_forge2d/flame_forge2d.dart';

/// Used to listen to a [BodyComponent]'s contact events.
///
/// Contact events occur whenever two [Fixture] meet each other.
///
/// To react to contacts you should assign [ContactCallbacks] to a [Body]'s
/// userData or/and to a [Fixture]'s userData.
/// {@macro flame_forge2d.world_contact_listener.algorithm}
class ContactCallbacks {
  /// Called when two [Fixture]s start being in contact.
  ///
  /// It is called for sensors and non-sensors.
  void beginContact(Object other, Contact contact) {
    onBeginContact?.call(other, contact);
  }

  /// Called when two [Fixture]s cease being in contact.
  ///
  /// It is called for sensors and non-sensors.
  void endContact(Object other, Contact contact) {
    onEndContact?.call(other, contact);
  }

  /// Called after collision detection, but before collision resolution.
  ///
  /// This gives you a chance to disable the [Contact] based on the current
  /// configuration.
  /// Sensors do not create [Manifold]s.
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    onPreSolve?.call(other, contact, oldManifold);
  }

  /// Called after collision resolution.
  ///
  /// Usually defined to gather collision impulse results.
  /// If one of the colliding objects is a sensor, this will not be called.
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
