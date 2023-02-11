import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentTreeProvider =
    StateNotifierProvider<ComponentTreeNotifier, Node?>((ref) {
  final gameState = ref.watch(gameControllerProvider);
  return ComponentTreeNotifier(gameState.game as FlameGame?);
});

@immutable
class Node {
  Node._({required this.component, this.expandable = false, this.children})
      : name = component.runtimeType.toString();

  factory Node.fromComponent(
    Component component, {
    Node? oldNode,
    bool? expanded,
  }) {
    assert(oldNode == null || oldNode.component == component);
    List<Node>? childrenNodes;
    if ((expanded ?? oldNode?.isExpanded ?? false) && component.hasChildren) {
      childrenNodes = [
        for (final child in component.children)
          Node.fromComponent(
            child,
            oldNode: oldNode?.children
                ?.firstWhereOrNull((node) => node.component == child),
          )
      ];
    }
    return Node._(
      component: component,
      expandable: component.hasChildren,
      children: childrenNodes,
    );
  }

  final Component component;
  final String name;
  final bool expandable;
  final List<Node>? children;
  bool get isExpanded => children != null;
  bool get isCollapsed => expandable && !isExpanded;

  /// Traverses the tree in depth-first order, calling [visitor] for each node.
  void traverse(_VisitorFn visitor) {
    final stop = visitor(this, 0, null, -1);
    if (!stop) {
      _traverseInner(1, visitor);
    }
  }

  bool _traverseInner(int depth, _VisitorFn visitor) {
    if (children != null) {
      var i = 0;
      for (final node in children!) {
        final stop = visitor(node, depth, this, i) ||
            node._traverseInner(depth + 1, visitor);
        if (stop) {
          return true;
        }
        i++;
      }
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is Node &&
      component == other.component &&
      name == other.name &&
      expandable == other.expandable &&
      listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(component, name, expandable, children);
}

/// The visitor function receives four parameters: the `node` itself, its
/// `depth` within the tree, the node's `parent` if it exists, and its
/// `index` within the parent's list of children. The function may return
/// `true` to indicate that the traversal should stop, or false to continue
/// tree traversal.
typedef _VisitorFn = bool Function(
  Node node,
  int depth,
  Node? parent,
  int index,
);

class ComponentTreeNotifier extends StateNotifier<Node?> {
  ComponentTreeNotifier(Component? root)
      : super(root == null ? null : Node.fromComponent(root)) {
    if (root != null) {
      _refresh(Duration.zero);
    }
  }

  void toggle(Component component) => _toggle(component);

  void expand(Component component) => _toggle(component, expand: true);

  void collapse(Component component) => _toggle(component, expand: false);

  void _toggle(Component component, {bool? expand}) {
    if (state!.component == component) {
      state = Node.fromComponent(
        component,
        oldNode: state,
        expanded: expand ?? !state!.isExpanded,
      );
      return;
    }
    final newTree = Node.fromComponent(state!.component, oldNode: state);
    newTree.traverse((node, level, parent, index) {
      if (node.component == component) {
        parent!.children![index] = Node.fromComponent(
          component,
          oldNode: node,
          expanded: expand ?? !node.isExpanded,
        );
        return true;
      }
      return false;
    });
    state = newTree;
  }

  static Duration refreshFrequency = const Duration(milliseconds: 300);
  Duration _timeSinceLastRefresh = Duration.zero;

  void _refresh(Duration timeDelta) {
    _timeSinceLastRefresh += timeDelta;
    if (_timeSinceLastRefresh >= refreshFrequency) {
      final newTree = Node.fromComponent(state!.component, oldNode: state);
      if (newTree != state) {
        state = newTree;
      }
      _timeSinceLastRefresh = Duration.zero;
    }
    WidgetsBinding.instance.addPostFrameCallback(_refresh);
  }
}
