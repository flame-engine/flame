import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flutter/material.dart';

class SimpleIsolateExample extends FlameGame {
  static const String description = '''
    This example showcases a simple FlameIsolate example, making it easy to 
    continually run heavy load without stutter.
    
    Tap the brown square to swap between running heavy load in in an isolate or
    synchronous.
    
    The selected backpressure strategy used for this example is
    `DiscardNewBackPressureStrategy`. This strategy discards all new jobs added
    to the queue if there is already a job in the queue.
  ''';

  @override
  Future<void> onLoad() async {
    final world = World();
    final cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: 400,
      height: 600,
    );
    addAll([world, cameraComponent]);

    const rect = Rect.fromLTRB(-120, -120, 120, 120);
    final circle = Path()..addOval(rect);
    final teal = Paint()..color = Colors.tealAccent;

    for (var i = 0; i < 20; i++) {
      world.add(
        RectangleComponent.square(size: 10)
          ..paint = teal
          ..add(
            MoveAlongPathEffect(
              circle,
              EffectController(
                duration: 6,
                startDelay: i * 0.3,
                infinite: true,
              ),
              oriented: true,
            ),
          ),
      );
    }

    world.add(CalculatePrimeNumber());
  }
}

enum ComputeType {
  isolate('Running in isolate'),
  synchronous('Running synchronously');

  final String description;

  const ComputeType(this.description);
}

class CalculatePrimeNumber extends PositionComponent
    with TapCallbacks, FlameIsolate {
  CalculatePrimeNumber() : super(anchor: Anchor.center);

  ComputeType computeType = ComputeType.isolate;
  late Timer _interval;

  @override
  BackpressureStrategy get backpressureStrategy =>
      DiscardNewBackPressureStrategy();

  @override
  void onLoad() {
    width = 200;
    height = 70;
  }

  @override
  Future<void> onMount() {
    _interval = Timer(0.4, repeat: true, onTick: _checkNextAgainstPrime)
      ..start();
    return super.onMount();
  }

  @override
  void update(double dt) {
    _interval.update(dt);
  }

  @override
  void onRemove() {
    _interval.stop();
    super.onRemove();
  }

  static const _minStartValue = 500000000;
  static const _maxStartValue = 600000000;
  static final _primeStartNumber =
      Random().nextInt(_maxStartValue - _minStartValue) + _minStartValue;

  MapEntry<int, bool> _primeData = MapEntry(
    _primeStartNumber,
    _isPrime(_primeStartNumber),
  );

  Future<void> _checkNextAgainstPrime() async {
    final nextInt = _primeData.key + 1;

    try {
      final bool isPrime;

      switch (computeType) {
        case ComputeType.isolate:
          isPrime = await isolate(_isPrime, nextInt);
          break;
        case ComputeType.synchronous:
          isPrime = _isPrime(nextInt);
          break;
      }

      _primeData = MapEntry(nextInt, isPrime);
    } on BackpressureDropException catch (_) {
      debugPrint('Backpressure kicked in');
    }
  }

  @override
  void onTapDown(_) {
    computeType =
        ComputeType.values[(computeType.index + 1) % ComputeType.values.length];
  }

  final _paint = Paint()..color = Colors.green;

  final _textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 10,
    ),
  );

  late final rect = Rect.fromLTWH(0, 0, width, height);
  late final topLeftVector = rect.topLeft.toVector2() + Vector2.all(4);
  late final centerVector = rect.center.toVector2();

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, _paint);

    _textPaint.render(
      canvas,
      computeType.description,
      topLeftVector,
    );

    _textPaint.render(
      canvas,
      '${_primeData.key} is${_primeData.value ? '' : ' not'} a prime number',
      centerVector,
      anchor: Anchor.center,
    );
  }
}

bool _isPrime(int value) {
  // Simulating heavy load
  if (value == 1) {
    return false;
  }
  for (var i = 2; i < value; ++i) {
    if (value % i == 0) {
      return false;
    }
  }
  return true;
}
