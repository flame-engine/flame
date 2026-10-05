import 'dart:math';
import 'dart:typed_data';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';

/// Measures tracing the outlines of images with
/// [ImageExtension.contourFromPixels] and splitting polygons into
/// [convexPieces], from the pixels to the convex pieces of a body.
///
/// This is a standalone suite, not part of `main.dart`. Run it with
/// `flutter test benchmark/image_contour_benchmark.dart`.
Future<void> main() async {
  for (final size in [128, 512, 2048]) {
    TraceBenchmark(size).report();
  }
  TraceBenchmark(2048, transparent: true).report();
  for (final vertices in [50, 200, 800, 2000]) {
    ConvexPiecesBenchmark(vertices).report();
  }
  for (final size in [512, 2048]) {
    PipelineBenchmark(size).report();
  }
}

/// A benchmark whose every sample is a single [run], since a run can take
/// tens of milliseconds, while the harness runs it 10 times per sample by
/// default.
abstract class _SingleRunBenchmark(super.name) extends BenchmarkBase {
  @override
  void exercise() => run();
}

/// Tracing the outlines of a [size] by [size] image, which is a blob with
/// wavy anti-aliased edges, or fully [transparent] to measure the scan of the
/// pixels alone.
class TraceBenchmark(final int size, {final bool transparent = false})
    extends _SingleRunBenchmark {
  this
    : super(
        'Trace contours of ${transparent ? 'transparent' : 'blob'} '
        '${size}x$size',
      );

  late final Uint8List _pixels;

  @override
  void setup() {
    _pixels = transparent ? Uint8List(size * size * 4) : _blob(size);
  }

  @override
  void run() {
    ImageExtension.contourFromPixels(_pixels, size, size);
  }
}

/// Splitting a star with [vertices] vertices, which is concave, into convex
/// pieces of at most 8 vertices.
class ConvexPiecesBenchmark(final int vertices) extends _SingleRunBenchmark {
  this : super('Convex pieces of a star with $vertices vertices');

  late final List<Vector2> _star;

  @override
  void setup() {
    _star = [
      for (var i = 0; i < vertices; i++)
        Vector2(cos(2 * pi * i / vertices), sin(2 * pi * i / vertices))
          ..scale(i.isEven ? 10 : 6),
    ];
  }

  @override
  void run() {
    convexPieces(_star);
  }
}

/// The whole way from the pixels of a [size] by [size] blob to the convex
/// pieces of its outline, through the polygons that a [PathComponent] makes
/// of it with the default sampling.
class PipelineBenchmark(final int size) extends _SingleRunBenchmark {
  this : super('Pixels to convex pieces of blob ${size}x$size');

  late final Uint8List _pixels;

  @override
  void setup() {
    _pixels = _blob(size);
  }

  @override
  void run() {
    final outline = ImageExtension.contourFromPixels(_pixels, size, size);
    for (final polygon in PathComponent.polygonsOf(outline)) {
      convexPieces(polygon);
    }
  }
}

/// A [size] by [size] image of a blob with 7 waves along its edge, which is
/// opaque inside and anti-aliased over a pixel along the edge.
Uint8List _blob(int size) {
  final pixels = Uint8List(size * size * 4);
  final center = size / 2;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x + 0.5 - center;
      final dy = y + 0.5 - center;
      final radius = center * (0.7 + 0.2 * sin(7 * atan2(dy, dx)));
      final inside = radius - sqrt(dx * dx + dy * dy);
      pixels[(y * size + x) * 4 + 3] = (inside.clamp(0, 1) * 255).round();
    }
  }
  return pixels;
}
