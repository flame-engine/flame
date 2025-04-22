import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopCommand extends FlameConsoleCommand {
  @override
  String get description => '';

  @override
  String get name => '';

  @override
  (String?, String) execute(FlameGame<World> game, ArgResults results) {
    return (null, '');
  }
}

void main() {
  group('Commands', () {
    testWithGame(
      'listAllChildren crawls on all children',
      FlameGame.new,
      (game) async {
        await game.world.add(
          RectangleComponent(
            children: [
              PositionComponent(),
            ],
          ),
        );

        await game.ready();

        final command = _NoopCommand();
        final components = command.listAllChildren(game.world);

        expect(components, hasLength(2));
        expect(components[0], isA<RectangleComponent>());
        expect(components[1], isA<PositionComponent>());
      },
    );

    group('onChildMatch', () {
      testWithGame(
        'match children with the given types',
        FlameGame.new,
        (game) async {
          await game.world.addAll([
            RectangleComponent(
              children: [
                PositionComponent(),
              ],
            ),
            PositionComponent(),
          ]);

          await game.ready();

          final command = _NoopCommand();
          final components = <Component>[];
          command.onChildMatch(
            components.add,
            rootComponent: game.world,
            types: ['PositionComponent'],
          );

          expect(components, hasLength(2));
          expect(components[0], isA<PositionComponent>());
          expect(components[1], isA<PositionComponent>());
        },
      );

      testWithGame(
        'match children with the given types and limit',
        FlameGame.new,
        (game) async {
          await game.world.addAll([
            RectangleComponent(
              children: [
                PositionComponent(),
              ],
            ),
            PositionComponent(),
          ]);

          await game.ready();

          final command = _NoopCommand();
          final components = <Component>[];
          command.onChildMatch(
            components.add,
            rootComponent: game.world,
            types: ['PositionComponent'],
            limit: 1,
          );

          expect(components, hasLength(1));
          expect(components[0], isA<PositionComponent>());
        },
      );

      testWithGame(
        'match children with the given id',
        FlameGame.new,
        (game) async {
          late Component target;
          await game.world.addAll([
            target = RectangleComponent(
              children: [
                PositionComponent(),
              ],
            ),
            PositionComponent(),
          ]);

          await game.ready();

          final command = _NoopCommand();
          final components = <Component>[];
          command.onChildMatch(
            components.add,
            rootComponent: game.world,
            ids: [target.hashCode.toString()],
          );

          expect(components, hasLength(1));
          expect(components[0], isA<PositionComponent>());
        },
      );
    });
  });
}
