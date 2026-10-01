/// The river: where the water is at every metre of the flight, and what
/// waits on it.
///
/// Plain Dart. Nothing here knows about Flame or a renderer, so the whole
/// course can be laid out and checked in a unit test, and the game and the
/// terrain mesh read one description of it rather than two.
///
/// **Distance runs up the river.** A point on the course is `(x, distance)`:
/// `x` across, metres from the middle of the valley, and `distance` along,
/// metres from where the first flight starts. Flame's `y` is `-distance`,
/// because Flame's `y` grows down the screen and the jet flies up it.
library;

import 'dart:math' as math;

import 'package:flutter3d_sim/flutter3d_sim.dart' show GameRandom;

import 'package:river_sortie/src/levels.dart';

/// How long one stretch of river is, bridge to bridge.
const double sectionLength = 180.0;

/// How far either side of the valley's middle the water may ever reach.
const double riverReach = 17.0;

/// How far either side of the middle the trees and houses stand.
const double valleyReach = 46.0;

/// How far either side the grass is drawn: as far as the camera sees at
/// all. The stretches ahead reach a few hundred units up the river, and a
/// wide window sees about as far across up there, so land that stopped at
/// [valleyReach] left the sky showing in both top corners. Only the outer
/// quads of each row get wider; the valley has no more vertices for it.
const double landReach = 400.0;

/// Half the water's width under a bridge, and where each stretch starts.
const double narrowHalf = 4.5;

/// How far before the end of its stretch a bridge stands.
const double bridgeInset = 10.0;

/// The river every run flies, unless a test asks for another.
const int defaultSeed = 1982;

/// How high the land stands above the water, and how deep the bed lies
/// under it, out of sight.
const double landHeight = 0.9;
const double bedDepth = -0.4;

/// A bank's slope: how far it reaches onto the land from the water line
/// at the top, and out under the water at the foot.
const double bankTop = 0.55;
const double bankUnder = 0.2;

/// How wide an island is before it stands at full height. A narrower one
/// is lower, down to nothing on the bed.
const double islandRise = 0.8;

/// What can be shot, and what it is worth.
enum TargetKind {
  tanker(30, 1.7),
  helicopter(60, 1.3),
  depot(80, 0.9),
  jet(100, 1.1);

  const TargetKind(this.points, this.halfLength);

  final int points;

  /// Half its length across the river, the way it moves: what keeps it off
  /// the banks.
  final double halfLength;
}

/// One target, as the course lays it out: before it is a component.
final class TargetPlan {
  const TargetPlan({
    required this.kind,
    required this.distance,
    required this.x,
    required this.heading,
    required this.speed,
    this.gunner = false,
  });

  final TargetKind kind;
  final double distance;
  final double x;

  /// `1` moving towards `+x`, `-1` towards `-x`. A still target still faces
  /// one way.
  final int heading;

  /// Metres per second once it wakes; zero for one that never moves.
  final double speed;

  /// A helicopter that fires at the jet.
  final bool gunner;
}

enum SceneryKind { tree, pine, house }

/// A tree or a house on the land, baked into the terrain mesh.
final class SceneryPlan {
  const SceneryPlan({
    required this.kind,
    required this.distance,
    required this.x,
    required this.scale,
    required this.turn,
  });

  final SceneryKind kind;
  final double distance;
  final double x;
  final double scale;

  /// Radians about the vertical, so no two houses face the same way.
  final double turn;
}

/// The river across one row of the course.
///
/// **An island is a width, not a flag.** Between two rows with and without
/// one, [island] grows from zero, so an island rises out of the middle of
/// the stream as a point and widens: a crossing into it is never a wall.
///
/// **The water is where the picture shows water.** A narrow island is also
/// a low one, under the surface until it is about a third of a metre
/// across, so what the jet can hit is [dryIsland], the part standing out
/// of the water, worked out from the same slopes the terrain mesh is built
/// with. Testing against [island] itself crashed a jet flying straight up
/// the middle into an island a few microns wide and still on the bed.
final class RiverRow {
  const RiverRow({
    required this.center,
    required this.half,
    required this.island,
  });

  final double center;
  final double half;
  final double island;

  double get left => center - half;
  double get right => center + half;
  double get islandLeft => center - island;
  double get islandRight => center + island;

  /// How far the island's slopes reach from its line, 0 to 1: it stands at
  /// full height only once it is [islandRise] across.
  double get islandGrown => (island / islandRise).clamp(0.0, 1.0);

  /// Half the width of the island above the water, zero while it is under.
  double get dryIsland {
    final grown = islandGrown;
    final crest = bedDepth + (landHeight - bedDepth) * grown;
    if (crest <= 0.0) {
      return 0.0;
    }
    final foot = island + bankUnder * grown;
    final shoulder = island - bankTop * grown;
    return foot + (shoulder - foot) * -bedDepth / (crest - bedDepth);
  }

  bool get hasIsland => dryIsland > 0.0;

