import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/tappable.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame/src/events/messages/tap_cancel_event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive tap events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "tapped" if the point where the tap has occurred is inside the component.
///
/// When using this mixin, make sure to also add the [HasTappableComponents]
/// mixin to your game.
///
/// This mixin is intended as a replacement of the [Tappable] mixin.
mixin TapCallbacks on Component {
  void onTapDown(TapDownEvent event) {}
  void onLongTapDown(TapDownEvent event) {}
  void onTapUp(TapUpEvent event) {}
  void onTapCancel(TapCancelEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasTappableComponents,
      'The components with TapCallbacks can only be added to a FlameGame with '
      'the HasTappableComponents mixin',
    );
  }
}
