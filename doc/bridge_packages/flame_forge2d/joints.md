# Joints

Joints are used to connect two different bodies together in various ways.
They help to simulate interactions between objects to create hinges, wheels, ropes, chains etc.

One `Body` in a joint may be of type `BodyType.static`. Joints between `BodyType.static` and/or
`BodyType.kinematic` are allowed, but have no effect and use some processing time.

To construct a `Joint`, you create the corresponding subclass of `JointDef` with its parameters,
and pass it to the typed creator method on the physics world, for example
`world.physicsWorld.createRevoluteJoint(revoluteJointDef)`. The creator returns the typed joint,
and when you want to remove a joint you call `joint.destroy()`.


## Built-in joints

Currently, Forge2D supports the following joints:

- [`DistanceJoint`](#distancejoint)
- [`FilterJoint`](#filterjoint)
- [`MotorJoint`](#motorjoint)
- [`MouseJoint`](#mousejoint)
- [`PrismaticJoint`](#prismaticjoint)
- [`RevoluteJoint`](#revolutejoint)
- [`WeldJoint`](#weldjoint)
- [`WheelJoint`](#wheeljoint)

The gear, pulley, rope, friction, and constant-volume joints from older Forge2D versions do not
exist in Box2D v3, and therefore no longer exist in Forge2D.


### `DistanceJoint`

A `DistanceJoint` constrains two points on two bodies to remain at a fixed distance from each
other.

You can view this as a massless, rigid rod, and by enabling its spring it can also act as a
spring/damper.

```dart
world.physicsWorld.createDistanceJoint(
  DistanceJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    length: 10,
    enableSpring: true,
    hertz: 3,
    dampingRatio: 0.2,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: distance_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

The most commonly used `DistanceJointDef` parameters:

- `localAnchorA`, `localAnchorB`: The anchor points relative to each body's origin.

- `length`: This parameter determines the distance between the two anchor points and must be
greater than 0. The default value is 1.

- `enableSpring`, `hertz`, `dampingRatio`: When the spring is enabled the rod becomes soft; the
higher the `hertz` value the stiffer the spring, and the `dampingRatio` defines how quickly the
oscillation comes to rest, where 0 means no damping and 1 indicates critical damping.

- `enableLimit`, `minLength`, `maxLength`: Restricts the distance between the bodies to a range
when the spring is enabled.

- `enableMotor`, `motorSpeed`, `maxMotorForce`: Drives the distance between the bodies.

```{warning}
Do not use a zero or short length.
```


### `FilterJoint`

A `FilterJoint` doesn't constrain the bodies at all; its only purpose is to disable all collision
between the two connected bodies.

```dart
world.physicsWorld.createFilterJoint(
  FilterJointDef(bodyA: firstBody, bodyB: secondBody),
);
```


### `MotorJoint`

A `MotorJoint` is used to control the relative motion between two bodies. A typical usage is to
control the movement of a dynamic body with respect to the fixed point, for example to create
animations.

A `MotorJoint` lets you control the motion of a body by specifying target position and rotation
offsets. You can set the maximum motor force and torque that will be applied to reach the target
position and rotation. If the body is blocked, it will stop and the contact forces will be
proportional the maximum motor force and torque.

```dart
final motorJoint = world.physicsWorld.createMotorJoint(
  MotorJointDef(
    bodyA: first,
    bodyB: second,
    maxForce: 1000,
    maxTorque: 1000,
    correctionFactor: 0.1,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: motor_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

A `MotorJointDef` has these optional tuning parameters:

- `maxForce`: the maximum translational force which will be applied to the joined body to reach the
target position.

- `maxTorque`: the maximum angular force which will be applied to the joined body to reach the
target rotation.

- `correctionFactor`: position correction factor in range [0, 1]. It adjusts the joint's response to
deviation from target position. A higher value makes the joint respond faster, while a lower value
makes it respond slower. If the value is set too high, the joint may overcompensate and oscillate,
becoming unstable. If set too low, it may respond too slowly.

The linear and angular offsets are the target distance and angle that the bodies should achieve
relative to each other's position and rotation. They can be passed to the `MotorJointDef` as
`linearOffset` and `angularOffset`, or changed later through the setters with the same names on
the `MotorJoint`.

For example, this code increments the angular offset of the joint every update cycle, causing the
body to rotate.

```dart
@override
void update(double dt) {
  super.update(dt);

  joint.angularOffset = joint.angularOffset + motorSpeed * dt;
}
```


### `MouseJoint`

The `MouseJoint` is used to manipulate bodies with the mouse. It attempts to drive a point on a body
towards the current position of the cursor. There is no restriction on rotation.

The `MouseJoint` definition has a target point, maximum force, hertz, and damping ratio. The
target point initially coincides with the body's anchor point. The maximum force is used to prevent
violent reactions when multiple dynamic bodies interact. You can make this as large as you like.
The hertz and damping ratio are used to create a spring/damper effect similar to the distance
joint.

```{warning}
Many users have tried to adapt the mouse joint for game play. Users often want
to achieve precise positioning and instantaneous response. The mouse joint 
doesn't work very well in that context. You may wish to consider using 
kinematic bodies instead.
```

```dart
final mouseJoint = world.physicsWorld.createMouseJoint(
  MouseJointDef(
    bodyA: groundBody,
    bodyB: ballBody,
    target: ballBody.position,
    maxForce: 3000 * ballBody.mass * 10,
    dampingRatio: 1,
    hertz: 5,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: mouse_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `maxForce`: This parameter defines the maximum constraint force that can be exerted to move the
  candidate body. Usually you will express as some multiple of the weight
  (multiplier *mass* gravity).

- `dampingRatio`: This parameter defines how quickly the oscillation comes to rest. It ranges from
  0 to 1, where 0 means no damping and 1 indicates critical damping.

- `hertz`: This parameter defines the response speed of the body, i.e. how quickly it tries to
  reach the target position

- `target`: The initial world target point. This is assumed to coincide with the body anchor
  initially. While dragging you update it through the `target` setter,
  `mouseJoint.target = newPosition;`.


### `PrismaticJoint`

The `PrismaticJoint` provides a single degree of freedom, allowing for a relative translation of two
bodies along an axis fixed in bodyA. Relative rotation is prevented.

`PrismaticJointDef` requires defining a line of motion using a local axis and anchor points.
The definition uses local anchor points and a local axis so that the initial configuration
can violate the constraint slightly.

The joint translation is zero when the local anchor points coincide in world space.

```{warning}
At least one body should be dynamic with a non-fixed rotation.
```

The `PrismaticJoint` definition is similar to the [`RevoluteJoint`](#revolutejoint) definition, but
instead of rotation, it uses translation.

```dart
final prismaticJoint = world.physicsWorld.createPrismaticJoint(
  PrismaticJointDef(
    bodyA: dynamicBody,
    bodyB: groundBody,
    localAxisA: Vector2(1, 0),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: prismatic_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: Bodies connected by the joint.
- `localAnchorA`, `localAnchorB`: The anchor points relative to each body's origin.
- `localAxisA`: The translation axis in bodyA's frame, along which the translation will be fixed.


#### Prismatic Joint Limit

You can limit the relative translation with a joint limit that specifies a lower and upper
translation.

```dart
PrismaticJointDef(
  ...
  enableLimit: true,
  lowerTranslation: -20,
  upperTranslation: 20,
);
```

- `enableLimit`: Set to true to enable translation limits
- `lowerTranslation`: The lower translation limit in meters
- `upperTranslation`: The upper translation limit in meters

You change the limits after the joint was created with this method:

```dart
prismaticJoint.setLimits(lower: -10, upper: 10);
```


#### Prismatic Joint Motor

You can use a motor to drive the motion or to model joint friction. A maximum motor force is
provided so that infinite forces are not generated.

```dart
PrismaticJointDef(
  ...
  enableMotor: true,
  motorSpeed: 1,
  maxMotorForce: 100,
);
```

- `enableMotor`: Set to true to enable the motor
- `motorSpeed`: The desired motor speed in meters per second
- `maxMotorForce`: The maximum motor force used to achieve the desired motor speed in N.

You change the motor's speed and force after the joint was created using these setters:

```dart
prismaticJoint.motorSpeed = 2;
prismaticJoint.maxMotorForce = 200;
```

Also, you can get the joint translation and speed using the following getters:

```dart
prismaticJoint.translation;
prismaticJoint.speed;
```


### `RevoluteJoint`

A `RevoluteJoint` forces two bodies to share a common anchor point, often called a hinge point.
The revolute joint has a single degree of freedom: the relative rotation of the two bodies.

To create a `RevoluteJoint`, provide two bodies and the local anchor points that coincide at the
hinge point. The definition uses local anchor points so that the initial configuration can violate
the constraint slightly.

```dart
final revoluteJoint = world.physicsWorld.createRevoluteJoint(
  RevoluteJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    localAnchorA: firstBody.localPoint(anchor),
    localAnchorB: secondBody.localPoint(anchor),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: revolute_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

In some cases you might wish to control the joint angle. For this, the `RevoluteJointDef` has
optional parameters that allow you to simulate a joint limit and/or a motor.


#### Revolute Joint Limit

You can limit the relative rotation with a joint limit that specifies a lower and upper angle.

```dart
RevoluteJointDef(
  ...
  enableLimit: true,
  lowerAngle: 0,
  upperAngle: pi / 2,
);
```

- `enableLimit`: Set to true to enable angle limits
- `lowerAngle`: The lower angle in radians
- `upperAngle`: The upper angle in radians

You change the limits after the joint was created with this method:

```dart
revoluteJoint.setLimits(lower: 0, upper: pi);
```


#### Revolute Joint Motor

You can use a motor to drive the relative rotation about the shared point. A maximum motor torque is
provided so that infinite forces are not generated.

```dart
RevoluteJointDef(
  ...
  enableMotor: true,
  motorSpeed: 5,
  maxMotorTorque: 100,
);
```

- `enableMotor`: Set to true to enable the motor
- `motorSpeed`: The desired motor speed in radians per second
- `maxMotorTorque`: The maximum motor torque used to achieve the desired motor speed in N-m.

You change the motor's speed and torque after the joint was created using these setters:

```dart
revoluteJoint.motorSpeed = 2;
revoluteJoint.maxMotorTorque = 200;
```

Also, you can get the current joint angle:

```dart
revoluteJoint.angle;
```


### `WeldJoint`

A `WeldJoint` is used to restrict all relative motion between two bodies, effectively joining them
together.

`WeldJointDef` requires two bodies that will be connected, and the local anchor points that
coincide at the weld point:

```dart
world.physicsWorld.createWeldJoint(
  WeldJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    localAnchorA: firstBody.localPoint(anchor),
    localAnchorB: secondBody.localPoint(anchor),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: weld_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: Two bodies that will be connected

- `localAnchorA`, `localAnchorB`: Anchor points relative to each body's origin, at which the two
  bodies will be welded together

The weld can also be made springy with the `linearHertz`, `angularHertz`, `linearDampingRatio`
and `angularDampingRatio` parameters.


#### Breakable Bodies and WeldJoint

Since the Forge2D constraint solver is iterative, joints are somewhat flexible. This means that the
bodies connected by a WeldJoint may bend slightly. If you want to simulate a breakable body, it's
better to create a single body with multiple shapes. When the body breaks, you can destroy a
shape and recreate it on a new body instead of relying on a `WeldJoint`.


### `WheelJoint`

A `WheelJoint` provides two degrees of freedom: translation along a spring-loaded axis fixed in
bodyA, and rotation of bodyB. It is designed for vehicle suspensions.

```dart
world.physicsWorld.createWheelJoint(
  WheelJointDef(
    bodyA: chassis,
    bodyB: wheel,
    localAnchorA: chassis.localPoint(wheel.position),
    localAxisA: Vector2(0, 1),
    hertz: 4,
    dampingRatio: 0.7,
    enableMotor: true,
    maxMotorTorque: 30,
    motorSpeed: -25,
  ),
);
```

- `localAxisA`: The suspension axis in bodyA's frame.
- `enableSpring`, `hertz`, `dampingRatio`: The suspension spring configuration.
- `enableLimit`, `lowerTranslation`, `upperTranslation`: Limits the suspension travel.
- `enableMotor`, `motorSpeed`, `maxMotorTorque`: Drives the wheel's rotation.
