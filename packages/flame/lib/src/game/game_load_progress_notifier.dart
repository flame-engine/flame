import 'dart:async';

import 'package:meta/meta.dart';

typedef _LoadingFutureFactory = Future<void>? Function();

/// The wrapper for the stream, encapsulating all initialization process.
/// Just use [reportLoadingProgress] function to send messages to custom
/// splash screen widget or to a component with "ProgressListener" mixin.
/// Please note that the type of message should be same for all participants
/// of messages exchange!
class GameLoadProgressNotifier<M> {
  StreamController<M>? _loadingStreamController;

  _LoadingFutureFactory? _externalLoaderFuture;

  /// Sends a message to all subscribers
  void reportLoadingProgress(M message) =>
      _loadingStreamController?.add(message);

  @internal
  Stream<M> getInGameStream() {
    final stream = _loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    _loadingStreamController = StreamController<M>.broadcast();
    return _loadingStreamController!.stream;
  }

  @internal
  Stream<M> initStreamLoader(_LoadingFutureFactory loaderFutureFactory) {
    final stream = _loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    _loadingStreamController =
        StreamController<M>.broadcast(onListen: _startOnLoadWithStream);
    _externalLoaderFuture = loaderFutureFactory;
    return _loadingStreamController!.stream;
  }

  Future<void> _startOnLoadWithStream() async {
    await _externalLoaderFuture?.call();
    _externalLoaderFuture = null;
  }

  void dispose() {
    _loadingStreamController?.close();
    _loadingStreamController = null;
  }
}
