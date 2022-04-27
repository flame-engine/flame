import 'package:flutter/gestures.dart';

abstract class MultiTapListener {
  double get longTapDelay;
  void handleTap(int pointerId);
  void handleTapDown(int pointerId, TapDownDetails details);
  void handleTapUp(int pointerId, TapUpDetails details);
  void handleTapCancel(int pointerId);
  void handleLongTapDown(int pointerId, TapDownDetails details);
}
