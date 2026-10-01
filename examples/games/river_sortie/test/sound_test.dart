/// What the game says, heard through `flutter3d_audio_core`'s silent backend,
/// which records every voice it is asked for and plays none of them.
library;

import 'package:flame_test/flame_test.dart';
import 'package:flutter3d_audio_core/flutter3d_audio_core.dart';
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart' show GameAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/river_game.dart';

/// A game whose speakers are a silent backend that records every voice,
/// opened as the first take-off would open them.
Future<(RiverGame, SilentBackend)> _newGame() async {
  final ears = SilentBackend();
  final game = await initializeGame(
    () => RiverGame(
      speakers: () async =>
          (scene: AudioScene(backend: ears), close: () async {}),
    ),
  );
  game.open3d(cpuTestDevice(width: 32, height: 24).device);
  await game.sound.open();
  await game.ready();
  return (game, ears);
}

Future<void> _run(RiverGame game, int steps) async {
  for (var i = 0; i < steps; i++) {
    game.update(1 / 60);
    await game.ready();
  }
}

Iterable<SilentVoice> _playing(SilentBackend ears, SoundDef sound) =>
    ears.live.where((voice) => voice.asset == sound.asset);

bool _heard(SilentBackend ears, SoundDef sound) =>
    ears.started.any((voice) => voice.asset == sound.asset);

void main() {
  test('the bank names every file the generator writes, once each', () {
    expect(Sounds.all.length, 11);
    expect(Sounds.all.assets.toSet(), hasLength(11));
  });

  test('the engine drones while the jet flies, and climbs with the '
      'throttle', () async {
    final (game, ears) = await _newGame();
    await _run(game, 10);
    expect(_playing(ears, Sounds.engine), isEmpty, reason: 'still waiting');

    game.input.press(GameAction.moveBack);
    await _run(game, 60);
    final slow = _playing(ears, Sounds.engine).single.rate;

    game.input
      ..release(GameAction.moveBack)
      ..press(GameAction.moveForward);
    await _run(game, 30);
    expect(_playing(ears, Sounds.engine).single.rate, greaterThan(slow));
  });

  test(
    'the first take-off asks for the speakers, and only the first',
    () async {
      final (game, _) = await _newGame();
      var asked = 0;
      game.onFirstFlight = () => asked++;
      game.input.press(RiverGame.fire);
      await _run(game, 5);
      expect(asked, 1);

      game.run.fuel = 0.0;
      await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
      // The next jet waits for a fresh press, as the first one did.
      game.input
        ..release(RiverGame.fire)
        ..press(RiverGame.fire);
      await _run(game, 5);
      expect(game.phase, Phase.flying);
      expect(asked, 1);
    },
  );

  test('a shot, a hit and a crash each make their sound, and a crash '
      'silences the engine', () async {
    final (game, ears) = await _newGame();
    game.input.press(RiverGame.fire);
    await _run(game, 20);
    expect(_heard(ears, Sounds.shot), isTrue);

    game.hitTarget(
      game.targets.firstWhere((t) => t.plan.kind == TargetKind.tanker),
    );
    await _run(game, 1);
    expect(_heard(ears, Sounds.boom), isTrue);

    game.run.fuel = 0.0;
    await _run(game, 2);
    expect(_heard(ears, Sounds.crash), isTrue);
    expect(_playing(ears, Sounds.engine), isEmpty);
  });

  test('a new run after the last jet is not an extra jet', () async {
    final (game, ears) = await _newGame();
    game.run.reserve = 0;
    game.input.press(RiverGame.fire);
    await _run(game, 1);
    game.run.fuel = 0.0;
    await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
    expect(game.phase, Phase.over);

    game.input
      ..release(RiverGame.fire)
      ..press(RiverGame.fire);
    await _run(game, 3);
    expect(game.run.reserve, 3);
    expect(_heard(ears, Sounds.extraJet), isFalse);

    // Earned, it is heard.
    game.run.award(10000);
    await _run(game, 1);
    expect(_heard(ears, Sounds.extraJet), isTrue);
  });

  test('the low-fuel alarm sounds below a quarter of a tank and stops over '
      'a depot', () async {
    final (game, ears) = await _newGame();
    game.input.press(GameAction.moveForward);
    await _run(game, 2);
    game.run.fuel = 0.2;
    await _run(game, 2);
    expect(_playing(ears, Sounds.lowFuel), hasLength(1));

    final depot = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.depot,
    );
    game.jet.position.setFrom(depot.position);
    // Four steps, not one: put there by hand twenty metres at a time, the
    // jet is only found over the depot on the third step after. Flame's
    // broadphase catches up with a jump over a few frames; flying never
    // makes one.
    await _run(game, 4);
    expect(game.refuelling, isTrue);
    expect(_playing(ears, Sounds.refuel), hasLength(1));
    expect(_playing(ears, Sounds.lowFuel), isEmpty);
  });

  test(
    'a blast up the river is quieter than one near, and on its own side',
    () async {
      // Mutation: play the river's sounds at the listener, flat.
      final (game, ears) = await _newGame();
      await _run(game, 2);
      final byDistance = game.targets.toList()
        ..sort((a, b) => a.plan.distance.compareTo(b.plan.distance));
      final near = byDistance.first;
      final far = byDistance.last;
      expect(far.plan.distance - near.plan.distance, greaterThan(60.0));

      game.hitTarget(near);
      await _run(game, 1);
      final nearVoice = ears.started.lastWhere(
        (v) => v.asset == Sounds.boom.asset || v.asset == Sounds.bigBoom.asset,
      );
      game.hitTarget(far);
      await _run(game, 1);
      final farVoice = ears.started.lastWhere(
        (v) => v.asset == Sounds.boom.asset || v.asset == Sounds.bigBoom.asset,
      );
      expect(farVoice, isNot(same(nearVoice)));
      expect(farVoice.gain, lessThan(nearVoice.gain));
      final side = near.plan.x - game.jet.position.x;
      if (side.abs() > 2.0) {
        expect(nearVoice.pan.sign, side.sign);
      }
    },
  );
}
