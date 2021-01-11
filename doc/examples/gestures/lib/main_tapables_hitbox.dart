import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
<<<<<<< HEAD:doc/examples/gestures/lib/main_tapables_hitbox.dart
=======
import 'package:flame/components/position_component.dart';
import 'package:flame/components/mixins/hitbox.dart';
import 'package:flame/components/mixins/tapable.dart';
>>>>>>> 400d9e14 (Use mixin for hitbox):doc/examples/gestures/lib/main_tapables_hull.dart

void main() {
  runApp(
    Container(
      padding: const EdgeInsets.all(50),
      color: const Color(0xFFA9A9A9),
      child: GameWidget(
        game: MyGame(),
      ),
    ),
  );
}

<<<<<<< HEAD
<<<<<<< HEAD:doc/examples/gestures/lib/main_tapables_hitbox.dart
class TapablePolygon extends PositionComponent with Tapable, Hitbox {
  TapablePolygon({Vector2 position}) {
    size = Vector2.all(100);
    // The hitbox is defined as percentages of the full size of the component
    shape = [
      Vector2(-1.0, 0.0),
      Vector2(-0.8, 0.6),
      Vector2(0.0, 1.0),
      Vector2(0.6, 0.9),
      Vector2(1.0, 0.0),
      Vector2(0.6, -0.8),
      Vector2(0, -1.0),
      Vector2(-0.8, -0.8),
=======
class TapablePolygon extends PositionComponent with Tapable, HasHitbox {
=======
class TapablePolygon extends PositionComponent with Tapable, Hitbox {
>>>>>>> 8534c9bb (Rename HasHitbox to Hitbox)
  TapablePolygon({Vector2 position}) {
    size = Vector2.all(100);
    // The hitbox is defined as percentages of the full size of the component
    hitbox = [
      Vector2(-0.5, 0),
      Vector2(-0.4, 0.3),
      Vector2(0, 0.5),
      Vector2(0.3, 0.45),
      Vector2(0.5, 0),
      Vector2(0.3, -0.4),
      Vector2(0, -0.5),
      Vector2(-0.4, -0.4),
>>>>>>> 400d9e14 (Use mixin for hitbox):doc/examples/gestures/lib/main_tapables_hull.dart
    ];
    this.position = position ?? Vector2.all(150);
  }

  @override
  bool onTapUp(TapUpDetails details) {
    return true;
  }

  @override
  bool onTapDown(TapDownDetails details) {
    angle += 1.0;
    size.add(Vector2.all(10));
    return true;
  }

  @override
  bool onTapCancel() {
    return true;
  }
}

class MyGame extends BaseGame with HasTapableComponents {
  MyGame() {
    debugMode = true;
    add(TapablePolygon()..anchor = Anchor.center);
    add(TapablePolygon()..y = 350);
  }
}
