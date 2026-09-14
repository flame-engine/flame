import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/game.dart';

const _amountTransforms = 1000;
const _amountPoints = 1000;

/// The per-frame pattern of a moving component: the position changes every
/// tick and the matrix is requested again when the component is rendered.
class PositionUpdateBenchmark extends BenchmarkBase {
  final Random random;

  late final List<Transform2D> _transforms;
  late final List<Vector2> _positions;

  PositionUpdateBenchmark(this.random) : super('Transform2D position update');

  static void main() {
    PositionUpdateBenchmark(Random(69420)).report();
  }

  @override
  void setup() {
    _transforms = _generateTransforms(random);
    _positions = _generateVectors(random, _amountTransforms);
  }

  @override
  void run() {
    for (var i = 0; i < _amountTransforms; i++) {
      final transform = _transforms[i];
      final position = _positions[i];
      transform.position.setValues(position.x, position.y);
      transform.transformMatrix;
    }
  }
}

/// A rotating component: the angle changes every tick and the matrix is
/// requested again when the component is rendered.
class AngleUpdateBenchmark extends BenchmarkBase {
  final Random random;

  late final List<Transform2D> _transforms;
  late final List<double> _angles;

  AngleUpdateBenchmark(this.random) : super('Transform2D angle update');

  static void main() {
    AngleUpdateBenchmark(Random(69420)).report();
  }

  @override
  void setup() {
    _transforms = _generateTransforms(random);
    _angles = List.generate(
      _amountTransforms,
      (_) => random.nextDouble() * 2 * pi,
    );
  }

  @override
  void run() {
    for (var i = 0; i < _amountTransforms; i++) {
      final transform = _transforms[i];
      transform.angle = _angles[i];
      transform.transformMatrix;
    }
  }
}

/// Converting points back and forth through an unchanged transform, as done
/// by hit testing and the camera.
class PointConversionBenchmark extends BenchmarkBase {
  final Random random;

  late final Transform2D _transform;
  late final List<Vector2> _points;
  final Vector2 _output = Vector2.zero();

  PointConversionBenchmark(this.random)
    : super('Transform2D localToGlobal/globalToLocal');

  static void main() {
    PointConversionBenchmark(Random(69420)).report();
  }

  @override
  void setup() {
    _transform = _generateTransforms(random).first;
    _points = _generateVectors(random, _amountPoints);
  }

  @override
  void run() {
    for (var i = 0; i < _amountPoints; i++) {
      final point = _points[i];
      _transform.localToGlobal(point, output: _output);
      _transform.globalToLocal(point, output: _output);
    }
  }
}

/// Assigning a full matrix to a transform and reading it back.
class MatrixAssignmentBenchmark extends BenchmarkBase {
  final Random random;

  late final List<Transform2D> _transforms;
  late final List<Matrix4> _matrices;

  MatrixAssignmentBenchmark(this.random)
    : super('Transform2D transformMatrix setter');

  static void main() {
    MatrixAssignmentBenchmark(Random(69420)).report();
  }

  @override
  void setup() {
    _transforms = _generateTransforms(random);
    _matrices = _generateTransforms(random)
        .map((transform) => transform.transformMatrix.clone())
        .toList(growable: false);
  }

  @override
  void run() {
    for (var i = 0; i < _amountTransforms; i++) {
      final transform = _transforms[i];
      transform.transformMatrix = _matrices[i];
      transform.transformMatrix;
    }
  }
}

/// Copying one transform into another and reading the resulting matrix.
class SetFromBenchmark extends BenchmarkBase {
  final Random random;

  late final List<Transform2D> _transforms;
  late final List<Transform2D> _sources;

  SetFromBenchmark(this.random) : super('Transform2D setFrom');

  static void main() {
    SetFromBenchmark(Random(69420)).report();
  }

  @override
  void setup() {
    _transforms = _generateTransforms(random);
    _sources = _generateTransforms(random);
    for (final source in _sources) {
      source.transformMatrix;
    }
  }

  @override
  void run() {
    for (var i = 0; i < _amountTransforms; i++) {
      final transform = _transforms[i];
      transform.setFrom(_sources[i]);
      transform.transformMatrix;
    }
  }
}

List<Transform2D> _generateTransforms(Random random) {
  return List.generate(
    _amountTransforms,
    (_) => Transform2D()
      ..position.setValues(
        random.nextDouble() * 1000,
        random.nextDouble() * 1000,
      )
      ..angle = random.nextDouble() * 2 * pi
      ..scale.setValues(
        random.nextDouble() * 3 + 0.5,
        random.nextDouble() * 3 + 0.5,
      )
      ..offset.setValues(
        random.nextDouble() * -100,
        random.nextDouble() * -100,
      ),
    growable: false,
  );
}

List<Vector2> _generateVectors(Random random, int amount) {
  return List.generate(
    amount,
    (_) => Vector2(random.nextDouble() * 1000, random.nextDouble() * 1000),
    growable: false,
  );
}

Future<void> main() async {
  PositionUpdateBenchmark.main();
  AngleUpdateBenchmark.main();
  PointConversionBenchmark.main();
  MatrixAssignmentBenchmark.main();
  SetFromBenchmark.main();
}
