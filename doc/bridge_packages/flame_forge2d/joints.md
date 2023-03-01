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
- MotorJoint
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

```{flutter-app}
:sources: ../../examples
:page: constant_volume_joint
:show: widget code infobox
:width: 200
:height: 200
```

```dart
  final constantVolumeJoint = ConstantVolumeJointDef()
    ..frequencyHz = 10
    ..dampingRatio = 0.8;

  bodies.forEach((body) {
    constantVolumeJoint.addBody(body);
  });
    
  world.createJoint(ConstantVolumeJoint(world, constantVolumeJoint));
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

```{flutter-app}
:sources: ../../examples
:page: distance_joint
:show: widget code infobox
:width: 200
:height: 200
```

```dart
final distanceJointDef = DistanceJointDef()
  ..initialize(firstBody, secondBody, firstBody.worldCenter, secondBody.worldCenter)
  ..length = 10
  ..frequencyHz = 3
  ..dampingRatio = 0.2;

world.createJoint(DistanceJoint(distanceJointDef));
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

A `FrictionJoint` is used for top-down friction. It provides 2D translational friction and angular
friction.

The `initialize` method requires two bodies and an anchor. The first body is the body the friction
will be applied to. The second body can be any body in the world, like a floor or an invisible
body. The reason is that the friction force will be applied to the first body when it collides with
any other bodies, not only the second body of the joint.

The third parameter is the anchor point in the world where the friction force will be applied.

```{flutter-app}
:sources: ../../examples
:page: friction_joint
:show: widget code infobox
:width: 200
:height: 200
```

```dart
final frictionJointDef = FrictionJointDef()
  ..initialize(ballBody, borderBody, ballBody.worldCenter)
  ..maxForce = 50
  ..maxTorque = 50;

  world.createJoint(FrictionJoint(frictionJointDef));
```

When creating a `FrictionJoint`, simulated friction can be applied via maximum force and torque
values:

- `maxForce`: the maximum translational friction which applied to the joined body. A higher value
- simulates higher friction.

- `maxTorque`: the maximum angular friction which may be applied to the joined body. A higher value
- simulates higher friction.

In other words, the former simulates the friction, when the body is sliding and the latter simulates
the friction when the body is spinning.
