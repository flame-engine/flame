import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'domino_example.dart';
import 'sprite_body_example.dart';

class CameraExample extends DominoExample {
  static const String description = '''
    This example showcases the possibility to follow BodyComponents with the
    camera. When the screen is tapped a pizza is added, which the camera will
    follow. Other than that it is the same as the domino example.
  ''';

  @override
  void onTapDown(TapDownInfo details) {
    final position = details.eventPosition.game;
    final pizza = Pizza(position);
    add(pizza);
    pizza.mounted.whenComplete(() => camera.followBodyComponent(pizza));
  }
}
