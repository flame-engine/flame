import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

/// Mixin allows a component to be notified about
/// progressNotifier.reportLoadingProgress event. You just need to implement
/// [onProgressMessage] function and game's
mixin ProgressListener<M> on Component {
  /// The function is subscribed on notifications
  void onProgressMessage(M message);

  Game get _gameRef {
    final game = findGame();
    assert(
      game != null,
      "Notifier can't be used without Game",
    );
    return game!;
  }

  StreamSubscription<M>? _streamSubscription;

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final stream = _gameRef.progressNotifier?.getInGameStream() as Stream<M>?;
    assert(
      stream != null,
      'The progressNotifier is not initialized',
    );

    _streamSubscription = stream!.listen(onProgressMessage);
  }

  @override
  @mustCallSuper
  void onRemove() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.onRemove();
  }
}
