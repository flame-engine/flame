/// Several players at one machine: each key reaches the player it is bound
/// for, and a pad is read on Flame's clock.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:flutter3d_game/flutter3d_game.dart'
    show Bindings, InputSource, PadInput;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pad_input/pad_input.dart';

const GameAction _up = GameAction('up');

FlameInputBridge _player(LogicalKeyboardKey key) => FlameInputBridge(
  bindings: Bindings(<InputSource, GameAction>{
    InputSource.key(key.keyId): _up,
  }),
  inputState: InputState(),
);

KeyDownEvent _down(LogicalKeyboardKey key) => KeyDownEvent(
  physicalKey: PhysicalKeyboardKey.keyA,
  logicalKey: key,
  timeStamp: Duration.zero,
);

/// A controller with the south face button held, and nothing else.
final class _HeldA extends GamepadPlatform {
  @override
  bool get isSupported => true;

  @override
  Stream<PadConnection> get connectionChanges =>
      const Stream<PadConnection>.empty();

  @override
  void read(PadSnapshot out) {
    out
      ..connected = true
      ..setDown(PadButton.faceSouth, down: true);
  }
}

void main() {
  test('each key reaches the player it is bound for, and no other', () {
    // Forwarded to the first bridge, player two's arrows moved player one.
    //
    // Mutation: stop at the first player.
    final one = _player(LogicalKeyboardKey.keyW);
    final two = _player(LogicalKeyboardKey.arrowUp);
    final players = PlayerInputs(<FlameInputBridge>[one, two]);

    expect(
      players.onGameKeyEvent(_down(LogicalKeyboardKey.arrowUp), const {}),
      KeyEventResult.handled,
    );
    expect(two.inputState.held(_up), isTrue);
    expect(one.inputState.held(_up), isFalse);

    expect(
      players.onGameKeyEvent(_down(LogicalKeyboardKey.keyQ), const {}),
      KeyEventResult.ignored,
      reason: "a key nobody has is the game's",
    );
    expect(players.stepEnds(), hasLength(2));
  });

  testWithGame<FlameGame>(
    "a pad beside the keys is read on Flame's clock",
    FlameGame.new,
    (game) async {
      // Nothing ticked a PadInput in a Flame game, and it never moved.
      //
      // Mutation: leave the pad unticked.
      final pad = PadInput(
        state: InputState(),
        pad: Gamepad(platform: _HeldA()),
      );
      final bridge = _player(LogicalKeyboardKey.keyW);
      game.addAll(<Component>[bridge.followPad(pad)]);
      await game.ready();

      expect(pad.heldButtons, isEmpty);
      game.update(1 / 60);
      expect(pad.heldButtons, contains(PadButton.faceSouth));
    },
  );
}
