import 'package:flame/src/components/core/component.dart';
import 'package:meta/meta.dart';

/// This mixin ensures that an `onGameResize` event is dispatched to the
/// component before it mounts.
@Deprecated('will be removed in 1.8.0')
mixin OnGameResizeBeforeMount on Component {
  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final size = findGame()!.canvasSize;
    onGameResize(size);
  }
}
