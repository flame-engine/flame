import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // fromKeyEvent reads HardwareKeyboard.instance, which throws without one
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardEvent', () {
    test('fromKeyEvent wraps each Flutter key event in its subclass', () {
      const physicalKey = PhysicalKeyboardKey.keyA;
      const logicalKey = LogicalKeyboardKey.keyA;

      final press = KeyboardEvent.fromKeyEvent(
        const KeyDownEvent(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          character: 'a',
          timeStamp: Duration.zero,
        ),
      );
      final hold = KeyboardEvent.fromKeyEvent(
        const KeyRepeatEvent(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          timeStamp: Duration.zero,
        ),
      );
      final release = KeyboardEvent.fromKeyEvent(
        const KeyUpEvent(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          timeStamp: Duration.zero,
        ),
      );

      expect(
        press,
        isA<KeyPressEvent>().having((e) => e.character, 'character', 'a'),
      );
      expect(press.physicalKey, physicalKey);
      expect(press.logicalKey, logicalKey);
      expect(hold, isA<KeyHoldEvent>());
      expect(release, isA<KeyReleaseEvent>());
    });

    test('each subclass exposes its own Flutter event type as raw', () {
      // Only compiles if raw is narrowed per subclass
      _expectRawTypes(
        createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA).raw,
        createKeyHoldEvent(logicalKey: LogicalKeyboardKey.keyA).raw,
        createKeyReleaseEvent(logicalKey: LogicalKeyboardKey.keyA).raw,
      );
    });

    test('fromKeyEvent rejects unknown Flutter key event types', () {
      expect(
        () => KeyboardEvent.fromKeyEvent(const _UnknownKeyEvent()),
        throwsArgumentError,
      );
    });

    test('modifier helpers read either side of the keyboard', () {
      final left = createKeyPressEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        keysPressed: {
          LogicalKeyboardKey.shiftLeft,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.altLeft,
          LogicalKeyboardKey.metaLeft,
        },
      );
      final right = createKeyPressEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        keysPressed: {
          LogicalKeyboardKey.shiftRight,
          LogicalKeyboardKey.controlRight,
          LogicalKeyboardKey.altRight,
          LogicalKeyboardKey.metaRight,
        },
      );
      final none = createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA);

      for (final event in [left, right]) {
        expect(event.isShiftPressed, isTrue);
        expect(event.isControlPressed, isTrue);
        expect(event.isAltPressed, isTrue);
        expect(event.isMetaPressed, isTrue);
      }
      expect(none.isShiftPressed, isFalse);
      expect(none.isControlPressed, isFalse);
      expect(none.isAltPressed, isFalse);
      expect(none.isMetaPressed, isFalse);
    });

    test('lock helpers read the enabled lock modes', () {
      final allOn = createKeyReleaseEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        lockModesEnabled: {
          KeyboardLockMode.capsLock,
          KeyboardLockMode.numLock,
          KeyboardLockMode.scrollLock,
        },
      );
      final allOff = createKeyReleaseEvent(
        logicalKey: LogicalKeyboardKey.keyA,
      );

      expect(allOn.isCapsLockOn, isTrue);
      expect(allOn.isNumLockOn, isTrue);
      expect(allOn.isScrollLockOn, isTrue);
      expect(allOff.isCapsLockOn, isFalse);
      expect(allOff.isNumLockOn, isFalse);
      expect(allOff.isScrollLockOn, isFalse);
    });
  });
}

void _expectRawTypes(
  KeyDownEvent press,
  KeyRepeatEvent hold,
  KeyUpEvent release,
) {
  expect([press, hold, release], everyElement(isA<KeyEvent>()));
}

class const _UnknownKeyEvent() extends KeyEvent {
  this
    : super(
        physicalKey: PhysicalKeyboardKey.keyA,
        logicalKey: LogicalKeyboardKey.keyA,
        timeStamp: Duration.zero,
      );
}
