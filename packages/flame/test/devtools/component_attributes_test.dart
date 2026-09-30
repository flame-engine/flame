import 'package:flame/components.dart';
import 'package:flame/devtools.dart';
import 'package:flame/src/devtools/component_attributes.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('componentAttributes', () {
    test('only reports the priority for a plain component', () {
      expect(componentAttributes(Component(priority: 3)), {'priority': 3});
    });

    test('reports the transform of a position component', () {
      final component = PositionComponent(
        position: Vector2(1, 2),
        size: Vector2(3, 4),
        angle: 0.5,
        scale: Vector2(2, 3),
        anchor: Anchor.center,
        priority: 7,
      );

      expect(componentAttributes(component), {
        'priority': 7,
        'position': [1.0, 2.0],
        'size': [3.0, 4.0],
        'angle': 0.5,
        'scale': [2.0, 3.0],
        'anchor': 'center',
      });
    });
  });

  group('ComponentTreeNode', () {
    testWithFlameGame('includes the attributes of every component', (
      game,
    ) async {
      final player = PositionComponent(position: Vector2(5, 6));
      await game.world.ensureAdd(player);

      final node = ComponentTreeNode.fromComponent(game);
      final worldNode = node.children.singleWhere((c) => c.name == 'World');
      final playerNode = worldNode.children.single;

      expect(playerNode.id, player.hashCode);
      expect(playerNode.attributes['position'], [5.0, 6.0]);
      expect(worldNode.attributes, {'priority': game.world.priority});
    });

    test('survives a round trip through JSON', () {
      final node = ComponentTreeNode(
        1,
        'Player',
        'Player()',
        true,
        [ComponentTreeNode(2, 'Child', 'Child()', false, [])],
        attributes: {
          'priority': 1,
          'position': [1.0, 2.0],
        },
      );

      final decoded = ComponentTreeNode.fromJson(node.toJson());

      expect(decoded.toJson(), node.toJson());
    });

    test('reads JSON without attributes', () {
      final decoded = ComponentTreeNode.fromJson({
        'id': 1,
        'name': 'Player',
        'toString': 'Player()',
        'isPositionComponent': false,
        'children': <dynamic>[],
      });

      expect(decoded.attributes, isEmpty);
    });
  });
}
