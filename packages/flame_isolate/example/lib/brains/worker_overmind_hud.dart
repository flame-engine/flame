import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';

enum ComputeType {
  isolate('Running in isolate'),
  compute('Running in compute function'),
  synchronous('Running synchronously');

  final String description;

  const ComputeType(this.description);
}

class WorkerOvermindHud extends PositionComponent with Tappable {
  ComputeType computeType = ComputeType.isolate;

  @override
  Future<void>? onLoad() {
    x = 10;
    y = 10;
    width = 210;
    height = 80;
    positionType = PositionType.viewport;
    return super.onLoad();
  }

  @override
  bool onTapDown(_) {
    computeType =
        ComputeType.values[(computeType.index + 1) % ComputeType.values.length];
    return false;
  }

  final _paint = Paint()..color = const Color(0xa98d560d);

  final textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 15,
    ),
  );

  @override
  void render(Canvas canvas) {
    final rect = toRect();
    canvas.drawRect(rect, _paint);

    textPaint.render(
      canvas,
      computeType.description,
      rect.center.toVector2(),
      anchor: Anchor.center,
    );
  }
}
