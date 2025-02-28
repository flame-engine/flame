import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/experimental/layout_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:meta/meta.dart';

@isTest
void testLayoutComponent(
  String testName,
  LayoutComponent Function() layoutConstructor,
  Future<void> Function(FlameGame<World>) testBody,
) {
  testWithFlameGame(testName, testBody);
}

Future<void> runLayoutComponentTestRegistry(
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
