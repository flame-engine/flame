import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// pointer scroll (mouse wheel) events.
///
/// This callback uses [ScrollDispatcher] to route events.
mixin ScrollCallbacks on Component {
  void onScroll(ScrollEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    ScrollDispatcher.addDispatcher(this);
  }
}
