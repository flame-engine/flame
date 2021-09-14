import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:forge2d/forge2d.dart' hide Timer;

import 'contact_callbacks.dart';
import 'forge2d_camera.dart';

class Forge2DGame extends FlameGame {
  static final Vector2 defaultGravity = Vector2(0, -10.0);
  static const double defaultZoom = 10.0;

  final World world;

  final ContactCallbacks _contactCallbacks = ContactCallbacks();

  @override
  final Forge2DCamera camera = Forge2DCamera();

  Forge2DGame({
    Vector2? gravity,
    double zoom = defaultZoom,
  }) : world = World(gravity ?? defaultGravity) {
    camera.zoom = zoom;
    world.setContactListener(_contactCallbacks);
  }

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);

    switch (state) {
      case AppLifecycleState.resumed:
        resumeEngine();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        pauseEngine();
        break;
    }
  }

  void addContactCallback(ContactCallback callback) {
    _contactCallbacks.register(callback);
  }

  void removeContactCallback(ContactCallback callback) {
    _contactCallbacks.deregister(callback);
  }

  void clearContactCallbacks() {
    _contactCallbacks.clear();
  }

  Vector2 worldToScreen(Vector2 position) => projectVector(position);
  Vector2 screenToWorld(Vector2 position) => unprojectVector(position);
}
