import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';

/// The type of callback used by the [AsyncTask] node.
typedef AsyncTaskCallback = Future<Status> Function(TickContext context);

/// A leaf node that runs an async callback.
///
/// The callback is started on the first tick. Until it completes the node
/// returns [Status.running]; afterwards it returns the status the callback
/// completed with. If the node is aborted while the callback is still in
/// flight, the eventual result is ignored. If the callback throws, the error
/// is rethrown from the next tick.
class AsyncTask(this.callback) extends Node {
  /// The async callback that is started when this node is entered.
  final AsyncTaskCallback callback;

  // Incremented on every run so that results of aborted runs can be ignored.
  int _run = 0;
  Status? _result;
  (Object, StackTrace)? _error;

  @override
  void onEnter(TickContext context) {
    final run = ++_run;
    _result = null;
    _error = null;
    // Future.sync makes an error that the callback throws before it returns a
    // future follow the same path as an error of the future itself.
    Future.sync(() => callback(context)).then(
      (status) {
        if (run == _run) {
          _result = status;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (run == _run) {
          _error = (error, stackTrace);
        }
      },
    );
  }

  @override
  Status onTick(TickContext context) {
    final error = _error;
    if (error != null) {
      Error.throwWithStackTrace(error.$1, error.$2);
    }
    return _result ?? Status.running;
  }

  @override
  void onAbort(TickContext context) {
    ++_run;
  }
}
