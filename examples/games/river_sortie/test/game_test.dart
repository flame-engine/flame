/// The game itself: a real `FlameGame`, loaded and mounted the way Flame's
/// own test harness does it, its world built on a CPU device, and stepped by
/// calling `update` sixty times a simulated second. Every hit below is
/// Flame's collision detection finding two hitboxes overlapping.
library;

import 'dart:math' as math;

import 'package:flame/collisions.dart' show ShapeHitbox;
import 'package:flame/components.dart' show TextComponent, Vector2;
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart' show GameAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/levels.dart';
import 'package:river_sortie/src/models.dart' show flightHeight;
import 'package:river_sortie/src/river_game.dart';
import 'package:river_sortie/src/rules.dart';

Future<RiverGame> _newGame() async {
  final game = await initializeGame(RiverGame.new);
  game.open3d(cpuTestDevice(width: 32, height: 24).device);
  await game.ready();
  return game;
}

/// Steps [game] [steps] sixtieths of a second, letting Flame add and remove
/// whatever the step queued before the next one.
Future<void> _run(RiverGame game, int steps) async {
  for (var i = 0; i < steps; i++) {
    game.update(1 / 60);
    await game.ready();
  }
}

/// Puts the jet at [x], [distance] and in the air, the stretches around it
/// built.
Future<void> _flyFrom(RiverGame game, double x, double distance) async {
  game.jet.position.setValues(x, -distance);
  game.phase = Phase.flying;
  await _run(game, 1);
}

/// Whether a jet at [x] flies from [from] to [to] without touching a bank.
bool _clear(Course course, double x, double from, double to) {
  for (var d = from; d <= to; d += 0.25) {
    if (!course.rowAt(d).isWater(x, halfWidth: RiverGame.wingReach + 0.2)) {
      return false;
    }
  }
  return true;
}

