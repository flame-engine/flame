import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/hot_reload_connector.dart';
import 'package:flame/src/devtools/dev_tools_service.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _Player() extends PositionComponent with HasGameRef {
  bool sawShadow = false;

  @override
  void onLoad() {
    sawShadow = findGame()!.isHotReloadShadow;
    add(RectangleComponent(size: Vector2.all(10)));
  }
}

class _ShadowGame() extends FlameGame {
  @override
  void onLoad() {
    world.add(_Player()..position = Vector2(1, 2));
    world.add(Component());
  }
}

List<Map<String, Object?>> _nodes(Map<String, Object?> description) {
  return (description['nodes']! as List).cast<Map<String, Object?>>();
}

void main() {
  group('declaration index', () {
    testWithFlameGame('is given to children added before mounting', (
      game,
    ) async {
      final first = Component();
      final second = Component();
      final parent = Component(children: [first]);
      parent.add(second);
      await game.world.ensureAdd(parent);

      expect(first.debugDeclarationIndex, 0);
      expect(second.debugDeclarationIndex, 1);
    });

    testWithFlameGame('is null for children added to a mounted parent', (
      game,
    ) async {
      final spawned = Component();
      await game.world.ensureAdd(spawned);

      expect(spawned.debugDeclarationIndex, isNull);
    });

    testWithFlameGame('is kept when the component is mounted again', (
      game,
    ) async {
      final child = Component();
      final parent = Component(children: [child]);
      await game.world.ensureAdd(parent);
      parent.remove(child);
      await game.ready();
      await parent.ensureAdd(child);

      expect(child.debugDeclarationIndex, 0);
    });
  });

  group('HotReloadConnector', () {
    testWithGame<_ShadowGame>(
      'builds a shadow game without replacing the live game',
      _ShadowGame.new,
      (game) async {
        HotReloadConnector.buildShadow('old', _ShadowGame.new);
        final description = await HotReloadConnector.awaitShadow('old');

        expect(DevToolsService.instance.game, same(game));
        expect(game.isHotReloadShadow, isFalse);

        final shadow = HotReloadConnector.component('old', 0) as FlameGame;
        expect(shadow.isHotReloadShadow, isTrue);
        expect(shadow.images, same(game.images));

        final player = _nodes(description).indexWhere(
          (node) => node['type'] == '_Player',
        );
        final playerNode = _nodes(description)[player];
        expect(playerNode['declaration_index'], isNotNull);
        expect(playerNode['hint'], contains('[1.0,2.0]'));
        expect(
          (HotReloadConnector.component('old', player) as _Player).sawShadow,
          isTrue,
        );

        HotReloadConnector.disposeShadows();
      },
    );

    testWithGame<_ShadowGame>(
      'describes the live tree in depth first order',
      _ShadowGame.new,
      (game) async {
        final nodes = _nodes(HotReloadConnector.describeLive());

        expect(nodes.first['parent'], isNull);
        expect(nodes.first['type'], '_ShadowGame');
        for (var i = 1; i < nodes.length; i++) {
          final parent = nodes[i]['parent']! as int;
          expect(parent, lessThan(i));
          expect(
            HotReloadConnector.component('live', i).parent,
            same(HotReloadConnector.component('live', parent)),
          );
        }
      },
    );

    testWithGame<_ShadowGame>(
      'moves a component from the new shadow into the live game',
      _ShadowGame.new,
      (game) async {
        HotReloadConnector.buildShadow('new', _ShadowGame.new);
        final shadowNodes = _nodes(await HotReloadConnector.awaitShadow('new'));
        final liveNodes = _nodes(HotReloadConnector.describeLive());
        final shadowPlayerIndex = shadowNodes.indexWhere(
          (node) => node['type'] == '_Player',
        );
        final liveWorldIndex = liveNodes.indexWhere(
          (node) => node['type'] == 'World',
        );
        final player =
            HotReloadConnector.component('new', shadowPlayerIndex) as _Player;
        final shadow = player.gameRef;

        HotReloadConnector.adopt(shadowPlayerIndex, liveWorldIndex);
        await game.ready();

        expect(player.parent, same(game.world));
        expect(player.isMounted, isTrue);
        expect(player.gameRef, same(game));
        expect(shadow.world.children.whereType<_Player>(), isEmpty);
        expect(game.world.children.whereType<_Player>(), hasLength(2));

        HotReloadConnector.disposeShadows();
      },
    );

    testWithGame<_ShadowGame>(
      'removes a live component',
      _ShadowGame.new,
      (game) async {
        final nodes = _nodes(HotReloadConnector.describeLive());
        final playerIndex = nodes.indexWhere(
          (node) => node['type'] == '_Player',
        );

        HotReloadConnector.remove(playerIndex);
        await game.ready();

        expect(game.world.children.whereType<_Player>(), isEmpty);
      },
    );
  });
}
