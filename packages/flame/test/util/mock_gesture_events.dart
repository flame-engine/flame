import 'package:flutter/gestures.dart';
import 'package:flame/gestures.dart';
import 'package:flame/extensions.dart';

TapDownInfo createTapDownEvent({
  Vector2? position,
  Vector2? gameWidgetPosition,
  Vector2? globalPosition,
}) {
  return TapDownInfo(
    position ?? Vector2.zero(),
    gameWidgetPosition ?? Vector2.zero(),
    globalPosition ?? Vector2.zero(),
    TapDownDetails(),
  );
}
