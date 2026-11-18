import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where [point] lands in the light's clip space: x and y across the map,
/// z the depth.
Vector3 _clip(DirectionalShadowProjection projection, Vector3 point) {
  final v = projection.viewProjection.transform(
    Vector4(point.x, point.y, point.z, 1),
  );
  return Vector3(v.x / v.w, v.y / v.w, v.z / v.w);
}

List<Vector3> _corners(Aabb3 box) => [
  for (var corner = 0; corner < 8; corner++)
    Vector3(
      corner & 1 == 0 ? box.min.x : box.max.x,
      corner & 2 == 0 ? box.min.y : box.max.y,
      corner & 4 == 0 ? box.min.z : box.max.z,
    ),
];

Matcher _inMap({double tolerance = 1e-5}) => predicate<Vector3>(
  (p) =>
      p.x >= -1 - tolerance &&
      p.x <= 1 + tolerance &&
      p.y >= -1 - tolerance &&
      p.y <= 1 + tolerance &&
      p.z >= -tolerance &&
      p.z <= 1 + tolerance,
  'inside the map',
);

/// A camera above the origin looking down -y at a square of [size] world
/// units centered on ([x], 0, [z]), up -z.
(Matrix4, Matrix4) _topDownCamera({
  double x = 0,
  double z = 0,
  double size = 10,
  double near = 0.1,
  double far = 100,
}) {
  final view = Matrix4.identity()
    ..setAsViewMatrix(Vector3(x, 20, z), Vector3(x, 0, z), Vector3(0, 0, -1));
  final projection = Matrix4.identity()..setAsOrthographic(size, 1, near, far);
  return (view, projection.multiplied(view));
}

