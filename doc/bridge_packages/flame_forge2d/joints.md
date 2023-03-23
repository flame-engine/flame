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
- [`MouseJoint`](#mousejoint)
- PrismaticJoint
- [`PulleyJoint`](#pulleyjoint)
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

```{flutter-app}
:sources: ../../examples
:page: motor_joint
:subfolder: stories/bridge_libraries/forge2d/joints
:show: code popup
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


### `MouseJoint`

The `MouseJoint` is used to manipulate bodies with the mouse. It attempts to drive a point on a body
towards the current position of the cursor. There is no restriction on rotation.

The `MouseJoint` definition has a target point, maximum force, frequency, and damping ratio. The
target point initially coincides with the body's anchor point. The maximum force is used to prevent
violent reactions when multiple dynamic bodies interact. You can make this as large as you like.
The frequency and damping ratio are used to create a spring/damper effect similar to the distance
joint.

```{warning}
Many users have tried to adapt the mouse joint for game play. Users often want
to achieve precisepositioning and instantaneous response. The mouse joint 
doesn't work very well in that context. You may wish to consider using 
kinematic bodies instead.
```

```dart
final mouseJointDef = MouseJointDef()
  ..maxForce = 3000 * ballBody.mass * 10
  ..dampingRatio = 1
  ..frequencyHz = 5
  ..target.setFrom(ballBody.position)
  ..collideConnected = false
  ..bodyA = groundBody
  ..bodyB = ballBody;

  mouseJoint = MouseJoint(mouseJointDef);
  world.createJoint(mouseJoint);
}
```

```{flutter-app}
:sources: ../../examples
:page: mouse_joint
:subfolder: stories/bridge_libraries/forge2d/joints
:show: code popup
```

- `maxForce`: This parameter defines the maximum constraint force that can be exerted to move the
  candidate body. Usually you will express as some multiple of the weight
  (multiplier *mass* gravity).

- `dampingRatio`: This parameter defines how quickly the oscillation comes to rest. It ranges from
  0 to 1, where 0 means no damping and 1 indicates critical damping.

- `frequencyHz`: This parameter defines the response speed of the body, i.e. how quickly it tries to
  reach the target position

- `target`: The initial world target point. This is assumed to coincide with the body anchor
  initially.


### `PulleyJoint`

A `PulleyJoint` is used to create an idealized pulley. The pulley connects two bodies to the ground
and to each other. As one body goes up, the other goes down. The total length of the pulley rope is
conserved according to the initial configuration:

```text
length1 + length2 == constant
```

You can supply a ratio that simulates a block and tackle. This causes one side of the pulley to
extend faster than the other. At the same time the constraint force is smaller on one side than the
other. You can use this to create a mechanical leverage.

```text
length1 + ratio * length2 == constant
```

For example, if the ratio is 2, then `length1` will vary at twice the rate of `length2`. Also the
force in the rope attached to the first body will have half the constraint force as the rope
attached to the second body.

```dart
final pulleyJointDef = PulleyJointDef()
  ..initialize(
    firstBody,
    secondBody,
    firstPulley.worldCenter,
    secondPulley.worldCenter,
    firstBody.worldCenter,     
    secondBody.worldCenter,
    1,
  );

world.createJoint(PulleyJoint(pulleyJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: pulley_joint
:subfolder: stories/bridge_libraries/forge2d/joints
:show: code popup
```

The `initialize` method of `PulleyJointDef` requires two ground anchors, two dynamic bodies and
their anchor points, and a pulley ratio.

- `b1`, `b2`: Two dynamic bodies connected with the joint
- `ga1`, `ga2`: Two ground anchors
- `anchor1`, `anchor2`: Anchors on the dynamic bodies the joint will be attached to
- `r`: Pulley ratio to simulate a block and tackle

`PulleyJoint` also provides the current lengths:

```dart
joint.getCurrentLengthA()
joint.getCurrentLengthB()
```

```{warning}
`PulleyJoint` can get a bit troublesome by itself. They often work better when
combined with prismatic joints. You should also cover the the anchor points 
with static shapes to prevent one side from going to zero length.
```
