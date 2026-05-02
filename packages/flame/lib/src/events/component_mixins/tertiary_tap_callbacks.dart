import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive tertiary
/// tap events (i.e. middle mouse clicks).
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "tapped" if the point where the tap has occurred is inside the component.
///
/// Note that FlameGame _is_ a [Component] and does implement
/// [containsLocalPoint]; so this can be used at the game level.
///
/// This callback uses [NonPrimaryTapDispatcher] to route events.
mixin TertiaryTapCallbacks on Component {
  void onTertiaryTapDown(TertiaryTapDownEvent event) {}
  void onTertiaryTapUp(TertiaryTapUpEvent event) {}
  void onTertiaryTapCancel(TertiaryTapCancelEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    NonPrimaryTapDispatcher.addDispatcher(this);
  }
}
