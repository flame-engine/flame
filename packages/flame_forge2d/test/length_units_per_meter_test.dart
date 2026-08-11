import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// The length unit is process-wide, so this file changes it for every test in
// it. `flutter test` runs each test file in its own process, which is what
// keeps it from reaching the rest of the suite.
class _ScaledGame extends Forge2DGame {
  _ScaledGame() : super(lengthUnitsPerMeter: 100);
}

class _ConflictingGame extends Forge2DGame {
  _ConflictingGame() : super(lengthUnitsPerMeter: 25);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Forge2DGame.lengthUnitsPerMeter', () {
    test('defaults to null, leaving the length unit alone', () {
      expect(Forge2DGame().lengthUnitsPerMeter, isNull);
    });

    testWithGame('scales the Forge2D tolerances', _ScaledGame.new, (
      game,
    ) async {
      expect(Tolerances.lengthUnitsPerMeter, 100);
      expect(Tolerances.linearSlop, closeTo(0.5, 1e-6));
      expect(Tolerances.speculativeDistance, closeTo(2, 1e-6));
    });

    // Runs after the game above has already fixed the length unit at 100.
    test('throws when a second game disagrees about the length unit', () async {
      await expectLater(
        _ConflictingGame().onLoad(),
        throwsA(isA<StateError>()),
      );
    });

    testWithGame(
      'a body is measured against the scaled tolerances',
      _ScaledGame.new,
      (game) async {
        // Two meters across, which is tiny at this scale but well clear of
        // the speculative distance in Box2D's own units.
        BodyComponent.debugWarnedAboutBodyScale = false;
        await game.world.ensureAdd(
          BodyComponent(
            bodyDef: BodyDef(type: BodyType.dynamic),
            shapeSpecs: [ShapeSpec(Circle(radius: 5))],
          ),
        );

        expect(BodyComponent.debugWarnedAboutBodyScale, isFalse);
      },
    );
  });
}
