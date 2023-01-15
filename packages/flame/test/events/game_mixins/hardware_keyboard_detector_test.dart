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
