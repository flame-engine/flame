# Joints

Joints are used to connect two different bodies together in various ways.
They help to simulate interactions between objects to create hinges, wheels, ropes, chains etc.

One `Body` in a joint may be of type `BodyType.static`.
Joints between `BodyType.static` and/or `BodyType.kinematic` are allowed,
but have no effect and use some processing time.

To construct a `Joint`, you need to create a corresponding subclass of `JointDef`
and initialize it with its parameters.

To register a `Joint` use `world.createJoint`
and later use `world.destroyJoint` when you want to remove it.


## Built-in joints

Currently, Forge2D supports the following joints:

- [`ConstantVolumeJoint`](#constantvolumejoint)
- DistanceJoint
- FrictionJoint
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
Essentially, it is a set of `DistanceJoint`s, that connects all bodies one after another.

It can for example be useful when simulating "soft-bodies".

```{flutter-app}
:sources: ../../../examples/stories/bridge_libraries/forge2d/joints/
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

`ConstantVolumeJointDef` requires at least 3 bodies to be added using the `addBody` method.

Optional param `frequencyHz` defines the frequency of oscillation of the joint.
If it's not 0, the higher the value is, the less springy each of the compound `DistantJoint`s are.

Another optional parameter is `dampingRatio`, it defines how fast the oscillation comes to rest.
It takes values from 0 to 1, where 0 = no damping, 1 = critical damping.

