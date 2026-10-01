/// The smallest hybrid game: Flame on top, flutter3d underneath, one clock.
///
///     flutter create --platforms=macos .    # then switch on Flutter GPU,
///     flutter run -d macos                  # see pubspec.yaml
///
/// Four things, each the least code that shows it:
///
/// * a Flame HUD drawn over the 3D layer, which is the only way round the two
///   layers go: Flame is always on top;
/// * a cube Flame steers with the arrow keys, through `FlameInputBridge` and
///   an `Object3dComponent` that writes Flame's position into the scene;
/// * a crate the physics drops onto a pad, whose landing reaches Flame as an
///   ordinary `onCollisionStart`, through `CollisionBridge`;
/// * one clock: the physics is stepped by a plain Flame component, inside
///   Flame's own update, never by a timer of its own.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart';

void main() => runApp(const HybridApp());

class HybridApp extends StatelessWidget {
  const HybridApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    title: 'Flame over flutter3d',
    debugShowCheckedModeBanner: false,
    home: HybridScreen(),
  );
}

class HybridScreen extends StatefulWidget {
  const HybridScreen({super.key});

  @override
  State<HybridScreen> createState() => _HybridScreenState();
}

class _HybridScreenState extends State<HybridScreen> {
  // Made once and kept: a game made in `build` starts again on every rebuild
  // and never draws a frame.
  final HybridGame _game = HybridGame();

  final CameraNode _camera = CameraNode(name: 'eye')
    ..setPosition(0.0, 4.5, 7.5)
    ..lookAt(Vector3(0.0, 0.5, 0.0));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Flutter3dFlameWidget(
      game: _game,
      camera: _camera,
      buildScene: (GraphicsDevice device) {
        final scene = Scene()..add(_camera);
        _game.buildWorld(device, scene);
        return scene;
      },
    ),
  );
}

/// The game. A [TransparentFlameGame], not a plain `FlameGame`: Flame paints
/// an opaque black background by default, right over the 3D layer.
class HybridGame extends TransparentFlameGame with KeyboardEvents {
  /// Flame's `y` becomes the scene's `z` on a floor half a metre up, where
  /// the cube's centre travels.
  static final BridgePlane floor = BridgePlane.ground(height: 0.5);

  final CollisionWorld collisionWorld = CollisionWorld();
  late final Dynamics dynamics = Dynamics(world: collisionWorld);

  final InputState input = InputState();
  late final FlameInputBridge inputBridge = FlameInputBridge(
    bindings: Bindings(<InputSource, GameAction>{
      InputSource.key(LogicalKeyboardKey.arrowUp.keyId): GameAction.moveForward,
      InputSource.key(LogicalKeyboardKey.arrowDown.keyId): GameAction.moveBack,
      InputSource.key(LogicalKeyboardKey.arrowLeft.keyId): GameAction.moveLeft,
      InputSource.key(LogicalKeyboardKey.arrowRight.keyId):
          GameAction.moveRight,
    }),
    inputState: input,
  );

  late final Object3dComponent cube;
  late final RigidBody crate;
  late final Map<String, Object?> _crateStart;
  late final engine.Material _padMaterial;

  final TextComponent hud = TextComponent(
    text: 'Arrow keys move the cube. Waiting for the crate.',
    position: Vector2(16.0, 16.0),
  );

  /// How many times Flame has heard the crate land.
  int landings = 0;

  double _sinceLanding = -1.0;

  /// The yard, the cube, the crate and the pad, once the device is open.
  void buildWorld(GraphicsDevice device, Scene scene) {
    MeshNode mesh(Shape shape, Vector4 colour) => MeshNode(
      DeviceMesh.upload(device, shape.build()),
      engine.Material(name: 'mesh', baseColor: colour, roughness: 0.6),
    );

    _padMaterial = engine.Material(
      name: 'pad',
      baseColor: Vector4(0.35, 0.4, 0.5, 1.0),
    );
    scene
      ..add(
        mesh(
          const PlaneShape(width: 12.0, depth: 12.0),
          Vector4(0.6, 0.6, 0.58, 1),
        ),
      )
      ..add(
        MeshNode(
          DeviceMesh.upload(
            device,
            CuboidShape(size: Vector3(2.0, 0.05, 2.0)).build(),
          ),
          _padMaterial,
        )..setPosition(2.0, 0.025, 0.0),
      )
      ..add(
        LightNode(intensity: 2.5)..setLocalForward(Vector3(-0.4, -1.0, -0.3)),
      );

    // The floor stops the crate; the pad is a trigger just above it, because
    // the solver rests a body on a surface and never inside it, so the floor
    // itself never reports an overlap.
    collisionWorld.addBox(Vector3(0.0, -0.5, 0.0), Vector3(12.0, 1.0, 12.0));
    final pad = collisionWorld.add(
      Collider(
        shape: CollisionBox(Vector3(1.0, 0.05, 1.0)),
        position: Vector3(2.0, 0.05, 0.0),
        kind: ColliderKind.trigger,
      ),
    );

    // Flame steers this one: Flame's position is written into the scene.
    cube = Object3dComponent(
      node: mesh(
        CuboidShape(size: Vector3.all(1.0)),
        Vector4(0.3, 0.6, 0.95, 1),
      ),
      scene: scene,
      plane: floor,
      direction: SyncDirection.flameToScene,
      position: Vector2(-2.0, 0.0),
    );

    // The physics moves this one, and Flame reads it.
    crate = dynamics.add(
      RigidBody(
        world: collisionWorld,
        shape: CollisionBox(Vector3.all(0.3)),
        position: Vector3(2.0, 4.0, 0.0),
      ),
    );
    _crateStart = crate.save();
    final crateComponent = _CrateComponent(
      body: crate,
      node: mesh(
        CuboidShape(size: Vector3.all(0.6)),
        Vector4(0.8, 0.5, 0.25, 1),
      ),
      scene: scene,
      plane: floor,
      onLanded: _onLanded,
    );
    CollisionBridge(
      collider: crate.collider,
      component: crateComponent,
      // Who the other side is, for Flame. Only the pad has an answer; the
      // floor is level geometry and reports nothing.
      resolveOther: (Collider other) => other == pad ? cube : null,
    );

    addAll(<Component>[
      // Stepped before the components that read the bodies it moves.
      PhysicsStepComponent(
        dynamics: dynamics,
        world: collisionWorld,
        priority: -100,
      ),
      cube,
      crateComponent,
      hud,
    ]);
  }

  void _onLanded() {
    landings++;
    _sinceLanding = 0.0;
    hud.text = 'Flame heard the crate land ($landings)';
    _padMaterial.baseColor.setValues(0.3, 0.8, 0.4, 1.0);
  }

  @override
  void update(double dt) {
    // The cube: Flame's own position, moved by the shared input. Forward is
    // away from the camera, which is -z in the scene and so -y in Flame.
    final axis = input.moveAxis;
    cube.position.add(Vector2(axis.x, -axis.y) * (3.0 * dt));

    // Drop the crate again a little after each landing.
    if (_sinceLanding >= 0.0) {
      _sinceLanding += dt;
      if (_sinceLanding > 2.0) {
        _sinceLanding = -1.0;
        crate.restore(_crateStart);
        _padMaterial.baseColor.setValues(0.35, 0.4, 0.5, 1.0);
      }
    }
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) => inputBridge.onGameKeyEvent(event, keysPressed);
}

/// The crate: a physics body the scene and Flame both follow, and the
/// Flame-side collision callbacks `CollisionBridge` calls.
class _CrateComponent extends RigidBodyComponent {
  _CrateComponent({
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
  }
}
