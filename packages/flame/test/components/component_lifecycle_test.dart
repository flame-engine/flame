import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends Component {
  final List<String> events = [];
  final String? name;

  _MyComponent([this.name]);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    events.add('onLoad');
  }

  @override
  void onMount() {
    events.add('onMount');
  }

  @override
  void onRemove() {
    events.add('onRemove');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize $size');
  }
}

void main() {
  group('Component Lifecycle', () {
    flameGame.test('correct order', (game) async {
      final component = _MyComponent();
      await game.add(component);
      await game.ready();

      expect(
        component.events,
        ['onGameResize [500.0,500.0]', 'onLoad', 'onMount'],
      );
    });

    flameGame.test('component mounted completes', (game) async {
      final component = _MyComponent();
      await game.add(component);
      final mounted = component.mounted;

      await game.ready();

      return expectLater(mounted, completes);
    });

    flameGame.test(
      'component mounted completes even after the '
      'component is already mounted',
      (game) async {
        final component = _MyComponent();
        await game.add(component);
        await game.ready();

        final mounted = component.mounted;

        return expectLater(mounted, completes);
      },
    );

    flameGame.test(
      'component mounted completes when changing parent',
      (game) async {
        final parent = _MyComponent('parent');
        final child = _MyComponent('child');
        parent.add(child);
        game.add(parent);

        var mounted = child.mounted;
        await game.ready();

        await expectLater(mounted, completes);

        child.changeParent(game);
        mounted = child.mounted;
        game.update(0);
        await game.ready();

        await expectLater(mounted, completes);
      },
    );

    flameGame.test('component loaded completes', (game) async {
      final component = _MyComponent();
      await game.add(component);
      final loaded = component.loaded;

      await game.ready();

      return expectLater(loaded, completes);
    });

    flameGame.test(
      'component loaded completes even after the '
      'component is already loaded',
      (game) async {
        final component = _MyComponent();
        await game.add(component);
        await game.ready();

        final loaded = component.loaded;

        return expectLater(loaded, completes);
      },
    );

    // Obsolete scenario, when we used to have a separate "prepare" stage
    flameGame.test('parent prepares the component', (game) async {
      final parent = _MyComponent('parent');
      final child = _MyComponent('child');
      await parent.add(child);
      await game.add(parent);
      await game.ready();

      // The parent tries to prepare the component before it is added to the
      // game and fails since it doesn't have a game root and therefore re-adds
      // the child when it has a proper root.
      expect(
        parent.events,
        ['onGameResize [500.0,500.0]', 'onLoad', 'onMount'],
      );
      expect(
        child.events,
        ['onGameResize [500.0,500.0]', 'onLoad', 'onMount'],
      );
    });

    flameGame.test('correct lifecycle on parent change', (game) async {
      final parent = _MyComponent('parent');
      final child = _MyComponent('child');
      parent.add(child);
      game.add(parent);
      await game.ready();
      child.changeParent(game);
      game.update(0);
      await game.ready();

      expect(
        parent.events,
        ['onGameResize [500.0,500.0]', 'onLoad', 'onMount'],
      );
      // onLoad should only be called the first time that the component is
      // loaded.
      expect(
        child.events,
        [
          'onGameResize [500.0,500.0]',
          'onLoad',
          'onMount',
          'onRemove',
          'onGameResize [500.0,500.0]',
          'onMount',
        ],
      );
    });

    flameGame.test(
      'components added in correct order even with different load times',
      (game) async {
        final a = SlowComponent(0.1);
        final b = SlowComponent(0.02);
        final c = SlowComponent(0.05);
        final d = SlowComponent(0);
        game.add(a);
        game.add(b);
        game.add(c);
        game.add(d);
        await game.ready();
        expect(game.children.toList(), equals([a, b, c, d]));
      },
    );

    testWidgets('Multi-widget game', (WidgetTester tester) {
      return tester.runAsync(() async {
        final game1 = FlameGame();
        final game2 = FlameGame();
        // Device size is set to 800x600
        await tester.pumpWidget(
          Row(
            textDirection: TextDirection.ltr,
            children: [
              SizedBox(width: 295, child: GameWidget(game: game1)),
              SizedBox(width: 505, child: GameWidget(game: game2)),
            ],
          ),
        );
        final component1 = _MyComponent('A')..addToParent(game1);
        final component2 = _MyComponent('B')..addToParent(game2);
        await game1.ready();
        await game2.ready();
        expect(
          component1.events,
          ['onGameResize [295.0,600.0]', 'onLoad', 'onMount'],
        );
        expect(
          component2.events,
          ['onGameResize [505.0,600.0]', 'onLoad', 'onMount'],
        );
      });
    });

    testWithFlameGame(
      'Remove and re-add component with children',
      (game) async {
        final parent = _MyComponent('parent');
        final child = _MyComponent('child')..addToParent(parent);
        await game.add(parent);
        await game.ready();

        expect(parent.isMounted, true);
        expect(child.isMounted, true);
        expect(parent.parent, game);
        expect(child.parent, parent);

        parent.removeFromParent();
        game.update(0); // needed until 1385 is merged
        await game.ready();

        expect(parent.isMounted, false);
        expect(child.isMounted, false);
        expect(parent.parent, isNull);
        expect(child.parent, isNull);

        await game.add(parent);
        await game.ready();

        expect(parent.isMounted, true);
        expect(child.isMounted, true);
        expect(parent.parent, game);
        expect(child.parent, parent);
      },
    );
  });
}

class SlowComponent extends Component {
  SlowComponent(this.loadTime);
  final double loadTime;

  @override
  Future<void> onLoad() async {
    final ms = (loadTime * 1000).toInt();
    await Future<int?>.delayed(Duration(milliseconds: ms));
  }
}
