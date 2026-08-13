import 'package:flame_forge2d/flame_forge2d.dart';

/// The contact data that is delivered to [ContactCallbacks] by the
/// [ContactEventsDispatcher].
///
/// Forge2D reports contacts as polled events after each step instead of
/// through listener callbacks, and sensor overlaps arrive through a separate
/// event stream. [Contact] wraps both streams in one type so that
/// [ContactCallbacks.beginContact] and [ContactCallbacks.endContact] can be
/// used for sensors and non-sensors alike.
class Contact {
  /// Creates the contact for a begin-touch event.
  Contact.begin({
    required this.shapeA,
    required this.shapeB,
    required Vector2 this.normal,
    required List<ContactPoint> this.points,
  }) : isSensorEvent = false;

  /// Creates the contact for an end-touch event.
  ///
  /// The shapes may already have been destroyed, check [Shape.isValid]
  /// before using them.
  Contact.end({required this.shapeA, required this.shapeB})
    : normal = null,
      points = null,
      isSensorEvent = false;

  /// Creates the contact for a sensor begin or end event.
  Contact.sensor({required Shape sensor, required Shape visitor})
    : shapeA = sensor,
      shapeB = visitor,
      normal = null,
      points = null,
      isSensorEvent = true;

  /// The first shape, or the sensor shape for sensor events.
  final Shape shapeA;

  /// The second shape, or the visiting shape for sensor events.
  final Shape shapeB;

  /// The contact normal in world coordinates, pointing from [shapeA] to
  /// [shapeB].
  ///
  /// Only available for begin-touch events of non-sensor shapes.
  final Vector2? normal;

  /// The initial contact points, recorded before the solver ran.
  ///
  /// Only available for begin-touch events of non-sensor shapes.
  final List<ContactPoint>? points;

  /// Whether this contact comes from a sensor overlap event.
  final bool isSensorEvent;

  /// The body of [shapeA].
  ///
  /// Only use this when [shapeA] is valid.
  Body get bodyA => shapeA.body;

  /// The body of [shapeB].
  ///
  /// Only use this when [shapeB] is valid.
  Body get bodyB => shapeB.body;

  /// The sensor shape of a sensor event.
  Shape get sensor {
    assert(isSensorEvent, 'Only sensor events have a sensor shape');
    return shapeA;
  }

  /// The shape that entered or left the sensor of a sensor event.
  Shape get visitor {
    assert(isSensorEvent, 'Only sensor events have a visitor shape');
    return shapeB;
  }

  /// Whether both shapes still exist in the world.
  ///
  /// End events can arrive after one of the shapes has been destroyed.
  bool get isValid => shapeA.isValid && shapeB.isValid;

  /// The non-null userData of the bodies and shapes involved in this
  /// contact, in the order body A, shape A, body B, shape B.
  ///
  /// Shapes that have already been destroyed are skipped, since their
  /// userData is removed together with them.
  Set<Object> get userDatas {
    final userDatas = <Object>{};
    for (final shape in [shapeA, shapeB]) {
      if (!shape.isValid) {
        continue;
      }
      final bodyUserData = shape.body.userData;
      if (bodyUserData != null) {
        userDatas.add(bodyUserData);
      }
      final shapeUserData = shape.userData;
      if (shapeUserData != null) {
        userDatas.add(shapeUserData);
      }
    }
    return userDatas;
  }
}
