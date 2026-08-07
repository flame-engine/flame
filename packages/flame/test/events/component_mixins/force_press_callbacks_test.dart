import 'package:flame/components.dart';
import 'package:flame/events.dart' hide PointerMoveEvent;
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForcePressCallbacks', () {
    testWithFlameGame(
      'adds the dispatcher to the game',
      (game) async {
        await game.ensureAdd(_ForcePressComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame(
      'the dispatcher is only added once',
      (game) async {
        await game.ensureAdd(_ForcePressComponent());
        await game.ensureAdd(_ForcePressComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame(
      'receives force press start on component',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(15, 15), 0.5);

        expect(component.startCount, 1);
        expect(component.isForcePressed, isTrue);
        expect(component.lastPressure, 0.5);
      },
    );

    testWithFlameGame(
      'does not receive events that start outside its bounds',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(5, 5), 0.5);

        expect(component.startCount, 0);
        expect(component.isForcePressed, isFalse);
      },
    );

    testWithFlameGame(
      'full lifecycle: start, peak, update, end',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(15, 15), 0.5);
        _forcePressPeak(game, const Offset(15, 15), 0.9);
        _forcePressUpdate(game, const Offset(15, 15), 0.95);
        _forcePressEnd(game, const Offset(15, 15), 0.1);

        expect(component.startCount, 1);
        expect(component.peakCount, 1);
        expect(component.updateCount, 1);
        expect(component.endCount, 1);
        expect(component.isForcePressed, isFalse);
      },
    );

    testWithFlameGame(
      'peak, update and end follow the pointer outside the component',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(15, 15), 0.5);
        // The pointer moved off the component; the gesture still belongs to it.
        _forcePressUpdate(game, const Offset(500, 500), 0.7);
        _forcePressEnd(game, const Offset(500, 500), 0.1);

        expect(component.updateCount, 1);
        expect(component.endCount, 1);
      },
    );

    testWithFlameGame(
      'a component removed mid-gesture stops receiving events',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(15, 15), 0.5);
        expect(component.startCount, 1);

        component.removeFromParent();
        await game.ready();

        _forcePressUpdate(game, const Offset(15, 15), 0.7);
        _forcePressEnd(game, const Offset(15, 15), 0.1);

        expect(component.updateCount, 0);
        expect(component.endCount, 0);
      },
    );

    testWithFlameGame(
      'the event exposes positions and the raw details',
      (game) async {
        final component = _ForcePressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _forcePressStart(game, const Offset(15, 15), 0.75);

        final event = component.lastEvent!;
        expect(event.raw, isA<ForcePressDetails>());
        expect(event.pressure, 0.75);
        expect(event.devicePosition, Vector2(15, 15));
        expect(event.canvasPosition, Vector2(15, 15));
        expect(event.localPosition, Vector2(5, 5));
      },
    );

    testWithFlameGame(
      'only the topmost component receives the start by default',
      (game) async {
        final bottom = _ForcePressComponent(size: Vector2.all(100));
        final top = _ForcePressComponent(size: Vector2.all(100));
        await game.ensureAddAll([bottom, top]);

        _forcePressStart(game, const Offset(50, 50), 0.5);

        expect(top.startCount, 1);
        expect(bottom.startCount, 0);
      },
    );

    testWithFlameGame(
      'continuePropagation lets the start reach components below',
      (game) async {
        final bottom = _ForcePressComponent(size: Vector2.all(100));
        final top = _ForcePressComponent(
          size: Vector2.all(100),
          continuePropagation: true,
        );
        await game.ensureAddAll([bottom, top]);

        _forcePressStart(game, const Offset(50, 50), 0.5);

        expect(top.startCount, 1);
        expect(bottom.startCount, 1);
      },
    );

    testWithGame(
      'FlameGame with ForcePressCallbacks receives events',
      _ForcePressGame.new,
      (game) async {
        _hasDispatcher(game);

        _forcePressStart(game, const Offset(15, 15), 0.5);

        expect(game.startCount, 1);
        expect(game.isForcePressed, isTrue);
      },
    );

    testWithFlameGame(
      'the dispatcher stays when the last component unmounts',
      (game) async {
        final component = _ForcePressComponent(size: Vector2.all(10));
        await game.ensureAdd(component);
        _hasDispatcher(game);

        component.removeFromParent();
        await game.ready();

        // The dispatcher is managed by the game, not by component unmounting.
        _hasDispatcher(game);
      },
    );

    testWidgets(
      'a real force press gesture reaches the component',
      (tester) async {
        final component = _ForcePressComponent(size: Vector2.all(800));
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();

        expect(component.isMounted, isTrue);

        const position = Offset(50, 50);
        final pointer = tester.nextPointer;
        final gesture = await tester.createGesture();

        await gesture.downWithCustomEvent(
          position,
          PointerDownEvent(
            pointer: pointer,
            position: position,
            pressure: 0.0,
            pressureMin: 0.0,
            pressureMax: 6.0,
          ),
        );

        // Below the start threshold: nothing is delivered yet.
        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointer,
            position: position,
            pressure: 0.3,
            pressureMin: 0.0,
            pressureMax: 6.0,
          ),
        );
        expect(component.startCount, 0);

        // Crosses the start threshold.
        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointer,
            position: position,
            pressure: 3.0,
            pressureMin: 0.0,
            pressureMax: 6.0,
          ),
        );
        expect(component.startCount, 1);
        expect(component.isForcePressed, isTrue);

        // Crosses the peak threshold.
        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointer,
            position: position,
            pressure: 5.5,
            pressureMin: 0.0,
            pressureMax: 6.0,
          ),
        );
        expect(component.peakCount, 1);

        await gesture.up();

        expect(component.endCount, 1);
        expect(component.isForcePressed, isFalse);
      },
    );
  });
}

