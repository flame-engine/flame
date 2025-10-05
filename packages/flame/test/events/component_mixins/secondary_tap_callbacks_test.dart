import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecondaryTapCallbacks', () {
    testWidgets(
      'receives secondary tap event',
      (tester) async {
        final component = _SecondaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kSecondaryButton,
        );
        await gesture.down(const Offset(10, 10));

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 0);

        await gesture.up();

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 1);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'primary and secondary are received separately',
      (tester) async {
        final component = _BothTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();

        final primaryGesture = await tester.createGesture();
        final secondaryGesture = await tester.createGesture(
          buttons: kSecondaryButton,
        );

        await primaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 1);
        expect(component.secondaryTapDown, 0);

        await primaryGesture.up();
        expect(component.primaryTapUp, 1);
        expect(component.secondaryTapUp, 0);

        await secondaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 1);
        expect(component.secondaryTapDown, 1);

        await secondaryGesture.up();
        expect(component.primaryTapUp, 1);
        expect(component.secondaryTapUp, 1);

        await primaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 2);
        expect(component.secondaryTapDown, 1);

        await secondaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 2);
        expect(component.secondaryTapDown, 2);

        await primaryGesture.up();
        expect(component.primaryTapUp, 2);
        expect(component.secondaryTapUp, 1);

        await secondaryGesture.up();
        expect(component.primaryTapUp, 2);
        expect(component.secondaryTapUp, 2);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      '''does not receive an event when secondary-tapping a position far from the component''',
      (tester) async {
        final component = _SecondaryTapCallbacksComponent()
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

        expect(component.secondaryTapDown, 0);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 0);

        await gesture.up();

        expect(component.secondaryTapDown, 0);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'receives a cancel event when gesture is canceled by drag',
      (tester) async {
        final component = _SecondaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kSecondaryButton,
        );
        await gesture.down(const Offset(10, 10));

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 0);

        await gesture.moveBy(const Offset(100, 100));

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 1);
        expect(component.secondaryTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'receives a cancel event when gesture is canceled by cancel',
      (tester) async {
        final component = _SecondaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kSecondaryButton,
        );
        await gesture.down(const Offset(10, 10));

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 0);
        expect(component.secondaryTap, 0);

        await gesture.cancel();

        expect(component.secondaryTapDown, 1);
        expect(component.secondaryTapCancel, 1);
        expect(component.secondaryTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWithFlameGame(
      'SecondaryTapDispatcher is added to game when the callback is mounted',
      (game) async {
        final component = _SecondaryTapCallbacksComponent();
        await game.add(component);
        await game.ready();

        expect(game.firstChild<SecondaryTapDispatcher>(), isNotNull);
      },
    );
  });
}

class _SecondaryTapCallbacksComponent extends PositionComponent
    with SecondaryTapCallbacks {
  _SecondaryTapCallbacksComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int secondaryTapDown = 0;
  int secondaryTapCancel = 0;
  int secondaryTap = 0;

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    secondaryTap++;
  }

  @override
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    secondaryTapCancel++;
  }

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    secondaryTapDown++;
  }
}

class _BothTapCallbacksComponent extends PositionComponent
    with TapCallbacks, SecondaryTapCallbacks {
  _BothTapCallbacksComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int primaryTapDown = 0;
  int primaryTapUp = 0;
  int primaryTapCancel = 0;

  int secondaryTapDown = 0;
  int secondaryTapUp = 0;
  int secondaryTapCancel = 0;

  @override
  void onTapUp(TapUpEvent event) {
    primaryTapUp++;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    primaryTapCancel++;
  }

  @override
  void onTapDown(TapDownEvent event) {
    primaryTapDown++;
  }

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    secondaryTapUp++;
  }

  @override
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    secondaryTapCancel++;
  }

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    secondaryTapDown++;
  }
}
