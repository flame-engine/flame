import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapCallbacks', () {
    testWithFlameGame(
        'make sure TapCallback components can be added to a FlameGame',
        (game) async {
      await game.ensureAdd(_TapCallbacksComponent());
      await game.ready();
      expect(game.children.toList()[2], isA<MultiTapDispatcher>());
    });

    testWithFlameGame('tap event start', (game) async {
      final component = _TapCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      game.add(component);
      await game.ready();

      expect(game.children.whereType<MultiTapDispatcher>().length, equals(1));
      game.firstChild<MultiTapDispatcher>()!.onTapDown(
            createTapDownEvents(
              game: game,
              localPosition: const Offset(12, 12),
              globalPosition: const Offset(12, 12),
            ),
          );
      expect(component.containsLocalPoint(Vector2(10, 10)), false);
    });

    testWithFlameGame(
      'tap up, down event',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(component.tapUpEvent, equals(1));
      },
    );

    testWithFlameGame(
      'longTapDown and tapCancel event',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onLongTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.longTapDownEvent, equals(1));

        dispatcher.onTapCancel(
          TapCancelEvent(1),
        );
        expect(component.tapCancelEvent, equals(1));
      },
    );

    testWidgets(
      'tap correctly registered handled event',
      (tester) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 4);
        expect(component.isMounted, isTrue);

        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 500));
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(1));
        expect(component.tapCancelEvent, equals(0));
      },
    );

    testWidgets(
      'tap outside of component is not registered as handled',
      (tester) async {
        final component = _TapCallbacksComponent()..size = Vector2.all(100);
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        await tester.tapAt(const Offset(110, 110));
        await tester.pump(const Duration(milliseconds: 500));
        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.longTapDownEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));
      },
    );

    testWithGame(
      'make sure the FlameGame can registers TapCallback on itself',
      _TapCallbacksGame.new,
      (game) async {
        await game.ready();
        expect(game.children.length, equals(3));
        expect(game.children.elementAt(1), isA<MultiTapDispatcher>());
      },
    );

    testWidgets(
      'tap correctly registered handled event directly on FlameGame',
      (tester) async {
        final game = _TapCallbacksGame()..onGameResize(Vector2.all(300));
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, equals(3));
        expect(game.isMounted, isTrue);

        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 500));
        expect(game.tapDownEvent, equals(1));
        expect(game.tapUpEvent, equals(1));
        expect(game.longTapDownEvent, equals(0));
        expect(game.tapCancelEvent, equals(0));
      },
    );

    testWithFlameGame(
      'viewport components should get events before world',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final hudComponent = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final world = World();
        final cameraComponent = CameraComponent(world: world)
          ..viewfinder.anchor = Anchor.topLeft;

        await game.ensureAddAll([world, cameraComponent]);
        await world.ensureAdd(component);
        await cameraComponent.viewport.ensureAdd(hudComponent);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(hudComponent.tapDownEvent, equals(1));
        expect(hudComponent.tapUpEvent, equals(0));
        expect(hudComponent.tapCancelEvent, equals(0));

        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(hudComponent.tapUpEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
      },
    );
  });
}

mixin _TapCounter on TapCallbacks {
  int tapDownEvent = 0;
  int tapUpEvent = 0;
  int longTapDownEvent = 0;
  int tapCancelEvent = 0;

  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
    tapDownEvent++;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    event.handled = true;
    longTapDownEvent++;
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;
    tapUpEvent++;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    event.handled = true;
    tapCancelEvent++;
  }
}

class _TapCallbacksComponent extends PositionComponent
    with TapCallbacks, _TapCounter {}

class _TapCallbacksGame extends FlameGame with TapCallbacks, _TapCounter {}
