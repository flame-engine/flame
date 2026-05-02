import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HoverCallbacks', () {
    testWithFlameGame(
      'make sure HoverCallbacks components can be added to a FlameGame',
      (game) async {
        await game.ensureAdd(_HoverCallbacksComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame('receive hover events', (game) async {
      final component = _HoverCallbacksComponent(
        position: Vector2.all(10),
        size: Vector2.all(10),
      );
      game.add(component);
      await game.ready();

      _hasDispatcher(game);

      _mouseEvent(game, Vector2.all(12));
      component.checkHoverEventCounts(enter: 1, exit: 0);

      _mouseEvent(game, Vector2.all(14));
      component.checkHoverEventCounts(enter: 1, exit: 0);

      _mouseEvent(game, Vector2.all(16));
      component.checkHoverEventCounts(enter: 1, exit: 0);

      _mouseEvent(game, Vector2.all(18));
      component.checkHoverEventCounts(enter: 1, exit: 0);

      _mouseEvent(game, Vector2.all(20));
      component.checkHoverEventCounts(enter: 1, exit: 1);

      _mouseEvent(game, Vector2.all(22));
      component.checkHoverEventCounts(enter: 1, exit: 1);

      _mouseEvent(game, Vector2.all(18));
      component.checkHoverEventCounts(enter: 2, exit: 1);

      _mouseEvent(game, Vector2.all(19));
      component.checkHoverEventCounts(enter: 2, exit: 1);

      _mouseEvent(game, Vector2.all(20));
      component.checkHoverEventCounts(enter: 2, exit: 2);
    });

    testWidgets(
      'fires enter and exit while the mouse button is held (regression #2741)',
      (tester) async {
        final component = _HoverCallbacksComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await tester.pumpWidget(
          GameWidget(game: FlameGame(children: [component])),
        );
        await tester.pump();

        final pointer = TestPointer(1, PointerDeviceKind.mouse);

        // Hover into the component — no buttons pressed.
        await tester.sendEventToBinding(pointer.hover(const Offset(15, 15)));
        component.checkHoverEventCounts(enter: 1, exit: 0);

        // Press the primary button while hovering.
        await tester.sendEventToBinding(pointer.down(const Offset(15, 15)));

        // Drag out of the component while still pressed — onHoverExit must
        // fire even though no PointerHoverEvent is produced during a press.
        await tester.sendEventToBinding(
          pointer.move(const Offset(40, 40), buttons: kPrimaryButton),
        );
        component.checkHoverEventCounts(enter: 1, exit: 1);

        // Drag back into the component while still pressed — onHoverEnter
        // must fire again.
        await tester.sendEventToBinding(
          pointer.move(const Offset(15, 15), buttons: kPrimaryButton),
        );
        component.checkHoverEventCounts(enter: 2, exit: 1);

        await tester.sendEventToBinding(pointer.up());
      },
    );
  });
}

void _mouseEvent(FlameGame game, Vector2 position) {
  game.firstChild<PointerMoveDispatcher>()!.onMouseMove(
    createMouseMoveEvent(
      game: game,
      position: position,
    ),
  );
}

void _hasDispatcher(FlameGame game) {
  expect(
    game.children.whereType<PointerMoveDispatcher>(),
    hasLength(1),
  );
}

mixin _HoverInspector on HoverCallbacks {
  int hoverEnterEvent = 0;
  int hoverExitEvent = 0;

  void checkHoverEventCounts({required int enter, required int exit}) {
    expect(
      hoverEnterEvent,
      equals(enter),
      reason: 'Mismatched hover enter event count',
    );
    expect(
      hoverExitEvent,
      equals(exit),
      reason: 'Mismatched hover exit event count',
    );
  }

  @override
  void onHoverEnter() {
    hoverEnterEvent++;
  }

  @override
  void onHoverExit() {
    hoverExitEvent++;
  }
}

class _HoverCallbacksComponent extends PositionComponent
    with HoverCallbacks, _HoverInspector {
  _HoverCallbacksComponent({
    super.position,
    super.size,
  });
}
