# Joints

Joints are used to connect two different bodies together in various ways.
They help to simulate interactions between objects to create hinges, wheels, ropes, chains etc.

One `Body` in a joint may be of type `BodyType.static`. Joints between `BodyType.static` and/or
`BodyType.kinematic` are allowed, but have no effect and use some processing time.

To construct a `Joint`, you need to create a corresponding subclass of `JointDef`and initialize it
with its parameters.

To register a `Joint` use `world.createJoint`and later use `world.destroyJoint` when you want to
remove it.


## Built-in joints

Currently, Forge2D supports the following joints:

- [`ConstantVolumeJoint`](#constantvolumejoint)
- [`DistanceJoint`](#distancejoint)
- [`FrictionJoint`](#frictionjoint)
- GearJoint
- [`MotorJoint`](#motorjoint)
- MouseJoint
- PrismaticJoint
- PulleyJoint
- RevoluteJoint
- RopeJoint
- WeldJoint
- WheelJoint


### `ConstantVolumeJoint`

This type of joint connects a group of bodies together and maintains a constant volume within them.
Essentially, it is a set of [`DistanceJoint`](#distancejoint)s, that connects all bodies one after
another.

It can for example be useful when simulating "soft-bodies".

```dart
  final constantVolumeJoint = ConstantVolumeJointDef()
    ..frequencyHz = 10
    ..dampingRatio = 0.8;

  bodies.forEach((body) {
    constantVolumeJoint.addBody(body);
  });
    
  world.createJoint(ConstantVolumeJoint(world, constantVolumeJoint));
```

```{flutter-app}
:sources: ../../examples
:subfolder: stories/bridge_libraries/forge2d/joints
:page: constant_volume_joint
:show: code popup
```

`ConstantVolumeJointDef` requires at least 3 bodies to be added using the `addBody` method. It also
has two optional parameters:

- `frequencyHz`: This parameter sets the frequency of oscillation of the joint. If it is not set to
0, the higher the value, the less springy each of the compound `DistantJoint`s are.

- `dampingRatio`: This parameter defines how quickly the oscillation comes to rest. It ranges from
0 to 1, where 0 means no damping and 1 indicates critical damping.


### `DistanceJoint`

A `DistanceJoint` constrains two points on two bodies to remain at a fixed distance from each other.

You can view this as a massless, rigid rod.

```dart
final distanceJointDef = DistanceJointDef()
  ..initialize(firstBody, secondBody, firstBody.worldCenter, secondBody.worldCenter)
  ..length = 10
  ..frequencyHz = 3
  ..dampingRatio = 0.2;

world.createJoint(DistanceJoint(distanceJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: distance_joint
:subfolder: stories/bridge_libraries/forge2d/joints
:show: code popup
```

To create a `DistanceJointDef`, you can use the `initialize` method, which requires two bodies and a
world anchor point on each body. The definition uses local anchor points, allowing for a slight
violation of the constraint in the initial configuration. This is useful when saving and
loading a game.

The `DistanceJointDef` has three optional parameters that you can set:

- `length`: This parameter determines the distance between the two anchor points and must be greater
than 0. The default value is 1.

- `frequencyHz`: This parameter sets the frequency of oscillation of the joint. If it is not set
to 0, the higher the value, the less springy the joint becomes.

- `dampingRatio`: This parameter defines how quickly the oscillation comes to rest. It ranges from
0 to 1, where 0 means no damping and 1 indicates critical damping.

```{warning}
Do not use a zero or short length.
```


### `FrictionJoint`

A `FrictionJoint` is used for simulating friction in a top-down game. It provides 2D translational
friction and angular friction.

The `FrictionJoint` isn't related to the friction that occurs when two shapes collide in the x-y plane
of the screen. Instead, it's designed to simulate friction along the z-axis, which is perpendicular
to the screen. The most common use-case for it is applying the friction force between a moving body
and the game floor.

The `initialize` method of the `FrictionJointDef` method requires two bodies that will have friction
force applied to them, and an anchor.

The third parameter is the `anchor` point in the world coordinates where the friction force will be
applied. In most cases, it would be the center of the first object. However, for more complex
physics interactions between bodies, you can set the `anchor` point to a specific location on one or
both of the bodies.

```dart
final frictionJointDef = FrictionJointDef()
  ..initialize(ballBody, floorBody, ballBody.worldCenter)
  ..maxForce = 50
  ..maxTorque = 50;

  world.createJoint(FrictionJoint(frictionJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: friction_joint
:subfolder: stories/bridge_libraries/forge2d/joints
:show: code popup
```

When creating a `FrictionJoint`, simulated friction can be applied via maximum force and torque
values:

- `maxForce`: the maximum translational friction which applied to the joined body. A higher value
- simulates higher friction.

- `maxTorque`: the maximum angular friction which may be applied to the joined body. A higher value
- simulates higher friction.

In other words, the former simulates the friction, when the body is sliding and the latter simulates
the friction when the body is spinning.


### `MotorJoint`

A `MotorJoint` is used to control the relative motion between two bodies. A typical usage is to
control the movement of a dynamic body with respect to the fixed point, for example to create
animations.

A `MotorJoint` lets you control the motion of a body by specifying target position and rotation
offsets. You can set the maximum motor force and torque that will be applied to reach the target
position and rotation. If the body is blocked, it will stop and the contact forces will be
proportional the maximum motor force and torque.

```dart
final motorJointDef = MotorJointDef()
  ..initialize(first, second)
  ..maxTorque = 1000
  ..maxForce = 1000
  ..correctionFactor = 0.1;

  world.createJoint(MotorJoint(motorJointDef));
```

A `MotorJointDef` has three optional parameters:

- `maxForce`: the maximum translational force which will be applied to the joined body to reach the
target position.

- `maxTorque`: the maximum angular force which will be applied to the joined body to reach the
target rotation.

- `correctionFactor`: position correction factor in range [0, 1]. It adjusts the joint's response to
deviation from target position. A higher value makes the joint respond faster, while a lower value
makes it respond slower. If the value is set too high, the joint may overcompensate and oscillate,
becoming unstable. If set too low, it may respond too slowly.
  
The linear and angular offsets are the target distance and angle that the bodies should achieve
relative to each other's position and rotation. By default, the linear target will be the distance
between the two body centers and the angular target will be the relative rotation of the bodies.
Use the `setLinearOffset(Vector2)` and `setLinearOffset(double)` methods of the `MotorJoint` to set
the desired relative translation and rotate between the bodies.

For example, this code increments the angular offset of the joint every update cycle, causing the
body to rotate.

```dart
@override
void update(double dt) {
  super.update(dt);
  
  final angularOffset = joint.getAngularOffset() + motorSpeed * dt;
  joint.setAngularOffset(angularOffset);
}
```
