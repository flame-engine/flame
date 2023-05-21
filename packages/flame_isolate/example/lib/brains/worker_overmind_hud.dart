import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';

enum ComputeType {
  isolate('Running in isolate'),
  compute('Running in compute function'),
  synchronous('Running synchronously');

  final String description;

  const ComputeType(this.description);
}

class WorkerOvermindHud extends PositionComponent with TapCallbacks {
  ComputeType computeType = ComputeType.isolate;

  @override
  void onLoad() {
    x = 10;
    y = 10;
    width = 210;
    height = 80;
  }

  @override
  void onTapDown(_) {
    computeType =
        ComputeType.values[(computeType.index + 1) % ComputeType.values.length];
  }

  final _paint = Paint()..color = const Color(0xa98d560d);

  final textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 15,
    ),
  );

  late final rect = toRect();
  late final centerVector = rect.center.toVector2();

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, _paint);

    textPaint.render(
      canvas,
      computeType.description,
      centerVector,
      anchor: Anchor.center,
    );
  }
}
