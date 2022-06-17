import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';

class DragEndEvent extends PositionEvent {
  DragEndEvent(
    this.pointerId,
    DragEndDetails details, {
    required super.devicePosition,
    required super.canvasPosition,
  }) : velocity = details.velocity.pixelsPerSecond.toVector2();

  final int pointerId;

  final Vector2 velocity;

  DragEndInfo asInfo(FlameGame game) {
    return DragEndInfo.fromDetails(
      game,
      DragEndDetails(
        velocity: Velocity(pixelsPerSecond: velocity.toOffset()),
      ),
    );
  }
}
