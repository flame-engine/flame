// Renders through Flutter GPU, which `flutter test` only provides when run as
// `flutter test --enable-impeller --enable-flutter-gpu`; without it every
// test here is skipped.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/game.dart' show GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Texture;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_test/flutter_test.dart';

const _side = 200;
const _red = ui.Color(0xFFFF0000);
const _blue = ui.Color(0xFF0000FF);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final gpuUnavailable = _gpuUnavailableReason();
  final skip = gpuUnavailable != null;

  setUpAll(() async {
    if (!skip) {
      await GpuBackend.initialize();
    }
  });

  group('CameraComponent3D rendering', () {
    testWidgets(
      'orthographic keeps a cube at the near and one at the far plane',
      skip: skip,
      (tester) async {
        // The default near (0.01) and far (1000): with OpenGL depth mapping
        // everything nearer than about 500 units was clipped away.
        final camera = CameraComponent3D(
          projection: CameraProjection.orthographic,
          orthographicHeight: 10,
          position: Vector3.zero(),
          target: Vector3(0, 0, -1),
        );
        final nearCube = Vector3(-2.5, 0, -0.6);
        final farCube = Vector3(2.5, 0, -999.4);
        final pixels = await _render(tester, camera, [
          (nearCube, Vector3.all(1), _red),
          (farCube, Vector3.all(1), _blue),
        ]);

        expect(pixels.colorAt(camera.worldToViewportPoint(nearCube)), _red);
        expect(pixels.colorAt(camera.worldToViewportPoint(farCube)), _blue);
        expect(pixels.colorAt(Vector2(_side / 2, _side / 2)), isNull);
      },
    );

    testWidgets(
      'perspective keeps a cube just beyond the near plane',
      skip: skip,
      (tester) async {
        // near 1, far 100: OpenGL depth mapping clipped 1 to ~2 units.
        final camera = CameraComponent3D(
          near: 1,
          far: 100,
          position: Vector3.zero(),
          target: Vector3(0, 0, -1),
        );
        final nearCube = Vector3(-0.3, 0, -1.5);
        final farCube = Vector3(30, 0, -99);
        final pixels = await _render(tester, camera, [
          (nearCube, Vector3.all(0.4), _red),
          (farCube, Vector3.all(1.6), _blue),
        ]);

        expect(pixels.colorAt(camera.worldToViewportPoint(nearCube)), _red);
        expect(pixels.colorAt(camera.worldToViewportPoint(farCube)), _blue);
      },
    );

    for (final projection in CameraProjection.values) {
      testWidgets(
        '${projection.name} silhouette matches worldToViewportPoint',
        skip: skip,
        (tester) async {
          final camera = CameraComponent3D(
            projection: projection,
            orthographicHeight: 10,
            position: Vector3.zero(),
            target: Vector3(0, 0, -1),
          );
          final center = Vector3(1.25, -0.5, -10);
          final size = Vector3(4, 4, 4);
          final pixels = await _render(tester, camera, [
            (center, size, _red),
          ]);

          final (:left, :right, :top, :bottom, :middle) = _silhouette(
            camera,
            center,
            size,
          );
          // A pixel is covered when its center is inside, so the pixels
          // 0.75 px inside each edge are red and those 0.75 px outside are
          // not: the raster and the projection agree to within that.
          expect(pixels.colorAt(Vector2(left + 0.75, middle.y)), _red);
          expect(pixels.colorAt(Vector2(left - 0.75, middle.y)), isNull);
          expect(pixels.colorAt(Vector2(right - 0.75, middle.y)), _red);
          expect(pixels.colorAt(Vector2(right + 0.75, middle.y)), isNull);
          expect(pixels.colorAt(Vector2(middle.x, top + 0.75)), _red);
          expect(pixels.colorAt(Vector2(middle.x, top - 0.75)), isNull);
          expect(pixels.colorAt(Vector2(middle.x, bottom - 0.75)), _red);
          expect(pixels.colorAt(Vector2(middle.x, bottom + 0.75)), isNull);
        },
      );
    }
  });
}

String? _gpuUnavailableReason() {
  try {
    // Throws when Flutter GPU is not available.
    gpu.gpuContext.defaultColorFormat;
    return null;
  } on Object catch (error) {
    return '$error';
  }
}

/// The screen extents of the box at [center] with [size] along the row and
/// the column through its projected center.
({double left, double right, double top, double bottom, Vector2 middle})
_silhouette(CameraComponent3D camera, Vector3 center, Vector3 size) {
  var left = double.infinity;
  var right = double.negativeInfinity;
  var top = double.infinity;
  var bottom = double.negativeInfinity;
  for (final sx in [-0.5, 0.5]) {
    for (final sy in [-0.5, 0.5]) {
      for (final sz in [-0.5, 0.5]) {
        final corner = Vector3(
          center.x + sx * size.x,
          center.y + sy * size.y,
          center.z + sz * size.z,
        );
        final p = camera.worldToViewportPoint(corner);
        if (p.x < left) {
          left = p.x;
        }
        if (p.x > right) {
          right = p.x;
        }
        if (p.y < top) {
          top = p.y;
        }
        if (p.y > bottom) {
          bottom = p.y;
        }
      }
    }
  }
  return (
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    middle: camera.worldToViewportPoint(center),
  );
}

Future<_Pixels> _render(
  WidgetTester tester,
  CameraComponent3D camera,
  List<(Vector3 center, Vector3 size, ui.Color color)> boxes,
) async {
  tester.view
    ..physicalSize = const Size(_side * 1.0, _side * 1.0)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final game = FlameGame3D(
    world: World3D(
      children: [
        for (final (center, size, color) in boxes)
          MeshComponent(
            position: center,
            mesh: CuboidMesh(
              size: size,
              material: UnlitMaterial(albedoColor: color)
                ..renderState = RenderState.opaque,
            ),
          ),
      ],
    ),
    camera: camera,
  );

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(camera.viewport.virtualSize, Vector2.all(_side.toDouble()));

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data!;
  }))!;
  return _Pixels(bytes);
}

/// The captured RGBA pixels.
class _Pixels(final ByteData bytes) {
  /// The color of the pixel containing [point] (logical pixels, at a device
  /// pixel ratio of 1): red, blue, or null for anything else.
  ui.Color? colorAt(Vector2 point) {
    final x = point.x.floor();
    final y = point.y.floor();
    final rgba = bytes.getUint32((y * _side + x) * 4);
    final r = (rgba >> 24) & 0xff;
    final g = (rgba >> 16) & 0xff;
    final b = (rgba >> 8) & 0xff;
    if (r > 200 && g < 60 && b < 60) {
      return _red;
    }
    if (b > 200 && r < 60 && g < 60) {
      return _blue;
    }
    return null;
  }
}
