import 'dart:async';

import 'package:meta/meta.dart';

typedef _LoadingFutureFactory = Future<void>? Function();

class GameLoadProgressNotifier<M> {
  StreamController<M>? loadingStreamController;

  _LoadingFutureFactory? _externalLoaderFuture;

  void reportLoadingProgress(M message) =>
      loadingStreamController?.add(message);

  @internal
  Stream<M> getInGameStream() {
    final stream = loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    loadingStreamController = StreamController<M>.broadcast();
    return loadingStreamController!.stream;
  }

  @internal
  Stream<M> initStreamLoader(_LoadingFutureFactory loaderFutureFactory) {
    final stream = loadingStreamController?.stream;
    if (stream != null) {
      return stream;
    }
    loadingStreamController =
        StreamController<M>.broadcast(onListen: _startOnLoadWithStream);
    _externalLoaderFuture = loaderFutureFactory;
    return loadingStreamController!.stream;
  }

  Future<void> _startOnLoadWithStream() async {
    assert(_externalLoaderFuture != null);
    await _externalLoaderFuture!.call();
    _externalLoaderFuture = null;
  }

  void dispose() {
    loadingStreamController?.close();
    loadingStreamController = null;
  }
}
