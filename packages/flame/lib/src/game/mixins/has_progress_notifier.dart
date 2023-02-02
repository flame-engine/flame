import 'dart:async';

import 'package:flame/game.dart';
import 'package:meta/meta.dart';

typedef _LoadingFutureFactory = Future<void>? Function();

/// The wrapper for the stream, encapsulating all initialization process.
/// Just use [reportLoadingProgress] function to send messages to custom
/// splash screen widget or to a component with "ProgressListener" mixin.
/// Please note that the type of message should be same for all participants
/// of messages exchange!
mixin HasProgressNotifier<M> on Game {
  StreamController<M>? _loadingStreamController;

  _LoadingFutureFactory? _externalLoaderFuture;
  final _onLoadCompleter = Completer<void>();

  Future<void> get onLoadWithProgressFuture => _onLoadCompleter.future;

  /// Sends a message to all subscribers
  void reportLoadingProgress(M message) =>
      _loadingStreamController?.add(message);

  @internal
  Stream<M> initMessagingStream(_LoadingFutureFactory loaderFutureFactory) {
    final stream = _loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    _loadingStreamController =
        StreamController<M>.broadcast(onListen: _startOnLoadWithStream);
    _externalLoaderFuture = loaderFutureFactory;
    return _loadingStreamController!.stream;
  }

  @internal
  Stream<M> get messagingStream {
    final stream = _loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    _loadingStreamController = StreamController<M>.broadcast();
    return _loadingStreamController!.stream;
  }

  Future<void> _startOnLoadWithStream() async {
    if (_externalLoaderFuture == null) {
      return;
    }
    await _externalLoaderFuture?.call();
    _externalLoaderFuture = null;
    _onLoadCompleter.complete();
  }

  @override
  void detach() {
    _loadingStreamController?.close();
    _loadingStreamController = null;
    super.detach();
  }
}
