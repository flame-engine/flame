import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CullBoundsChildren', () {
    // The camera looks at the world origin, so with a 60x40 viewport the
    // visible world rect is (-30, -20) to (30, 20).
    Future<World> setUp(FlameGame game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();
      return world;
    }

    void renderGame(FlameGame game) => game.render(MockCanvas());

    tearDown(() {
      CullWhenOffscreen.debugVerifyCulledSubtrees = false;
    });

    // The parent is far to the right of the view, and its child sticks out to
    // the left of it, into the view.
    (_Listing, _Listing) createParent() {
      final child = _Listing(position: Vector2(-100, 0));
      final parent = _Listing(position: Vector2(100, 0), children: [child]);
      return (parent, child);
    }

    test('is empty by default', () {
      expect(_Listing().cullBoundsChildren, isEmpty);
    });

    testWithFlameGame('a listed child that is on-screen keeps the parent', (
      game,
    ) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      parent.listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 1);
      expect(child.renderCount, 1);
    });

    testWithFlameGame('a child that is not listed is culled with the parent', (
      game,
    ) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);
      expect(child.renderCount, 0);
    });

    testWithFlameGame('a listed child that is off-screen does not', (
      game,
    ) async {
      final world = await setUp(game);
      final child = _Listing(position: Vector2(20, 20));
      final parent = _Listing(
        position: Vector2(500, 500),
        children: [child],
      )..listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);
      expect(child.renderCount, 0);
    });

    testWithFlameGame('children that are not listed are not looked at', (
      game,
    ) async {
      final world = await setUp(game);
      final visible = _Listing(position: Vector2(-100, 0));
      final inside = _Listing(position: Vector2(5, 5));
      final parent = _Listing(
        position: Vector2(100, 0),
        children: [visible, inside],
      )..listed = [inside];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);
      expect(visible.renderCount, 0);
    });

    testWithFlameGame('follows a listed child that moves', (game) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      child.position = Vector2(500, 0);
      parent.listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);

      child.position = Vector2(-100, 0);
      renderGame(game);
      expect(parent.renderCount, 1);
      expect(child.renderCount, 1);

      child.position = Vector2(500, 0);
      renderGame(game);
      expect(parent.renderCount, 1);
    });

    testWithFlameGame('works for a descendant that is not a child', (
      game,
    ) async {
      final world = await setUp(game);
      final grandchild = _Listing(position: Vector2(-100, 0));
      final parent = _Listing(
        position: Vector2(100, 0),
        children: [
          PositionComponent(children: [grandchild]),
        ],
      )..listed = [grandchild];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 1);
      expect(grandchild.renderCount, 1);
    });

    testWithFlameGame('uses the scale of the parent', (game) async {
      final world = await setUp(game);
      // The child is at x = 100 - 50 * 2 = 0, and is 10 * 2 wide.
      final child = _Listing(position: Vector2(-50, 0));
      final parent = _Listing(
        position: Vector2(100, 0),
        scale: Vector2.all(2),
        children: [child],
      )..listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 1);
      expect(child.renderCount, 1);
    });

    testWithFlameGame('ignores a component that is not mounted', (game) async {
      final world = await setUp(game);
      // On-screen, but not in the game.
      final stranger = _Listing(position: Vector2.zero());
      final parent = _Listing(position: Vector2(100, 0))..listed = [stranger];
      await world.ensureAdd(parent);

      expect(() => renderGame(game), returnsNormally);
      expect(parent.renderCount, 0);
    });

    testWithFlameGame('ignores a child that was removed', (game) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      parent.listed = [child];
      await world.ensureAdd(parent);

      child.removeFromParent();
      await game.ready();
      renderGame(game);
      expect(parent.renderCount, 0);
    });

    testWithFlameGame('is added to cullPadding', (game) async {
      final world = await setUp(game);
      // The child is at x = 100, so it is 70 units from the view.
      final child = _Listing(position: Vector2(-100, 0));
      final parent = _Listing(
        position: Vector2(200, 0),
        children: [child],
      )..listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);

      parent.cullPadding = 80;
      renderGame(game);
      expect(parent.renderCount, 1);
    });

    testWithFlameGame('works with a cullBounds that calls super', (
      game,
    ) async {
      final world = await setUp(game);
      final child = _Listing(position: Vector2(-500, -500));
      final parent = _Listing(
        position: Vector2(500, 500),
        extraBounds: const Rect.fromLTWH(500, 500, 10, 10),
        children: [child],
      )..listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 1);
      expect(child.renderCount, 1);
    });

    testWithFlameGame('is replaced by a cullBounds that does not call super', (
      game,
    ) async {
      final world = await setUp(game);
      final child = _Listing(position: Vector2(-500, -500));
      final parent = _Listing(
        position: Vector2(500, 500),
        replacedBounds: const Rect.fromLTWH(500, 500, 10, 10),
        children: [child],
      )..listed = [child];
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);
    });

    testWithFlameGame('is ignored when culling is turned off', (game) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      parent
        ..listed = [child]
        ..cullingEnabled = false;
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 1);
    });

    testWithFlameGame('follows a list that changes between frames', (
      game,
    ) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      await world.ensureAdd(parent);

      renderGame(game);
      expect(parent.renderCount, 0);

      parent.listed = [child];
      renderGame(game);
      expect(parent.renderCount, 1);

      parent.listed = [];
      renderGame(game);
      expect(parent.renderCount, 1);
    });

    testWithFlameGame('follows a list that changes while updating', (
      game,
    ) async {
      final world = await setUp(game);
      final (parent, child) = createParent();
      await world.ensureAdd(parent);

      parent.onUpdate = () => parent.listed = [child];
      game.update(0.1);
      renderGame(game);
      expect(parent.renderCount, 1);
      expect(child.renderCount, 1);

      parent.onUpdate = () => parent.listed = [];
      game.update(0.1);
      renderGame(game);
      expect(parent.renderCount, 1);
    });

    group('with the cached list of the children', () {
      testWithFlameGame('does not create the children of a childless one', (
        game,
      ) async {
        final world = await setUp(game);
        final parent = _AllChildren(position: Vector2(100, 0));
        await world.ensureAdd(parent);

        expect(parent.cullBoundsChildren, isEmpty);
        expect(parent.hasChildren, isFalse);
      });

      testWithFlameGame('uses all of the children', (game) async {
        final world = await setUp(game);
        final child = _Listing(position: Vector2(-100, 0));
        final parent = _AllChildren(
          position: Vector2(100, 0),
          children: [child],
        );
        await world.ensureAdd(parent);

        renderGame(game);
        expect(parent.renderCount, 1);
        expect(child.renderCount, 1);
      });

      testWithFlameGame('follows children that are added and removed', (
        game,
      ) async {
        final world = await setUp(game);
        final parent = _AllChildren(position: Vector2(100, 0));
        await world.ensureAdd(parent);

        renderGame(game);
        expect(parent.renderCount, 0);

        final child = _Listing(position: Vector2(-100, 0));
        await parent.ensureAdd(child);
        renderGame(game);
        expect(parent.renderCount, 1);

        child.removeFromParent();
        await game.ready();
        renderGame(game);
        expect(parent.renderCount, 1);
      });

      testWithFlameGame('ignores children that are not position components', (
        game,
      ) async {
        final world = await setUp(game);
        final parent = _AllChildren(
          position: Vector2(100, 0),
          children: [Component()],
        );
        await world.ensureAdd(parent);

        expect(() => renderGame(game), returnsNormally);
        expect(parent.cullBoundsChildren, isEmpty);
        expect(parent.renderCount, 0);
      });
    });

    testWithFlameGame(
      'the debug check accepts a culled parent with a listed child',
      (game) async {
        CullWhenOffscreen.debugVerifyCulledSubtrees = true;
        final world = await setUp(game);
        final child = _Listing(position: Vector2(20, 20));
        final parent = _Listing(
          position: Vector2(500, 500),
          children: [child],
        )..listed = [child];
        await world.ensureAdd(parent);

        expect(() => renderGame(game), returnsNormally);
        expect(parent.renderCount, 0);
      },
    );

    testWithFlameGame(
      'the debug check accepts a visible parent with a listed child',
      (game) async {
        CullWhenOffscreen.debugVerifyCulledSubtrees = true;
        final world = await setUp(game);
        final (parent, child) = createParent();
        parent.listed = [child];
        await world.ensureAdd(parent);

        expect(() => renderGame(game), returnsNormally);
        expect(parent.renderCount, 1);
      },
    );

    testWithFlameGame(
      'the debug check still reports a child that is not listed',
      (game) async {
        CullWhenOffscreen.debugVerifyCulledSubtrees = true;
        final world = await setUp(game);
        final (parent, _) = createParent();
        await world.ensureAdd(parent);

        expect(() => renderGame(game), throwsA(isA<AssertionError>()));
      },
    );
  });
}

