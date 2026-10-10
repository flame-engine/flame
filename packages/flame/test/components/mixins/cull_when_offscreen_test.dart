import 'dart:math';
import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CullWhenOffscreen', () {
    // The camera looks at the world origin, so with a 60x40 viewport the
    // visible world rect is (-30, -20) to (30, 20).
    Future<(FlameGame, World, CameraComponent)> setUp(FlameGame game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();
      return (game, world, camera);
    }

    void renderGame(FlameGame game) => game.render(MockCanvas());

    testWithFlameGame('renders a component inside the view', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2.zero());
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('skips a component outside the view', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);
    });

    testWithFlameGame('still updates a culled component', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      game.update(0.1);
      expect(component.updateCount, 1);
    });

    testWithFlameGame('skips the children of a culled component', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final child = _CountingComponent(position: Vector2.zero());
      final parent = _CountingComponent(
        position: Vector2(500, 500),
        children: [child],
      );
      await world.ensureAdd(parent);

      renderGame(game);
      expect(child.renderCount, 0);
    });

    testWithFlameGame('reacts to the camera moving', (game) async {
      final (_, world, camera) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      camera.viewfinder.position = Vector2(500, 500);
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('reacts to the component moving', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      component.position = Vector2.zero();
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('cullPadding extends the bounds', (game) async {
      final (_, world, _) = await setUp(game);
      // Bounds are (40, 0) to (50, 10), just right of the visible rect.
      final component = _CountingComponent(position: Vector2(40, 0));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      component.cullPadding = 15;
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('does not cull when cullingEnabled is false', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500))
        ..cullingEnabled = false;
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);

      component.cullingEnabled = true;
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('uses an overridden cullBounds', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(
        position: Vector2(500, 500),
        bounds: const Rect.fromLTWH(0, 0, 10, 10),
      );
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('never culls components in the viewport', (game) async {
      final (_, _, camera) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await camera.viewport.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('never culls components outside of a world', (
      game,
    ) async {
      await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await game.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('is conservative for a rotated camera', (game) async {
      final (_, world, camera) = await setUp(game);
      camera.viewfinder.angle = 0.7;
      // Inside the rotated view, but outside the unrotated 60x40 rect.
      final component = _CountingComponent(position: Vector2(-10, 25));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('uses the camera that is rendering the world', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final minimap = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(20, 20),
      )..viewfinder.position = Vector2(500, 500);
      await game.ensureAdd(minimap);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      // Seen by the minimap, culled by the main camera.
      renderGame(game);
      expect(component.renderCount, 1);
    });

    group('nesting', () {
      testWithFlameGame(
        'checks a nested child on its own when the parent is visible',
        (game) async {
          final (_, world, _) = await setUp(game);
          final inside = _CountingComponent(position: Vector2(200, 200));
          final outside = _CountingComponent(position: Vector2(350, 350));
          // Covers the whole view, from (-200, -200) to (200, 200).
          final parent = _CountingComponent(
            position: Vector2(-200, -200),
            boxSize: Vector2.all(400),
            children: [inside, outside],
          );
          await world.ensureAdd(parent);

          renderGame(game);
          expect(parent.renderCount, 1);
          expect(inside.renderCount, 1);
          expect(outside.renderCount, 0);
        },
      );

      testWithFlameGame(
        'a culled parent skips its nested children but not their updates',
        (game) async {
          final (_, world, _) = await setUp(game);
          final child = _CountingComponent(position: Vector2.zero());
          final parent = _CountingComponent(
            position: Vector2(500, 500),
            children: [child],
          );
          await world.ensureAdd(parent);

          renderGame(game);
          game.update(0.1);
          expect(child.renderCount, 0);
          expect(child.updateCount, 1);
        },
      );

      testWithFlameGame(
        'a chunk with explicit bounds culls its children as a group',
        (game) async {
          final (_, world, camera) = await setUp(game);
          final near = _CountingComponent(position: Vector2(10, 10));
          final far = _CountingComponent(position: Vector2(900, 900));
          final chunk = _CountingComponent(
            position: Vector2(1000, 1000),
            boxSize: Vector2.all(1000),
            children: [near, far],
          );
          await world.ensureAdd(chunk);

          renderGame(game);
          expect(chunk.renderCount, 0);
          expect(near.renderCount, 0);
          expect(far.renderCount, 0);

          camera.viewfinder.position = Vector2(1010, 1010);
          renderGame(game);
          expect(chunk.renderCount, 1);
          expect(near.renderCount, 1);
          expect(far.renderCount, 0);
        },
      );

      testWithFlameGame('uses the scale of a non-culled ancestor', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final visible = _CountingComponent(position: Vector2(-50, -50));
        final hidden = _CountingComponent(position: Vector2(-100, -100));
        // A child at local (-50, -50) ends up at the origin, and one at
        // (-100, -100) ends up at (-100, -100), outside of the view.
        final parent = PositionComponent(
          position: Vector2(100, 100),
          scale: Vector2.all(2),
          children: [visible, hidden],
        );
        await world.ensureAdd(parent);

        renderGame(game);
        expect(visible.renderCount, 1);
        expect(hidden.renderCount, 0);
      });

      testWithFlameGame('uses the rotation of a non-culled ancestor', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final visible = _CountingComponent(position: Vector2(5, 0));
        final hidden = _CountingComponent(position: Vector2(100, 0));
        final parent = PositionComponent(
          angle: pi / 2,
          children: [visible, hidden],
        );
        await world.ensureAdd(parent);

        renderGame(game);
        expect(visible.renderCount, 1);
        expect(hidden.renderCount, 0);
      });

      testWithFlameGame(
        'a disabled child is not rendered when its parent is culled',
        (game) async {
          final (_, world, _) = await setUp(game);
          final child = _CountingComponent(position: Vector2.zero())
            ..cullingEnabled = false;
          final parent = _CountingComponent(
            position: Vector2(500, 500),
            children: [child],
          );
          await world.ensureAdd(parent);

          renderGame(game);
          expect(parent.renderCount, 0);
          expect(child.renderCount, 0);
        },
      );

      testWithFlameGame(
        'a disabled child is always rendered when its parent is rendered',
        (game) async {
          final (_, world, _) = await setUp(game);
          // The child is far outside of the view, but its parent covers it.
          final child = _CountingComponent(position: Vector2(350, 350))
            ..cullingEnabled = false;
          final parent = _CountingComponent(
            position: Vector2(-200, -200),
            boxSize: Vector2.all(400),
            children: [child],
          );
          await world.ensureAdd(parent);

          renderGame(game);
          expect(parent.renderCount, 1);
          expect(child.renderCount, 1);
        },
      );

      testWithFlameGame(
        'a disabled parent renders, while its enabled child still culls',
        (game) async {
          final (_, world, _) = await setUp(game);
          final child = _CountingComponent(position: Vector2.zero());
          final parent = _CountingComponent(
            position: Vector2(500, 500),
            children: [child],
          )..cullingEnabled = false;
          await world.ensureAdd(parent);

          renderGame(game);
          expect(parent.renderCount, 1);
          expect(child.renderCount, 0);
        },
      );
    });

    group('children outside of the bounds of the parent', () {
      tearDown(() {
        CullWhenOffscreen.debugVerifyCulledSubtrees = false;
      });

      // The parent is far to the right of the view, but its child is placed to
      // the left of it, at the origin.
      (_CountingComponent, _CountingComponent) createParent({
        double padding = 0,
      }) {
        final child = _CountingComponent(position: Vector2(-100, 0));
        final parent = _CountingComponent(
          position: Vector2(100, 0),
          children: [child],
        )..cullPadding = padding;
        return (parent, child);
      }

      testWithFlameGame('are culled with the parent by default', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final (parent, child) = createParent();
        await world.ensureAdd(parent);

        renderGame(game);
        expect(parent.renderCount, 0);
        expect(child.renderCount, 0);
      });

      testWithFlameGame('are rendered when cullPadding covers them', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final (parent, child) = createParent(padding: 100);
        await world.ensureAdd(parent);

        renderGame(game);
        expect(parent.renderCount, 1);
        expect(child.renderCount, 1);
      });

      testWithFlameGame('are rendered when cullBounds covers them', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final child = _CountingComponent(position: Vector2(-100, 0));
        final parent = _CountingComponent(
          position: Vector2(100, 0),
          bounds: const Rect.fromLTWH(0, 0, 200, 10),
          children: [child],
        );
        await world.ensureAdd(parent);

        renderGame(game);
        expect(child.renderCount, 1);
      });

      testWithFlameGame(
        'the debug check reports a visible child and the fixing padding',
        (game) async {
          CullWhenOffscreen.debugVerifyCulledSubtrees = true;
          final (_, world, _) = await setUp(game);
          await world.ensureAdd(createParent().$1);

          expect(
            () => renderGame(game),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message.toString(),
                'message',
                contains('cullPadding to at least 100'),
              ),
            ),
          );
        },
      );

      testWithFlameGame('the debug check passes once the padding is enough', (
        game,
      ) async {
        CullWhenOffscreen.debugVerifyCulledSubtrees = true;
        final (_, world, _) = await setUp(game);
        await world.ensureAdd(createParent(padding: 100).$1);

        expect(() => renderGame(game), returnsNormally);
      });

      testWithFlameGame(
        'the debug check ignores children that are not visible',
        (game) async {
          CullWhenOffscreen.debugVerifyCulledSubtrees = true;
          final (_, world, _) = await setUp(game);
          await world.ensureAdd(
            _CountingComponent(
              position: Vector2(500, 500),
              children: [_CountingComponent(position: Vector2(10, 10))],
            ),
          );

          expect(() => renderGame(game), returnsNormally);
        },
      );

      testWithFlameGame(
        'the debug check ignores children with isVisible = false',
        (game) async {
          CullWhenOffscreen.debugVerifyCulledSubtrees = true;
          final (_, world, _) = await setUp(game);
          final hidden = _HiddenComponent(position: Vector2(-100, 0));
          await world.ensureAdd(
            _CountingComponent(position: Vector2(100, 0), children: [hidden]),
          );

          expect(() => renderGame(game), returnsNormally);
        },
      );

      testWithFlameGame(
        'the debug check looks through components without a position',
        (game) async {
          CullWhenOffscreen.debugVerifyCulledSubtrees = true;
          final (_, world, _) = await setUp(game);
          final wrapper = Component(
            children: [_CountingComponent(position: Vector2(-100, 0))],
          );
          await world.ensureAdd(
            _CountingComponent(position: Vector2(100, 0), children: [wrapper]),
          );

          expect(() => renderGame(game), throwsA(isA<AssertionError>()));
        },
      );

      testWithFlameGame('the debug check is off by default', (game) async {
        final (_, world, _) = await setUp(game);
        await world.ensureAdd(createParent().$1);

        expect(CullWhenOffscreen.debugVerifyCulledSubtrees, isFalse);
        expect(() => renderGame(game), returnsNormally);
      });

      testWithFlameGame(
        'a component without a size hides children that are visible',
        (game) async {
          final (_, world, _) = await setUp(game);
          final child = _CountingComponent(position: Vector2(-500, -500));
          await world.ensureAdd(
            _CountingComponent(
              position: Vector2(500, 500),
              boxSize: Vector2.zero(),
              children: [child],
            ),
          );

          renderGame(game);
          expect(child.renderCount, 0);
        },
      );
    });

    group('bounds', () {
      final anchors = {
        'topLeft': Anchor.topLeft,
        'center': Anchor.center,
        'bottomRight': Anchor.bottomRight,
      };
      final scales = [
        Vector2(1, 1),
        Vector2(2, 3),
        Vector2(-1, 1),
        Vector2(-2, -2),
      ];

      for (final anchor in anchors.entries) {
        for (final scale in scales) {
          testWithFlameGame(
            'the fast path matches toAbsoluteRect for anchor ${anchor.key} '
            'and scale $scale',
            (game) async {
              final (_, world, _) = await setUp(game);
              final component = _CountingComponent(
                position: Vector2(13, -7),
                boxSize: Vector2(20, 12),
                anchor: anchor.value,
                scale: scale,
              );
              await world.ensureAdd(component);

              final fast = component.cullBounds;
              final slow = component.toAbsoluteRect();
              expect(fast.left, closeTo(slow.left, 1e-9));
              expect(fast.top, closeTo(slow.top, 1e-9));
              expect(fast.right, closeTo(slow.right, 1e-9));
              expect(fast.bottom, closeTo(slow.bottom, 1e-9));
            },
          );
        }
      }

      testWithFlameGame('a rotated component uses its rotated bounds', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        // A long thin box that points into the view from the right.
        final component = _CountingComponent(
          position: Vector2(100, 0),
          boxSize: Vector2(200, 2),
          angle: pi,
        );
        await world.ensureAdd(component);

        renderGame(game);
        expect(component.renderCount, 1);
      });

      testWithFlameGame('a component that only touches the edge is culled', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final touching = _CountingComponent(position: Vector2(30, 0));
        final overlapping = _CountingComponent(position: Vector2(29.9, 0));
        await world.ensureAdd(touching);
        await world.ensureAdd(overlapping);

        renderGame(game);
        expect(touching.renderCount, 0);
        expect(overlapping.renderCount, 1);
      });

      testWithFlameGame('a component that is partly in view is rendered', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final component = _CountingComponent(
          position: Vector2(30, 0),
          anchor: Anchor.center,
        );
        await world.ensureAdd(component);

        renderGame(game);
        expect(component.renderCount, 1);
      });

      testWithFlameGame('zooming in culls what is no longer visible', (
        game,
      ) async {
        final (_, world, camera) = await setUp(game);
        final component = _CountingComponent(position: Vector2(20, 0));
        await world.ensureAdd(component);

        renderGame(game);
        expect(component.renderCount, 1);

        // The visible area is now (-15, -10) to (15, 10).
        camera.viewfinder.zoom = 2;
        renderGame(game);
        expect(component.renderCount, 1);
      });
    });

    group('limitations and lifecycle', () {
      testWithFlameGame('a custom decorator is not taken into account', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        // Drawn at the origin, but its bounds are at (500, 500).
        final component = _CountingComponent(position: Vector2(500, 500))
          ..decorator.addLast(_TranslateDecorator(Vector2(-500, -500)));
        await world.ensureAdd(component);

        renderGame(game);
        expect(component.renderCount, 0);

        component.cullingEnabled = false;
        renderGame(game);
        expect(component.renderCount, 1);
      });

      testWithFlameGame('is never applied to children of the viewfinder', (
        game,
      ) async {
        final (_, _, camera) = await setUp(game);
        final component = _CountingComponent(position: Vector2(500, 500));
        await camera.viewfinder.ensureAdd(component);

        renderGame(game);
        expect(component.renderCount, 1);
      });

      testWithFlameGame('follows the component when it changes world', (
        game,
      ) async {
        final (_, world, _) = await setUp(game);
        final otherWorld = World();
        final otherCamera = CameraComponent(
          world: otherWorld,
          viewport: FixedSizeViewport(60, 40),
        )..viewfinder.position = Vector2(500, 500);
        game.addAll([otherWorld, otherCamera]);
        await game.ready();

        final component = _CountingComponent(position: Vector2(500, 500));
        await world.ensureAdd(component);
        renderGame(game);
        expect(component.renderCount, 0);

        component.removeFromParent();
        await game.ready();
        otherWorld.add(component);
        await game.ready();
        renderGame(game);
        expect(component.renderCount, 1);
      });
    });
  });
}

class _CountingComponent({
  super.position,
  super.children,
  super.anchor,
  super.scale,
  super.angle,
  Vector2? boxSize,
  Rect? bounds,
}) extends PositionComponent with CullWhenOffscreen {
  this {
    size = boxSize ?? Vector2.all(10);
  }

  final Rect? _bounds = bounds;
  int renderCount = 0;
  int updateCount = 0;

  @override
  Rect get cullBounds => _bounds ?? super.cullBounds;

  @override
  void render(Canvas canvas) {
    renderCount++;
  }

  @override
  void update(double dt) {
    updateCount++;
  }
}

class _HiddenComponent({super.position})
    extends PositionComponent
    with HasVisibility {
  this {
    size = Vector2.all(10);
    isVisible = false;
  }
}

class _TranslateDecorator(final Vector2 offset) extends Decorator {
  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    canvas.save();
    canvas.translate(offset.x, offset.y);
    draw(canvas);
    canvas.restore();
  }
}