  /// The stretches of open water across this row, left to right.
  List<(double, double)> get channels {
    final dry = dryIsland;
    return dry > 0.0
        ? <(double, double)>[(left, center - dry), (center + dry, right)]
        : <(double, double)>[(left, right)];
  }

  /// The channel [x] is over, or null over land.
  (double, double)? channelAt(double x) {
    for (final channel in channels) {
      if (x >= channel.$1 && x <= channel.$2) {
        return channel;
      }
    }
    return null;
  }

  /// Whether everything within [halfWidth] of [x] is over water.
  bool isWater(double x, {double halfWidth = 0.0}) => channels.any(
    (channel) => x - halfWidth >= channel.$1 && x + halfWidth <= channel.$2,
  );

  /// Whether [x] is on land at least [margin] from any water.
  bool isLand(double x, {double margin = 0.0}) {
    final outside = x < left - margin || x > right + margin;
    final dry = dryIsland;
    final onIsland = x > center - dry + margin && x < center + dry - margin;
    return outside || onIsland;
  }
}

/// The shape of the river at one point along a section, before smoothing.
typedef _Key = ({double at, double center, double half, double island});

/// One stretch of river, bridge to bridge, and what is on it.
///
/// **Every stretch starts and ends narrow, on the middle line.** That is what
/// makes a stretch generated on its own join the one before it without
/// either knowing the other: both meet at [narrowHalf] around zero, which
/// is also where the bridge crosses.
final class Section {
  Section._(this.index, this._keys, this.targets, this.scenery);

  /// Section [index] of the river [seed] lays out. The same two numbers give
  /// the same stretch, every time: the river is a place, not a dice roll.
  ///
  /// What is on it, and how wide and winding it runs, is the [Mix] of the
  /// level it belongs to, by [stageOf].
  factory Section.generate(int index, {int seed = defaultSeed}) {
    final random = GameRandom(_seedFor(seed, index));
    final mix = stageOf(index).level.mix;
    final keys = _layOut(index, mix, random);
    final shell = Section._(index, keys, const <TargetPlan>[], const []);
    return Section._(
      index,
      keys,
      index < 0 ? const <TargetPlan>[] : _populate(shell, mix, random),
      _plant(shell, random),
    );
  }

  final int index;
  final List<_Key> _keys;
  final List<TargetPlan> targets;
  final List<SceneryPlan> scenery;

  double get start => index * sectionLength;
  double get end => start + sectionLength;
  double get bridgeAt => end - bridgeInset;

  /// The stretch before the first flight has no bridge to cross: the jet
  /// starts past it.
  bool get hasBridge => index >= 0;

  /// The river at [distance], which has to fall inside this section.
  RiverRow rowAt(double distance) {
    final local = (distance - start).clamp(0.0, sectionLength);
    var i = 0;
    while (i < _keys.length - 2 && _keys[i + 1].at <= local) {
      i++;
    }
    final a = _keys[i];
    final b = _keys[i + 1];
    final t = ((local - a.at) / (b.at - a.at)).clamp(0.0, 1.0);
    final s = t * t * (3.0 - 2.0 * t);
    double mix(double from, double to) => from + (to - from) * s;
    return RiverRow(
      center: mix(a.center, b.center),
      half: mix(a.half, b.half),
      island: mix(a.island, b.island),
    );
  }

  /// Narrow at both ends, and every sixteen metres between a width, a
  /// centre and maybe an island. The stretch before the first one is a calm
  /// straight run, so the first thing a player sees is not a test.
  static List<_Key> _layOut(int index, Mix mix, GameRandom random) {
    _Key narrow(double at) =>
        (at: at, center: 0.0, half: narrowHalf, island: 0.0);
    if (index < 0) {
      return <_Key>[
        narrow(0.0),
        (at: 20.0, center: 0.0, half: 9.0, island: 0.0),
        (at: sectionLength - 30.0, center: 0.0, half: 9.0, island: 0.0),
        narrow(sectionLength - 20.0),
        narrow(sectionLength),
      ];
    }
    final keys = <_Key>[narrow(0.0), narrow(14.0)];
    var center = 0.0;
    for (var at = 30.0; at <= sectionLength - 38.0; at += 16.0) {
      final half =
          mix.narrowest + (mix.widest - mix.narrowest) * random.nextDouble();
      final reach = riverReach - half;
      center = (center + (random.nextDouble() * 2.0 - 1.0) * 8.0).clamp(
        -reach,
        reach,
      );
      // No island on the first width after the start: one growing out of
      // the middle there rose right in front of a jet that had only just
      // taken off straight up the stream.
      final island =
          at > 30.0 && half >= 10.0 && random.nextDouble() < mix.islands
          ? math.min(half * (0.3 + 0.2 * random.nextDouble()), half - 3.5)
          : 0.0;
      keys.add((at: at, center: center, half: half, island: island));
    }
    return keys
      ..add(narrow(sectionLength - 22.0))
      ..add(narrow(sectionLength));
  }

