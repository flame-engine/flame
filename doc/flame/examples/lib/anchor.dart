import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class AnchorGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final parent = RectangleComponent(
      size: size / 2,
      paint: BasicPalette.red.paint(),
      position: size / 2,
    );
    await add(parent);
  }
}
