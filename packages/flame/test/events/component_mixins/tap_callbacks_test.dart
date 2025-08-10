import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
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
      },
    );

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

  testWidgets(
    'taps are delivered to a TapCallbacks component',
    (tester) async {
      var nTapDown = 0;
      var nLongTapDown = 0;
      var nTapCancel = 0;
      var nTapUp = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2(200, 100),
            position: Vector2(50, 50),
            onTapDown: (e) => nTapDown++,
            onLongTapDown: (e) => nLongTapDown++,
            onTapCancel: (e) => nTapCancel++,
            onTapUp: (e) => nTapUp++,
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      expect(game.children.length, 4);

      // regular tap
      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(nTapDown, 1);
      expect(nTapUp, 1);
      expect(nLongTapDown, 0);
      expect(nTapCancel, 0);

      // long tap
      await tester.longPressAt(const Offset(100, 100));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 2);
      expect(nTapUp, 2);
      expect(nLongTapDown, 1);
      expect(nTapCancel, 0);

      // cancelled tap
      var gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 3);
      expect(nTapUp, 2);
      expect(nTapCancel, 1);

      // tap cancelled via movement
      gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.moveBy(const Offset(20, 20));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 4);
      expect(nTapUp, 2);
      expect(nTapCancel, 2);
    },
  );

  testWidgets(
    'TapCallbacks component nested in another TapCallbacks component',
    (tester) async {
      var nTapDownChild = 0;
      var nTapDownParent = 0;
      var nTapCancelChild = 0;
      var nTapCancelParent = 0;
      var nTapUpChild = 0;
      var nTapUpParent = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2.all(100),
            position: Vector2.zero(),
            onTapDown: (e) => nTapDownParent++,
            onTapUp: (e) => nTapUpParent++,
            onTapCancel: (e) => nTapCancelParent++,
            children: [
              _TapWithCallbacksComponent(
                size: Vector2.all(50),
                position: Vector2.all(25),
                onTapDown: (e) {
                  nTapDownChild++;
                  e.continuePropagation = true;
                },
                onTapCancel: (e) => nTapCancelChild++,
                onTapUp: (e) => nTapUpChild++,
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.longPressAt(const Offset(50, 50));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownChild, 1);
      expect(nTapDownParent, 1);
      expect(nTapUpChild, 1);
      expect(nTapUpParent, 1);
      expect(nTapCancelChild, 0);
      expect(nTapCancelParent, 0);

      // cancelled tap
      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownChild, 2);
      expect(nTapDownParent, 2);
      expect(nTapUpChild, 1);
      expect(nTapUpParent, 1);
      expect(nTapCancelChild, 1);
      expect(nTapCancelParent, 1);
    },
  );

  testWidgets(
    'tap events do not propagate down by default',
    (tester) async {
      var nTapDownParent = 0;
      var nTapCancelParent = 0;
      var nTapUpParent = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2.all(100),
            position: Vector2.zero(),
            onTapDown: (e) => nTapDownParent++,
            onTapUp: (e) => nTapUpParent++,
            onTapCancel: (e) => nTapCancelParent++,
            children: [
              _SimpleTapCallbacksComponent(size: Vector2.all(100)),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.longPressAt(const Offset(50, 50));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownParent, 0);
      expect(nTapUpParent, 0);
      expect(nTapCancelParent, 0);

      // cancelled tap
      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownParent, 0);
      expect(nTapUpParent, 0);
      expect(nTapCancelParent, 0);
    },
  );

  testWidgets(
    'local coordinates during tap events',
    (tester) async {
      TapDownEvent? tapDownEvent;
      final game = FlameGame(
        children: [
          PositionComponent(
            size: Vector2.all(400),
            position: Vector2.all(10),
            children: [
              PositionComponent(
                size: Vector2(300, 200),
                scale: Vector2(1.5, 2),
                position: Vector2.all(40),
                children: [
                  _TapWithCallbacksComponent(
                    size: Vector2(100, 50),
                    position: Vector2(50, 50),
                    onTapDown: (e) => tapDownEvent = e,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.tapAt(const Offset(200, 200));
      await tester.pump(const Duration(seconds: 1));
      expect(tapDownEvent, isNotNull);
      expect(tapDownEvent!.devicePosition, Vector2(200, 200));
      expect(tapDownEvent!.canvasPosition, Vector2(200, 200));
      expect(tapDownEvent!.localPosition, Vector2(50, 25));
      final trace = tapDownEvent!.renderingTrace.reversed.toList();
      expect(trace[0], Vector2(50, 25));
      expect(trace[1], Vector2(100, 75));
      expect(trace[2], Vector2(190, 190));
      expect(trace[3], Vector2(200, 200));
    },
  );
}

class _TapWithCallbacksComponent extends PositionComponent with TapCallbacks {
  _TapWithCallbacksComponent({
    required Vector2 super.position,
    required Vector2 super.size,
    super.children,
    void Function(TapDownEvent)? onTapDown,
    void Function(TapDownEvent)? onLongTapDown,
    void Function(TapUpEvent)? onTapUp,
    void Function(TapCancelEvent)? onTapCancel,
  }) : _onTapDown = onTapDown,
       _onLongTapDown = onLongTapDown,
       _onTapUp = onTapUp,
       _onTapCancel = onTapCancel;

  final void Function(TapDownEvent)? _onTapDown;
  final void Function(TapDownEvent)? _onLongTapDown;
  final void Function(TapUpEvent)? _onTapUp;
  final void Function(TapCancelEvent)? _onTapCancel;

  @override
  void onTapDown(TapDownEvent event) => _onTapDown?.call(event);

  @override
  void onLongTapDown(TapDownEvent event) => _onLongTapDown?.call(event);

  @override
  void onTapUp(TapUpEvent event) => _onTapUp?.call(event);

  @override
  void onTapCancel(TapCancelEvent event) => _onTapCancel?.call(event);
}

class _SimpleTapCallbacksComponent extends PositionComponent with TapCallbacks {
  _SimpleTapCallbacksComponent({super.size});
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
