import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  late Svg svgInstance;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    svgInstance.renderPosition(
      canvas,
      Vector2(100, 200),
      Vector2.all(300),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    svgInstance = await loadSvg('android.svg');
    final android = SvgComponent.fromSvg(
      svgInstance,
      position: Vector2.all(100),
      size: Vector2.all(100),
    );
    add(android);
  }
}
