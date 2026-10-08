import 'dart:convert';
import 'dart:developer';

import 'package:behavior_tree/behavior_tree.dart';
import 'package:flame/components.dart';
import 'package:flame/devtools.dart';
import 'package:flame_behavior_tree/src/has_behavior_tree.dart';
import 'package:flutter/foundation.dart';

/// Reports the behavior trees of the components to the Flame devtools
/// extension, through the `ext.flame_devtools.getBehaviorTree` service
/// extension.
///
/// The extension takes the `id` of a component, which is its `hashCode`, like
/// the other service extensions of the devtools. It responds with whether the
/// component has a behavior tree, and if so with the tree, the status of every
/// node of it, and the contents of its blackboard, see [describeBehaviorTree].
///
/// The connector is registered the first time that a component with
/// [HasBehaviorTree] is mounted in debug mode, so nothing is registered for
/// games that do not use behavior trees.
class BehaviorTreeConnector() extends DevToolsConnector {
  static var _isRegistered = false;

  /// Registers the connector with the [DevToolsService], unless that was
  /// already done or the app is not running in debug mode.
  static void ensureRegistered() {
    if (!kDebugMode || _isRegistered) {
      return;
    }
    _isRegistered = true;
    DevToolsService.instance.registerConnector(BehaviorTreeConnector());
  }

  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getBehaviorTree',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final component = findComponent<Component>(id);
        if (component == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'No component with the id ${parameters['id']} was found.',
          );
        }

        return ServiceExtensionResponse.result(
          json.encode({'id': id, ...describeBehaviorTree(component)}),
        );
      },
    );
  }
}

/// Describes the behavior tree of [component] with JSON compatible values.
///
/// For a component without a behavior tree this is just
/// `{'hasBehaviorTree': false}`. Otherwise it also has:
///
/// - `tickInterval`: the time between two ticks of the tree, in seconds.
/// - `status`: the name of the status that the root returned last, or null.
/// - `tree`: the root node. Every node has a `type`, an optional `name`, the
///   `status` that it returned last (or null if it was not ticked yet or was
///   aborted), whether it `isRunning`, and its `children`.
/// - `blackboard`: a list with the `key` and the `value` as a string, for every
///   value that is set on the blackboard of the tree.
Map<String, dynamic> describeBehaviorTree(Component component) {
  if (component is! HasBehaviorTree || !component.hasBehaviorTree) {
    return {'hasBehaviorTree': false};
  }

  final tree = component.behaviorTree;
  final blackboard = tree.blackboard;
  final keys = blackboard.keys.toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return {
    'hasBehaviorTree': true,
    'tickInterval': component.tickInterval,
    'status': tree.lastStatus?.name,
    'tree': _describeNode(tree.root),
    'blackboard': [
      for (final key in keys)
        {'key': key.name, 'value': '${blackboard.getOrNull(key)}'},
    ],
  };
}

Map<String, dynamic> _describeNode(Node node) {
  final children = switch (node) {
    Composite() => node.children,
    Decorator() => [node.child],
    _ => const <Node>[],
  };
  return {
    'type': node.runtimeType.toString(),
    if (node.name != null) 'name': node.name,
    'status': node.lastStatus?.name,
    'isRunning': node.isRunning,
    'children': children.map(_describeNode).toList(),
  };
}
