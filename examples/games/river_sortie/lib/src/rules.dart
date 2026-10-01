/// The rules of a run, kept apart from everything that draws or moves it:
/// the score, the jets left, the fuel, and the bridge a lost jet starts
/// again from.
library;

import 'dart:math' as math;

import 'package:river_sortie/src/course.dart' show TargetKind;
import 'package:river_sortie/src/levels.dart';

/// One run, from the first take-off to the last jet lost.
final class RunState {
  /// Jets in reserve at the start, not counting the one flying.
  static const int startingReserve = 3;

  /// Another jet in reserve every this many points.
  static const int extraJetEvery = 10000;

  /// A full tank lasts this many seconds of flying.
  static const double tankSeconds = 38.0;

  /// A depot fills an empty tank in this many seconds over it.
  static const double refillSeconds = 2.4;

  /// Below this the gauge warns.
  static const double lowFuel = 0.25;

  int score = 0;
  int reserve = startingReserve;

  /// From empty at zero to full at one.
  double fuel = 1.0;

  /// The section a lost jet starts again from: the one past the last bridge
  /// it brought down.
  int checkpoint = 0;

  int _nextExtraJet = extraJetEvery;

  /// What has gone down on the level being flown, by kind. Kept through a
  /// lost jet: what was shot stays shot, even though the river puts it back.
  final Map<TargetKind, int> tally = <TargetKind, int>{};

  /// One more [kind] down on this level.
  void count(TargetKind kind) => tally[kind] = (tally[kind] ?? 0) + 1;

  /// How many more of [kind] [level]'s task wants.
  int stillWanted(Level level, TargetKind kind) =>
      math.max(0, (level.task[kind] ?? 0) - (tally[kind] ?? 0));

  /// Whether [level]'s task is done, and its last bridge can fall.
  bool taskDone(Level level) =>
      level.task.keys.every((kind) => stillWanted(level, kind) == 0);

  /// [level] is flown: its bonus, and a clean tally for the next one.
  void finishLevel(Level level) {
    award(level.bonus);
    tally.clear();
  }

  bool get outOfFuel => fuel <= 0.0;
  bool get fuelLow => fuel < lowFuel;

  /// Adds [points], and a jet in reserve for every threshold they carry the
  /// score past.
  void award(int points) {
    score += points;
    while (score >= _nextExtraJet) {
      reserve++;
      _nextExtraJet += extraJetEvery;
    }
  }

  void burn(double dt) => fuel = math.max(0.0, fuel - dt / tankSeconds);

  void refuel(double dt) => fuel = math.min(1.0, fuel + dt / refillSeconds);

  /// The bridge at the end of section [index] is down: the next jet starts
  /// past it.
  void bridgeDown(int index) => checkpoint = math.max(checkpoint, index + 1);

  /// Takes a jet out of reserve for the next attempt, with a full tank.
  /// False when there is none left and the run is over.
  bool nextJet() {
    if (reserve == 0) {
      return false;
    }
    reserve--;
    fuel = 1.0;
    return true;
  }
}
