import 'package:flame_forge2d/flame_forge2d.dart';

/// Used to listen to a [BodyComponent]'s contact events.
///
/// Contact events occur whenever two [Shape]s meet each other.
///
/// To react to contacts you should assign [ContactCallbacks] to a [Body]'s
/// userData or/and to a [Shape]'s userData.
/// {@macro flame_forge2d.contact_events_dispatcher.algorithm}
///
/// The old `preSolve` and `postSolve` callbacks no longer exist in Forge2D.
/// To disable contacts before they are solved, set
/// [Forge2DWorld.preSolveCallback] (and [ShapeDef.enablePreSolveEvents] on
/// the involved shapes). To measure impact strength, enable
/// [ShapeDef.enableHitEvents] and poll the world's `contactEvents.hit`.
mixin class ContactCallbacks {
  /// Called when two [Shape]s start being in contact.
  ///
  /// It is called for sensors and non-sensors.
  void beginContact(Object other, Contact contact) {
    onBeginContact?.call(other, contact);
  }

  /// Called when two [Shape]s cease being in contact.
  ///
  /// It is called for sensors and non-sensors.
  void endContact(Object other, Contact contact) {
    onEndContact?.call(other, contact);
  }

  void Function(Object other, Contact contact)? onBeginContact;

  void Function(Object other, Contact contact)? onEndContact;
}
