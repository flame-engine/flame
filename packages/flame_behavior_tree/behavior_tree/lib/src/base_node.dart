import 'package:behavior_tree/behavior_tree.dart';
import 'package:meta/meta.dart';

/// A base class for all the nodes.
abstract class BaseNode implements NodeInterface {
  NodeStatus _status = NodeStatus.notStarted;

  @override
  NodeStatus get status => _status;

  @override
  set status(NodeStatus value) {
    _status = value;
  }

  @override
  @mustCallSuper
  void reset() {
    _status = NodeStatus.notStarted;
  }
}