  /// Targets from a little past the start to a little short of the bridge,
  /// in the level's [Mix]: its kinds, its speeds, its spacing.
  static List<TargetPlan> _populate(
    Section section,
    Mix mix,
    GameRandom random,
  ) {
    final targets = <TargetPlan>[];
    final (closest, furthest) = mix.spacing;
    var distance = section.start + 28.0;
    while (distance < section.end - 32.0) {
      final kind = mix.kindFor(random.nextDouble());
      final heading = random.nextBool() ? 1 : -1;
      final rolledMoving = random.nextDouble() < mix.moving;
      final gunner =
          kind == TargetKind.helicopter && random.nextDouble() < mix.gunners;
      final row = section.rowAt(distance);
      final x = switch (kind) {
        // A jet comes in from off the side and crosses the whole valley.
        TargetKind.jet => -heading * (riverReach + 6.0),
        _ => _placeOnWater(row, kind.halfLength, random),
      };
      if (x != null) {
        // **A mover needs water to move across.** One put on a channel
        // barely longer than itself turned at each bank several times a
        // second and read as a craft shaking in place, not moving.
        final room = switch (row.channelAt(x)) {
          (final from, final to) => to - from - 2.0 * kind.halfLength,
          null => 0.0,
        };
        final moves = rolledMoving && room >= _roomToMove;
        targets.add(
          TargetPlan(
            kind: kind,
            distance: distance,
            x: x,
            heading: heading,
            speed:
                mix.speed *
                switch (kind) {
                  TargetKind.depot => 0.0,
                  TargetKind.jet => 14.0,
                  TargetKind.helicopter => moves ? 4.5 : 0.0,
                  TargetKind.tanker => moves ? 3.0 : 0.0,
                },
            gunner: gunner,
          ),
        );
      }
      distance += closest + (furthest - closest) * random.nextDouble();
    }
    return targets;
  }

  /// How far a tanker or a helicopter must be able to travel across its
  /// channel to be given a speed at all.
  static const double _roomToMove = 3.0;

  /// Somewhere on one of the row's channels, clear of both banks, or null
  /// when the channel picked is too narrow for it.
  static double? _placeOnWater(
    RiverRow row,
    double halfLength,
    GameRandom random,
  ) {
    final channels = row.channels;
    final (from, to) = channels[random.nextInt(channels.length)];
    final lo = from + halfLength + 0.4;
    final hi = to - halfLength - 0.4;
    if (hi <= lo) {
      return null;
    }
    return lo + (hi - lo) * random.nextDouble();
  }

  /// Trees and the odd house on the land either side and on the islands,
  /// kept off the banks and off the road that runs to the bridge.
  static List<SceneryPlan> _plant(Section section, GameRandom random) {
    final scenery = <SceneryPlan>[];
    for (var at = 1.5; at < sectionLength; at += 2.5) {
      final distance = section.start + at;
      final row = section.rowAt(distance);
      final count = 3 + random.nextInt(3);
      for (var i = 0; i < count; i++) {
        final x = (random.nextDouble() * 2.0 - 1.0) * (valleyReach - 1.0);
        final roll = random.nextDouble();
        final keepOff = (distance - section.bridgeAt).abs() < 3.5;
        if (!keepOff && row.isLand(x, margin: 1.6)) {
          scenery.add(
            SceneryPlan(
              kind: roll < 0.07
                  ? SceneryKind.house
                  : roll < 0.55
                  ? SceneryKind.pine
                  : SceneryKind.tree,
              distance: distance + random.nextDouble() * 1.5,
              x: x,
              scale: 0.8 + 0.5 * random.nextDouble(),
              turn: random.nextDouble() * math.pi * 2.0,
            ),
          );
        }
      }
    }
    return scenery;
  }

  /// One seed per section from the run's seed and the section's number.
  ///
  /// **Mixed, not added.** [GameRandom] is a xorshift, and two seeds a few
  /// units apart start it on sequences that agree for their first draws, so
  /// neighbouring sections came out with the same first width.
  static int _seedFor(int seed, int index) {
    var h = (seed * 0x9E3779B1 + index * 0x85EBCA77) & 0xFFFFFFFF;
    h = ((h ^ (h >> 16)) * 0x7FEB352D) & 0xFFFFFFFF;
    h = ((h ^ (h >> 15)) * 0x846CA68B) & 0xFFFFFFFF;
    return (h ^ (h >> 16)) | 1;
  }
}

/// The whole river, generated a section at a time as the jet reaches it.
final class Course {
  Course({this.seed = defaultSeed});

  final int seed;
  final Map<int, Section> _sections = <int, Section>{};

  Section section(int index) =>
      _sections.putIfAbsent(index, () => Section.generate(index, seed: seed));

  int sectionIndexAt(double distance) => (distance / sectionLength).floor();

  RiverRow rowAt(double distance) =>
      section(sectionIndexAt(distance)).rowAt(distance);
}
