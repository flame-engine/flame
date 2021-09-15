import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as flutter;
import 'package:test/test.dart';

class MyGame extends FlameGame with HasTappableComponents {}

class MyComponent extends PositionComponent with Tappable, HasGameRef {
  bool tapped = false;
  bool isUpdateCalled = false;
  bool isRenderCalled = false;
  int onRemoveCallCounter = 0;
  late Vector2 gameSize;

  @override
  bool onTapDown(_) {
    tapped = true;
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    isUpdateCalled = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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

class MyAsyncComponent extends MyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    return Future.value();
  }
}

class PositionComponentNoNeedForRect extends PositionComponent with Tappable {}

Vector2 size = Vector2(1.0, 1.0);

void main() {
  group('FlameGame test', () {
    test('adds the component to the component list', () {
      final game = MyGame();
      final component = MyComponent();

      game.onGameResize(size);
      game.add(component);
      // runs a cycle to add the component
      game.update(0.1);

      expect(true, game.children.contains(component));
    });

    test(
      'when the component has onLoad function, adds after load completion',
      () async {
        final game = MyGame();
        final component = MyAsyncComponent();

        game.onGameResize(size);
        await game.add(component);
        // runs a cycle to add the component
        game.update(0.1);

        expect(true, game.children.contains(component));

        expect(component.gameSize, size);
        expect(component.gameRef, game);
      },
    );

    test('prepare adds gameRef and calls onGameResize', () {
      final game = MyGame();
      final component = MyComponent();

      game.onGameResize(size);
      game.add(component);

      expect(component.gameSize, size);
      expect(component.gameRef, game);
    });

    test('component can be tapped', () {
      final game = MyGame();
      final component = MyComponent();

      game.onGameResize(size);
      game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);
      game.onTapDown(1, createTapDownEvent(game));

      expect(component.tapped, true);
    });

    test('component is added to component list', () {
      final game = MyGame();
      final component = MyComponent();

      game.onGameResize(size);
      game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);

      expect(game.children.contains(component), true);
    });

    flutter.testWidgets(
      'component render and update is called',
      (flutter.WidgetTester tester) async {
        final game = MyGame();
        final component = MyComponent();

        game.onGameResize(size);
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

    test('onRemove is only called once on component', () {
      final game = MyGame();
      final component = MyComponent();

      game.onGameResize(size);
      game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);
      // The component is removed both by removing it on the game instance and
      // by the function on the component, but the onRemove callback should
      // only be called once.
      component.removeFromParent();
      game.children.remove(component);
      // The component is not removed from the component list until an update has been performed
      game.update(0.0);

      expect(component.onRemoveCallCounter, 1);
    });
  });

  test('remove depend SpriteComponent.shouldRemove', () {
    final game = MyGame()..onGameResize(size);

    // addLater here
    game.add(SpriteComponent()..shouldRemove = true);
    game.update(0);
    expect(game.children.length, equals(1));

    // remove effected here
    game.update(0);
    expect(game.children.isEmpty, equals(true));
  });

  test('remove depend SpriteAnimationComponent.shouldRemove', () {
    final game = MyGame()..onGameResize(size);
    game.add(SpriteAnimationComponent()..shouldRemove = true);
    game.update(0);
    expect(game.children.length, equals(1));

    game.update(0);
    expect(game.children.isEmpty, equals(true));
  });

  test('clear removes all components', () {
    final game = MyGame();
    final components = List.generate(3, (index) => MyComponent());

    game.onGameResize(size);
    game.addAll(components);

    // The components are not added to the component list until an update has been performed
    game.update(0.0);
    expect(game.children.length, equals(3));

    game.children.clear();

    // Ensure clear does not remove components directly
    expect(game.children.length, equals(3));
    game.update(0.0);
    expect(game.children.isEmpty, equals(true));
  });
}
