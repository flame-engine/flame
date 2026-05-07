import 'dart:async';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/parser.dart';
import 'package:flame_3d_example/example_game_3d.dart';

class ModelsExample extends ExampleGame3D {
  static const perSide = 4;
  static const spacing = 2.0;
  static const distance = 4.0;
  static const offset = -(perSide - 1) * spacing / 2;

  @override
  FutureOr<void> onSetup() async {
    camera.distance = 12;

    final model = await ModelParser.parse('objects/skeleton.glb');

    final allNames = model.animationNames.toList();

    final sides = <({double angle, Vector3 Function(int) pos})>[
      (angle: 180, pos: (i) => Vector3(offset + i * spacing, 0, distance)),
      (angle: 0, pos: (i) => Vector3(offset + i * spacing, 0, -distance)),
      (angle: -90, pos: (i) => Vector3(distance, 0, offset + i * spacing)),
      (angle: 90, pos: (i) => Vector3(-distance, 0, offset + i * spacing)),
    ];

    for (var s = 0; s < sides.length; s++) {
      final side = sides[s];
      for (var i = 0; i < perSide; i++) {
        final nameIndex = (s * perSide + i) % allNames.length;
        world.add(
          ModelComponent(
            model: model,
            position: side.pos(i),
            rotation: Quaternion.axisAngle(
              Vector3(0, 1, 0),
              side.angle * degrees2Radians,
            ),
            scale: Vector3.all(1.0),
          )..playAnimationByName(allNames[nameIndex]),
        );
      }
    }
  }
}
