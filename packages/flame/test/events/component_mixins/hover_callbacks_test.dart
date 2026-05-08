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
      'fires onHoverCancel when a button is pressed mid-hover '
      '(regression #2741)',
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
        component.checkHoverEventCounts(enter: 1, exit: 0, cancel: 0);

        // Press the primary button while hovering — onHoverCancel must fire
        // (not onHoverExit; the press semantically ends the hover).
        await tester.sendEventToBinding(pointer.down(const Offset(15, 15)));
        component.checkHoverEventCounts(enter: 1, exit: 0, cancel: 1);

        // Drag around while pressed — no further hover events should fire,
        // because we are no longer hovering anything until release.
        await tester.sendEventToBinding(
          pointer.move(const Offset(40, 40), buttons: kPrimaryButton),
        );
        await tester.sendEventToBinding(
          pointer.move(const Offset(15, 15), buttons: kPrimaryButton),
        );
        component.checkHoverEventCounts(enter: 1, exit: 0, cancel: 1);

        // Release and re-hover — onHoverEnter must fire again, since the
        // hover state is now eligible to resume.
        await tester.sendEventToBinding(pointer.up());
        await tester.sendEventToBinding(pointer.hover(const Offset(15, 15)));
        component.checkHoverEventCounts(enter: 2, exit: 0, cancel: 1);
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
  int hoverCancelEvent = 0;

  void checkHoverEventCounts({
    required int enter,
    required int exit,
    int? cancel,
  }) {
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
    if (cancel != null) {
      expect(
        hoverCancelEvent,
        equals(cancel),
        reason: 'Mismatched hover cancel event count',
      );
    }
  }

  @override
  void onHoverEnter() {
    hoverEnterEvent++;
  }

  @override
  void onHoverExit() {
    hoverExitEvent++;
  }

  @override
  void onHoverCancel() {
    hoverCancelEvent++;
  }
}

class _HoverCallbacksComponent extends PositionComponent
    with HoverCallbacks, _HoverInspector {
  _HoverCallbacksComponent({
    super.position,
    super.size,
  });
}
