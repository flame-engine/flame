import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ZoomTestGame()));
}

class ZoomTestGame extends FlameGame with ScaleDetector {
  late RectComponent rect;
  Vector2 zoomCenter = Vector2.zero();

  @override
  Future<void> onLoad() async {
    rect = RectComponent(
      position: size / 2,
      size: Vector2.all(100),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.blue,
    );
    add(rect);
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    zoomCenter = info.eventPosition.game;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final zoomFactor = info.scale.global;
    final before = zoomCenter - camera.position;
    camera.zoom = (camera.zoom * zoomFactor).clamp(0.2, 5.0);
    final after = zoomCenter - camera.position;
    camera.position += before - after;
  }
}

class RectComponent extends PositionComponent {
  final Paint paint;
  RectComponent({
    required super.position,
    required super.size,
    required this.paint,
    super.anchor,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), paint);
  }
}