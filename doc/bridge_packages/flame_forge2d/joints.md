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
- [`GearJoint`](#gearjoint)
- [`MotorJoint`](#motorjoint)
- [`MouseJoint`](#mousejoint)
- [`PrismaticJoint`](#prismaticjoint)
- [`PulleyJoint`](#pulleyjoint)
- [`RevoluteJoint`](#revolutejoint)
- [`RopeJoint`](#ropejoint)
- [`WeldJoint`](#weldjoint)
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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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


### `GearJoint`

The `GearJoint` is used to connect two joints together. Joints are required to be a
[`RevoluteJoint`](#revolutejoint) or a [`PrismaticJoint`](#prismaticjoint) in any combination.

```{warning}
The connected joints must attach a dynamic body to a static body. 
The static body is expected to be a bodyA on those joints
```

```dart
final gearJointDef = GearJointDef()
  ..bodyA = firstJoint.bodyA
  ..bodyB = secondJoint.bodyA
  ..joint1 = firstJoint
  ..joint2 = secondJoint
  ..ratio = 1;

world.createJoint(GearJoint(gearJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: gear_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `joint1`, `joint2`: Connected revolute or prismatic joints
- `bodyA`, `bodyB`: Any bodies form the connected joints, as long as they are not the same body.
- `ratio`: Gear ratio

Similarly to [`PulleyJoint`](#pulleyjoint), you can specify a gear ratio to bind the motions
together:

```text
coordinate1 + ratio * coordinate2 == constant 
```

The ratio can be negative or positive. If one joint is a `RevoluteJoint` and the other joint is a
`PrismaticJoint`, then the ratio will have units of length or units of 1/length.

Since the `GearJoint` depends on two other joints, if these are destroyed, the `GearJoint` needs to
be destroyed as well.

```{warning}
Manually destroy the `GearJoint` if joint1 or joint2 is destroyed
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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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
to achieve precise positioning and instantaneous response. The mouse joint 
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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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


### `PrismaticJoint`

The `PrismaticJoint` provides a single degree of freedom, allowing for a relative translation of two
bodies along an axis fixed in bodyA. Relative rotation is prevented.

`PrismaticJointDef` requires defining a line of motion using an axis and an anchor point.
The definition uses local anchor points and a local axis so that the initial configuration
can violate the constraint slightly.

The joint translation is zero when the local anchor points coincide in world space.
Using local anchors and a local axis helps when saving and loading a game.

```{warning}
At least one body should by dynamic with a non-fixed rotation.
```

The `PrismaticJoint` definition is similar to the [`RevoluteJoint`](#revolutejoint) definition, but
instead of rotation, it uses translation.

```dart
final prismaticJointDef = PrismaticJointDef()
  ..initialize(
    dynamicBody,
    groundBody,
    dynamicBody.worldCenter,
    Vector2(1, 0),
  )
```

```{flutter-app}
:sources: ../../examples
:page: prismatic_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `b1`, `b2`: Bodies connected by the joint.
- `anchor`: World anchor point, to put the axis through. Usually the center of the first body.
- `axis`: World translation axis, along which the translation will be fixed.

In some cases you might wish to control the range of motion. For this, the `PrismaticJointDef` has
optional parameters that allow you to simulate a joint limit and/or a motor.


#### Prismatic Joint Limit

You can limit the relative rotation with a joint limit that specifies a lower and upper translation.

```dart
jointDef
  ..enableLimit = true
  ..lowerTranslation = -20
  ..upperTranslation = 20;
```

- `enableLimit`: Set to true to enable translation limits
- `lowerTranslation`: The lower translation limit in meters
- `upperTranslation`: The upper translation limit in meters

You change the limits after the joint was created with this method:

```dart
prismaticJoint.setLimits(-10, 10);
```


#### Prismatic Joint Motor

You can use a motor to drive the motion or to model joint friction. A maximum motor force is
provided so that infinite forces are not generated.

```dart
jointDef
  ..enableMotor = true
  ..motorSpeed = 1
  ..maxMotorForce = 100;
```

- `enableMotor`: Set to true to enable the motor
- `motorSpeed`: The desired motor speed in radians per second
- `maxMotorForce`: The maximum motor torque used to achieve the desired motor speed in N-m.

You change the motor's speed and force after the joint was created using these methods:

```dart
prismaticJoint.setMotorSpeed(2);
prismaticJoint.setMaxMotorForce(200);
```

Also, you can get the joint angle and speed using the following methods:

```dart
prismaticJoint.getJointTranslation();
prismaticJoint.getJointSpeed();
```


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
:subfolder: stories/bridge_libraries/flame_forge2d/joints
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


### `RevoluteJoint`

A `RevoluteJoint` forces two bodies to share a common anchor point, often called a hinge point.
The revolute joint has a single degree of freedom: the relative rotation of the two bodies.

To create a `RevoluteJoint`, provide two bodies and a common point to the `initialize` method.
The definition uses local anchor points so that the initial configuration can violate the
constraint slightly.

```dart
final jointDef = RevoluteJointDef()
  ..initialize(firstBody, secondBody, firstBody.position);
world.createJoint(RevoluteJoint(jointDef));
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
jointDef
  ..enableLimit = true
  ..lowerAngle = 0
  ..upperAngle = pi / 2;
```

- `enableLimit`: Set to true to enable angle limits
- `lowerAngle`: The lower angle in radians
- `upperAngle`: The upper angle in radians

You change the limits after the joint was created with this method:

```dart
revoluteJoint.setLimits(0, pi);
```


#### Revolute Joint Motor

You can use a motor to drive the relative rotation about the shared point. A maximum motor torque is
provided so that infinite forces are not generated.

```dart
jointDef
  ..enableMotor = true
  ..motorSpeed = 5
  ..maxMotorTorque = 100;
```

- `enableMotor`: Set to true to enable the motor
- `motorSpeed`: The desired motor speed in radians per second
- `maxMotorTorque`: The maximum motor torque used to achieve the desired motor speed in N-m.

You change the motor's speed and torque after the joint was created using these methods:

```dart
revoluteJoint.setMotorSpeed(2);
revoluteJoint.setMaxMotorTorque(200);
```

Also, you can get the joint angle and speed using the following methods:

```dart
revoluteJoint.jointAngle();
revoluteJoint.jointSpeed();
```


### `RopeJoint`

A `RopeJoint` restricts the maximum distance between two points on two bodies.

`RopeJointDef` requires two body anchor points and the maximum length.

```dart
final ropeJointDef = RopeJointDef()
  ..bodyA = firstBody
  ..localAnchorA.setFrom(firstBody.getLocalCenter())
  ..bodyB = secondBody
  ..localAnchorB.setFrom(secondBody.getLocalCenter())
  ..maxLength = (secondBody.worldCenter - firstBody.worldCenter).length;

world.createJoint(RopeJoint(ropeJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: rope_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: Connected bodies
- `localAnchorA`, `localAnchorB`: Optional parameter, anchor point relative to the body's origin.
- `maxLength`: The maximum length of the rope. This must be larger than `linearSlop`, or the joint
will have no effect.

```{warning}
The joint assumes that the maximum length doesn't change during simulation. 
See `DistanceJoint` if you want to dynamically control length.
```


### `WeldJoint`

A `WeldJoint` is used to restrict all relative motion between two bodies, effectively joining them
together.

`WeldJointDef` requires two bodies that will be connected, and a world anchor:

```dart
final weldJointDef = WeldJointDef()
  ..initialize(bodyA, bodyB, anchor);

world.createJoint(WeldJoint(weldJointDef));
```

```{flutter-app}
:sources: ../../examples
:page: weld_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: Two bodies that will be connected

- `anchor`: Anchor point in world coordinates, at which two bodies will be welded together
  to 0, the higher the value, the less springy the joint becomes.


#### Breakable Bodies and WeldJoint

Since the Forge2D constraint solver is iterative, joints are somewhat flexible. This means that the
bodies connected by a WeldJoint may bend slightly. If you want to simulate a breakable body, it's
better to create a single body with multiple fixtures. When the body breaks, you can destroy a
fixture and recreate it on a new body instead of relying on a `WeldJoint`.
