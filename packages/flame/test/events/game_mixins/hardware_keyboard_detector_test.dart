import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HardwareKeyboardDetector', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('zero state', () {
      final game = _GameWithHardwareKeyboardDetector();
      expect(game.isAltPressed, false);
      expect(game.isShiftPressed, false);
      expect(game.isControlPressed, false);
      expect(game.isCapsLockOn, false);
      expect(game.isNumLockOn, false);
      expect(game.isScrollLockOn, false);
      expect(game.pauseKeyEvents, false);
    });

    testWithGame<_GameWithHardwareKeyboardDetector>(
      'game detects key presses',
      _GameWithHardwareKeyboardDetector.new,
      (game) async {
        await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await simulateKeyUpEvent(LogicalKeyboardKey.arrowLeft);
        await simulateKeyDownEvent(LogicalKeyboardKey.space);
        await simulateKeyUpEvent(LogicalKeyboardKey.space);
        expect(game.events.length, 4);
        expect(game.events[0], isA<KeyDownEvent>());
        expect(game.events[1], isA<KeyUpEvent>());
        expect(game.events[2], isA<KeyDownEvent>());
        expect(game.events[3], isA<KeyUpEvent>());
        expect(game.events[0].physicalKey, PhysicalKeyboardKey.arrowLeft);
        expect(game.events[1].physicalKey, PhysicalKeyboardKey.arrowLeft);
        expect(game.events[2].physicalKey, PhysicalKeyboardKey.space);
        expect(game.events[3].physicalKey, PhysicalKeyboardKey.space);
      },
    );

    testWithGame<_GameWithHardwareKeyboardDetector>(
      'modifier keys',
      _GameWithHardwareKeyboardDetector.new,
      (game) async {
        await simulateKeyDownEvent(LogicalKeyboardKey.altLeft);
        await simulateKeyDownEvent(LogicalKeyboardKey.numLock);
        await simulateKeyUpEvent(LogicalKeyboardKey.numLock);
        await simulateKeyDownEvent(LogicalKeyboardKey.altRight);
        await simulateKeyDownEvent(LogicalKeyboardKey.controlRight);
        await simulateKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        var checkedAll = false;
        game.keyEventHandler = (KeyEvent event) {
          expect(event, isA<KeyDownEvent>());
          expect(event.physicalKey, PhysicalKeyboardKey.keyZ);
          expect(event.logicalKey, LogicalKeyboardKey.keyZ);
          expect(event.character, 'z');
          expect(game.isControlPressed, true);
          expect(game.isShiftPressed, true);
          expect(game.isAltPressed, true);
          expect(game.isCapsLockOn, false);
          expect(game.isScrollLockOn, false);
          expect(game.isNumLockOn, true);
          checkedAll = true;
        };

        await simulateKeyDownEvent(LogicalKeyboardKey.keyZ);
        expect(checkedAll, true);
      },
    );

    testWithGame<_GameWithHardwareKeyboardDetector>(
      'key events paused',
      _GameWithHardwareKeyboardDetector.new,
      (game) async {
        game.pauseKeyEvents = true;
        await simulateKeyDownEvent(LogicalKeyboardKey.enter);
        await simulateKeyUpEvent(LogicalKeyboardKey.enter);
        expect(game.events, isEmpty);

        game.pauseKeyEvents = false;
        await simulateKeyDownEvent(LogicalKeyboardKey.enter);
        await simulateKeyUpEvent(LogicalKeyboardKey.enter);
        expect(game.events.length, 2);
      },
    );

    testWithGame<_GameWithHardwareKeyboardDetector>(
      'pause key events while the user holds down a key',
      _GameWithHardwareKeyboardDetector.new,
      (game) async {
        await simulateKeyDownEvent(LogicalKeyboardKey.enter);
        await simulateKeyDownEvent(LogicalKeyboardKey.capsLock);
        expect(game.events.length, 2);
        expect(game.events.whereType<KeyDownEvent>().length, 2);

        game.pauseKeyEvents = true;
        expect(game.events.length, 4);
        expect(game.events.whereType<KeyDownEvent>().length, 2);
        expect(game.events.whereType<KeyUpEvent>().length, 2);

        game.pauseKeyEvents = false;
        expect(game.events.length, 6);
        expect(game.events.whereType<KeyDownEvent>().length, 4);
        expect(game.events.whereType<KeyUpEvent>().length, 2);

        await simulateKeyUpEvent(LogicalKeyboardKey.enter);
        await simulateKeyUpEvent(LogicalKeyboardKey.capsLock);
        expect(game.events.length, 8);
        expect(game.events.whereType<KeyDownEvent>().length, 4);
        expect(game.events.whereType<KeyUpEvent>().length, 4);
      },
    );
  });
}

class _GameWithHardwareKeyboardDetector extends FlameGame
    with HardwareKeyboardDetector {
  final List<KeyEvent> events = [];
  void Function(KeyEvent)? keyEventHandler;

  @override
  void onKeyEvent(KeyEvent event) {
    events.add(event);
    keyEventHandler?.call(event);
  }
}
