/// The rules of a run on their own: points, jets, fuel and the checkpoint.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/rules.dart';

void main() {
  test('the targets are worth what they always were', () {
    expect(TargetKind.tanker.points, 30);
    expect(TargetKind.helicopter.points, 60);
    expect(TargetKind.depot.points, 80);
    expect(TargetKind.jet.points, 100);
  });

  test('every ten thousand points puts another jet in reserve', () {
    final run = RunState()..award(9990);
    expect(run.reserve, RunState.startingReserve);
    run.award(30);
    expect(run.reserve, RunState.startingReserve + 1);
    // One award that crosses two thresholds pays for both.
    run.award(20000);
    expect(run.reserve, RunState.startingReserve + 3);
  });

  test('a full tank lasts its time, and a depot fills it', () {
    final run = RunState();
    for (var i = 0; i < 60 * (RunState.tankSeconds ~/ 2); i++) {
      run.burn(1 / 60);
    }
    expect(run.fuel, closeTo(0.5, 0.01));
    expect(run.outOfFuel, isFalse);

    run.refuel(RunState.refillSeconds);
    expect(run.fuel, 1.0);

    run.burn(RunState.tankSeconds + 1.0);
    expect(run.fuel, 0.0);
    expect(run.outOfFuel, isTrue);
  });

  test('the checkpoint only ever moves up the river', () {
    final run = RunState()..bridgeDown(2);
    expect(run.checkpoint, 3);
    run.bridgeDown(0);
    expect(run.checkpoint, 3);
  });

  test('a lost jet is replaced from reserve until there is none', () {
    final run = RunState()..fuel = 0.2;
    for (var i = 0; i < RunState.startingReserve; i++) {
      expect(run.nextJet(), isTrue);
      expect(run.fuel, 1.0);
    }
    expect(run.reserve, 0);
    expect(run.nextJet(), isFalse);
  });
}
