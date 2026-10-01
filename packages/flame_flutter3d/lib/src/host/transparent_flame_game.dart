import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show Flutter3dFlameWidget;
import 'package:flame_flutter3d/src/host/flutter3d_flame_widget.dart'
    show Flutter3dFlameWidget;
import 'package:flutter/painting.dart' show Color;

/// A [FlameGame] whose background does not paint over
/// [Flutter3dFlameWidget]'s 3D layer.
///
/// **Every bridged game needs this, and nothing enforces it.** `GameWidget`
/// paints `Game.backgroundColor()` as an opaque `DecoratedBox` behind its own
/// canvas — reasonable for a `GameWidget` on its own, and exactly wrong in
/// the `Stack` [Flutter3dFlameWidget] builds, where that box sits on top of
/// `SceneSurface`. `Game.backgroundColor()` defaults to opaque black, so a
/// game that never overrides it draws a solid black rectangle over the 3D
/// layer every frame — the 3D scene still renders underneath, sized and lit
/// correctly, and nothing on screen shows it.
///
/// Extend this instead of [FlameGame], or override [backgroundColor] the
/// same way this class does, and whatever the 2D layer does not cover shows
/// the 3D layer through it.
class TransparentFlameGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}
