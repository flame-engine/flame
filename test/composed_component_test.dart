import 'dart:ui';

import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapeable.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

import 'package:flame/game.dart';
import 'package:flame/components/component.dart';

class MyGame extends BaseGame {}

class MyTap extends PositionComponent with Tapeable, Resizable {
  bool tapped = false;

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void onTapDown(TapDownDetails details) {
    tapped = true;
  }

  @override
  bool checkTapOverlap(Offset o) => true;
}

class MyComposed extends Component with HasGameRef, Tapeable, ComposedComponent {

  @override
  void update(double dt) {}

  @override
  void render(Canvas c) {}

  @override
  Rect toRect() => Rect.zero;
}

class PositionComponentNoNeedForRect extends PositionComponent with Tapeable {
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}
}

const Size size = Size(1.0, 1.0);

void main() {
  group('composable component test', () {
    test('taps and resizes children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed()..add(child);

      game.size = size;
      game.add(wrapper);
      game.onTapDown(TapDownDetails(globalPosition: const Offset(0.0, 0.0)));

      expect(child.size, size);
      expect(child.tapped, true);
    });
  });
}
