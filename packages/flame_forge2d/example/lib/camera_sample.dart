import 'package:flame/input.dart';

import 'domino_sample.dart';

class CameraSample extends DominoSample {
  @override
  void onTapDown(TapDownInfo details) {
    final position = details.eventPosition.game;
    final pizza = Pizza(position, pizzaImage);
    add(pizza);
    final component = pizza.positionComponent;
    camera.followComponent(component);
  }
}
