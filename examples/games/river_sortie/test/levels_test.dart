/// The campaign against the river it lays out: that the levels follow each
/// other bridge by bridge, and that every task can be done with what its
/// level puts on the water.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/levels.dart';

void main() {
  test('the levels follow each other, a bridge each', () {
    var section = 0;
    for (var i = 0; i < campaign.length - 1; i++) {
      final stage = stageOf(section);
      expect(stage.index, i);
      expect(stage.first, section);
      expect(firstSectionOf(i), section);
      expect(stageOf(stage.last).index, i);
      section = stage.last + 1;
    }
    // The last level never ends.
    expect(stageOf(section).index, campaign.length - 1);
    expect(stageOf(section + 500).index, campaign.length - 1);
    // The calm water behind the start is the first level's.
    expect(stageOf(-1).index, 0);
  });

  test('every task can be done with what its level puts on the river', () {
    final course = Course();
    for (var i = 0; i < campaign.length - 1; i++) {
      final stage = stageOf(firstSectionOf(i));
      final plans = <TargetPlan>[
        for (var s = stage.first; s <= stage.last; s++)
          ...course.section(s).targets,
      ];
      for (final MapEntry(key: kind, value: wanted)
          in stage.level.task.entries) {
        final there = plans.where((plan) => plan.kind == kind).length;
        // With room to miss: a task that needs every last one is a level
        // nobody finishes.
        expect(
          there,
          greaterThanOrEqualTo(wanted + (wanted + 1) ~/ 2),
          reason: '${stage.level.name} wants $wanted ${kind.name}, has $there',
        );
      }
    }
  });

  test('the first level has no jets, and later ones have gunners', () {
    final course = Course();
    final first = stageOf(0);
    for (var s = first.first; s <= first.last; s++) {
      expect(
        course.section(s).targets.where((t) => t.kind == TargetKind.jet),
        isEmpty,
      );
      expect(course.section(s).targets.where((t) => t.gunner), isEmpty);
    }
    final rotors = stageOf(firstSectionOf(2));
    expect(
      <TargetPlan>[
        for (var s = rotors.first; s <= rotors.last; s++)
          ...course.section(s).targets,
      ].where((t) => t.gunner),
      isNotEmpty,
    );
  });

  test('a mix picks each kind in its share', () {
    const mix = Mix(tanker: 1.0, helicopter: 1.0, depot: 1.0, jet: 1.0);
    final counts = <TargetKind, int>{};
    for (var i = 0; i < 400; i++) {
      final kind = mix.kindFor(i / 400);
      counts[kind] = (counts[kind] ?? 0) + 1;
    }
    for (final kind in TargetKind.values) {
      expect(counts[kind], 100, reason: kind.name);
    }
  });
}
