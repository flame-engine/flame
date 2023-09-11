// ignore_for_file: deprecated_member_use

import 'package:examples/stories/bridge_libraries/flame_forge2d/domino_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/sprite_body_example.dart';
import 'package:flame/input.dart';

class CameraExample extends DominoExample {
  static const String description = '''
    This example showcases the possibility to follow BodyComponents with the
    camera. When the screen is tapped a pizza is added, which the camera will
    follow. Other than that it is the same as the domino example.
  ''';

  @override
  void onTapDown(TapDownInfo info) {
    final position = screenToWorld(info.eventPosition.widget);
    final pizza = Pizza(position);
    world.add(pizza);
    pizza.mounted.whenComplete(() => cameraComponent.follow(pizza));
  }
}
