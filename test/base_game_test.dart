import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/game.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter;

class MyGame extends BaseGame with HasTapableComponents {}

class MyComponent extends PositionComponent
    with Tapable, Resizable, HasGameRef {
  bool tapped = false;
  bool isUpdateCalled = false;
  bool isRenderCalled = false;
  int onRemoveCallCounter = 0;

  @override
  bool onTapDown(TapDownDetails details) {
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
  bool checkOverlap(Vector2 v) => true;

  @override
  void onRemove() => ++onRemoveCallCounter;
}

class PositionComponentNoNeedForRect extends PositionComponent with Tapable {}

Vector2 size = Vector2(1.0, 1.0);

void main() {
  group('BaseGame test', () {
    test('prepare adds gameRef and calls onGameResize', () async {
      final MyGame game = MyGame();
      final MyComponent component = MyComponent();

      game.size.setFrom(size);
      await game.add(component);

      expect(component.gameSize, size);
      expect(component.gameRef, game);
    });

    test('component can be tapped', () async {
      final MyGame game = MyGame();
      final MyComponent component = MyComponent();

      game.size.setFrom(size);
      await game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);
      game.onTapDown(1, TapDownDetails(globalPosition: const Offset(0.0, 0.0)));

      expect(component.tapped, true);
    });

    test('component is added to component list', () async {
      final MyGame game = MyGame();
      final MyComponent component = MyComponent();

      game.size.setFrom(size);
      await game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);

      expect(game.components.contains(component), true);
    });

    flutter.testWidgets('component render and update is called',
        (flutter.WidgetTester tester) async {
      final MyGame game = MyGame();
      final MyComponent component = MyComponent();

      game.size.setFrom(size);
      await game.add(component);
      GameRenderBox renderBox;
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
    });

    test('onRemove is only called once on component', () async {
      final MyGame game = MyGame();
      final MyComponent component = MyComponent();

      game.size.setFrom(size);
      await game.add(component);
      // The component is not added to the component list until an update has been performed
      game.update(0.0);
      // The component is removed both by removing it on the game instance and
      // by the function on the component, but the onRemove callback should
      // only be called once.
      component.remove();
      game.remove(component);
      // The component is not removed from the component list until an update has been performed
      game.update(0.0);

      expect(component.onRemoveCallCounter, 1);
    });
  });
}
