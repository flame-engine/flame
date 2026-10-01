import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/input_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Tapper extends PositionComponent with TapCallbacks {
  _Tapper() : super(position: Vector2(10, 10), size: Vector2(20, 20));

  final taps = <Vector2>[];

  @override
  void onTapUp(TapUpEvent event) => taps.add(event.localPosition);
}

class _Dragger extends PositionComponent with DragCallbacks {
  _Dragger() : super(size: Vector2(100, 100));

  int starts = 0;
  int updates = 0;
  int ends = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    starts++;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) => updates++;

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    ends++;
  }
}

class _KeyGame extends FlameGame with HasKeyboardHandlerComponents {}

class _Listener extends Component with KeyboardHandler {
  final events = <KeyEvent>[];
  final pressed = <Set<LogicalKeyboardKey>>[];

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    events.add(event);
    pressed.add(keysPressed);
    return true;
  }
}

void main() {
  group('InputConnector', () {
    testWithFlameGame('taps the component at the position', (game) async {
      final tapper = _Tapper();
      await game.ensureAdd(tapper);

      expect(InputConnector.tap(game, const Offset(15, 20)), isNull);

      expect(tapper.taps, [Vector2(5, 10)]);
    });

    testWithFlameGame('reports when nothing handles taps', (game) async {
      expect(
        InputConnector.tap(game, Offset.zero),
        contains('TapCallbacks'),
      );
    });

    testWithFlameGame('drags across the component in steps', (game) async {
      final dragger = _Dragger();
      await game.ensureAdd(dragger);

      expect(
        InputConnector.drag(
          game,
          const Offset(10, 10),
          const Offset(50, 10),
          steps: 4,
        ),
        isNull,
      );

      expect(dragger.starts, 1);
      expect(dragger.updates, 4);
      expect(dragger.ends, 1);
    });

    testWithFlameGame('reports when nothing handles drags', (game) async {
      expect(
        InputConnector.drag(game, Offset.zero, Offset.zero),
        contains('DragCallbacks'),
      );
    });

    testWithGame('presses and releases a key', _KeyGame.new, (game) async {
      final listener = _Listener();
      await game.ensureAdd(listener);

      expect(
        InputConnector.pressKey(game, LogicalKeyboardKey.space),
        isNull,
      );

      expect(listener.events, [isA<KeyDownEvent>(), isA<KeyUpEvent>()]);
      expect(listener.events.first.logicalKey, LogicalKeyboardKey.space);
      expect(listener.pressed, [
        {LogicalKeyboardKey.space},
        <LogicalKeyboardKey>{},
      ]);
    });

    testWithGame('only presses a key down', _KeyGame.new, (game) async {
      final listener = _Listener();
      await game.ensureAdd(listener);

      InputConnector.pressKey(game, LogicalKeyboardKey.keyA, action: 'down');

      expect(listener.events, [isA<KeyDownEvent>()]);
      expect(listener.events.single.character, 'A');
    });

    testWithFlameGame('reports when the game ignores keys', (game) async {
      expect(
        InputConnector.pressKey(game, LogicalKeyboardKey.space),
        contains('HasKeyboardHandlerComponents'),
      );
    });
  });

  group('InputConnector.findLogicalKey', () {
    test('finds keys by name, letter and label', () {
      expect(
        InputConnector.findLogicalKey('arrowLeft'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(
        InputConnector.findLogicalKey('Arrow Left'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(
        InputConnector.findLogicalKey('arrow_left'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(InputConnector.findLogicalKey('space'), LogicalKeyboardKey.space);
      expect(InputConnector.findLogicalKey('a'), LogicalKeyboardKey.keyA);
      expect(InputConnector.findLogicalKey('keyA'), LogicalKeyboardKey.keyA);
      expect(InputConnector.findLogicalKey('1'), LogicalKeyboardKey.digit1);
      expect(InputConnector.findLogicalKey('F5'), LogicalKeyboardKey.f5);
    });

    test('returns null for unknown keys', () {
      expect(InputConnector.findLogicalKey(''), isNull);
      expect(InputConnector.findLogicalKey('banana'), isNull);
    });
  });
}
