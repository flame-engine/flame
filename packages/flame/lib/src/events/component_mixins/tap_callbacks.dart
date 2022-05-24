
import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/tap_cancel_event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';

mixin TapCallbacks on Component {
  void onTapDown(TapDownEvent event) {}
  void onLongTapDown(TapDownEvent event) {}
  void onTapUp(TapUpEvent event) {}
  void onTapCancel(TapCancelEvent event) {}
}
