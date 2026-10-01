/// A [FlameInputBridge] translates Flame's own keyboard and drag callbacks
/// into the same [Bindings]/[InputState] calls `flutter3d_game`'s
/// `DesktopInput` makes, so both write into one shared [InputState].
library;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/src/input/flame_input_bridge.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:flutter3d_game/flutter3d_game.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

KeyDownEvent _down(LogicalKeyboardKey key) => KeyDownEvent(
  logicalKey: key,
  physicalKey: PhysicalKeyboardKey.keyW,
  timeStamp: Duration.zero,
);

KeyUpEvent _up(LogicalKeyboardKey key) => KeyUpEvent(
  logicalKey: key,
  physicalKey: PhysicalKeyboardKey.keyW,
  timeStamp: Duration.zero,
);

/// A [DragUpdateEvent] carrying [delta], built without mounting any widget.
///
/// [DragUpdateEvent.deviceDelta] is derived purely from the
/// [DragUpdateDetails] passed to the constructor, so a bare [FlameGame] that
/// is never added to a widget tree is enough to build one by hand.
DragUpdateEvent _drag(FlameGame game, Offset delta) => DragUpdateEvent(
  1,
  game,
  DragUpdateDetails(globalPosition: Offset.zero, delta: delta),
);

void main() {
  late Bindings bindings;
  late InputState state;
  late FlameInputBridge bridge;

  setUp(() {
    bindings = Bindings(<InputSource, GameAction>{
      InputSource.key(LogicalKeyboardKey.keyW.keyId): GameAction.moveForward,
    });
    state = InputState();
    bridge = FlameInputBridge(bindings: bindings, inputState: state);
  });

  test('a bound key press latches its action as held', () {
    final consumed = !bridge.onKeyEvent(
      _down(LogicalKeyboardKey.keyW),
      <LogicalKeyboardKey>{LogicalKeyboardKey.keyW},
    );

    expect(consumed, isTrue);
    expect(state.held(GameAction.moveForward), isTrue);
  });

  test('the matching release lets the action go', () {
    bridge.onKeyEvent(_down(LogicalKeyboardKey.keyW), <LogicalKeyboardKey>{
      LogicalKeyboardKey.keyW,
    });

    bridge.onKeyEvent(_up(LogicalKeyboardKey.keyW), <LogicalKeyboardKey>{});

    expect(state.held(GameAction.moveForward), isFalse);
  });

  test('an unbound key is left alone, for the game to handle itself', () {
    final notConsumed = bridge.onKeyEvent(
      _down(LogicalKeyboardKey.keyQ),
      <LogicalKeyboardKey>{LogicalKeyboardKey.keyQ},
    );

    expect(notConsumed, isTrue);
    expect(state.held(GameAction.moveForward), isFalse);
  });

  test('onGameKeyEvent answers a game: handled for a bound key, ignored for '
      'the rest', () {
    // Mutation: return the component's polarity unflipped, and an unbound
    // key reads as handled, which is how a game loses its own shortcuts.
    expect(
      bridge.onGameKeyEvent(
        _down(LogicalKeyboardKey.keyW),
        <LogicalKeyboardKey>{LogicalKeyboardKey.keyW},
      ),
      KeyEventResult.handled,
    );
    expect(state.held(GameAction.moveForward), isTrue);
    expect(
      bridge.onGameKeyEvent(
        _down(LogicalKeyboardKey.keyQ),
        <LogicalKeyboardKey>{LogicalKeyboardKey.keyQ},
      ),
      KeyEventResult.ignored,
    );
  });

  test('a drag accumulates into the shared look delta', () {
    final game = FlameGame();

    bridge.onDragUpdate(_drag(game, const Offset(3.0, -1.0)));
    bridge.onDragUpdate(_drag(game, const Offset(2.0, 4.0)));

    expect(state.lookDelta.x, 5.0);
    expect(state.lookDelta.y, 3.0);
  });

  test('endStep drains the look delta, as InputState documents', () {
    final game = FlameGame();

    bridge.onDragUpdate(_drag(game, const Offset(10.0, 10.0)));
    state
      ..beginStep()
      ..endStep();

    expect(state.lookDelta.x, 0.0);
    expect(state.lookDelta.y, 0.0);
  });
}
