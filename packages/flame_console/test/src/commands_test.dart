import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
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

  @override
  ArgParser get parser => ArgParser();
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
              PositionedComponent(),
            ],
          ),
        );

        await game.ready();

        final command = _NoopCommand();
        final components = command.listAllChildren(game.world);

        expect(components, hasLength(2));
        expect(components[0], isA<RectangleComponent>());
        expect(components[1], isA<PositionedComponent>());
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
                PositionedComponent(),
              ],
            ),
            PositionedComponent(),
          ]);

          await game.ready();

          final command = _NoopCommand();
          final components = <Component>[];
          command.onChildMatch(
            components.add,
            rootComponent: game.world,
            types: ['PositionedComponent'],
          );

          expect(components, hasLength(2));
          expect(components[0], isA<PositionedComponent>());
          expect(components[1], isA<PositionedComponent>());
        },
      );

      testWithGame(
        'match children with the given types and limit',
        FlameGame.new,
        (game) async {
          await game.world.addAll([
            RectangleComponent(
              children: [
                PositionedComponent(),
              ],
            ),
            PositionedComponent(),
          ]);

          await game.ready();

          final command = _NoopCommand();
          final components = <Component>[];
          command.onChildMatch(
            components.add,
            rootComponent: game.world,
            types: ['PositionedComponent'],
            limit: 1,
          );

          expect(components, hasLength(1));
          expect(components[0], isA<PositionedComponent>());
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
                PositionedComponent(),
              ],
            ),
            PositionedComponent(),
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
          expect(components[0], isA<PositionedComponent>());
        },
      );
    });
  });
}
