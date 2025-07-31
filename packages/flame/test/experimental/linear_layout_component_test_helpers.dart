import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:meta/meta.dart';

@isTest
void testLinearLayoutComponent(
  String testName,
  LinearLayoutComponent Function() layoutConstructor,
  Future<void> Function(FlameGame<World>) testBody,
) {
  testWithFlameGame(testName, testBody);
}

Future<void> runLinearLayoutComponentTestRegistry(
  Map<String, Future<void> Function(FlameGame<World>, Direction)> testRegistry,
) async {
  for (final entry in testRegistry.entries) {
    final name = entry.key;
    final testFunction = entry.value;
    testWithFlameGame('[RowComponent] $name', (game) {
      return testFunction(game, Direction.horizontal);
    });
    testWithFlameGame('[ColumnComponent] $name', (game) {
      return testFunction(game, Direction.vertical);
    });
  }
}
