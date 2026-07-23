import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/joint_renderer.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class WheelJointExample extends Forge2DExampleGame {
  static const description = '''
    This example shows how to use a `WheelJoint`, which is the suspension of
    a vehicle: the wheel can spin and travel along a spring-loaded axis.

    Tap the screen to change the direction that the car drives in.
  ''';

  WheelJointExample()
    : super(
        gravity: Vector2(0, 10.0),
        world: WheelJointWorld(),
        metersToPixels: 14,
      );
}

class WheelJointWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  final joints = <WheelJoint>[];
  static const _motorSpeed = 20.0;
  bool drivingRight = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(Terrain());
    // Keeps the car on the track instead of driving off into the void.
    add(TrackEnd(Terrain.startX));
    add(TrackEnd(Terrain.endX));

    final chassis = Chassis(Vector2(-14, 1));
    await add(chassis);
    // Follow the car so that it stays visible while it drives.
    game.camera.follow(chassis);

    for (final offset in [Vector2(-1.6, 0.9), Vector2(1.6, 0.9)]) {
      final wheel = Wheel(chassis.body.position + offset);
      await add(wheel);

      // The wheel hangs under the chassis on a spring and is driven by the
      // joint's motor.
      final joint = physicsWorld.createWheelJoint(
        WheelJointDef(
          bodyA: chassis.body,
          bodyB: wheel.body,
          localAnchorA: offset,
          localAxisA: Vector2(0, 1),
          hertz: 4,
          dampingRatio: 0.6,
          enableLimit: true,
          lowerTranslation: -0.3,
          upperTranslation: 0.3,
          enableMotor: true,
          maxMotorTorque: 60,
          motorSpeed: _motorSpeed,
        ),
      );
      joints.add(joint);
      add(JointRenderer(joint: joint, color: ExampleColors.amber));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    drivingRight = !drivingRight;
    for (final joint in joints) {
      joint.motorSpeed = drivingRight ? _motorSpeed : -_motorSpeed;
    }
  }
}

class Chassis extends BodyComponent with GlowingBody {
  Chassis(this._position) {
    paint = Paint()..color = ExampleColors.indigo;
  }

  final Vector2 _position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.dynamic, position: _position);
    return world.createBody(bodyDef)..createShape(
      Polygon.box(2.2, 0.5),
      ShapeDef(material: SurfaceMaterial(friction: 0.3)),
    );
  }
}

class Wheel extends BodyComponent with GlowingBody {
  Wheel(this._position) {
    paint = Paint()..color = ExampleColors.emerald;
  }

  final Vector2 _position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(type: BodyType.dynamic, position: _position);
    return world.createBody(bodyDef)..createShape(
      Circle(radius: 0.7),
      ShapeDef(density: 2, material: SurfaceMaterial(friction: 1.5)),
    );
  }
}

/// Rolling hills for the car to drive over, built as a one-sided chain.
class Terrain extends BodyComponent with GlowingBody {
  Terrain() {
    paint = Paint()..color = ExampleColors.slate;
  }

  static const startX = -20.0;
  static const endX = 100.0;

  /// The height of the ground at [x].
  static double heightAt(double x) => 6 - sin((x - startX) / 3) * 1.2;

  @override
  Body createBody() {
    // Chains are one-sided: the solid surface is to the right of the winding
    // direction. Flame's y-axis points down, so listing the ground from left
    // to right is what puts the drivable surface on top.
    final points = <Vector2>[
      for (var x = startX; x <= endX; x++) Vector2(x, heightAt(x)),
    ];

    return world.createBody(BodyDef())..createChain(
      ChainDef(
        points: points,
        materials: [SurfaceMaterial(friction: 0.8)],
      ),
    );
  }
}

/// A wall at the end of the track that the car bumps into.
class TrackEnd extends BodyComponent with GlowingBody {
  TrackEnd(this._x) {
    paint = Paint()..color = ExampleColors.slate;
  }

  final double _x;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(_x, Terrain.heightAt(_x) - 4),
    );
    return world.createBody(bodyDef)..createShape(Polygon.box(0.5, 4));
  }
}
