import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';

void main() {
  final widget = Container(
    padding: const EdgeInsets.all(0),
    color: const Color(0xFFA9A9A9),
    child: GameWidget(
      game: MyGame(),
    ),
  );

  runApp(widget);
}

class DraggableSquare extends PositionComponent with Draggable {
  @override
  bool debugMode = true;
  bool _isDragging = false;

  DraggableSquare({Vector2? position}) {
    size = Vector2.all(100);
    this.position = position ?? Vector2.all(100);
  }

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = _isDragging ? Colors.greenAccent : Colors.purple;
  }

  Vector2? initialPosition;
  Vector2? dragDeltaPosition;

  @override
  bool onDragStart(int pointerId, Vector2 startPosition) {
    initialPosition = startPosition;
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateDetails details) {
    if (initialPosition != null && !_isDragging) {
      _isDragging = true;
      dragDeltaPosition = initialPosition! - position;
    }
    position = details.localPosition.toVector2() - dragDeltaPosition!;
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndDetails details) {
    _isDragging = false;
    return true;
  }
}

class MyGame extends BaseGame with HasDraggableComponents {
  MyGame() {
    add(DraggableSquare()..anchor = Anchor.topLeft);
    add(DraggableSquare()..y = 350);
  }
}
