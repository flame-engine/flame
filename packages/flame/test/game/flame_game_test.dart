import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as flutter;
import 'package:flutter_test/flutter_test.dart';

class _GameWithTappables extends FlameGame with HasTappables {}

class _MyTappableComponent extends _MyComponent with Tappable {
  bool tapped = false;

  @override
  bool onTapDown(_) {
    tapped = true;
    return true;
  }
}

class _MyComponent extends PositionComponent with HasGameRef {
  bool isUpdateCalled = false;
  bool isRenderCalled = false;
  int onRemoveCallCounter = 0;
  late Vector2 gameSize;

  @override
  void update(double dt) {
    isUpdateCalled = true;
  }

  @override
  void render(Canvas canvas) {
    isRenderCalled = true;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }

  @override
  bool containsPoint(Vector2 v) => true;

  @override
  void onRemove() {
    super.onRemove();
    ++onRemoveCallCounter;
  }
}

class _MyAsyncComponent extends _MyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    return Future.value();
  }
}

void main() {
  final withTappables = FlameTester(() => _GameWithTappables());

  group('FlameGame test', () {
    flameGame.test(
      'adds the component to the component list',
      (game) async {
        final component = Component();
        await game.ensureAdd(component);

        expect(true, game.children.contains(component));
      },
    );

    withTappables.test(
      'when the component has onLoad function, adds after load completion',
      (game) async {
        final component = _MyAsyncComponent();
        await game.ensureAdd(component);

        expect(true, game.children.contains(component));
        expect(component.gameSize, game.size);
        expect(component.gameRef, game);
      },
    );

    flameGame.test('prepare adds gameRef and calls onGameResize', (game) async {
      final component = _MyComponent();
      await game.ensureAdd(component);

      expect(component.gameSize, game.size);
      expect(component.gameRef, game);
    });

    withTappables.test('component can be tapped', (game) async {
      final component = _MyTappableComponent();
      await game.ensureAdd(component);
      game.onTapDown(1, createTapDownEvent(game));

      expect(component.tapped, true);
    });

    flameGame.test('component is added to component list', (game) async {
      final component = _MyComponent();
      await game.ensureAdd(component);

      expect(game.children.contains(component), true);
    });

    flutter.testWidgets(
      'component render and update is called',
      (flutter.WidgetTester tester) async {
        final game = FlameGame();
        final component = _MyComponent();

        game.onGameResize(Vector2.zero());
        game.add(component);
        late GameRenderBox renderBox;
        await tester.pumpWidget(
          Builder(
            builder: (BuildContext context) {
              renderBox = GameRenderBox(context, game);
              return GameWidget(game: game);
            },
          ),
        );
        renderBox.attach(PipelineOwner());
        renderBox.gameLoopCallback(1.0);
        expect(component.isUpdateCalled, true);
        renderBox.paint(
          PaintingContext(ContainerLayer(), Rect.zero),
          Offset.zero,
        );
        expect(component.isRenderCalled, true);
        renderBox.detach();
      },
    );

    flameGame.test('onRemove is only called once on component', (game) async {
      final component = _MyComponent();

      await game.ensureAdd(component);
      // The component is removed both by removing it on the game instance and
      // by the function on the component, but the onRemove callback should
      // only be called once.
      component.removeFromParent();
      game.children.remove(component);
      // The component is not removed from the component list until an update
      // has been performed.
      game.update(0.0);

      expect(component.onRemoveCallCounter, 1);
    });
  });

  flameGame.test('removes PositionComponent when shouldRemove is true',
      (game) async {
    final component = PositionComponent();
    await game.ensureAdd(component);
    expect(game.children.length, equals(1));
    component.shouldRemove = true;
    game.updateTree(0);
    expect(game.children.isEmpty, equals(true));
  });

  flameGame.test('clear removes all components', (game) async {
    final components = List.generate(3, (index) => Component());
    await game.ensureAddAll(components);
    expect(game.children.length, equals(3));

    game.children.clear();

    // Ensure clear does not remove components directly
    expect(game.children.length, equals(3));
    game.updateTree(0);
    expect(game.children.isEmpty, equals(true));
  });

  test("can't add a component to a game that don't have layout yet", () {
    final game = FlameGame();
    final component = Component();

    const message = '"prepare/add" called before the game is ready. '
        'Did you try to access it on the Game constructor? '
        'Use the "onLoad" or "onMount" method instead.';

    expect(
      () => game.add(component),
      throwsA(
        predicate(
          (e) => e is AssertionError && e.message == message,
        ),
      ),
    );
  });
}
