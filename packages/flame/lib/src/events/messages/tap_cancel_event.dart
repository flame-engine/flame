
import 'package:flame/src/events/messages/event.dart';

class TapCancelEvent extends Event {
  TapCancelEvent(this.pointerId);

  final int pointerId;
}
