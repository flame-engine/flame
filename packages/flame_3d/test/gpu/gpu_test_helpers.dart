import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Color, Size;

import 'package:flame/game.dart' show GameWidget;
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import '../../bin/_build_shaderbundle.dart' as shaderbundle;

/// Whether Flutter GPU can render in this test process.
///
/// It needs `flutter test --enable-impeller --enable-flutter-gpu`; without
/// those flags the GPU tests skip themselves.
final bool gpuAvailable = GpuBackend.isAvailable;

/// Initializes the Flutter GPU backend for the tests of a file, when
/// available.
void setUpGpu() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (gpuAvailable) {
      await GpuBackend.initialize();
    }
  });
}

/// A GPU test, skipped when Flutter GPU is unavailable.
@isTest
void testGpu(String description, WidgetTesterCallback callback) {
  testWidgets(description, callback, skip: !gpuAvailable);
}

/// The RGBA pixels of a rendered frame.
class Pixels(
  /// The width in pixels.
  final int width,

  /// The height in pixels.
  final int height,

  /// The pixels, 4 bytes (RGBA) each, row by row.
  final Uint8List rgba,
) {
  /// The color of the pixel at ([x], [y]) as `(r, g, b, a)` bytes.
  (int, int, int, int) at(int x, int y) {
    final i = (y * width + x) * 4;
    return (rgba[i], rgba[i + 1], rgba[i + 2], rgba[i + 3]);
  }

  /// The number of pixels for which [test] holds.
  int count(bool Function(int r, int g, int b, int a) test) {
    var count = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      if (test(rgba[i], rgba[i + 1], rgba[i + 2], rgba[i + 3])) {
        count++;
      }
    }
    return count;
  }

  /// Whether the pixel at ([x], [y]) is the transparent clear color.
  bool isClear(int x, int y) => at(x, y).$4 == 0;
}

/// Pumps [game] in a [width]x[height] logical-pixel view for [frames] frames
/// and returns the pixels of the last frame.
Future<Pixels> renderGame(
  WidgetTester tester,
  FlameGame3D game, {
  double width = 128,
  double height = 128,
  double pixelRatio = 1,
  int frames = 3,
}) async {
  tester.view
    ..physicalSize = Size(width * pixelRatio, height * pixelRatio)
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData();
    final pixels = Pixels(
      image.width,
      image.height,
      data!.buffer.asUint8List(),
    );
    image.dispose();
    return pixels;
  }))!;
}

/// Decodes the PNG file at [path] (relative to the package root).
Future<Pixels> loadPng(WidgetTester tester, String path) async {
  return (await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(
      File(path).readAsBytesSync(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData();
    final pixels = Pixels(
      image.width,
      image.height,
      data!.buffer.asUint8List(),
    );
    image.dispose();
    codec.dispose();
    return pixels;
  }))!;
}

/// The number of pixels of [a] and [b] (of equal size) whose channels differ
/// by more than [tolerance].
int differingPixels(Pixels a, Pixels b, {int tolerance = 2}) {
  expect(a.width, b.width);
  expect(a.height, b.height);
  var count = 0;
  for (var i = 0; i < a.rgba.length; i += 4) {
    for (var c = 0; c < 4; c++) {
      if ((a.rgba[i + c] - b.rgba[i + c]).abs() > tolerance) {
        count++;
        break;
      }
    }
  }
  return count;
}

/// A GPU test that does not need widgets, skipped when Flutter GPU is
/// unavailable.
@isTest
void testGpuEngine(String description, Future<void> Function() body) {
  test(
    description,
    body,
    skip: gpuAvailable
        ? false
        : 'Flutter GPU is unavailable, run with '
              '--enable-impeller --enable-flutter-gpu',
  );
}

/// The pixels and statistics of a frame rendered by [renderFrame].
class Frame(
  /// The rendered pixels.
  final Pixels pixels,

  /// The statistics of the frame.
  final RenderStats stats,
);

/// A view matrix looking from the origin down -z, y up.
Matrix4 get defaultView => Matrix4.identity();