class _Listing({
  super.position,
  super.children,
  super.scale,
  Rect? extraBounds,
  Rect? replacedBounds,
}) extends PositionComponent with CullWhenOffscreen, CullBoundsChildren {
  this {
    size = Vector2.all(10);
  }

  final Rect? _extraBounds = extraBounds;
  final Rect? _replacedBounds = replacedBounds;
  int renderCount = 0;

  /// What [cullBoundsChildren] returns.
  List<PositionComponent> listed = const [];

  /// Called on every update, to change [listed] while the game is updating.
  void Function()? onUpdate;

  @override
  Iterable<PositionComponent> get cullBoundsChildren => listed;

  @override
  void update(double dt) {
    super.update(dt);
    onUpdate?.call();
  }

  @override
  Rect get cullBounds {
    final replaced = _replacedBounds;
    if (replaced != null) {
      return replaced;
    }
    final extra = _extraBounds;
    return extra == null
        ? super.cullBounds
        : super.cullBounds.expandToInclude(extra);
  }

  @override
  void render(Canvas canvas) {
    renderCount++;
  }
}

/// Lists all of its children, in the way that the documentation shows.
class _AllChildren({
  super.position,
  super.children,
}) extends PositionComponent with CullWhenOffscreen, CullBoundsChildren {
  this {
    size = Vector2.all(10);
  }

  int renderCount = 0;

  @override
  Iterable<PositionComponent> get cullBoundsChildren =>
      hasChildren ? children.query<PositionComponent>() : const [];

  @override
  void render(Canvas canvas) {
    renderCount++;
  }
}
