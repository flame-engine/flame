import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _RemoveComponent extends Component {
  int removeCounter = 0;

  @override
  void onRemove() {
    super.onRemove();
    removeCounter++;
  }
}

class _PrepareGame extends FlameGame {
  late final _ParentOnPrepareComponent prepareParent;

  @override
  Future<void> onLoad() async {
    await add(prepareParent = _ParentOnPrepareComponent());
  }
}

class _OnPrepareComponent extends Component {
  int prepareRuns = 0;

  @override
  void onMount() {
    super.onMount();
    prepareRuns++;
  }
}

class _ParentOnPrepareComponent extends _OnPrepareComponent {
  @override
  Future<void> onLoad() async {
    await add(_OnPrepareComponent());
  }
}

void main() {
  final prepareGame = FlameTester(() => _PrepareGame());

  group('Component', () {
    test('get/set x/y or position', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(2.2, 3.4);
      expect(c.x, 2.2);
      expect(c.y, 3.4);

      c.position.setValues(1.0, 0.0);
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('get/set width/height or size', () {
      final PositionComponent c = SpriteComponent();
      c.size.setValues(2.2, 3.4);
      expect(c.size.x, 2.2);
      expect(c.size.y, 3.4);

      c.size.setValues(1.0, 0.0);
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('get/set rect', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      final rect = c.toRect();
      expect(rect.left, 0.0);
      expect(rect.top, 1.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.0);
      expect(c.y, 10.0);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('get/set rect with anchor', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final rect = c.toRect();
      expect(rect.left, -1.0);
      expect(rect.top, 0.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.5);
      expect(c.y, 10.5);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('get/set anchorPosition', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final anchorPosition = c.topLeftPosition;
      expect(anchorPosition.x, -1.0);
      expect(anchorPosition.y, 0.0);
    });

    flameGame.test('removeFromParent', (game) async {
      final c1 = Component()..addToParent(game);
      await game.ready();

      expect(c1.isMounted, true);
      c1.removeFromParent();
      expect(c1.isMounted, true);
      await game.ready();
      expect(c1.isMounted, false);
      expect(game.children.length, 0);
    });

    flameGame.test(
      'remove and re-add should not double trigger onRemove',
      (game) async {
        final component = _RemoveComponent();
        await game.ensureAdd(component);

        component.removeFromParent();
        game.update(0);
        expect(component.removeCounter, 1);
        expect(component.isMounted, false);

        component.removeCounter = 0;
        await game.ensureAdd(component);
        expect(component.removeCounter, 0);
        expect(game.children.length, 1);
      },
    );

    prepareGame.test(
      'adding children to a parent that is not yet added to a game should not '
      'run double onPrepare',
      (game) async {
        final parent = game.prepareParent;
        expect(parent.prepareRuns, 1);
        expect(parent.children.isNotEmpty, true);
        expect((parent.children.first as _OnPrepareComponent).prepareRuns, 1);
      },
    );

    test('childrenFactory', () {
      final game = FlameGame()..onGameResize(Vector2.all(100));
      assert(game.isMounted, true);
      final component0 = Component();
      expect(component0.children.strictMode, false);

      Component.childrenFactory = () => ComponentSet(strictMode: true);
      final component1 = Component();
      final component2 = Component();
      component1.add(component2);
      component2.add(Component());
      expect(component1.children.strictMode, true);
      expect(component2.children.strictMode, true);
    });

    test('game resize while components are being added', () async {
      final game = FlameGame()..onGameResize(Vector2.all(100));
      final component = ComponentWithSizeHistory();
      game.add(component);
      expect(component.history, equals([Vector2(100, 100)]));
      expect(component.isMounted, false);
      game.onGameResize(Vector2(500, 300));
      game.onGameResize(Vector2(300, 500));
      expect(
        component.history,
        equals([Vector2(100, 100), Vector2(500, 300), Vector2(300, 500)]),
      );
      await game.ready();
      expect(component.history.length, 3);
      expect(component.history.last, equals(Vector2(300, 500)));
    });

    test('game resize in zoomed game', () async {
      final game = FlameGame()
        ..camera.zoom = 10
        ..onGameResize(Vector2(300, 200));
      final component = ComponentWithSizeHistory();
      game.add(component);
      await game.ready();

      game.onGameResize(Vector2(400, 500));
      expect(
        component.history,
        equals([Vector2(300, 200), Vector2(400, 500)]),
      );
    });

    group('descendants', () {
      testWithFlameGame(
        'length must be 0 when it is called before being loaded',
        (game) async {
          final component = Component()..add(Component()..add(Component()));

          expect(game.descendants().length, 0);
          await game.ensureAdd(component);
          expect(game.descendants().length, 3);
        },
      );

      testWithFlameGame(
        'length must be 3 when the number of added components is 3',
        (game) async {
          final component = Component()..add(Component()..add(Component()));
          await game.ensureAdd(component);

          expect(game.descendants().length, 3);
        },
      );

      testWithFlameGame(
        'length must be equal to the number of added components including '
        'itself when the passed parameter includeSelf is true',
        (game) async {
          final component = Component()..add(Component()..add(Component()));
          await game.ensureAdd(component);
          final descendants = game.descendants(includeSelf: true);

          expect(descendants.length, 4);
          for (final component in descendants) {
            expect(component.findGame() != null, true);
          }
        },
      );

      testWithFlameGame(
        'length must be 0 when hasPendingLifecycleEvents is true',
        (game) async {
          final component = Component()..add(Component()..add(Component()));
          game.add(component);

          expect(game.hasPendingLifecycleEvents, true);
          expect(game.descendants().length, 0);
        },
      );

      testWithFlameGame(
        'length should not change when hasPendingLifecycleEvents is true after '
        'adding',
        (game) async {
          final component = Component()..add(Component()..add(Component()));
          await game.add(component);
          await game.ready();

          expect(game.hasPendingLifecycleEvents, false);

          game.add(Component());

          expect(game.hasPendingLifecycleEvents, true);
          expect(game.descendants().length, 3);
        },
      );

      testWithFlameGame(
        'order must adhere to the "depth-first search" algorithm',
        (game) async {
          final componentA = Component()..addToParent(game);
          final componentB = Component()..addToParent(game);
          final componentC = Component()..addToParent(game);
          final componentD = Component()..addToParent(componentB);
          final componentE = Component()..addToParent(componentB);
          final componentF = Component()..addToParent(componentE);
          await game.ready();

          final expectedOrder = [
            componentA,
            componentB,
            componentD,
            componentE,
            componentF,
            componentC,
          ];
          expect(
            game.descendants().toList(),
            expectedOrder,
          );
          expect(
            game.descendants(includeSelf: true).toList(),
            [game, ...expectedOrder],
          );
          expect(
            game.descendants(reversed: true).toList(),
            expectedOrder.reversed.toList(),
          );
          expect(
            game.descendants(reversed: true, includeSelf: true).toList(),
            [...expectedOrder.reversed, game],
          );
        },
      );

      testWithFlameGame('descendants() iterator is lazy', (game) async {
        final componentA = Visitor()..addToParent(game);
        final componentB = Visitor()..addToParent(game);
        final componentC = Visitor()..addToParent(componentB);
        final componentD = Visitor()..addToParent(componentB);
        final componentE = Visitor()..addToParent(game);
        await game.ready();

        game.descendants().whereType<Visitor>().firstWhere((component) {
          component.visited = true;
          return component == componentC;
        });
        expect(componentA.visited, true);
        expect(componentB.visited, true);
        expect(componentC.visited, true);
        expect(componentD.visited, false);
        expect(componentE.visited, false);
      });
    });
  });
}

class ComponentWithSizeHistory extends Component {
  List<Vector2> history = [];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    history.add(size.clone());
  }
}

class Visitor extends Component {
  bool visited = false;
}
