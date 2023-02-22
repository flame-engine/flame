# Joints

Joints are used to connect two different bodies together in various ways.
They help to simulate interactions between objects to create hinges, wheels, ropes, chains etc.

One `Body` may be `BodyType.static`. 
Joint between `BodyType.static` and/or `BodyType.kinematic` are allowed,
but have no effect and use some processing time.

Currently, Forge2D supports following joints:

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

To construct a `Joint`, you need to create a corresponding subclass of `JointDef` and init it with parameters.

To register a `Joint` use `world.createJoint` and to remove `world.destroyJoint`.

## Built-in joints

### `ConstantVolumeJoint`

This type of joint connects a group of bodies together and maintains a constant volume within them.
Essentially, it is a set of `DistantJoint`, that connects all bodies one after another.

It might be useful for "soft-bodies" simulation.

```{flutter-app}
:sources: ../../../packages/flame_forge2d/example
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

`ConstantVolumeJointDef` requires at least 3 bodies to be added using `addBody` method.

Optional param `frequencyHz` defines the frequency of oscillation of the joint.
If it's not 0, the higher the value is, the less springy each of the compound `DistantJoint` is.

Another optional param `dampingRatio` defines how fast the oscillation comes to rest.
It takes values from 0 to 1, where 0 = no damping, 1 = critical damping.

