import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with DragCallbacks {
  static final _paint = Paint()..color = Colors.white;
  @override
  void onDragEnd(DragEndEvent event) {
    //TODO: implements onDragEnd
  }
  @override
  void onDragCancel(DragCancelEvent event) {
    // TODO: implement onDragCancel
  }

  @override
  void onDragStart(DragStartEvent event) {
    // TODO: implement onDragStart
  }
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // TODO: implement onDragUpdate
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}

class SpaceShooterGame extends FlameGame with HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: SpaceShooterGame());
  }
}
