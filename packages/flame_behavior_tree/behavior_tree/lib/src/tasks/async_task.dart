import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';

typedef AsyncTaskCallback = Future<NodeStatus> Function();

/// This is a leaf node that will execute the given async task when ticked.
/// While the callback is executing, this node will report [status] as
/// [NodeStatus.running]. Once the callback finishes, the status will be updated
/// to the returned value of the callback.
class AsyncTask extends BaseNode implements INode {
  /// Creates an async task node for given [callback].
  AsyncTask(AsyncTaskCallback callback) : _callback = callback;

  final AsyncTaskCallback _callback;
  var _isCallbackRunning = false;

  @override
  void tick() {
    if (!_isCallbackRunning) {
      _isCallbackRunning = true;
      status = NodeStatus.running;

      _callback().then((returnedStatus) {
        status = returnedStatus;
        _isCallbackRunning = false;
      });
    }
  }
}
