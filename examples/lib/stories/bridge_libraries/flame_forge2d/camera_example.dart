import 'package:examples/stories/bridge_libraries/flame_forge2d/domino_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/sprite_body_example.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class CameraExample extends Forge2DGame {
  static const String description = '''
    This example showcases the possibility to follow BodyComponents with the
    camera. When the screen is tapped a pizza is added, which the camera will
    follow. Other than that it is the same as the domino example.
  ''';
  CameraExample() : super(world: CameraExampleWorld());
}

class CameraExampleWorld extends DominoExampleWorld {
  @override
  void onTapDown(TapDownEvent info) {
    final position = info.localPosition;
    final pizza = Pizza(position);
    add(pizza);
    pizza.mounted.whenComplete(() => game.camera.follow(pizza));
  }
}