void main() {
  test('the jet waits on the water until the trigger', () async {
    final game = await _newGame();
    final start = game.distance;
    await _run(game, 60);
    expect(game.phase, Phase.ready);
    expect(game.distance, start);

    game.input.press(RiverGame.fire);
    await _run(game, 60);
    expect(game.phase, Phase.flying);
    expect(game.distance, greaterThan(start + 5.0));
  });

  test(
    'Flame moves the jet and the bridge carries it into the scene',
    () async {
      final game = await _newGame();
      game.input.press(GameAction.moveForward);
      await _run(game, 45);

      final node = game.jet.node.readPosition();
      expect(node.z, closeTo(-game.distance, 1e-6));
      expect(node.x, closeTo(game.jet.position.x, 1e-6));
      expect(node.y, closeTo(flightHeight, 1e-6));
    },
  );

  test('flying onto the bank loses a jet, and the next starts on the '
      'water', () async {
    final game = await _newGame();
    game.input
      ..press(RiverGame.fire)
      ..press(GameAction.moveLeft);
    for (var i = 0; i < 300 && game.phase != Phase.crashed; i++) {
      await _run(game, 1);
    }
    expect(game.phase, Phase.crashed);
    expect(game.lastCrash, Crash.bank);

    game.input
      ..release(RiverGame.fire)
      ..release(GameAction.moveLeft);
    await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
    expect(game.phase, Phase.ready);
    expect(game.run.reserve, RunState.startingReserve - 1);
    expect(
      game.course.rowAt(game.distance).isWater(game.jet.position.x),
      isTrue,
    );
  });

  test('a shot brings a target down, and it scores and counts', () async {
    final game = await _newGame();
    // A still target the jet has a clear run at from twenty metres short,
    // and not a depot, whose blast could take a neighbour and score twice.
    final target = game.targets.firstWhere(
      (t) =>
          t.plan.kind != TargetKind.jet &&
          t.plan.kind != TargetKind.depot &&
          t.plan.speed == 0.0 &&
          _clear(
            game.course,
            t.plan.x,
            t.plan.distance - 20.0,
            t.plan.distance - 2.0,
          ),
    );
    await _flyFrom(game, target.plan.x, target.plan.distance - 20.0);
    game.input.press(RiverGame.fire);
    for (var i = 0; i < 90 && !target.down; i++) {
      await _run(game, 1);
    }
    expect(target.down, isTrue);
    // At least: shots still in the air when it went down may find more.
    expect(game.run.score, greaterThanOrEqualTo(target.plan.kind.points));
    expect(game.run.tally[target.plan.kind], greaterThanOrEqualTo(1));
  });

  test('a target going down puts its points over it on the screen, '
      'and they rise and go', () async {
    final game = await _newGame();
    final target = game.targets.firstWhere(
      (t) => t.plan.kind != TargetKind.depot,
    );
    final at = target.scenePosition;
    // The game's own camera, put straight behind and above the target.
    game.camera3d
      ..setPosition(at.x, at.y + 10.0, at.z + 10.0)
      ..lookAt(at);
    game.hitTarget(target);
    await game.ready();

    Iterable<TextComponent> popups() => game.camera.viewport.children
        .whereType<TextComponent>()
        .where((text) => text.text == '+${target.plan.kind.points}');
    final popup = popups().single;
    // Looked at from straight behind and above: the middle of the screen.
    expect(popup.position.x, closeTo(game.size.x / 2, 1.0));
    expect(popup.position.y, closeTo(game.size.y / 2, 1.0));

    await _run(game, 30);
    expect(popup.position.y, lessThan(game.size.y / 2 - 10.0));
    await _run(game, 40);
    expect(popups(), isEmpty);
  });

  test('a tanker hit lists and sinks, and is no longer solid', () async {
    final game = await _newGame();
    final tanker = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.tanker,
    );
    game.hitTarget(tanker);
    await _run(game, 1);
    expect(tanker.children.whereType<ShapeHitbox>(), isEmpty);

    await _run(game, 60);
    expect(tanker.isMounted, isTrue, reason: 'still going under');
    expect(tanker.elevation, lessThan(-0.3));
    await _run(game, 120);
    expect(tanker.isMounted, isFalse);
  });

  test('a helicopter hit spins down into the river', () async {
    final game = await _newGame();
    final helicopter = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.helicopter,
    );
    game.hitTarget(helicopter);
    await _run(game, 20);
    expect(helicopter.elevation, lessThan(flightHeight - 0.2));
    await _run(game, 40);
    expect(helicopter.isMounted, isFalse);
  });

  test('a depot going up takes its neighbours with it', () async {
    final game = await _newGame();
    final depot = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.depot,
    );
    final neighbour = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.tanker,
    );
    final far = game.targets.lastWhere((t) => t != depot && t != neighbour);
    neighbour.position.setFrom(depot.position + Vector2(2.5, 0.0));

    game.hitTarget(depot);
    expect(neighbour.down, isTrue);
    expect(far.down, isFalse);
    expect(game.run.score, TargetKind.depot.points + TargetKind.tanker.points);
  });

  test('the last bridge of a level stands until the task is done, and '
      'falling finishes the level', () async {
    final game = await _newGame();
    game.startOnLevel(1);
    final stage = stageOf(firstSectionOf(1));
    expect(stage.level.task[TargetKind.tanker], greaterThan(0));
    final last = game.course.section(stage.last);
    final center = last.rowAt(last.bridgeAt).center;

    // Task not done: the shots spark off it, and the jet flies into it.
    await _flyFrom(game, center, last.bridgeAt - 12.0);
    final shielded = game.bridges.firstWhere((b) => b.section == stage.last);
    expect(game.shielded(shielded), isTrue);
    game.input.press(RiverGame.fire);
    await _run(game, 60);
    expect(shielded.down, isFalse);
    expect(shielded.shield.visible, isTrue);
    expect(game.lastCrash, Crash.collision);
    expect(game.banner, contains('TANKERS'));

    // Task done: the same bridge falls, and the level pays its bonus.
    await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
    game.run.tally[TargetKind.tanker] = stage.level.task[TargetKind.tanker]!;
    final before = game.run.score;
    await _flyFrom(game, center, last.bridgeAt - 12.0);
    final open = game.bridges.firstWhere((b) => b.section == stage.last);
    expect(game.shielded(open), isFalse);
    await _run(game, 1);
    expect(open.shield.visible, isFalse);
    for (var i = 0; i < 60 && !open.down; i++) {
      await _run(game, 1);
    }
    expect(open.down, isTrue);
    expect(
      game.run.score - before,
      greaterThanOrEqualTo(500 + stage.level.bonus),
    );
    expect(game.run.tally, isEmpty);
    expect(game.run.checkpoint, stage.last + 1);
    expect(game.banner, contains('LEVEL COMPLETE'));
  });

  test('a gunner helicopter fires at the jet, and its bullet brings the jet '
      'down', () async {
    final game = await _newGame();
    game.startOnLevel(2);
    final stage = stageOf(firstSectionOf(2));
    final gunner =
        <TargetPlan>[
          for (var i = stage.first; i <= stage.last; i++)
            ...game.course.section(i).targets,
        ].firstWhere(
          (plan) =>
              plan.gunner &&
              _clear(
                game.course,
                plan.x,
                plan.distance - 31.0,
                plan.distance - 29.0,
              ),
        );

    await _flyFrom(game, gunner.x, gunner.distance - 30.0);
    game.speed = 0.0;
    var fired = false;
    for (var i = 0; i < 120 && !fired; i++) {
      // Held in place: only the helicopter's aim is under test here.
      game.jet.position.y = -(gunner.distance - 30.0);
      await _run(game, 1);
      fired = game.children.whereType<EnemyShotComponent>().isNotEmpty;
    }
    expect(fired, isTrue);

    for (var i = 0; i < 120 && game.phase == Phase.flying; i++) {
      game.jet.position.y = -(gunner.distance - 30.0);
      await _run(game, 1);
    }
    expect(game.lastCrash, Crash.collision);
  });

  test('a depot shot from right over it takes the jet too', () async {
    final game = await _newGame();
    final depot = game.targets.firstWhere(
      (t) => t.plan.kind == TargetKind.depot,
    );
    await _flyFrom(game, depot.plan.x, depot.plan.distance - 0.5);
    game.hitTarget(depot);
    expect(game.phase, Phase.crashed);
    expect(game.lastCrash, Crash.collision);
  });

  test('an intact bridge stops the jet', () async {
    final game = await _newGame();
    final section = game.course.section(0);
    final center = section.rowAt(section.bridgeAt).center;
    await _flyFrom(game, center, section.bridgeAt - 6.0);
    await _run(game, 40);
    expect(game.phase, Phase.crashed);
    expect(game.lastCrash, Crash.collision);
  });

  test('a bridge shot down lets the jet through, and the next jet starts '
      'past it', () async {
    final game = await _newGame();
    final section = game.course.section(0);
    final center = section.rowAt(section.bridgeAt).center;
    final bridge = game.bridges.firstWhere((b) => b.section == 0);
    await _flyFrom(game, center, section.bridgeAt - 12.0);

    game.input.press(RiverGame.fire);
    for (var i = 0; i < 300 && game.distance < section.end + 5.0; i++) {
      await _run(game, 1);
    }
    expect(bridge.down, isTrue);
    expect(game.phase, Phase.flying);
    expect(game.distance, greaterThan(section.end));
    expect(game.run.checkpoint, 1);
    expect(game.run.score, greaterThanOrEqualTo(500));

    game.run.fuel = 0.0;
    await _run(game, 1);
    expect(game.lastCrash, Crash.fuel);
    await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
    expect(game.phase, Phase.ready);
    expect(game.course.sectionIndexAt(game.distance), 1);
  });

  test('flying over a depot fills the tank', () async {
    final game = await _newGame();
    final depot = game.targets.firstWhere(
      (t) =>
          t.plan.kind == TargetKind.depot &&
          _clear(
            game.course,
            t.plan.x,
            t.plan.distance - 6.0,
            t.plan.distance + 3.0,
          ),
    );
    await _flyFrom(game, depot.plan.x, depot.plan.distance - 6.0);
    game.run.fuel = 0.5;
    await _run(game, 45);
    expect(game.phase, Phase.flying);
    expect(game.run.fuel, greaterThan(0.55));
  });

  test('a moving target waits for the jet to come close', () async {
    final game = await _newGame();
    final mover = game.targets.firstWhere(
      (t) =>
          t.plan.speed > 0.0 &&
          t.plan.kind != TargetKind.jet &&
          t.plan.distance - game.distance > RiverGame.wakeRange + 10.0,
    );
    await _run(game, 60);
    expect(mover.position.x, closeTo(mover.plan.x, 1e-4));

    // Still on the water, only nearer: it is distance that wakes a target,
    // not the jet being in the air.
    game.jet.position.y = -(mover.plan.distance - RiverGame.wakeRange + 5.0);
    // The furthest it got rather than where it ended: a mover that meets a
    // bank turns back, and a second later can be where it started.
    var furthest = 0.0;
    for (var i = 0; i < 60; i++) {
      await _run(game, 1);
      furthest = math.max(furthest, (mover.position.x - mover.plan.x).abs());
    }
    expect(mover.awake, isTrue);
    expect(furthest, greaterThan(0.5));
  });

  test("every model loads and takes its primitive's place", () async {
    final game = await _newGame();
    // The files on disk: an isolate in a test has no app bundle to read.
    await game.dressWithModels(source: FileAssetSource.new);

    bool wearsModel(SceneNode visual) =>
        visual.children.length == 1 &&
        (visual.children.single.name ?? '').endsWith('model');
    expect(wearsModel(game.jet.visual), isTrue);
    for (final target in game.targets) {
      expect(
        wearsModel(target.visual),
        target.plan.kind != TargetKind.depot,
        reason: '${target.plan.kind} at ${target.plan.distance}',
      );
    }
  });

  test(
    'the last jet lost ends the run, and the trigger starts another',
    () async {
      final game = await _newGame();
      game.run.reserve = 0;
      game.input.press(RiverGame.fire);
      await _run(game, 1);
      game.run.fuel = 0.0;
      await _run(game, (RiverGame.crashPause * 60).ceil() + 2);
      expect(game.phase, Phase.over);

      game.input
        ..release(RiverGame.fire)
        ..press(RiverGame.fire);
      await _run(game, 1);
      expect(game.phase, Phase.ready);
      expect(game.run.reserve, RunState.startingReserve);
      expect(game.run.score, 0);
    },
  );

  test('a second of flight covers the same river at any frame rate', () async {
    // Flown in frames, the jet's distance and its throttle depended on how
    // long each frame was. In fixed steps they cannot.
    //
    // Mutation: fly in Flame's frames rather than in the game's steps.
    Future<double> flown(double frame) async {
      final game = await _newGame();
      game.input.press(GameAction.moveForward);
      final frames = (1.0 / frame).round();
      for (var i = 0; i < frames; i++) {
        game.update(frame);
        await game.ready();
      }
      return game.distance;
    }

    final slow = await flown(1 / 30);
    expect(slow, greaterThan(0.0));
    expect(await flown(1 / 120), closeTo(slow, 1e-6));
  });
}
