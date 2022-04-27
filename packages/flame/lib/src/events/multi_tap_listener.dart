import 'package:flutter/gestures.dart';

abstract class MultiTapListener {
  void handleTap(int pointerId);
  void handleTapDown(int pointerId, TapDownDetails details);
  void handleTapUp(int pointerId, TapUpDetails details);
  void handleTapCancel(int pointerId);
}
