import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// An SVG with a square of the given [side] at ([x], [y]).
SvgPaths _square(double x, double y, [double side = 10]) => SvgPaths(
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
  '<rect x="$x" y="$y" width="$side" height="$side" fill="#ff0000"/> </svg>',
);

final _a = _square(0, 0);
final _b = _square(30, 10);

/// Frame 0 shows [_a] in [0, 1), 1 shows [_b] in [1, 2), 2 shows [_a] again
/// in [2, 3).
SvgPathsAnimation _animationOf({bool loop = true}) => SvgPathsAnimation([
  SvgPathsAnimationFrame(_a, start: 0, duration: 1),
  SvgPathsAnimationFrame(_b, start: 1, duration: 1),
  SvgPathsAnimationFrame(_a, start: 2, duration: 1),
], loop: loop);

List<SvgPathsHitbox> _hitboxesOf(SvgPathsAnimationComponent component) =>
    component.children.whereType<SvgPathsHitbox>().toList();

List<bool> _activeOf(SvgPathsAnimationComponent component) => [
  for (final hitbox in _hitboxesOf(component))
    hitbox.collisionType == CollisionType.active,
];

void main() {
  group('SvgPathsAnimationComponent', () {
    test('is as large as the area of the animation by default', () {
      expect(
        SvgPathsAnimationComponent(_animationOf()).size,
        Vector2(40, 20),
      );
      expect(
        SvgPathsAnimationComponent(_animationOf(), size: Vector2.all(5)).size,
        Vector2.all(5),
      );
    });

    test('has a hitbox for each SVG of the frames', () {
      final component = SvgPathsAnimationComponent(_animationOf());
      expect(_hitboxesOf(component).length, 2);
      expect(_activeOf(component), [true, false]);
      expect(
        SvgPathsAnimationComponent(_animationOf(), hitboxes: false).children,
        isEmpty,
      );
    });

    test('places the hitboxes within the common area', () {
      final component = SvgPathsAnimationComponent(
        _animationOf(),
        size: Vector2(80, 40),
      );
      final [a, b] = _hitboxesOf(component);
      expect(a.position, Vector2.zero());
      expect(b.position, Vector2(60, 20));
      expect(b.scale, Vector2.all(2));
    });

    test('activates the hitboxes of the frames shown', () {
      final component = SvgPathsAnimationComponent(
        _animationOf(),
        renderHitboxes: true,
      );
      expect(_hitboxesOf(component).map((h) => h.renderShape), [true, false]);
      component.update(1.5);
      expect(_activeOf(component), [false, true]);
      expect(_hitboxesOf(component).map((h) => h.renderShape), [false, true]);
      component.update(1);
      expect(_activeOf(component), [true, false]);
    });

    test('does not tick while not playing', () {
      final component = SvgPathsAnimationComponent(
        _animationOf(),
        playing: false,
      )..update(1.5);
      expect(component.animationTicker.currentIndices, [0]);
      expect(_activeOf(component), [true, false]);
    });

    test('renders the frames shown', () async {
      final component = SvgPathsAnimationComponent(
        _animationOf(),
        hitboxes: false,
      )..update(1.5);
      final recorder = ui.PictureRecorder();
      component.render(ui.Canvas(recorder));
      final image = recorder.endRecording().toImageSync(40, 20);
      addTearDown(image.dispose);
      final bytes = (await image.toByteData())!;
      // The alpha of the pixel at (x, y), in RGBA order.
      int alphaAt(int x, int y) => bytes.getUint8((y * 40 + x) * 4 + 3);
      expect(alphaAt(35, 15), 255);
      expect(alphaAt(5, 5), 0);
    });

    testWithFlameGame('is removed when finished', (game) async {
      final component = SvgPathsAnimationComponent(
        _animationOf(loop: false),
        removeOnFinish: true,
      );
      await game.ensureAdd(component);
      game.update(2);
      await game.ready();
      expect(component.isMounted, isTrue);
      game.update(2);
      await game.ready();
      expect(component.isMounted, isFalse);
    });

    testWithFlameGame('resets when removed', (game) async {
      final component = SvgPathsAnimationComponent(
        _animationOf(),
        resetOnRemove: true,
      );
      await game.ensureAdd(component);
      game.update(1.5);
      expect(_activeOf(component), [false, true]);
      game.remove(component);
      await game.ready();
      expect(component.animationTicker.clock, 0);
      expect(_activeOf(component), [true, false]);
    });
  });
}
