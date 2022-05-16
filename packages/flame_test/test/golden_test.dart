import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Golden tests', () {
    final tester = FlameTester(FlameGame.new);

    tester.testGameWidget(
      'renders correctly',
      setUp: (game, _) async {
        await game.ensureAdd(
          CircleComponent(
            radius: 10,
            position: Vector2.all(100),
            paint: Paint()..color = Colors.white,
          ),
        );
      },
      verify: (game, tester) async {
        await expectLater(
          find.byGame<FlameGame>(),
          matchesGoldenFile('golden_test.png'),
        );
      },
    );

    testGolden(
      'Same test but with testGolden',
      (game) async {
        final paint = Paint()..color = Colors.white;
        game.add(
          CircleComponent(radius: 10, position: Vector2.all(100), paint: paint),
        );
      },
      goldenFile: 'golden_test.png',
    );
  });
}
