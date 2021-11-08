import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/mixins/hoverable.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:test/test.dart';

class _GameWithHoverables extends FlameGame with HasHoverableComponents {}

final withHoverables = FlameTester(() => _GameWithHoverables());

class _GameWithoutHoverables extends FlameGame {}

final withoutHoverables = FlameTester(() => _GameWithoutHoverables());

class HoverableComponent extends PositionComponent with Hoverable {
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

class NonPropagatingComponent extends HoverableComponent {
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

void main() {
  group('hoverable test', () {
    withHoverables.test(
      'make sure they cannot be added to invalid games',
      (game) async {
        // should be ok
        await game.add(HoverableComponent());

        final game2 = _GameWithoutHoverables();
        game2.onGameResize(Vector2.all(100));

        const message =
            'Hoverable Components can only be added to a FlameGame with '
            'HasHoverableComponents';

        expect(
          () => game2.add(HoverableComponent()),
          throwsA(
            predicate(
              (e) => e is AssertionError && e.message == message,
            ),
          ),
        );
      },
    );

    withHoverables.test(
      'single component',
      (game) async {
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
      },
    );

    withHoverables.test(
      'camera is respected',
      (game) async {
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
      },
    );

    withHoverables.test(
      'multiple components',
      (game) async {
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
      },
    );

    withHoverables.test(
      'composed components',
      (game) async {
        final parent = HoverableComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(10);
        final child = NonPropagatingComponent()
          ..position = Vector2.all(0)
          ..size = Vector2.all(10);
        await parent.add(child);
        await game.add(parent);
        game.update(0);
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
