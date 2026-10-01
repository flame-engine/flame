/// The campaign: which stretches of river make up which level, what is on
/// them, and what the pilot has to do before the level's last bridge will
/// fall.
///
/// Plain Dart, like the course it shapes.
library;

import 'dart:math' as math;

import 'package:river_sortie/src/course.dart' show TargetKind;

/// What a level's stretches are populated with.
final class Mix {
  const Mix({
    required this.tanker,
    required this.helicopter,
    required this.depot,
    this.jet = 0.0,
    this.moving = 0.5,
    this.speed = 1.0,
    this.gunners = 0.0,
    this.islands = 0.35,
    this.narrowest = 6.0,
    this.widest = 15.0,
    this.spacing = (9.0, 14.0),
  });

  /// How the targets divide between the kinds. They need not add up to
  /// one; each is a share of their sum.
  final double tanker;
  final double helicopter;
  final double depot;
  final double jet;

  /// The chance a tanker or a helicopter moves at all once woken.
  final double moving;

  /// How fast everything that moves moves, against the first level.
  final double speed;

  /// The share of helicopters that fire at the jet.
  final double gunners;

  /// The chance a wide enough width of river has an island in it.
  final double islands;

  /// The river's half-width, narrowest and widest.
  final double narrowest;
  final double widest;

  /// Metres between one target and the next, least and most.
  final (double, double) spacing;

  /// Which kind [roll], between zero and one, picks.
  TargetKind kindFor(double roll) {
    final total = tanker + helicopter + depot + jet;
    var at = roll * total;
    for (final (kind, share) in <(TargetKind, double)>[
      (TargetKind.jet, jet),
      (TargetKind.depot, depot),
      (TargetKind.helicopter, helicopter),
    ]) {
      if (at < share) {
        return kind;
      }
      at -= share;
    }
    return TargetKind.tanker;
  }
}

/// One level: a name, a line of briefing, how many bridges long it is, and
/// the task that unshields its last one.
final class Level {
  const Level({
    required this.name,
    required this.briefing,
    required this.bridges,
    required this.mix,
    this.task = const <TargetKind, int>{},
  });

  final String name;
  final String briefing;
  final int bridges;
  final Mix mix;

  /// How many of each kind have to go down before the last bridge of the
  /// level can be. Empty for a level whose task is its bridges.
  final Map<TargetKind, int> task;

  /// Points for finishing it.
  int get bonus => 1000 * bridges;
}

/// The levels in order. After the last, the river goes on as the last one
/// for ever.
const List<Level> campaign = <Level>[
  Level(
    name: 'Shakedown',
    briefing: 'Bring down both bridges.',
    bridges: 2,
    mix: Mix(
      tanker: 0.45,
      helicopter: 0.2,
      depot: 0.3,
      moving: 0.55,
      speed: 0.8,
      islands: 0.25,
      narrowest: 7.0,
      spacing: (11.0, 16.0),
    ),
  ),
  Level(
    name: 'Supply Line',
    briefing: 'Sink six tankers before the last bridge.',
    bridges: 3,
    task: <TargetKind, int>{TargetKind.tanker: 6},
    mix: Mix(tanker: 0.55, helicopter: 0.15, depot: 0.25, moving: 0.7),
  ),
  Level(
    name: 'Rotor Alley',
    briefing: 'Down five helicopters. Some of them shoot back.',
    bridges: 3,
    task: <TargetKind, int>{TargetKind.helicopter: 5},
    mix: Mix(
      tanker: 0.25,
      helicopter: 0.45,
      depot: 0.22,
      jet: 0.08,
      moving: 0.75,
      speed: 1.1,
      gunners: 0.4,
    ),
  ),
  Level(
    name: 'Jet Stream',
    briefing: 'Shoot down three jets as they cross.',
    bridges: 3,
    task: <TargetKind, int>{TargetKind.jet: 3},
    mix: Mix(
      tanker: 0.3,
      helicopter: 0.3,
      depot: 0.2,
      jet: 0.18,
      moving: 0.8,
      speed: 1.2,
      gunners: 0.5,
      islands: 0.45,
      narrowest: 5.5,
      spacing: (8.0, 12.0),
    ),
  ),
  Level(
    name: 'Long Haul',
    briefing: 'Sink eight tankers and down four helicopters. Fuel is scarce.',
    bridges: 4,
    task: <TargetKind, int>{TargetKind.tanker: 8, TargetKind.helicopter: 4},
    mix: Mix(
      tanker: 0.4,
      helicopter: 0.32,
      depot: 0.12,
      jet: 0.14,
      moving: 0.85,
      speed: 1.3,
      gunners: 0.6,
      islands: 0.45,
      narrowest: 5.5,
      spacing: (8.0, 12.0),
    ),
  ),
  Level(
    name: 'Open River',
    briefing: 'No more orders. See how far the fuel goes.',
    bridges: 1 << 20,
    mix: Mix(
      tanker: 0.35,
      helicopter: 0.33,
      depot: 0.14,
      jet: 0.16,
      moving: 0.9,
      speed: 1.4,
      gunners: 0.7,
      islands: 0.5,
      narrowest: 5.0,
      spacing: (7.0, 11.0),
    ),
  ),
];

/// A level placed on the river: which sections it covers.
final class Stage {
  const Stage(this.index, this.level, this.first);

  /// Its place in [campaign].
  final int index;
  final Level level;

  /// Its first section, and its last: the one whose bridge ends it.
  final int first;
  int get last => first + level.bridges - 1;
}

/// The level section [section] belongs to. The calm water behind the start
/// counts as the first level's.
Stage stageOf(int section) {
  var first = 0;
  for (var i = 0; i < campaign.length; i++) {
    final level = campaign[i];
    if (section < first + level.bridges || i == campaign.length - 1) {
      return Stage(i, level, first);
    }
    first += level.bridges;
  }
  throw StateError('unreachable: the last level has no end');
}

/// The first section of level [index], clamped to the campaign.
int firstSectionOf(int index) {
  var first = 0;
  for (var i = 0; i < math.min(index, campaign.length - 1); i++) {
    first += campaign[i].bridges;
  }
  return first;
}
