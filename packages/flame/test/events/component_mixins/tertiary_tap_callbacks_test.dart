import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TertiaryTapCallbacks', () {
    testWidgets(
      'receives tertiary tap event',
      (tester) async {
        final component = _TertiaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kMiddleMouseButton,
        );
        await gesture.down(const Offset(10, 10));

        expect(component.tertiaryTapDown, 1);
        expect(component.tertiaryTapCancel, 0);
        expect(component.tertiaryTap, 0);

        await gesture.up();

        expect(component.tertiaryTapDown, 1);
        expect(component.tertiaryTapCancel, 0);
        expect(component.tertiaryTap, 1);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'primary and tertiary are received separately',
      (tester) async {
        final component = _PrimaryAndTertiaryComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();

        final primaryGesture = await tester.createGesture();
        final tertiaryGesture = await tester.createGesture(
          buttons: kMiddleMouseButton,
        );

        await primaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 1);
        expect(component.tertiaryTapDown, 0);

        await primaryGesture.up();
        expect(component.primaryTapUp, 1);
        expect(component.tertiaryTapUp, 0);

        await tertiaryGesture.down(const Offset(10, 10));
        expect(component.primaryTapDown, 1);
        expect(component.tertiaryTapDown, 1);

        await tertiaryGesture.up();
        expect(component.primaryTapUp, 1);
        expect(component.tertiaryTapUp, 1);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'secondary and tertiary are received separately',
      (tester) async {
        final component = _SecondaryAndTertiaryComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();

        final secondaryGesture = await tester.createGesture(
          buttons: kSecondaryButton,
        );
        final tertiaryGesture = await tester.createGesture(
          buttons: kMiddleMouseButton,
        );

        await secondaryGesture.down(const Offset(10, 10));
        expect(component.secondaryTapDown, 1);
        expect(component.tertiaryTapDown, 0);

        await secondaryGesture.up();
        expect(component.secondaryTapUp, 1);
        expect(component.tertiaryTapUp, 0);

        await tertiaryGesture.down(const Offset(10, 10));
        expect(component.secondaryTapDown, 1);
        expect(component.tertiaryTapDown, 1);

        await tertiaryGesture.up();
        expect(component.secondaryTapUp, 1);
        expect(component.tertiaryTapUp, 1);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      '''does not receive an event when tertiary-tapping a position far from the component''',
      (tester) async {
        final component = _TertiaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kMiddleMouseButton,
        );
        await gesture.down(const Offset(100, 100));

        expect(component.tertiaryTapDown, 0);
        expect(component.tertiaryTapCancel, 0);
        expect(component.tertiaryTap, 0);

        await gesture.up();

        expect(component.tertiaryTapDown, 0);
        expect(component.tertiaryTapCancel, 0);
        expect(component.tertiaryTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWidgets(
      'receives a cancel event when gesture is canceled',
      (tester) async {
        final component = _TertiaryTapCallbacksComponent()
          ..position = Vector2.all(10);
        await tester.pumpWidget(
          GameWidget(
            game: FlameGame(children: [component]),
          ),
        );
        await tester.pump();
        await tester.pump();

        final gesture = await tester.createGesture(
          buttons: kMiddleMouseButton,
        );
        await gesture.down(const Offset(10, 10));

        expect(component.tertiaryTapDown, 1);
        expect(component.tertiaryTapCancel, 0);
        expect(component.tertiaryTap, 0);

        await gesture.cancel();

        expect(component.tertiaryTapDown, 1);
        expect(component.tertiaryTapCancel, 1);
        expect(component.tertiaryTap, 0);

        await tester.pump(kDoubleTapMinTime);
      },
    );

    testWithFlameGame(
      'TertiaryTapDispatcher is added to game when the callback is mounted',
      (game) async {
        final component = _TertiaryTapCallbacksComponent();
        await game.add(component);
        await game.ready();

        expect(game.firstChild<TertiaryTapDispatcher>(), isNotNull);
      },
    );

    testWithFlameGame(
      'TertiaryTapDispatcher persists after component is removed',
      (game) async {
        final component = _TertiaryTapCallbacksComponent();
        await game.add(component);
        await game.ready();

        expect(game.firstChild<TertiaryTapDispatcher>(), isNotNull);

        game.remove(component);
        await game.ready();

        // Dispatcher persists even after the component is removed
        expect(game.firstChild<TertiaryTapDispatcher>(), isNotNull);
      },
    );
  });
}

class _TertiaryTapCallbacksComponent extends PositionComponent
    with TertiaryTapCallbacks {
  _TertiaryTapCallbacksComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int tertiaryTapDown = 0;
  int tertiaryTapCancel = 0;
  int tertiaryTap = 0;

  @override
  void onTertiaryTapUp(TertiaryTapUpEvent event) {
    tertiaryTap++;
  }

  @override
  void onTertiaryTapCancel(TertiaryTapCancelEvent event) {
    tertiaryTapCancel++;
  }

  @override
  void onTertiaryTapDown(TertiaryTapDownEvent event) {
    tertiaryTapDown++;
  }
}

class _PrimaryAndTertiaryComponent extends PositionComponent
    with TapCallbacks, TertiaryTapCallbacks {
  _PrimaryAndTertiaryComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int primaryTapDown = 0;
  int primaryTapUp = 0;
  int tertiaryTapDown = 0;
  int tertiaryTapUp = 0;

  @override
  void onTapDown(TapDownEvent event) {
    primaryTapDown++;
  }

  @override
  void onTapUp(TapUpEvent event) {
    primaryTapUp++;
  }

  @override
  void onTertiaryTapDown(TertiaryTapDownEvent event) {
    tertiaryTapDown++;
  }

  @override
  void onTertiaryTapUp(TertiaryTapUpEvent event) {
    tertiaryTapUp++;
  }
}

class _SecondaryAndTertiaryComponent extends PositionComponent
    with SecondaryTapCallbacks, TertiaryTapCallbacks {
  _SecondaryAndTertiaryComponent() {
    anchor = Anchor.center;
    size = Vector2.all(10);
  }

  int secondaryTapDown = 0;
  int secondaryTapUp = 0;
  int tertiaryTapDown = 0;
  int tertiaryTapUp = 0;

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    secondaryTapDown++;
  }

  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    secondaryTapUp++;
  }

  @override
  void onTertiaryTapDown(TertiaryTapDownEvent event) {
    tertiaryTapDown++;
  }

  @override
  void onTertiaryTapUp(TertiaryTapUpEvent event) {
    tertiaryTapUp++;
  }
}
