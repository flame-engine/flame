import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/messages/double_tap_cancel_event.dart';
import 'package:flame/src/events/messages/double_tap_down_event.dart';
import 'package:flame/src/events/messages/double_tap_event.dart';

mixin DoubleTapCallbacks on Component {
  void onDoubleTap(DoubleTapEvent event) {}
  void onDoubleTapCancel(DoubleTapCancelEvent event) {}
  void onDoubleTapDown(DoubleTapDownEvent event) {}
}
