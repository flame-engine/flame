import 'dart:async';
import 'dart:math';

import 'package:example/crate.dart';
import 'package:example/player_box.dart';
import 'package:example/rotating_light.dart';
import 'package:example/touch_controlled_camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/material.dart' show runApp, Color, Colors;

class ExampleGame3D extends FlameGame3D<World3D, TouchControlledCamera>
    with DragCallbacks, ScrollDetector {
  ExampleGame3D()
      : super(
          world: World3D(clearColor: const Color(0xFFFFFFFF)),
          camera: TouchControlledCamera(),
        );

  @override
  FutureOr<void> onLoad() async {
    world.addAll([
      LightComponent.ambient(
        intensity: 1.0,
      ),
      RotatingLight(),

      LightComponent.point(
        position: Vector3(0, 0.1, 0),
        color: const Color(0xFFFF00FF),
      ),
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.05,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              const Color(0xFFFF00FF),
            ),
          ),
        ),
        position: Vector3(0, 0.1, 0),
      ),

      LightComponent.point(
        position: Vector3(-2, 3, 2),
        color: const Color(0xFFFF2255),
      ),
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.05,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              const Color(0xFFFF2255),
            ),
          ),
        ),
        position: Vector3(-2, 4, 2),
      ),

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
            albedoTexture: ColorTexture(Colors.green),
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
          useFaceNormals: false,
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

  @override
  void onScroll(PointerScrollInfo info) {
    const scrollSensitivity = 0.01;
    final delta = info.scrollDelta.global.y.clamp(-10, 10) * scrollSensitivity;

    camera.distance += delta;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    camera.delta.setValues(event.deviceDelta.x, event.deviceDelta.y);
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    camera.delta.setZero();
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    camera.delta.setZero();
    super.onDragCancel(event);
  }
}

void main() {
  final example = ExampleGame3D();

  runApp(GameWidget(game: example));
}

extension on Random {
  double range(num min, num max) => nextDouble() * (max - min) + min;

  int iRange(int min, int max) => range(min, max).toInt();
}
