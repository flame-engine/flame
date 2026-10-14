import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle() extends Mock implements AssetBundle;

class _CollisionGame() extends FlameGame with HasCollisionDetection;

SvgPathsComponent _componentOf(
  List<(String, String)> paths, {
  SvgHitboxes hitboxes = SvgHitboxes.single,
  Vector2? size,
  double sampling = 1.0,
  double? tolerance,
  bool renderHitboxes = false,
}) {
  final buffer = StringBuffer(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> ',
  );
  for (final (path, style) in paths) {
    buffer.write('<path d="$path" $style/> ');
  }
  buffer.write('</svg>');
  return SvgPathsComponent(
    SvgPaths(buffer.toString()),
    hitboxes: hitboxes,
    size: size,
    sampling: sampling,
    tolerance: tolerance,
    renderHitboxes: renderHitboxes,
  );
}

int _vertices(SvgPathsComponent component) {
  final hitbox = component.children.whereType<SvgPathsHitbox>().single;
  return hitbox.polygons.fold(0, (sum, polygon) => sum + polygon.length);
}

PathHitbox _perPathHitboxOf(String path, String style) {
  return _componentOf([(path, style)], hitboxes: SvgHitboxes.perPath).children
      .whereType<PathComponent>()
      .single
      .children
      .whereType<PathHitbox>()
      .single;
}

