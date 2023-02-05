import 'package:flame/game.dart';
import 'package:flame/src/events/component_mixins/double_tap_callbacks.dart';
import 'package:flame/src/events/tagged_component.dart';

mixin MultiDoubleTapDispatcher on FlameGame {
  final Set<TaggedComponent<DoubleTapCallbacks>> _records = {};
  bool _eventHandlerRegistered = false;
}
