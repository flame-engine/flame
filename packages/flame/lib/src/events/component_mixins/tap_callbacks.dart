
import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';

mixin TapCallbacks on Component {

  void onTapDown(TapDownEvent event) {}
}
