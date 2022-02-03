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
      await parent.add(child);
      await game.ensureAdd(parent);
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

    testWidgets('Multi-widget game', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final game1 = FlameGame();
        final game2 = FlameGame();
        await tester.pumpWidget( // Device size is set to 800x600
          Row(
            textDirection: TextDirection.ltr,
            children: [
              SizedBox(width: 295, child: GameWidget(game: game1)),
              SizedBox(width: 505, child: GameWidget(game: game2)),
            ],
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration());
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
