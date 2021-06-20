import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame/palette.dart';
import 'package:flame/components.dart';

import 'balls.dart';
import 'boundaries.dart';

class TapableSample extends Forge2DGame with HasTapableComponents {
  TapableSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final center = screenToWorld(viewport.effectiveSize / 2);
    add(TapableBall(center));
  }
}

class TapableBall extends Ball with Tapable {
  TapableBall(Vector2 position) : super(position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  bool onTapDown(_) {
    body.applyLinearImpulse(Vector2.random() * 1000);
    paint = randomPaint();
    return false;
  }
}
