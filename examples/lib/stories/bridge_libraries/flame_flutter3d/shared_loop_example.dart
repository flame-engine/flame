import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_flutter3d/story_host.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_sim/flutter3d_sim.dart';

class SharedLoopExample extends FlameGame with HasFlutter3d {
  static const String description = '''
    Flame and flutter3d on one clock. The crates are Flame components: their
    `MoveEffect`, `RotateEffect` and `ScaleEffect` are Flame's own, and each
    frame the bridge writes where Flame put them into the 3D scene, after
    the effects have run.

    Tap a crate: the tap is tested against what is drawn in perspective,
    not against Flame's flat rectangle, and the crate flashes through a
    `TintEffect`. The falling box is simulated by flutter3d's physics,
    stepped as a Flame component, and its landing on the pad reaches Flame
    as an ordinary `onCollisionStart`.
  ''';

  static final BridgePlane floor = BridgePlane.ground(height: 0.5);

  final CollisionWorld collisionWorld = CollisionWorld();
  late final Dynamics dynamics = Dynamics(world: collisionWorld);

  final TextComponent hud = TextComponent(position: Vector2.all(16));

  int taps = 0;
  int landings = 0;

  @override
  CameraNode createCamera3d() =>
      CameraNode(
          name: 'camera',
          projection: const PerspectiveProjection(fovYRadians: 0.8, far: 200),
        )
        ..setPosition(0, 6, 8)
        ..lookAt(Vector3(0, 0, -1));

  @override
  void onOpen3d() {
    clearColor.setValues(0.55, 0.7, 0.85, 1);
    MeshNode mesh(Shape shape, Vector4 color) => MeshNode(
      DeviceMesh.upload(device, shape.build()),
      engine.Material(name: 'mesh', baseColor: color, roughness: 0.6),
    );

    scene
      ..add(
        mesh(
          const PlaneShape(width: 16, depth: 16),
          Vector4(0.55, 0.6, 0.5, 1),
        ),
      )
      ..add(
        LightNode(intensity: 2.5)..setLocalForward(Vector3(-0.4, -1, -0.3)),
      );

    // Three crates moved by Flame's effects alone.
    final crates = [
      for (var i = 0; i < 3; i++)
        _Crate(
          node: mesh(CuboidShape(size: Vector3.all(1)), _crateColor),
          scene: scene,
          plane: floor,
          position: Vector2(-3 + 3.0 * i, -3),
          onTapped: _onTapped,
        ),
    ];
    crates[0].add(
      MoveEffect.by(
        Vector2(0, 3),
        EffectController(duration: 1.5, alternate: true, infinite: true),
      ),
    );
    crates[1].add(
      RotateEffect.by(
        2 * math.pi,
        EffectController(duration: 3, infinite: true),
      ),
    );
    crates[2].add(
      ScaleEffect.to(
        Vector2.all(1.6),
        EffectController(duration: 0.8, alternate: true, infinite: true),
      ),
    );

    // The physics: a floor, a trigger pad on it, and a box dropped onto it.
    collisionWorld.addBox(Vector3(0, -0.5, 0), Vector3(16, 1, 16));
    final pad = collisionWorld.add(
      Collider(
        shape: CollisionBox(Vector3(1, 0.05, 1)),
        position: Vector3(0, 0.05, 1.5),
        kind: ColliderKind.trigger,
      ),
    );
    final padNode = mesh(
      CuboidShape(size: Vector3(2, 0.05, 2)),
      Vector4(0.35, 0.4, 0.5, 1),
    )..setPosition(0, 0.025, 1.5);
    scene.add(padNode);

    final box = dynamics.add(
      RigidBody(
        world: collisionWorld,
        shape: CollisionBox(Vector3.all(0.3)),
        position: Vector3(0, 3, 1.5),
      ),
    );
    final boxComponent = _FallingBox(
      body: box,
      node: mesh(
        CuboidShape(size: Vector3.all(0.6)),
        Vector4(0.9, 0.5, 0.2, 1),
      ),
      scene: scene,
      plane: floor,
      onLanded: _onLanded,
    );
    CollisionBridge(
      collider: box.collider,
      component: boxComponent,
      resolveOther: (other) => other == pad ? crates[1] : null,
    );

    addAll([
      PhysicsStepComponent(dynamics: dynamics, world: collisionWorld),
      ...crates,
      boxComponent,
      Taps3dComponent(),
      hud,
    ]);
    _updateHud();
  }

  static final Vector4 _crateColor = Vector4(0.75, 0.55, 0.35, 1);

  void _onTapped(_Crate crate) {
    taps++;
    crate.add(
      TintEffect(
        Vector4(1, 0.25, 0.25, 1),
        EffectController(duration: 0.15, alternate: true),
      ),
    );
    _updateHud();
  }

  void _onLanded() {
    landings++;
    _updateHud();
  }

  void _updateHud() {
    hud.text =
        'Drawn with ${backendName(device)}. '
        'Taps: $taps. Landings heard by Flame: $landings.';
  }
}

class _Crate extends Object3dComponent with Tap3dCallbacks {
  _Crate({
    required super.node,
    required super.scene,
    required super.plane,
    required super.position,
    required this.onTapped,
  }) : super(
         direction: SyncDirection.flameToScene,
         size: Vector2.all(1),
         anchor: Anchor.center,
       );

  final void Function(_Crate crate) onTapped;

  @override
  void onTap3d(Vector2 screen) => onTapped(this);
}

/// A box the physics drops; it is dropped again a while after each landing.
class _FallingBox extends RigidBodyComponent {
  _FallingBox({
    required super.body,
    required super.node,
    required super.scene,
    required super.plane,
    required this.onLanded,
  });

  final void Function() onLanded;

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    onLanded();
    add(TimerComponent(period: 1.5, removeOnFinish: true, onTick: _drop));
  }

  void _drop() => teleport(Vector3(0, 3, 1.5));
}
