/// The state of the behavior tree of a component at a moment in time, as it is
/// reported by the `ext.flame_devtools.getBehaviorTree` service extension of
/// `flame_behavior_tree`.
class const BehaviorTreeSnapshot({
  required this.tickInterval,
  required this.status,
  required this.root,
  required this.blackboard,
}) {
  factory BehaviorTreeSnapshot.fromJson(Map<String, dynamic> json) {
    return BehaviorTreeSnapshot(
      tickInterval: (json['tickInterval'] as num).toDouble(),
      status: json['status'] as String?,
      root: BehaviorTreeNodeSnapshot.fromJson(
        json['tree'] as Map<String, dynamic>,
      ),
      blackboard: [
        for (final entry in json['blackboard'] as List)
          BlackboardEntry(
            key: (entry as Map<String, dynamic>)['key'] as String,
            value: entry['value'] as String,
          ),
      ],
    );
  }

  /// The time between two ticks of the tree, in seconds. 0 means that the tree
  /// is ticked on every update.
  final double tickInterval;

  /// The name of the status that the root node returned last, if any.
  final String? status;

  final BehaviorTreeNodeSnapshot root;

  final List<BlackboardEntry> blackboard;
}

/// A node of a [BehaviorTreeSnapshot].
class const BehaviorTreeNodeSnapshot({
  required this.type,
  required this.name,
  required this.status,
  required this.isRunning,
  required this.children,
}) {
  factory BehaviorTreeNodeSnapshot.fromJson(Map<String, dynamic> json) {
    return BehaviorTreeNodeSnapshot(
      type: json['type'] as String,
      name: json['name'] as String?,
      status: json['status'] as String?,
      isRunning: json['isRunning'] as bool,
      children: [
        for (final child in json['children'] as List)
          BehaviorTreeNodeSnapshot.fromJson(child as Map<String, dynamic>),
      ],
    );
  }

  /// The type of the node, for example `Sequence`.
  final String type;

  /// The name that was given to the node, if any.
  final String? name;

  /// The name of the status that the node returned last, or null if it has not
  /// been ticked yet or was aborted.
  final String? status;

  final bool isRunning;

  final List<BehaviorTreeNodeSnapshot> children;

  /// What the node is doing now: `running` while it is running, otherwise the
  /// last status that it returned, or null.
  String? get state => isRunning ? 'running' : status;
}

/// A value on the blackboard of a behavior tree.
class const BlackboardEntry({required this.key, required this.value}) {
  final String key;

  /// The value as a string.
  final String value;
}
