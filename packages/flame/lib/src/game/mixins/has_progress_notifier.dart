import 'dart:async';

import 'package:flame/game.dart';
import 'package:meta/meta.dart';

typedef _LoadingFutureFactory = Future<void>? Function();

mixin HasProgressNotifier<M> on Game {
  final progressNotifier = GameLoadProgressNotifier<M>._();

  @internal
  Stream<M> initMessagingStream(_LoadingFutureFactory loaderFutureFactory) =>
      progressNotifier._initStream(loaderFutureFactory);

  @internal
  Stream<M> get messagingStream => progressNotifier._getStream();

  @override
  void detach() {
    progressNotifier._dispose();
  }
}

/// The wrapper for the stream, encapsulating all initialization process.
/// Just use [reportLoadingProgress] function to send messages to custom
/// splash screen widget or to a component with "ProgressListener" mixin.
/// Please note that the type of message should be same for all participants
/// of messages exchange!
class GameLoadProgressNotifier<M> {
  /// It is not a good idea to use the class anywhere outside of
  /// [HasProgressNotifier] because it is too specialized for it.
  GameLoadProgressNotifier._();

  StreamController<M>? _loadingStreamController;

  _LoadingFutureFactory? _externalLoaderFuture;
  final _onLoadCompleter = Completer<void>();

  Future<void> get onLoadFuture => _onLoadCompleter.future;

  /// Sends a message to all subscribers
  void reportLoadingProgress(M message) =>
      _loadingStreamController?.add(message);

  Stream<M> _getStream() {
    final stream = _loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    _loadingStreamController = StreamController<M>.broadcast();
    return _loadingStreamController!.stream;
  }

  Stream<M> _initStream(_LoadingFutureFactory loaderFutureFactory) {
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
    if (_externalLoaderFuture == null) {
      return;
    }
    await _externalLoaderFuture?.call();
    _externalLoaderFuture = null;
    _onLoadCompleter.complete();
  }

  void _dispose() {
    _loadingStreamController?.close();
    _loadingStreamController = null;
  }
}
