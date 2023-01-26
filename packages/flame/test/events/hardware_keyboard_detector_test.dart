import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HardwareKeyboardDetector', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('zero state', () {
      final component = _MyKeyboardDetector();
      expect(component.isAltPressed, false);
      expect(component.isShiftPressed, false);
      expect(component.isControlPressed, false);
      expect(component.isCapsLockOn, false);
      expect(component.isNumLockOn, false);
      expect(component.isScrollLockOn, false);
      expect(component.pauseKeyEvents, true);
    });

    testWithFlameGame('game detects key presses', (game) async {
      HardwareKeyboard.instance.clearState();
      final detector = _MyKeyboardDetector()..addToParent(game);
      await game.ready();

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      await simulateKeyUpEvent(LogicalKeyboardKey.arrowLeft);
      await simulateKeyDownEvent(LogicalKeyboardKey.space);
      await simulateKeyUpEvent(LogicalKeyboardKey.space);
      expect(detector.events.length, 4);
      expect(detector.events[0], isA<KeyDownEvent>());
      expect(detector.events[1], isA<KeyUpEvent>());
      expect(detector.events[2], isA<KeyDownEvent>());
      expect(detector.events[3], isA<KeyUpEvent>());
      expect(detector.events[0].physicalKey, PhysicalKeyboardKey.arrowLeft);
      expect(detector.events[1].physicalKey, PhysicalKeyboardKey.arrowLeft);
      expect(detector.events[2].physicalKey, PhysicalKeyboardKey.space);
      expect(detector.events[3].physicalKey, PhysicalKeyboardKey.space);
    });

    testWithFlameGame('modifier keys', (game) async {
      HardwareKeyboard.instance.clearState();
      await simulateKeyDownEvent(LogicalKeyboardKey.altLeft);
      await simulateKeyDownEvent(LogicalKeyboardKey.numLock);
      await simulateKeyUpEvent(LogicalKeyboardKey.numLock);
      await simulateKeyDownEvent(LogicalKeyboardKey.altRight);
      await simulateKeyDownEvent(LogicalKeyboardKey.controlRight);
      await simulateKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      final detector = _MyKeyboardDetector()..addToParent(game);
      await game.ready();

      var checkedAll = false;
      detector.keyEventHandler = (KeyEvent event) {
        expect(event, isA<KeyDownEvent>());
        expect(event.physicalKey, PhysicalKeyboardKey.keyZ);
        expect(event.logicalKey, LogicalKeyboardKey.keyZ);
        expect(event.character, 'z');
        expect(detector.isControlPressed, true);
        expect(detector.isShiftPressed, true);
        expect(detector.isAltPressed, true);
        expect(detector.isCapsLockOn, false);
        expect(detector.isScrollLockOn, false);
        expect(detector.isNumLockOn, true);
        checkedAll = true;
      };

      await simulateKeyDownEvent(LogicalKeyboardKey.keyZ);
      expect(checkedAll, true);

      await simulateKeyUpEvent(LogicalKeyboardKey.altLeft);
      await simulateKeyUpEvent(LogicalKeyboardKey.altRight);
      await simulateKeyUpEvent(LogicalKeyboardKey.controlRight);
      await simulateKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await simulateKeyUpEvent(LogicalKeyboardKey.keyZ);
    });

    testWithFlameGame('key events paused', (game) async {
      HardwareKeyboard.instance.clearState();
      final detector = _MyKeyboardDetector()..addToParent(game);
      await game.ready();

      detector.pauseKeyEvents = true;
      await simulateKeyDownEvent(LogicalKeyboardKey.enter);
      await simulateKeyUpEvent(LogicalKeyboardKey.enter);
      expect(detector.events, isEmpty);

      detector.pauseKeyEvents = false;
      await simulateKeyDownEvent(LogicalKeyboardKey.enter);
      await simulateKeyUpEvent(LogicalKeyboardKey.enter);
      expect(detector.events.length, 2);
    });

    testWithFlameGame('pause key events while keys are pressed', (game) async {
      HardwareKeyboard.instance.clearState();
      final detector = _MyKeyboardDetector()..addToParent(game);
      await game.ready();

      await simulateKeyDownEvent(LogicalKeyboardKey.enter);
      await simulateKeyDownEvent(LogicalKeyboardKey.capsLock);
      expect(detector.events.length, 2);
      expect(detector.events.whereType<KeyDownEvent>().length, 2);

      detector.pauseKeyEvents = true;
      expect(detector.events.length, 4);
      expect(detector.events.whereType<KeyDownEvent>().length, 2);
      expect(detector.events.whereType<KeyUpEvent>().length, 2);

      detector.pauseKeyEvents = false;
      expect(detector.events.length, 6);
      expect(detector.events.whereType<KeyDownEvent>().length, 4);
      expect(detector.events.whereType<KeyUpEvent>().length, 2);

      await simulateKeyUpEvent(LogicalKeyboardKey.enter);
      await simulateKeyUpEvent(LogicalKeyboardKey.capsLock);
      expect(detector.events.length, 8);
      expect(detector.events.whereType<KeyDownEvent>().length, 4);
      expect(detector.events.whereType<KeyUpEvent>().length, 4);
    });

    testWithFlameGame('stop listening when component unmounts', (game) async {
      HardwareKeyboard.instance.clearState();
      final detector = _MyKeyboardDetector()..addToParent(game);
      await game.ready();

      await simulateKeyDownEvent(LogicalKeyboardKey.keyA);
      detector.removeFromParent();
      await game.ready();

      // The detector will send a synthesized "keyUp" event when it unmounts.
      expect(detector.events.length, 2);
      expect(detector.events.whereType<KeyDownEvent>().length, 1);
      expect(detector.events.whereType<KeyUpEvent>().length, 1);

      // But new events will not be listened.
      await simulateKeyUpEvent(LogicalKeyboardKey.keyA);
      expect(detector.events.length, 2);

      // The fact that Q button is pressed will be delivered once the detector
      // mounts, whereas the W button was pressed and released while the
      // detector was unmounted, so it won't be seen.
      await simulateKeyDownEvent(LogicalKeyboardKey.keyQ);
      await simulateKeyDownEvent(LogicalKeyboardKey.keyW);
      await simulateKeyUpEvent(LogicalKeyboardKey.keyW);
      expect(detector.events.length, 2);
      game.add(detector);
      await game.ready();
      expect(detector.events.length, 3);
      expect(detector.events.last.physicalKey, PhysicalKeyboardKey.keyQ);
    });
  });
}

class _MyKeyboardDetector extends HardwareKeyboardDetector {
  final List<KeyEvent> events = [];
  void Function(KeyEvent)? keyEventHandler;

  @override
  void onKeyEvent(KeyEvent event) {
    events.add(event);
    keyEventHandler?.call(event);
  }
}