void main() {
  group('DirectionalShadowProjection', () {
    final sun = Vector3(0.4, -1, 0.3);

    test('covers the whole region without a camera', () {
      final projection = DirectionalShadowProjection();
      final region = Aabb3.minMax(Vector3(-2, 0, -3), Vector3(4, 1, 5));

      final fitted = projection.update(
        direction: sun,
        casters: region,
        resolution: 512,
      );

      expect(fitted, isTrue);
      for (final corner in _corners(region)) {
        expect(_clip(projection, corner), _inMap());
      }
      expect(projection.texelWidth, greaterThan(0));
      expect(projection.texelHeight, greaterThan(0));
    });

    test('looks along the light, from the world origin', () {
      final projection = DirectionalShadowProjection()
        ..update(
          direction: sun,
          casters: Aabb3.minMax(Vector3(10, 0, 10), Vector3(12, 1, 12)),
          resolution: 256,
        );
      // The view does not move with the region.
      expect(projection.view.transform3(Vector3.zero()).length, 0);
      // Points further along the light are deeper.
      final point = Vector3(11, 0.5, 11);
      final further = point + sun.normalized() * 0.5;
      expect(
        _clip(projection, further).z,
        greaterThan(_clip(projection, point).z),
      );
      expect(
        _clip(projection, further).xy.distanceTo(_clip(projection, point).xy),
        lessThan(1e-5),
      );
    });

    test('reaches back to every caster towards the light', () {
      final projection = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-5, 0, -5), Vector3(5, 0, 5));
      // A tall tower, much nearer the light than the ground.
      final casters = Aabb3.copy(ground)
        ..hull(Aabb3.minMax(Vector3(-1, 0, -1), Vector3(1, 30, 1)));

      projection.update(
        direction: sun,
        casters: casters,
        receivers: ground,
        resolution: 512,
      );

      for (final corner in _corners(ground)) {
        expect(_clip(projection, corner), _inMap());
      }
      // The top of the tower is in the depth range.
      final top = _clip(projection, Vector3(0, 30, 0));
      expect(top.z, inInclusiveRange(0, 1));
      expect(projection.near, lessThan(projection.far));
    });

    test('fits the part of the region the camera sees', () {
      final whole = DirectionalShadowProjection();
      final visible = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-100, 0, -100), Vector3(100, 1, 100));
      final (view, viewProjection) = _topDownCamera(x: 20, z: -10);

      whole.update(direction: sun, casters: ground, resolution: 1024);
      visible.update(
        direction: sun,
        casters: ground,
        resolution: 1024,
        cameraViewProjection: viewProjection,
        cameraView: view,
      );

      // About 10 by 10 of the 200 by 200 units: texels 10 to 20 times
      // smaller.
      expect(visible.texelWidth, lessThan(whole.texelWidth / 10));
      // What the camera sees is in the map, what it does not see is not.
      for (final x in [15.0, 20.0, 24.9]) {
        for (final z in [-14.9, -10.0, -5.1]) {
          expect(_clip(visible, Vector3(x, 0.5, z)), _inMap());
        }
      }
      expect(_clip(visible, Vector3(-20, 0.5, 10)), isNot(_inMap()));
    });

    test('fits nothing when the camera sees none of the region', () {
      final projection = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-5, 0, -5), Vector3(5, 1, 5));
      final (view, viewProjection) = _topDownCamera(x: 40);

      expect(
        projection.update(
          direction: sun,
          casters: ground,
          resolution: 512,
          cameraViewProjection: viewProjection,
          cameraView: view,
        ),
        isFalse,
      );
    });

    test('cuts the view at the maximum distance', () {
      final near = DirectionalShadowProjection();
      final all = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-50, 0, -100), Vector3(50, 1, 0));
      // A perspective camera looking along -z over the ground.
      final view = Matrix4.identity()
        ..setAsViewMatrix(
          Vector3(0, 2, 0),
          Vector3(0, 0, -10),
          Vector3(0, 1, 0),
        );
      final viewProjection =
          (Matrix4.identity()..setAsPerspective(60, 1, 0.1, 500)).multiplied(
            view,
          );

      all.update(
        direction: sun,
        casters: ground,
        resolution: 512,
        cameraViewProjection: viewProjection,
        cameraView: view,
      );
      near.update(
        direction: sun,
        casters: ground,
        resolution: 512,
        cameraViewProjection: viewProjection,
        cameraView: view,
        maxDistance: 10,
      );

      expect(near.texelWidth, lessThan(all.texelWidth / 3));
      expect(_clip(near, Vector3(0, 0.5, -5)), _inMap());
      expect(_clip(near, Vector3(0, 0.5, -60)), isNot(_inMap()));
    });

    test('keeps a world point on the same spot of a texel as the camera '
        'pans', () {
      final projection = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-100, 0, -100), Vector3(100, 1, 100));
      final point = Vector3(3.3, 0.5, -2.7);
      final spots = <Vector2>[];
      final widths = <double>{};
      for (final pan in [0.0, 0.013, 0.37, 1.91, 2.5]) {
        final (view, viewProjection) = _topDownCamera(x: pan, z: pan * 0.7);
        projection.update(
          direction: sun,
          casters: ground,
          resolution: 1024,
          cameraViewProjection: viewProjection,
          cameraView: view,
        );
        widths.add(projection.texelWidth);
        // The edges of the map are on whole texels of the light's view.
        final column = projection.left / projection.texelWidth;
        final row = projection.bottom / projection.texelHeight;
        expect(column, closeTo(column.roundToDouble(), 1e-6));
        expect(row, closeTo(row.roundToDouble(), 1e-6));
        // Where the point lands within its texel.
        final clip = _clip(projection, point);
        final texels = Vector2(
          (clip.x + 1) / 2 * 1024,
          (clip.y + 1) / 2 * 1024,
        );
        spots.add(Vector2(texels.x % 1, texels.y % 1));
      }
      expect(widths, hasLength(1));
      for (final spot in spots) {
        expect(spot.distanceTo(spots.first), lessThan(2e-3));
      }
    });

    test('without stabilizing, follows the camera continuously', () {
      final projection = DirectionalShadowProjection();
      final ground = Aabb3.minMax(Vector3(-100, 0, -100), Vector3(100, 1, 100));
      final lefts = <double>[];
      for (final pan in [0.0, 0.013]) {
        final (view, viewProjection) = _topDownCamera(x: pan);
        projection.update(
          direction: sun,
          casters: ground,
          resolution: 1024,
          cameraViewProjection: viewProjection,
          cameraView: view,
          stabilize: false,
        );
        lefts.add(projection.left);
      }
      final shift = (lefts[1] - lefts[0]) / projection.texelWidth;
      expect(shift, isNot(closeTo(shift.roundToDouble(), 1e-3)));
    });

    test('keeps its size while the region shrinks a little', () {
      final projection = DirectionalShadowProjection();
      double widthFor(double size) {
        projection.update(
          direction: Vector3(0, -1, 0),
          casters: Aabb3.minMax(Vector3.zero(), Vector3(size, 1, size)),
          resolution: 512,
        );
        return projection.texelWidth * 512;
      }

      final large = widthFor(10);
      expect(large, greaterThanOrEqualTo(10));
      // A little smaller: the same size of the ladder.
      expect(widthFor(9.5), large);
      // Much smaller: a smaller size.
      final small = widthFor(5);
      expect(small, lessThan(large));
      expect(small, greaterThanOrEqualTo(5));
      // Sizes are on a ladder of steps of 2^(1/8).
      final steps = (large / small).log2() * 8;
      expect(steps, closeTo(steps.roundToDouble(), 1e-6));
    });
  });
}

extension on double {
  double log2() => math.log(this) / math.ln2;
}
