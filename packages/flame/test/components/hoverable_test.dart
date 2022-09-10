import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:test/test.dart';

void main() {
  group('Hoverable', () {
    testWithGame<_GameWithHoverables>(
      'make sure they can be added to game with HasHoverables',
      _GameWithHoverables.new,
      (game) async {
        await game.add(_HoverableComponent());
        await game.ready();
      },
    );

    testWithFlameGame(
      'make sure they cannot be added to invalid games',
      (game) async {
        expect(
          () async {
            await game.add(_HoverableComponent());
            await game.ready();
          },
          failsAssert(
            'Hoverable Components can only be added to a FlameGame with '
            'HasHoverables',
          ),
        );
      },
    );

    testWithGame<_GameWithHoverables>(
      'single component',
      _GameWithHoverables.new,
      (game) async {
        final c = _HoverableComponent()
          ..position = Vector2(10, 20)
          ..size = Vector2(3, 3);
        await game.ensureAdd(c);

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
      },
    );

    testWithGame<_GameWithHoverables>(
      'camera is respected',
      _GameWithHoverables.new,
      (game) async {
        final c = _HoverableComponent()
          ..position = Vector2(10, 20)
          ..size = Vector2(3, 3);
        await game.ensureAdd(c);

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
      },
    );

    testWithGame<_GameWithHoverables>(
      'multiple components',
      _GameWithHoverables.new,
      (game) async {
        final a = _HoverableComponent()
          ..position = Vector2(10, 0)
          ..size = Vector2(2, 20);
        final b = _HoverableComponent()
          ..position = Vector2(10, 10)
          ..size = Vector2(2, 2);
        final c = _HoverableComponent()
          ..position = Vector2(0, 7)
          ..size = Vector2(20, 2);
        await game.ensureAdd(a);
        await game.ensureAdd(b);
        await game.ensureAdd(c);

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
      },
    );

    testWithGame<_GameWithHoverables>(
      'composed components',
      _GameWithHoverables.new,
      (game) async {
        final parent = _HoverableComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(10);
        final child = _NonPropagatingComponent()
          ..position = Vector2.all(0)
          ..size = Vector2.all(10);
        await parent.add(child);
        await game.ensureAdd(parent);
        _triggerMouseMove(game, 15, 15);
        expect(child.isHovered, true);
        expect(parent.isHovered, false);
        expect(child.enterCount, 1);
        expect(parent.enterCount, 0);
        _triggerMouseMove(game, 35, 35);
        expect(child.isHovered, false);
        expect(parent.isHovered, false);
        expect(child.leaveCount, 1);
        expect(parent.leaveCount, 0);
      },
    );
  });
}

class _GameWithHoverables extends FlameGame with HasHoverables {}

class _HoverableComponent extends PositionComponent with Hoverable {
  int enterCount = 0;
  int leaveCount = 0;

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    enterCount++;
    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    leaveCount++;
    return true;
  }
}

class _NonPropagatingComponent extends _HoverableComponent {
  @override
  bool onHoverEnter(PointerHoverInfo info) {
    super.onHoverEnter(info);
    return false;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    super.onHoverLeave(info);
    return false;
  }
}

// TODO(luan): we can probably provide some helpers to facilitate testing events
void _triggerMouseMove(HasHoverables game, double dx, double dy) {
  game.onMouseMove(
    PointerHoverInfo.fromDetails(
      game,
      PointerHoverEvent(
        position: Offset(dx, dy),
      ),
    ),
  );
}