/// An orthographic projection showing x and y in [-1, 1], and depth from
/// z = 0 (depth 0) to z = -10 (depth 1).
Matrix4 get defaultProjection => Matrix4.identity()..setEntry(2, 2, -0.1);

/// Renders one frame of [width]x[height] pixels straight through a
/// [GraphicsDevice] and a [RenderContext3D]: [draw] records the draws.
Future<Frame> renderFrame({
  required void Function(RenderContext3D context) draw,
  int width = 64,
  int height = 64,
  Matrix4? view,
  Matrix4? projection,
  List<Light> lights = const [],
  int msaaSampleCount = 1,
  GraphicsDevice? device,
  RenderContext3D? context,
}) async {
  final graphicsDevice = device ?? GraphicsDevice();
  final renderContext = context ?? RenderContext3D(graphicsDevice);
  graphicsDevice.begin();
  renderContext
    ..lights = lights
    ..setCamera(view ?? defaultView, projection ?? defaultProjection);
  graphicsDevice.beginPass(
    Size(width.toDouble(), height.toDouble()),
    msaaSampleCount: msaaSampleCount,
    frontFace: renderContext.frontFace,
  );
  draw(renderContext);
  renderContext.flush();
  final image = graphicsDevice.endPass();
  graphicsDevice.end();
  final stats = RenderStats()..setFrom(graphicsDevice.lastFrameStats);
  final pixels = await readImage(image);
  image.dispose();
  return Frame(pixels, stats);
}

/// Reads the pixels of [image].
Future<Pixels> readImage(ui.Image image) async {
  final data = await image.toByteData();
  return Pixels(image.width, image.height, data!.buffer.asUint8List());
}

/// An opaque unlit material of [color], drawn in batches.
UnlitMaterial opaqueUnlit(Color color) {
  return UnlitMaterial(albedoColor: color)..renderState = RenderState.opaque;
}

/// A square of side `2 * halfSize` in the z = 0 plane, facing +z: its
/// triangles are counter-clockwise seen from +z.
Surface quad(Material material, {double halfSize = 0.5}) {
  final h = halfSize;
  const stride = 20;
  final vertices = Float32List(4 * stride);
  const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
  for (final (i, (x, y)) in corners.indexed) {
    vertices
      ..setRange(i * stride, i * stride + 3, [x * h, y * h, 0])
      // Texture coordinates.
      ..setRange(i * stride + 3, i * stride + 5, [(x + 1) / 2, (1 - y) / 2])
      // White vertex color.
      ..setRange(i * stride + 5, i * stride + 9, [1, 1, 1, 1])
      // Normal.
      ..setRange(i * stride + 9, i * stride + 12, [0, 0, 1]);
  }
  return Surface.fromBuffers(
    vertices: vertices,
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    material: material,
  );
}

/// The pixel of a [width]x[height] frame where the point ([x], [y]) of the
/// default camera's view lands.
(int, int) pixelAt(double x, double y, {int width = 64, int height = 64}) {
  return (((x + 1) / 2 * width).floor(), ((1 - y) / 2 * height).floor());
}

/// Compiles the GLSL shaders named [names] in `test/gpu/shaders` into shader
/// bundles and registers them with the backend as
/// `test/<name>.shaderbundle`.
Future<void> registerTestShaders(List<String> names) async {
  final temp = Directory.systemTemp.createTempSync('flame_3d_test_shaders');
  try {
    await shaderbundle.build(
      names,
      Directory('test/gpu/shaders'),
      temp,
      [Directory('shaders')],
    );
    for (final name in names) {
      final file = File('${temp.path}/$name.shaderbundle');
      if (!file.existsSync()) {
        throw StateError('Shader "$name" did not compile');
      }
      await GpuBackend.instance.registerShaderLibrary(
        'test/$name.shaderbundle',
        ByteData.sublistView(file.readAsBytesSync()),
      );
    }
  } finally {
    temp.deleteSync(recursive: true);
  }
}