void _forcePressStart(FlameGame game, Offset position, double pressure) {
  _dispatcher(game).handleForcePressStart(_details(position, pressure));
}

void _forcePressPeak(FlameGame game, Offset position, double pressure) {
  _dispatcher(game).handleForcePressPeak(_details(position, pressure));
}

void _forcePressUpdate(FlameGame game, Offset position, double pressure) {
  _dispatcher(game).handleForcePressUpdate(_details(position, pressure));
}

void _forcePressEnd(FlameGame game, Offset position, double pressure) {
  _dispatcher(game).handleForcePressEnd(_details(position, pressure));
}

ForcePressDetails _details(Offset position, double pressure) {
  return ForcePressDetails(
    globalPosition: position,
    localPosition: position,
    pressure: pressure,
  );
}

ForcePressDispatcher _dispatcher(FlameGame game) {
  return game.firstChild<ForcePressDispatcher>()!;
}

void _hasDispatcher(FlameGame game) {
  expect(game.children.whereType<ForcePressDispatcher>(), hasLength(1));
}

class _ForcePressComponent extends PositionComponent with ForcePressCallbacks {
  _ForcePressComponent({
    super.position,
    super.size,
    this.continuePropagation = false,
  });

  final bool continuePropagation;

  int startCount = 0;
  int peakCount = 0;
  int updateCount = 0;
  int endCount = 0;
  double? lastPressure;
  ForcePressEvent? lastEvent;

  @override
  void onForcePressStart(ForcePressEvent event) {
    super.onForcePressStart(event);
    event.continuePropagation = continuePropagation;
    startCount++;
    lastPressure = event.pressure;
    lastEvent = event;
  }

  @override
  void onForcePressPeak(ForcePressEvent event) {
    peakCount++;
    lastPressure = event.pressure;
  }

  @override
  void onForcePressUpdate(ForcePressEvent event) {
    updateCount++;
    lastPressure = event.pressure;
  }

  @override
  void onForcePressEnd(ForcePressEvent event) {
    super.onForcePressEnd(event);
    endCount++;
    lastPressure = event.pressure;
  }
}

class _ForcePressGame extends FlameGame with ForcePressCallbacks {
  int startCount = 0;

  @override
  void onForcePressStart(ForcePressEvent event) {
    super.onForcePressStart(event);
    startCount++;
  }
}
