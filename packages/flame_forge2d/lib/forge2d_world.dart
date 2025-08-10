import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:forge2d/forge2d.dart' as forge2d;

/// The root component when using [Forge2DGame], can handle both
/// [BodyComponent]s and normal Flame components.
///
/// Wraps the world class that comes from Forge2D ([forge2d.World]).
class Forge2DWorld extends World {
  Forge2DWorld({
    Vector2? gravity,
    forge2d.ContactListener? contactListener,
    super.children,
  }) : physicsWorld = forge2d.World(gravity ?? defaultGravity)
         ..setContactListener(contactListener ?? WorldContactListener());

  static final Vector2 defaultGravity = Vector2(0, 10.0);

  final forge2d.World physicsWorld;

  @override
  void update(double dt) {
    physicsWorld.stepDt(dt);
  }

  Body createBody(BodyDef def) {
    return physicsWorld.createBody(def);
  }

  void destroyBody(Body body) {
    physicsWorld.destroyBody(body);
  }

  void createJoint(forge2d.Joint joint) {
    physicsWorld.createJoint(joint);
  }

  void destroyJoint(forge2d.Joint joint) {
    physicsWorld.destroyJoint(joint);
  }

  void raycast(RayCastCallback callback, Vector2 point1, Vector2 point2) {
    physicsWorld.raycast(callback, point1, point2);
  }

  void clearForces() {
    physicsWorld.clearForces();
  }

  void queryAABB(forge2d.QueryCallback callback, AABB aabb) {
    physicsWorld.queryAABB(callback, aabb);
  }

  void raycastParticle(
    forge2d.ParticleRaycastCallback callback,
    Vector2 point1,
    Vector2 point2,
  ) {
    physicsWorld.particleSystem.raycast(callback, point1, point2);
  }

  /// Don't change the gravity object directly, use the setter instead.
  Vector2 get gravity => physicsWorld.gravity;

  /// Sets the gravity of the world and wakes up all bodies.
  set gravity(Vector2? gravity) {
    physicsWorld.gravity = gravity ?? defaultGravity;
    for (final body in physicsWorld.bodies) {
      body.setAwake(true);
    }
  }
}
