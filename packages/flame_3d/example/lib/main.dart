import 'dart:async';
import 'dart:math';

import 'package:example/crate.dart';
import 'package:example/keyboard_controlled_camera.dart';
import 'package:example/player_box.dart';
import 'package:example/rotating_light.dart';
import 'package:example/simple_hud.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart' as v64 show Vector2;
import 'package:flame/game.dart' show FlameGame, GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show runApp, Color, Colors, Listener;

class ExampleGame3D extends FlameGame<World3D>
    with HasKeyboardHandlerComponents {
  ExampleGame3D()
      : super(
          world: World3D(clearColor: const Color(0xFFFFFFFF)),
          camera: KeyboardControlledCamera(
            viewport: FixedResolutionViewport(
              resolution: v64.Vector2(800, 600),
            ),
            hudComponents: [SimpleHud()],
          ),
        );

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  FutureOr<void> onLoad() async {
    world.addAll([
      RotatingLight(),

      // Add a player box
      PlayerBox(),

      // Floating crate
      Crate(size: Vector3.all(1), position: Vector3(0, 5, 0)),

      // Floating sphere
      MeshComponent(
        position: Vector3(5, 5, 5),
        mesh: SphereMesh(
          radius: 1,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(Colors.purple),
          ),
        ),
      ),

      // Floor
      MeshComponent(
        mesh: PlaneMesh(
          size: Vector2(32, 32),
          material: SpatialMaterial(albedoTexture: ColorTexture(Colors.grey)),
        ),
      ),

      // Front wall
      MeshComponent(
        position: Vector3(16.5, 2.5, 0),
        mesh: CuboidMesh(
          size: Vector3(1, 5, 32),
          material: SpatialMaterial(albedoTexture: ColorTexture(Colors.yellow)),
        ),
      ),

      // Left wall
      MeshComponent(
        position: Vector3(0, 2.5, 16.5),
        mesh: CuboidMesh(
          size: Vector3(32, 5, 1),
          material: SpatialMaterial(albedoTexture: ColorTexture(Colors.blue)),
        ),
      ),

      // Right wall
      MeshComponent(
        position: Vector3(0, 2.5, -16.5),
        mesh: CuboidMesh(
          size: Vector3(32, 5, 1),
          material: SpatialMaterial(albedoTexture: ColorTexture(Colors.lime)),
        ),
      ),
    ]);

    final rnd = Random();
    for (var i = 0; i < 20; i++) {
      final height = rnd.range(1, 12);

      world.add(
        MeshComponent(
          position: Vector3(rnd.range(-15, 15), height / 2, rnd.range(-15, 15)),
          mesh: CuboidMesh(
            size: Vector3(1, height, 1),
            material: SpatialMaterial(
              albedoTexture: ColorTexture(
                Color.fromRGBO(rnd.iRange(20, 255), rnd.iRange(10, 55), 30, 1),
              ),
            ),
          ),
        ),
      );
    }
  }
}

void main() {
  final example = ExampleGame3D();

  runApp(
    Listener(
      onPointerMove: (event) {
        if (!event.down) {
          return;
        }
        example.camera.pointerEvent = event;
      },
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent || !event.down) {
          return;
        }
        example.camera.scrollMove = event.delta.dy / 3000;
      },
      onPointerUp: (event) => example.camera.pointerEvent = null,
      onPointerCancel: (event) => example.camera.pointerEvent = null,
      child: GameWidget(game: example),
    ),
  );
}

extension on Random {
  double range(num min, num max) => nextDouble() * (max - min) + min;

  int iRange(int min, int max) => range(min, max).toInt();
}
