import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';

typedef AsyncTaskCallback = Future<NodeStatus> Function();

/// This is a leaf node that will execute the given async task when ticked.
/// While the callback is executing, this node will report [status] as
/// [NodeStatus.running]. Once the callback finishes, the status will be updated
/// to the returned value of the callback.
class AsyncTask implements Node {
  /// Creates an async task node for given [callback].
  AsyncTask(AsyncTaskCallback callback) : _callback = callback;

  final AsyncTaskCallback _callback;
  var _isCallbackRunning = false;
  var _status = NodeStatus.running;

  @override
  NodeStatus get status => _status;

  @override
  void tick() {
    if (!_isCallbackRunning) {
      _isCallbackRunning = true;
      _status = NodeStatus.running;

      _callback().then((returnedStatus) {
        _status = returnedStatus;
        _isCallbackRunning = false;
      });
    }
  }
}
