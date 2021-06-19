import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/gestures.dart';
import 'package:forge2d_samples/domino_sample.dart';

class CameraSample extends DominoSample {
  @override
  void onTapDown(TapDownInfo details) {
    final Vector2 position = details.eventPosition.game;
    final pizza = Pizza(position, pizzaImage);
    add(pizza);
    final component = pizza.positionComponent;
    camera.followComponent(component);
  }
}
