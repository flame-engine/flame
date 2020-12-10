import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

class MyGame extends BaseGame with HasTapableComponents {}

class MyTap extends PositionComponent with Tapable, Resizable {
  bool tapped = false;
  bool updated = false;
  bool rendered = false;

  @override
  void update(double dt) {
    super.update(dt);
    updated = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    rendered = true;
  } 
  
  @override
  bool onTapDown(TapDownDetails details) {
    tapped = true;
    return true;
  }

  @override
  bool checkOverlap(Vector2 v) => true;
}

class MyComposed extends PositionComponent with HasGameRef, Tapable {
  @override
  Rect toRect() => Rect.zero;
}

class PositionComponentNoNeedForRect extends PositionComponent with Tapable {}

Vector2 size = Vector2(1.0, 1.0);

void main() {
  group('composable component test', () {
    test('taps and resizes children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();

      game.size = size;
      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);
      game.onTapDown(1, TapDownDetails(globalPosition: const Offset(0.0, 0.0)));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    test('updates and renders children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();

      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);

      //expect(child.rendered, true);
      expect(child.updated, true);
    });
  });
}
