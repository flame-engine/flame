import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoubleTapCallbacks', () {
    testWidgets(
      'receives double-tap event',
      (tester) async {
        final component = _DoubleTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture();
        await gesture.down(const Offset(10, 10));
        await tester.pump();

        await gesture.up();
        expect(component.doubleTapDown, 0);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await tester.pump(kDoubleTapMinTime);
        await gesture.down(const Offset(10, 10));

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await gesture.up();

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 1);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      '''does not receive an event when double-tapping a position far from the component''',
      (tester) async {
        final component = _DoubleTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture();
        await gesture.down(const Offset(100, 100));
        await gesture.up();

        await tester.pump(kDoubleTapMinTime);
        await gesture.down(const Offset(100, 100));

        expect(component.doubleTapDown, 0);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await gesture.up();

        expect(component.doubleTapDown, 0);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'receives a cancel event when gesture is canceled by drag',
      (tester) async {
        final component = _DoubleTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture();
        await gesture.down(const Offset(10, 10));
        await gesture.up();

        await tester.pump(kDoubleTapMinTime);
        await gesture.down(const Offset(10, 10));

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await gesture.moveBy(const Offset(100, 100));

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 1);
        expect(component.doubleTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'receives a cancel event when gesture is canceled by cancel',
      (tester) async {
        final component = _DoubleTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture();
        await gesture.down(const Offset(10, 10));
        await gesture.up();

        await tester.pump(kDoubleTapMinTime);
        await gesture.down(const Offset(10, 10));

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 0);
        expect(component.doubleTap, 0);

        await gesture.cancel();

        expect(component.doubleTapDown, 1);
        expect(component.doubleTapCancel, 1);
        expect(component.doubleTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWithFlameGame(
      'DoubleTapDispatcher is added to game when the callback is mounted',
      (game) async {
        final component = _DoubleTapCallbacksComponent();
        await game.add(component);
        await game.ready();

        expect(game.firstChild<DoubleTapDispatcher>(), isNotNull);
      },
    );
  });
}

class _DoubleTapCallbacksComponent extends PositionComponent
    with DoubleTapCallbacks {
  _DoubleTapCallbacksComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int doubleTapDown = 0;
  int doubleTapCancel = 0;
  int doubleTap = 0;

  @override
  void onDoubleTapUp(DoubleTapEvent event) {
    doubleTap++;
  }

  @override
  void onDoubleTapCancel(DoubleTapCancelEvent event) {
    doubleTapCancel++;
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    doubleTapDown++;
  }
}
