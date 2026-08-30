import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _ShapeBody extends BodyComponent {
  _ShapeBody({required this.geometry, required this.type});

  final ShapeGeometry geometry;
  final BodyType type;

  @override
  Body createBody() =>
      world.createBody(BodyDef(type: type))..createShape(geometry, ShapeDef());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('body scale warning', () {
    late List<String> messages;
    late DebugPrintCallback previousDebugPrint;

    setUp(() {
      BodyComponent.debugWarnedAboutBodyScale = false;
      messages = [];
      previousDebugPrint = debugPrint;
      debugPrint = (message, {int? wrapWidth}) => messages.add(message ?? '');
    });

    tearDown(() {
      debugPrint = previousDebugPrint;
      BodyComponent.debugWarnedAboutBodyScale = false;
    });

    // The ball from the report that prompted this warning: a radius equal to
    // the speculative distance, so it is permanently in contact.
    testWithGame(
      'warns for a dynamic body around the speculative distance',
      Forge2DGame.new,
      (game) async {
        await game.world.ensureAdd(
          _ShapeBody(
            geometry: Circle(radius: Tolerances.speculativeDistance),
            type: BodyType.dynamic,
          ),
        );

        expect(messages, hasLength(1));
        expect(messages.single, contains('meters across'));
        expect(messages.single, contains('lengthUnitsPerMeter'));
      },
    );

    testWithGame('only warns once', Forge2DGame.new, (game) async {
      for (var i = 0; i < 3; i++) {
        await game.world.ensureAdd(
          _ShapeBody(geometry: Circle(radius: 0.01), type: BodyType.dynamic),
        );
      }

      expect(messages, hasLength(1));
    });

    testWithGame(
      'does not warn for a body in the range Forge2D is tuned for',
      Forge2DGame.new,
      (game) async {
        await game.world.ensureAdd(
          _ShapeBody(geometry: Circle(radius: 0.5), type: BodyType.dynamic),
        );

        expect(messages, isEmpty);
      },
    );

    testWithGame(
      'does not warn for thin static geometry',
      Forge2DGame.new,
      (game) async {
        await game.world.ensureAdd(
          _ShapeBody(
            geometry: Polygon.box(20, 0.001),
            type: BodyType.static,
          ),
        );

        expect(messages, isEmpty);
      },
    );

    // Long and thin is a normal shape to have; only bodies that are small in
    // every direction are a scale problem.
    testWithGame(
      'does not warn for a thin but long dynamic body',
      Forge2DGame.new,
      (game) async {
        await game.world.ensureAdd(
          _ShapeBody(
            geometry: Polygon.box(5, 0.005),
            type: BodyType.dynamic,
          ),
        );

        expect(messages, isEmpty);
      },
    );
  });
}
