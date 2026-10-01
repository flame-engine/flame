/// [TransparentFlameGame] does not paint over [Flutter3dFlameWidget]'s 3D
/// layer the way a bare [FlameGame] does.
///
/// A live bug, not a hypothetical: every page and game built on
/// `Flutter3dFlameWidget` before this class existed drew a solid black
/// rectangle over its own 3D scene, because `GameWidget` paints
/// `Game.backgroundColor()` — opaque black by default — as a `DecoratedBox`
/// behind its own canvas, and that canvas sits on top of `SceneSurface` in
/// the `Stack` this package builds. No widget test caught it: mounting a
/// real `GameWidget` under `flutter_test` hangs in this environment (see
/// `flutter3d_flame_widget_test.dart`), so this checks the one thing that
/// does not need a mounted widget — the colour `GameWidget` would read.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a bare FlameGame paints opaque black, the bug this class fixes', () {
    expect(FlameGame().backgroundColor(), const Color(0xFF000000));
  });

  test('TransparentFlameGame paints nothing behind the 3D layer', () {
    expect(TransparentFlameGame().backgroundColor(), const Color(0x00000000));
  });
}
