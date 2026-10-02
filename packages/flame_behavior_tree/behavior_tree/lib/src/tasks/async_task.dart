import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';

typedef AsyncTaskCallback = Future<NodeStatus> Function();

/// This is a leaf node that will execute the given async task when ticked.
/// While the callback is executing, this node will report [status] as
/// [NodeStatus.running]. Once the callback finishes, the status will be updated
/// to the returned value of the callback.
class AsyncTask(final AsyncTaskCallback _callback)
    extends BaseNode
    implements NodeInterface {
  @override
  void tick() {
    if (status != NodeStatus.running) {
      status = NodeStatus.running;

      _callback().then((returnedStatus) {
        status = returnedStatus;
      });
    }
  }
}
