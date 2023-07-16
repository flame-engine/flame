import 'package:flame/components.dart';
import 'package:flame_forge2d/world_contact_listener.dart';
import 'package:forge2d/forge2d.dart' as forge2d;
import 'package:forge2d/forge2d.dart' hide World;

class Forge2DWorld extends World {
  final forge2d.World physicsWorld;

  static final Vector2 defaultGravity = Vector2(0, 10.0);

  Forge2DWorld({
    Vector2? gravity,
    forge2d.ContactListener? contactListener,
  }) : physicsWorld = forge2d.World(gravity ?? defaultGravity)
          ..setContactListener(contactListener ?? WorldContactListener());

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
}
