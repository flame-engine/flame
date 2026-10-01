/// The river as the course lays it out, with nothing drawn and no game
/// running: the part of River Sortie that decides whether it can be flown.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';

/// The first dozen stretches, which is further than a good run gets.
const int _sections = 12;

void main() {
  test('the same seed lays out the same river', () {
    final a = Course();
    final b = Course();
    for (var d = 0.0; d < sectionLength * 3; d += 7.0) {
      expect(a.rowAt(d).center, b.rowAt(d).center);
      expect(a.rowAt(d).half, b.rowAt(d).half);
      expect(a.rowAt(d).island, b.rowAt(d).island);
    }
    expect(
      a.section(2).targets.map((t) => (t.kind, t.distance, t.x)),
      b.section(2).targets.map((t) => (t.kind, t.distance, t.x)),
    );
  });

  test('another seed lays out another river', () {
    final a = Course();
    final b = Course(seed: 7);
    var differs = false;
    for (var d = 20.0; d < sectionLength; d += 5.0) {
      differs |= a.rowAt(d).center != b.rowAt(d).center;
    }
    expect(differs, isTrue);
  });

  test('every stretch meets the next narrow and on the middle line', () {
    // Generated one at a time, with no knowledge of each other: this is
    // the only thing that makes them join.
    final course = Course();
    for (var i = -1; i < _sections; i++) {
      final section = course.section(i);
      for (final d in <double>[section.start, section.end - 0.001]) {
        final row = course.rowAt(d);
        expect(row.center, closeTo(0.0, 1e-6), reason: 'section $i at $d');
        expect(row.half, closeTo(narrowHalf, 1e-3), reason: 'section $i');
        expect(row.hasIsland, isFalse, reason: 'section $i');
      }
    }
  });

  test('a tanker or a helicopter that moves has water to move across', () {
    final course = Course();
    var movers = 0;
    for (var i = 0; i < _sections; i++) {
      for (final target in course.section(i).targets) {
        if (target.kind == TargetKind.jet || target.speed == 0.0) {
          continue;
        }
        movers++;
        final (from, to) = course.rowAt(target.distance).channelAt(target.x)!;
        expect(
          to - from - 2.0 * target.kind.halfLength,
          greaterThanOrEqualTo(3.0),
          reason: '${target.kind} at ${target.distance}',
        );
      }
    }
    expect(movers, greaterThan(0));
  });

  test('there is always a channel a jet fits through', () {
    final course = Course();
    for (var d = -sectionLength; d < sectionLength * _sections; d += 0.5) {
      final row = course.rowAt(d);
      final widest = row.channels
          .map((c) => c.$2 - c.$1)
          .reduce((a, b) => a > b ? a : b);
      expect(widest, greaterThan(3.0), reason: 'at $d');
      expect(row.left, greaterThanOrEqualTo(-riverReach - 1e-9));
      expect(row.right, lessThanOrEqualTo(riverReach + 1e-9));
    }
  });

  test('an island still on the bed is water to fly over', () {
    const low = RiverRow(center: 0.0, half: 10.0, island: 0.1);
    expect(low.dryIsland, 0.0);
    expect(low.hasIsland, isFalse);
    expect(low.isWater(0.0, halfWidth: 0.75), isTrue);

    const high = RiverRow(center: 0.0, half: 10.0, island: 3.0);
    expect(high.dryIsland, closeTo(3.0, 0.1));
    expect(high.isWater(0.0), isFalse);
    expect(high.isWater(-6.0, halfWidth: 0.75), isTrue);
    expect(high.isLand(0.0, margin: 1.0), isTrue);
  });

  test('everything that floats is laid out on the water', () {
    final course = Course();
    for (var i = 0; i < _sections; i++) {
      for (final target in course.section(i).targets) {
        if (target.kind == TargetKind.jet) {
          continue;
        }
        expect(
          course
              .rowAt(target.distance)
              .isWater(target.x, halfWidth: target.kind.halfLength),
          isTrue,
          reason: '${target.kind} at ${target.distance}',
        );
      }
    }
  });

  test('trees and houses stand on the land', () {
    final course = Course();
    for (var i = -1; i < 4; i++) {
      final section = course.section(i);
      expect(section.scenery, isNotEmpty);
      for (final plant in section.scenery) {
        expect(
          section.rowAt(plant.distance).isWater(plant.x),
          isFalse,
          reason: '${plant.kind} at ${plant.distance}, ${plant.x}',
        );
      }
    }
  });

  test('the stretch behind the start is calm: no targets, no bridge', () {
    final section = Course().section(-1);
    expect(section.targets, isEmpty);
    expect(section.hasBridge, isFalse);
    expect(Course().section(0).hasBridge, isTrue);
  });
}
