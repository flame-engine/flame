import 'dart:math';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'common.dart';

const _amountComponents = 10000;
const _viewport = 200.0;
const _componentSize = 10.0;

/// Renders [_amountComponents] components through a camera.
///
/// The components are spread over an area [spread] times the size of the
/// viewport, so with a large spread only a small fraction is visible.
/// [culled] decides whether the components use `CullWhenOffscreen`.
class CullingBenchmark({
  required final String label,
  required final bool culled,
  required final double spread,
}) extends AsyncBenchmarkBase {
  late final FlameGame _game;

  this : super('Culling Benchmark ($label)');

  @override
  Future<void> setup() async {
    final world = World();
    final camera = CameraComponent(
      world: world,
      viewport: FixedSizeViewport(_viewport, _viewport),
    );
    _game = FlameGame(world: world, camera: camera);
    await mountGame(_game, size: Vector2.all(_viewport));

    final random = Random(69420);
    final extent = _viewport * spread;
    world.addAll(
      List.generate(
        _amountComponents,
        (_) {
          final position = Vector2(
            (random.nextDouble() - 0.5) * extent,
            (random.nextDouble() - 0.5) * extent,
          );
          return culled
              ? _CulledComponent(position: position)
              : _PlainComponent(position: position);
        },
      ),
    );
    await _game.ready();
  }

  @override
  Future<void> run() async {
    // A real recording canvas, so that the draw calls skipped by culling have
    // a realistic cost (a `MockCanvas` is far more expensive than a real one).
    final recorder = PictureRecorder();
    _game.render(Canvas(recorder));
    recorder.endRecording().dispose();
  }
}

Future<void> main() async {
  // Baseline: every component is drawn, with and without the mixin.
  await CullingBenchmark(
    label: 'off-screen, plain',
    culled: false,
    spread: 7,
  ).report();
  await CullingBenchmark(
    label: 'off-screen, culled',
    culled: true,
    spread: 7,
  ).report();
  // Worst case for culling: everything is visible, only the check is paid.
  await CullingBenchmark(
    label: 'on-screen, plain',
    culled: false,
    spread: 1,
  ).report();
  await CullingBenchmark(
    label: 'on-screen, culled',
    culled: true,
    spread: 1,
  ).report();
}

final _paint = Paint();

class _PlainComponent({super.position}) extends PositionComponent {
  this : super(size: Vector2.all(_componentSize));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}

class _CulledComponent({super.position})
    extends PositionComponent
    with CullWhenOffscreen {
  this : super(size: Vector2.all(_componentSize));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