void main() {
  group('SvgPathsComponent', () {
    group('assetPath', () {
      test('is in assets/svgs by default', () {
        expect(SvgPathsComponent.assetPath('ship'), 'assets/svgs/ship.svg');
      });

      test('adds the missing slash of the folder', () {
        expect(
          SvgPathsComponent.assetPath('ship', 'assets/other'),
          'assets/other/ship.svg',
        );
      });

      test('keeps the slash of the folder', () {
        expect(
          SvgPathsComponent.assetPath('ship', 'assets/other/'),
          'assets/other/ship.svg',
        );
      });
    });

    group('load', () {
      // Two paths with the same paint, which are merged by default.
      const svg =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
          '<path d="M0 0L20 0L20 20Z" fill="#ff0000"/> '
          '<path d="M60 60L80 60L80 80Z" fill="#ff0000"/> </svg>';

      AssetsCache cacheOf(AssetBundle bundle) {
        when(() => bundle.loadString(any())).thenAnswer((_) async => svg);
        return AssetsCache(bundle: bundle);
      }

      test('reads the file in assets/svgs via the given cache', () async {
        final bundle = _MockAssetBundle();
        final component = await SvgPathsComponent.load(
          'ship',
          cache: cacheOf(bundle),
        );
        verify(() => bundle.loadString('assets/svgs/ship.svg')).called(1);
        expect(component.svg.length, 1);
        expect(component.hitboxes, SvgHitboxes.single);
      });

      test('reads the file in the given folder and package', () async {
        final bundle = _MockAssetBundle();
        await SvgPathsComponent.load(
          'ship',
          assetsPath: 'assets/other',
          cache: cacheOf(bundle),
          package: 'my_pkg',
        );
        verify(
          () => bundle.loadString('packages/my_pkg/assets/other/ship.svg'),
        ).called(1);
      });

      test('passes on the merge and the hitboxes', () async {
        final component = await SvgPathsComponent.load(
          'ship',
          cache: cacheOf(_MockAssetBundle()),
          merge: false,
          hitboxes: SvgHitboxes.perPath,
          size: Vector2.all(50),
        );
        expect(component.svg.length, 2);
        expect(component.hitboxes, SvgHitboxes.perPath);
        expect(component.children.whereType<PathComponent>().length, 2);
        expect(component.size, Vector2.all(50));
      });
    });

    test('has no children for an empty SVG', () {
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"/>',
      );
      for (final hitboxes in SvgHitboxes.values) {
        final component = SvgPathsComponent(
          svg,
          hitboxes: hitboxes,
          size: Vector2.all(100),
        );
        expect(component.children, isEmpty, reason: hitboxes.name);
      }
    });

    testWithGame<_CollisionGame>(
      'has hitboxes without an area',
      _CollisionGame.new,
      (game) async {
        for (final hitboxes in SvgHitboxes.values) {
          for (final size in [Vector2.zero(), Vector2(10, 0)]) {
            final component = _componentOf(
              [('M0 0L50 0L50 50Z', 'fill="#ff0000"')],
              hitboxes: hitboxes,
              size: size,
            );
            await game.ensureAdd(component);
            game.update(0);
            expect(
              component.descendants().whereType<PathHitbox>(),
              hasLength(1),
              reason: '${hitboxes.name} $size',
            );
          }
        }
      },
    );

    group('hitbox paints', () {
      const paths = [
        ('M0 0L50 0L50 50Z', 'fill="#ff0000"'),
        ('M50 50L100 50L100 100Z', 'fill="#00ff00"'),
      ];

      test('are not shared between per-path hitboxes', () {
        final component = _componentOf(
          paths,
          hitboxes: SvgHitboxes.perPath,
          renderHitboxes: true,
        );
        final hitboxes = component.children
            .whereType<PathComponent>()
            .map((path) => path.children.whereType<PathHitbox>().single)
            .toList();
        expect(hitboxes.length, 2);
        expect(identical(hitboxes[0].paint, hitboxes[1].paint), isFalse);
      });

      test('are not shared between single hitboxes', () {
        final first = _componentOf(paths, renderHitboxes: true);
        final second = _componentOf(paths, renderHitboxes: true);
        expect(
          identical(
            first.children.whereType<SvgPathsHitbox>().single.paint,
            second.children.whereType<SvgPathsHitbox>().single.paint,
          ),
          isFalse,
        );
      });
    });

    test('closes the open contours of filled paths for the hitbox', () {
      final hitbox = _perPathHitboxOf('M0 0L50 0L50 50', 'fill="#ff0000"');
      expect(hitbox.polygons.length, 1);
      expect(hitbox.containsLocalPoint(Vector2(40, 10)), isTrue);
    });

    test('closes the open contours of filled and stroked paths', () {
      final hitbox = _perPathHitboxOf(
        'M0 0L50 0L50 50',
        'fill="#ff0000" stroke="#000000" stroke-width="2"',
      );
      expect(hitbox.polygons.length, 1);
    });

    test('does not create polygons for open stroked paths', () {
      final hitbox = _perPathHitboxOf(
        'M0 0L50 0L50 50',
        'fill="none" stroke="#000000" stroke-width="2"',
      );
      expect(hitbox.polygons, isEmpty);
    });

    test('with perPath hitboxes, has a hitbox in each path component', () {
      final component = _componentOf(
        [
          ('M0 0L50 0L50 50Z', 'fill="#ff0000"'),
          ('M50 50L100 50L100 100Z', 'fill="#00ff00"'),
        ],
        hitboxes: SvgHitboxes.perPath,
      );
      final paths = component.children.whereType<PathComponent>().toList();
      expect(paths.length, 2);
      for (final path in paths) {
        expect(path.children.whereType<PathHitbox>().length, 1);
      }
      expect(component.children.whereType<SvgPathsHitbox>(), isEmpty);
    });

    group('polygon sampling', () {
      // A circle in a small SVG, so that it is scaled up a lot.
      const circle = [
        (
          'M16 0A16 16 0 1 1 16 32A16 16 0 1 1 16 0Z',
          'fill="#ff0000"',
        ),
      ];

      test('is in the units of the component, not of the SVG', () {
        final small = _componentOf(circle, size: Vector2.all(32));
        final large = _componentOf(circle, size: Vector2.all(320));
        // The same shape needs more vertices to be followed as closely when
        // it is ten times larger.
        expect(_vertices(large), greaterThan(_vertices(small)));
      });

      test('can be coarser', () {
        final fine = _componentOf(circle, size: Vector2.all(320));
        final coarse = _componentOf(
          circle,
          size: Vector2.all(320),
          sampling: 40,
        );
        expect(_vertices(coarse), lessThan(_vertices(fine)));
      });

      test('can have a looser tolerance', () {
        final fine = _componentOf(circle, size: Vector2.all(320));
        final loose = _componentOf(
          circle,
          size: Vector2.all(320),
          tolerance: 20,
        );
        expect(_vertices(loose), lessThan(_vertices(fine)));
      });
    });

    test('with a single hitbox, has one hitbox for all the paths', () {
      final component = _componentOf([
        ('M0 0L50 0L50 50Z', 'fill="#ff0000"'),
        ('M50 50L100 50L100 100Z', 'fill="#00ff00"'),
      ]);
      // The paths are rendered by the component, so there are no path
      // components, and the hitbox is the only child.
      expect(component.children.length, 1);
      final hitbox = component.children.whereType<SvgPathsHitbox>().single;
      expect(hitbox.polygons.length, 2);
      // The hitbox is placed like the paths within the component.
      expect(hitbox.position.x, closeTo(0, 1e-6));
      expect(hitbox.position.y, closeTo(0, 1e-6));
      expect(hitbox.size.x, closeTo(100, 1e-6));
      expect(hitbox.size.y, closeTo(100, 1e-6));
    });

    group('rendering', () {
      const paths = [
        // An open contour, which a fill closes.
        ('M5 5L40 5L40 40', 'fill="#ff0000"'),
        // A ring: the hole is not filled.
        (
          'M55 55L95 55L95 95L55 95ZM65 65L65 85L85 85L85 65Z',
          'fill="#00ff00" fill-rule="evenodd"',
        ),
        // A closed contour with a fill and a stroke.
        (
          'M5 55L40 55L40 90L5 90Z',
          'fill="#0000ff" stroke="#ffffff" stroke-width="6"',
        ),
        // An open contour with a stroke only.
        ('M50 5L95 5', 'fill="none" stroke="#ffff00" stroke-width="4"'),
      ];

      Future<ByteData> render(WidgetTester tester, SvgHitboxes hitboxes) async {
        return (await tester.runAsync(() async {
          final component = _componentOf(
            paths,
            hitboxes: hitboxes,
            size: Vector2.all(100),
          );
          final recorder = ui.PictureRecorder();
          component.renderTree(ui.Canvas(recorder));
          final image = await recorder.endRecording().toImage(100, 100);
          return await image.toByteData();
        }))!;
      }

      int alphaAt(ByteData data, int x, int y) {
        return data.getUint8((y * 100 + x) * 4 + 3);
      }

      testWidgets('draws open filled contours and skips holes', (tester) async {
        final data = await render(tester, SvgHitboxes.single);
        // Inside of the closed open triangle, and of the ring but not its hole.
        expect(alphaAt(data, 30, 15), 255);
        expect(alphaAt(data, 60, 90), 255);
        expect(alphaAt(data, 75, 75), 0);
      });

      testWidgets('is the same with a single hitbox and per path', (
        tester,
      ) async {
        final single = await render(tester, SvgHitboxes.single);
        final perPath = await render(tester, SvgHitboxes.perPath);
        var different = 0;
        for (var i = 0; i < single.lengthInBytes; i++) {
          if ((single.getUint8(i) - perPath.getUint8(i)).abs() > 64) {
            different++;
          }
        }
        // Only a few pixels on the edges may differ.
        expect(different, lessThan(100 * 100 * 4 * 0.01));
      });
    });
  });
}
