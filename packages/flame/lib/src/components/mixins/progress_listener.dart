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

  HasProgressNotifier get _gameRefWithProgress {
    final game = findGame();
    assert(
      game != null,
      "Notifier can't be used without Game",
    );
    assert(
      game is HasProgressNotifier,
      'Game must have HasProgressNotifier mixin',
    );
    return game! as HasProgressNotifier;
  }

  StreamSubscription<M>? _streamSubscription;

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();

    final stream = _gameRefWithProgress.messagingStream as Stream<M>;
    _streamSubscription = stream.listen(onProgressMessage);
  }

  @override
  @mustCallSuper
  void onRemove() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.onRemove();
  }
}
