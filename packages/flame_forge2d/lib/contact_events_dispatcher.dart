import 'package:flame_forge2d/flame_forge2d.dart';

/// Dispatches the physics world's polled contact and sensor events to the
/// [ContactCallbacks] found in the userData of the involved bodies and
/// shapes.
///
/// {@template flame_forge2d.contact_events_dispatcher.algorithm}
/// If the [Body] `userData` is set to a [ContactCallbacks] the contact events
/// of this will be called when any of the body's [Shape]s contacts another
/// [Shape].
///
/// If instead you wish to be more specific and only trigger contact events
/// when a specific [Shape] contacts another [Shape], you can set the shape's
/// `userData` to a [ContactCallbacks].
///
/// If the colliding [Shape] `userData` and [Body] `userData` are `null`, then
/// the contact events are not called.
///
/// Forge2D only reports events for shapes that have opted in to them, so
/// remember to set [ShapeDef.enableContactEvents] (and
/// [ShapeDef.enableSensorEvents] for sensors and their visitors) on the
/// shapes that should generate events. The default
/// [BodyComponent.createBody] implementation enables them automatically when
/// a [ContactCallbacks] is present in the body's or shape's userData.
///
/// The described behavior is a simple out of the box solution to propagate
/// contact events. If you wish to implement your own logic you can subclass
/// [ContactEventsDispatcher] and provide it to your [Forge2DGame] or
/// [Forge2DWorld].
/// {@endtemplate}
class ContactEventsDispatcher {
  /// Called by [Forge2DWorld.update] after each physics step, with the
  /// events that were generated during that step.
  void dispatch(ContactEvents contactEvents, SensorEvents sensorEvents) {
    for (final event in contactEvents.begin) {
      beginContact(
        Contact.begin(
          shapeA: event.shapeA,
          shapeB: event.shapeB,
          normal: event.normal,
          points: event.points,
        ),
      );
    }
    for (final event in sensorEvents.begin) {
      beginContact(
        Contact.sensor(sensor: event.sensor, visitor: event.visitor),
      );
    }
    for (final event in contactEvents.end) {
      endContact(Contact.end(shapeA: event.shapeA, shapeB: event.shapeB));
    }
    for (final event in sensorEvents.end) {
      endContact(Contact.sensor(sensor: event.sensor, visitor: event.visitor));
    }
  }

  /// Dispatches a begin contact to the [ContactCallbacks] of the involved
  /// bodies and shapes.
  void beginContact(Contact contact) {
    _dispatch(
      contact,
      (contactCallbacks, other) => contactCallbacks.beginContact(
        other,
        contact,
      ),
    );
  }

  /// Dispatches an end contact to the [ContactCallbacks] of the involved
  /// bodies and shapes.
  void endContact(Contact contact) {
    _dispatch(
      contact,
      (contactCallbacks, other) => contactCallbacks.endContact(other, contact),
    );
  }

  void _dispatch(
    Contact contact,
    void Function(ContactCallbacks contactCallbacks, Object other) callback,
  ) {
    final userDatas = contact.userDatas;
    for (final contactCallbacks in userDatas.whereType<ContactCallbacks>()) {
      for (final other in userDatas) {
        if (other != contactCallbacks) {
          callback(contactCallbacks, other);
        }
      }
    }
  }
}
