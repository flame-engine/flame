import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'projector_test.dart';

void main() {
  group('FlameGame', () {
    testWithFlameGame(
      'default viewport does not change size',
      (game) async {
        game.onGameResize(Vector2(100.0, 200.0));
        expect(game.canvasSize, Vector2(100.0, 200.00));
        expect(game.size, Vector2(100.0, 200.00));
      },
    );

    testWithFlameGame('Game in game', (game) async {
      final innerGame = FlameGame();
      game.add(innerGame);
      await game.ready();

      expect(innerGame.canvasSize, closeToVector(800, 600));
      expect(innerGame.isLoaded, true);
      expect(innerGame.isMounted, true);
    });

    group('components', () {
      testWithFlameGame(
        'Add component',
        (game) async {
          final component = Component();
          await game.ensureAdd(component);

          expect(component.isMounted, true);
          expect(game.children.contains(component), true);
        },
      );

      testWithGame<_GameWithTappables>(
        'Add component with onLoad function',
        _GameWithTappables.new,
        (game) async {
          final component = _MyAsyncComponent();
          await game.ensureAdd(component);

          expect(game.children.contains(component), true);
          expect(component.gameSize, game.size);
          expect(component.gameRef, game);
        },
      );

      testWithFlameGame(
        'prepare adds gameRef and calls onGameResize',
        (game) async {
          final component = _MyComponent();
          await game.ensureAdd(component);

          expect(component.gameSize, game.size);
          expect(component.gameRef, game);
        },
      );

      testWithGame<_GameWithTappables>(
        'component can be tapped',
        _GameWithTappables.new,
        (game) async {
          final component = _MyTappableComponent();
          await game.ensureAdd(component);
          game.onTapDown(1, createTapDownEvent(game));

          expect(component.tapped, true);
        },
      );

      testWidgets(
        'component render and update is called',
        (WidgetTester tester) async {
          final game = FlameGame();
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
          final component = _MyComponent()..addToParent(game);

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

      testWithFlameGame(
        'onRemove is only called once on component',
        (game) async {
          final component = _MyComponent();
          await game.ensureAdd(component);
          // The component is removed both by removing it on the game instance
          // and by the function on the component, but the onRemove callback
          // should only be called once.
          component.removeFromParent();
          game.remove(component);
          // The component is not removed from the component list until an
          // update has been performed.
          game.update(0.0);

          expect(component.onRemoveCallCounter, 1);
        },
      );

      testWithFlameGame(
        'removes PositionComponent when shouldRemove is true',
        (game) async {
          final component = PositionComponent();
          await game.ensureAdd(component);
          expect(game.children.length, equals(1));
          component.shouldRemove = true;
          game.updateTree(0);
          expect(game.children.isEmpty, equals(true));
        },
      );

      testWithFlameGame('clear removes all components', (game) async {
        final components = List.generate(3, (index) => Component());
        await game.ensureAddAll(components);
        expect(game.children.length, equals(3));

        game.children
            .clear(); // ignore: deprecated_member_use_from_same_package

        // Ensure clear does not remove components directly
        expect(game.children.length, equals(3));
        game.updateTree(0);
        expect(game.children.isEmpty, equals(true));
      });

      testWidgets(
        'can add a component to a game without a layout',
        (WidgetTester tester) async {
          final game = FlameGame();
          final component = Component()..addToParent(game);
          expect(game.hasLayout, false);

          await tester.pumpWidget(GameWidget(game: game));
          game.update(0);
          expect(game.children.length, 1);
          expect(game.children.first, component);
        },
      );
    });

    group('projector', () {
      testWithFlameGame(
        'default viewport+camera should be identity projections',
        (game) async {
          checkProjectorReversibility(game.projector);
          expect(game.projector.projectVector(Vector2(1, 2)), Vector2(1, 2));
          expect(game.projector.unprojectVector(Vector2(1, 2)), Vector2(1, 2));
          expect(game.projector.scaleVector(Vector2(1, 2)), Vector2(1, 2));
          expect(game.projector.unscaleVector(Vector2(1, 2)), Vector2(1, 2));
        },
      );

      testWithFlameGame(
        'viewport only with scale projection (no camera)',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 200));
          expect(viewport.scale, 2);
          expect(viewport.resizeOffset, Vector2.zero()); // no translation
          checkProjectorReversibility(game.projector);

          expect(game.projector.projectVector(Vector2(1, 2)), Vector2(2, 4));
          expect(game.projector.unprojectVector(Vector2(2, 4)), Vector2(1, 2));
          expect(game.projector.scaleVector(Vector2(1, 2)), Vector2(2, 4));
          expect(game.projector.unscaleVector(Vector2(2, 4)), Vector2(1, 2));

          expect(
            game.viewportProjector.projectVector(Vector2(1, 2)),
            Vector2(2, 4),
          );
          expect(
            game.viewportProjector.unprojectVector(Vector2(2, 4)),
            Vector2(1, 2),
          );
          expect(
            game.viewportProjector.scaleVector(Vector2(1, 2)),
            Vector2(2, 4),
          );
          expect(
            game.viewportProjector.unscaleVector(Vector2(2, 4)),
            Vector2(1, 2),
          );
        },
      );

      testWithFlameGame(
        'viewport only with translation projection (no camera)',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 100));
          expect(viewport.scale, 1); // no scale
          expect(viewport.resizeOffset, Vector2(50, 0)); // y is unchanged
          checkProjectorReversibility(game.projector);

          // Click on x=0 means -50 in the game coordinates.
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(-50, 0),
          );
          // Click on x=50 is right on the edge of the viewport.
          expect(
            game.projector.unprojectVector(Vector2.all(50)),
            Vector2(0, 50),
          );
          // Click on x=150 is on the other edge.
          expect(
            game.projector.unprojectVector(Vector2.all(150)),
            Vector2(100, 150),
          );
          // 50 past the end.
          expect(
            game.projector.unprojectVector(Vector2(200, 0)),
            Vector2(150, 0),
          );

          // Translations should not affect projecting deltas.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(
            game.projector.unscaleVector(Vector2.all(50)),
            Vector2.all(50),
          );
          expect(
            game.projector.unscaleVector(Vector2.all(150)),
            Vector2.all(150),
          );
          expect(
            game.projector.unscaleVector(Vector2(200, 0)),
            Vector2(200, 0),
          );
        },
      );

      testWithFlameGame(
        'viewport only with both scale and translation (no camera)',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 400));
          expect(viewport.scale, 2);
          expect(viewport.resizeOffset, Vector2(0, 100)); // x is unchanged
          checkProjectorReversibility(game.projector);

          // Click on y=0 means -100 in the game coordinates.
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(0, -50),
          );
          expect(
            game.projector.unprojectVector(Vector2(0, 100)),
            Vector2.zero(),
          );
          expect(
            game.projector.unprojectVector(Vector2(0, 300)),
            Vector2(0, 100),
          );
          expect(
            game.projector.unprojectVector(Vector2(0, 400)),
            Vector2(0, 150),
          );
        },
      );

      testWithFlameGame(
        'camera only with zoom (default viewport)',
        (game) async {
          game.onGameResize(Vector2.all(1));

          game.camera.zoom = 3; // 3x zoom
          checkProjectorReversibility(game.projector);

          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2.zero(),
          );
          expect(game.projector.unprojectVector(Vector2(3, 6)), Vector2(1, 2));

          expect(
            game.viewportProjector.unprojectVector(Vector2.zero()),
            Vector2.zero(),
          );
          expect(
            game.viewportProjector.unprojectVector(Vector2(3, 6)),
            Vector2(3, 6),
          );

          // Delta considers the zoom.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(game.projector.unscaleVector(Vector2(3, 6)), Vector2(1, 2));
        },
      );

      testWithFlameGame(
        'camera only with translation (default viewport)',
        (game) async {
          game.onGameResize(Vector2.all(1));

          // Top left corner of the screen is (50, 100).
          game.camera.snapTo(Vector2(50, 100));
          checkProjectorReversibility(game.projector);

          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(50, 100),
          );
          expect(
            game.projector.unprojectVector(Vector2(-50, 50)),
            Vector2(0, 150),
          );

          // Delta ignores translations.
          expect(game.projector.scaleVector(Vector2.zero()), Vector2.zero());
          expect(
            game.projector.scaleVector(Vector2(-50, 50)),
            Vector2(-50, 50),
          );
        },
      );

      testWithFlameGame(
        'camera only with both zoom and translation (default viewport)',
        (game) async {
          game.onGameResize(Vector2.all(10));

          // No-op because the default is already top left.
          game.camera.setRelativeOffset(Anchor.topLeft);
          // Top left corner of the screen is (-100, -100).
          game.camera.snapTo(Vector2.all(-100));
          // Zoom is 2x, meaning every 1 unit you walk away of (-100, -100).
          game.camera.zoom = 2;
          checkProjectorReversibility(game.projector);

          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(-100, -100),
          );
          // Let's "walk" 10 pixels down on the screen;
          // that means the world walks 5 units.
          expect(
            game.projector.unprojectVector(Vector2(0, 10)),
            Vector2(-100, -95),
          );
          // To get to the world 0,0 we need to walk 200 screen units.
          expect(
            game.projector.unprojectVector(Vector2.all(200)),
            Vector2.zero(),
          );

          // Note: in the current implementation, if we change the relative
          // position the zoom is still applied w.r.t. the top left of the
          // screen.
          game.camera.setRelativeOffset(Anchor.center);
          game.camera.snap();

          // That means that the center would be -100, -100 if the zoom was 1
          // meaning the topLeft will be (-105, -105) (regardless of zoom),
          // but since the offset is set to center, topLeft will be
          // (-102.5, -102.5)
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2.all(-102.5),
          );
          // and with 2x zoom the center will actually be -100, -100 since the
          // relative offset is set to center.
          expect(
            game.projector.unprojectVector(Vector2.all(5)),
            Vector2.all(-100),
          );
          // TODO(luan): we might want to change the behaviour so that the zoom
          // is applied w.r.t. the relativeOffset and not topLeft

          // For deltas, we consider only the zoom.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(game.projector.unscaleVector(Vector2(2, 4)), Vector2(1, 2));
        },
      );

      testWithFlameGame('camera & viewport - two translations', (game) async {
        final viewport = FixedResolutionViewport(Vector2.all(100));
        game.camera.viewport = viewport; // default camera
        game.onGameResize(Vector2(200, 100));
        game.camera.snapTo(Vector2(10, 100));
        expect(viewport.scale, 1); // no scale
        expect(viewport.resizeOffset, Vector2(50, 0)); // y is unchanged
        checkProjectorReversibility(game.projector);

        // Top left of viewport should be top left of camera.
        expect(
          game.projector.unprojectVector(Vector2(50, 0)),
          Vector2(10, 100),
        );
        // Viewport only, top left should be the top left of screen.
        expect(
          game.viewportProjector.unprojectVector(Vector2(50, 0)),
          Vector2.zero(),
        );
        // Top right of viewport is top left of camera + effective screen width.
        expect(
          game.projector.unprojectVector(Vector2(150, 0)),
          Vector2(110, 100),
        );
        // Vertically, only the camera translation is applied.
        expect(
          game.projector.unprojectVector(Vector2(40, 123)),
          Vector2(0, 223),
        );

        // Deltas should not be affected by translations at all.
        expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
        expect(game.projector.unscaleVector(Vector2(1, 2)), Vector2(1, 2));
      });

      testWithFlameGame('camera zoom & viewport translation', (game) async {
        final viewport = FixedResolutionViewport(Vector2.all(100));
        game.camera.viewport = viewport;
        game.onGameResize(Vector2(200, 100));
        game.camera.zoom = 2;
        game.camera.snap();
        expect(viewport.scale, 1); // no scale
        expect(viewport.resizeOffset, Vector2(50, 0)); // y is unchanged
        checkProjectorReversibility(game.projector);

        // (50, 0) is the top left corner of the camera
        expect(game.projector.unprojectVector(Vector2(50, 0)), Vector2.zero());
        // the top left of the screen is 50 viewport units to the left,
        // but applying the camera zoom on top results in 25 units
        // in the game space
        expect(game.projector.unprojectVector(Vector2.zero()), Vector2(-25, 0));
        // for every two units we walk to right or bottom means one game units
        expect(game.projector.unprojectVector(Vector2(52, 20)), Vector2(1, 10));
        // the bottom right of the viewport is at (150, 100) on screen
        // coordinates for the viewport that is walking (100, 100) in viewport
        // units for the camera we need to half that so it means walking
        // (50, 50) this is the bottom-right most world pixel that is painted.
        expect(
          game.projector.unprojectVector(Vector2(150, 100)),
          Vector2.all(50),
        );

        // For deltas, we consider only the 2x zoom of the camera.
        expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
        expect(game.projector.unscaleVector(Vector2(2, 4)), Vector2(1, 2));
      });

      testWithFlameGame(
        'camera translation & viewport scale+translation',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 400));
          expect(viewport.scale, 2);
          expect(viewport.resizeOffset, Vector2(0, 100)); // x is unchanged

          // The camera should apply a (10, 10) translation on top of the
          // viewport.
          game.camera.snapTo(Vector2.all(10));

          checkProjectorReversibility(game.projector);

          // In the viewport space the top left of the screen would be
          // (0, -100), which means 100 viewport units above the top left of the
          // camera (10, 10) each viewport unit is twice the camera unit, so
          // that is 50 above.
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(10, -40),
          );
          // The top left of the camera should be (10, 10) on game space.
          // The top left of the camera should be at (0, 100) on the viewport.
          expect(
            game.projector.unprojectVector(Vector2(0, 100)),
            Vector2(10, 10),
          );

          // For deltas, we consider only 2x scale of the viewport.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(game.projector.unscaleVector(Vector2(2, 4)), Vector2(1, 2));
        },
      );

      testWithFlameGame(
        'camera & viewport scale/zoom + translation (cancel out scaling)',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 400));
          expect(viewport.scale, 2);
          expect(viewport.resizeOffset, Vector2(0, 100)); // x is unchanged

          // The camera should apply a (10, 10) translation + a 0.5x zoom on top
          // of the viewport coordinate system.
          game.camera.zoom = 0.5;
          game.camera.snapTo(Vector2.all(10));

          checkProjectorReversibility(game.projector);

          // In the viewport space the top left of the screen would be (0, -100)
          // that means 100 screen units above the top left of the camera
          // (10, 10) each viewport unit is exactly one camera unit, because the
          // zoom cancels out the scale.
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(10, -90),
          );
          // The top-left most visible pixel on the viewport would be at
          // (0, 100) in screen coordinates. That should be the top left of the
          // camera that is snapped to 10,10 by definition.
          expect(
            game.projector.unprojectVector(Vector2(0, 100)),
            Vector2(10, 10),
          );
          // Now each unit we walk in screen space means only 2 units on the
          // viewport space because of the scale. however, since the camera
          // applies a 1/2x zoom, each unit step equals to 1 unit on the game
          // space.
          expect(
            game.projector.unprojectVector(Vector2(1, 100)),
            Vector2(11, 10),
          );
          // The last pixel of the viewport is on screen coordinates of
          // (200, 300) for the camera, that should be: top left (10,10) +
          // effective size (100, 100) * zoom (1/2).
          expect(
            game.projector.unprojectVector(Vector2(200, 300)),
            Vector2.all(210),
          );

          // For deltas, since the scale and the zoom cancel out, this should
          // no-op.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(game.projector.unscaleVector(Vector2(1, 2)), Vector2(1, 2));
        },
      );

      testWithFlameGame(
        'camera & viewport scale/zoom + translation',
        (game) async {
          final viewport = FixedResolutionViewport(Vector2.all(100));
          game.camera.viewport = viewport;
          game.onGameResize(Vector2(200, 400));
          expect(viewport.scale, 2);
          expect(viewport.resizeOffset, Vector2(0, 100)); // x is unchanged

          // The camera should apply a (50, 0) translation + 4x zoom on top of
          // the viewport coordinate system.
          game.camera.zoom = 4;
          game.camera.snapTo(Vector2(50, 0));

          checkProjectorReversibility(game.projector);

          // In the viewport space the top left of the screen would be (0, -100)
          // that means 100 screen units above the top left of the camera
          // (50, 0) each screen unit is 1/2 a viewport unit each viewport unit
          // is 1/4 of a camera unit so a game unit is 1/8 the screen unit.
          expect(
            game.projector.unprojectVector(Vector2.zero()),
            Vector2(50, -100 / 8),
          );
          // The top left of the camera (50, 0) should be at screen coordinates
          // (0, 100).
          expect(
            game.projector.unprojectVector(Vector2(0, 100)),
            Vector2(50, 0),
          );
          // now each unit we walk on that 200 unit square on screen equals to
          // 1/2 units on the same 100 unit square on the viewport space
          // then, given the 4x camera zoom, each viewport unit becomes 4x a
          // game unit.
          expect(
            game.projector.unprojectVector(Vector2(8, 108)),
            Vector2(51, 1),
          );
          expect(
            game.projector.unprojectVector(Vector2(16, 104)),
            Vector2(52, 0.5),
          );
          expect(
            game.projector.unprojectVector(Vector2(12, 112)),
            Vector2(51.5, 1.5),
          );

          // Deltas only care about the effective scaling factor, which is 8x.
          expect(game.projector.unscaleVector(Vector2.zero()), Vector2.zero());
          expect(game.projector.unscaleVector(Vector2(8, 16)), Vector2(1, 2));
        },
      );
    });
  });
}

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
  Future<void> onLoad() {
    return Future.value();
  }
}
