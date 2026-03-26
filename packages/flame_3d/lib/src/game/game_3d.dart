import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:meta/meta.dart';

mixin Game3D on Game {
  @internal
  final GraphicsDevice device = GraphicsDevice();

  @internal
  late final RenderContext3D context = RenderContext3D(device);

  @override
  void render(Canvas canvas) {
    device.begin();
    super.render(canvas);
    device.end();
  }
}
