import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/mixins/hoverable.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:test/test.dart';

class _GameWithHoverables extends FlameGame with HasHoverableComponents {}

class _GameWithoutHoverables extends FlameGame {}

class HoverableComponent extends PositionComponent with Hoverable {
  int enterCount = 0;
  int leaveCount = 0;

  @override
  void onHoverEnter(PointerHoverInfo info) {
    enterCount++;
  }

  @override
  void onHoverLeave(PointerHoverInfo info) {
    leaveCount++;
  }
}

void main() {
  group('hoverable test', () {
    test('make sure they cannot be added to invalid games', () async {
      final game1 = _GameWithHoverables();
      game1.onGameResize(Vector2.all(100));
      // should be ok
      await game1.add(HoverableComponent());

      final game2 = _GameWithoutHoverables();
      game2.onGameResize(Vector2.all(100));

      expect(
        () => game2.add(HoverableComponent()),
        throwsA(isA<AssertionError>()),
      );
    });
    test('single component', () async {
      final game = _GameWithHoverables();
      game.onGameResize(Vector2.all(100));

      final c = HoverableComponent()
        ..position = Vector2(10, 20)
        ..size = Vector2(3, 3);
      await game.add(c);
      game.update(0);

      expect(c.isHovered, false);
      expect(c.enterCount, 0);
      expect(c.leaveCount, 0);

      _triggerMouseMove(game, 0, 0);
      expect(c.isHovered, false);
      expect(c.enterCount, 0);
      expect(c.leaveCount, 0);

      _triggerMouseMove(game, 11, 0);
      expect(c.isHovered, false);
      expect(c.enterCount, 0);
      expect(c.leaveCount, 0);

      _triggerMouseMove(game, 11, 21); // enter!
      expect(c.isHovered, true);
      expect(c.enterCount, 1);
      expect(c.leaveCount, 0);

      _triggerMouseMove(game, 12, 22); // still inside
      expect(c.isHovered, true);
      expect(c.enterCount, 1);
      expect(c.leaveCount, 0);

      _triggerMouseMove(game, 11, 25); // leave
      expect(c.isHovered, false);
      expect(c.enterCount, 1);
      expect(c.leaveCount, 1);

      _triggerMouseMove(game, 11, 21); // enter again
      expect(c.isHovered, true);
      expect(c.enterCount, 2);
      expect(c.leaveCount, 1);
    });
    test('camera is respected', () async {
      final game = _GameWithHoverables();
      game.onGameResize(Vector2.all(100));

      final c = HoverableComponent()
        ..position = Vector2(10, 20)
        ..size = Vector2(3, 3);
      await game.add(c);
      game.update(0);

      // component is now at the corner of the screen
      game.camera.snapTo(Vector2(10, 20));

      _triggerMouseMove(game, 11, 21);
      expect(c.isHovered, false);
      _triggerMouseMove(game, 11, 1);
      expect(c.isHovered, false);
      _triggerMouseMove(game, 1, 1);
      expect(c.isHovered, true);
      _triggerMouseMove(game, 5, 1);
      expect(c.isHovered, false);
    });
    test('multiple components', () async {
      final game = _GameWithHoverables();
      game.onGameResize(Vector2.all(100));

      final a = HoverableComponent()
        ..position = Vector2(10, 0)
        ..size = Vector2(2, 20);
      final b = HoverableComponent()
        ..position = Vector2(10, 10)
        ..size = Vector2(2, 2);
      final c = HoverableComponent()
        ..position = Vector2(0, 7)
        ..size = Vector2(20, 2);
      await game.add(a);
      await game.add(b);
      await game.add(c);
      game.update(0);

      _triggerMouseMove(game, 0, 0);
      expect(a.isHovered, false);
      expect(b.isHovered, false);
      expect(c.isHovered, false);

      _triggerMouseMove(game, 10, 10);
      expect(a.isHovered, true);
      expect(b.isHovered, true);
      expect(c.isHovered, false);

      _triggerMouseMove(game, 11, 8);
      expect(a.isHovered, true);
      expect(b.isHovered, false);
      expect(c.isHovered, true);

      _triggerMouseMove(game, 11, 6);
      expect(a.isHovered, true);
      expect(b.isHovered, false);
      expect(c.isHovered, false);
    });
  });
}

// TODO(luan) we can probably provide some helpers to facilitate testing events
void _triggerMouseMove(HasHoverableComponents game, double dx, double dy) {
  game.onMouseMove(
    PointerHoverInfo.fromDetails(
      game,
      PointerHoverEvent(
        position: Offset(dx, dy),
      ),
    ),
  );
}
