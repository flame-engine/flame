import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeyboardCallbacks', () {
    testWithFlameGame(
      'mounting a KeyboardCallbacks component adds the dispatcher',
      (game) async {
        await game.ensureAdd(_KeyboardCallbacksComponent([]));
        await game.ready();

        expect(game.children.whereType<KeyboardDispatcher>(), hasLength(1));
        expect(game.keyDetector, isNotNull);
      },
    );

    testWithFlameGame(
      'removing the dispatcher clears the key detector',
      (game) async {
        await game.ensureAdd(_KeyboardCallbacksComponent([]));
        await game.ready();

        game.firstChild<KeyboardDispatcher>()!.removeFromParent();
        await game.ready();

        expect(game.keyDetector, isNull);
      },
    );

    testWithFlameGame(
      'every component receives the event, topmost first',
      (game) async {
        final received = <String>[];
        final parent = _KeyboardCallbacksComponent(received, label: 'parent');
        final child = _KeyboardCallbacksComponent(received, label: 'child');
        final sibling = _KeyboardCallbacksComponent(received, label: 'sibling');
        parent.add(child);
        game.addAll([parent, sibling]);
        await game.ready();

        _dispatch(
          game,
          createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA),
        );

        expect(received, ['sibling', 'child', 'parent']);
      },
    );

    testWithFlameGame(
      'a component can stop the event from reaching the ones after it',
      (game) async {
        final received = <String>[];
        final bottom = _KeyboardCallbacksComponent(received, label: 'bottom');
        final top = _KeyboardCallbacksComponent(
          received,
          label: 'top',
          stopPropagation: true,
        );
        game.addAll([bottom, top]);
        await game.ready();

        _dispatch(
          game,
          createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA),
        );

        expect(received, ['top']);
      },
    );

    testWithFlameGame(
      'onKeyboardEvent forwards each event to its specific callback',
      (game) async {
        final component = _SpecificCallbacksComponent();
        await game.ensureAdd(component);

        _dispatch(
          game,
          createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA),
        );
        _dispatch(
          game,
          createKeyHoldEvent(logicalKey: LogicalKeyboardKey.keyA),
        );
        _dispatch(
          game,
          createKeyReleaseEvent(logicalKey: LogicalKeyboardKey.keyA),
        );

        expect(component.calls, ['press', 'hold', 'release']);
      },
    );

    testWithFlameGame(
      'overriding onKeyboardEvent without super silences the specific '
      'callbacks',
      (game) async {
        final component = _SilencingComponent();
        await game.ensureAdd(component);

        _dispatch(
          game,
          createKeyPressEvent(logicalKey: LogicalKeyboardKey.keyA),
        );

        expect(component.calls, ['general']);
      },
    );

    testWidgets(
      'key events reach the game through the widget tree',
      (tester) async {
        final game = _KeyboardCallbacksGame();
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

        expect(
          game.events.map((e) => (e.runtimeType, e.logicalKey)),
          [
            (KeyPressEvent, LogicalKeyboardKey.shiftLeft),
            (KeyPressEvent, LogicalKeyboardKey.keyA),
            (KeyHoldEvent, LogicalKeyboardKey.keyA),
            (KeyReleaseEvent, LogicalKeyboardKey.keyA),
            (KeyReleaseEvent, LogicalKeyboardKey.shiftLeft),
          ],
        );
        final pressA = game.events[1];
        expect(pressA.isShiftPressed, isTrue);
        expect(
          pressA.keysPressed,
          {LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.keyA},
        );
        expect(game.events[3].isShiftPressed, isTrue);
        expect(game.events[4].isShiftPressed, isFalse);
      },
    );

    testWidgets(
      'works alongside the KeyboardEvents game mixin',
      (tester) async {
        final game = _LegacyKeyboardGame();
        final component = _KeyboardCallbacksComponent(<String>[]);
        await tester.pumpWidget(GameWidget(game: game));
        await game.ensureAdd(component);
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);

        expect(component.received, hasLength(1));
        expect(game.legacyEvents, hasLength(1));
      },
    );
  });
}

void _dispatch(FlameGame game, KeyboardEvent event) {
  game.firstChild<KeyboardDispatcher>()!.onKeyboardEvent(event);
}

class _KeyboardCallbacksComponent(
  final List<String> received, {
  final String label = '',
  final bool stopPropagation = false,
}) extends Component with KeyboardCallbacks {
  @override
  void onKeyboardEvent(KeyboardEvent event) {
    received.add(label);
    if (stopPropagation) {
      event.continuePropagation = false;
    }
  }
}

class _SpecificCallbacksComponent() extends Component with KeyboardCallbacks {
  final List<String> calls = [];

  @override
  void onKeyPress(KeyPressEvent event) => calls.add('press');

  @override
  void onKeyHold(KeyHoldEvent event) => calls.add('hold');

  @override
  void onKeyRelease(KeyReleaseEvent event) => calls.add('release');
}

class _SilencingComponent() extends _SpecificCallbacksComponent {
  @override
  void onKeyboardEvent(KeyboardEvent event) => calls.add('general');
}

class _KeyboardCallbacksGame() extends FlameGame with KeyboardCallbacks {
  final List<KeyboardEvent> events = [];

  @override
  void onKeyboardEvent(KeyboardEvent event) => events.add(event);
}

class _LegacyKeyboardGame() extends FlameGame with KeyboardEvents {
  final List<KeyEvent> legacyEvents = [];

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    legacyEvents.add(event);
    return KeyEventResult.handled;
  }
}
