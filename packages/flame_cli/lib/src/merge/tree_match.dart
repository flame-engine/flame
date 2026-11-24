import 'package:flame_cli/src/flame_cli_exception.dart';

/// A component in a tree that the `HotReloadConnector` of the game described,
/// where the [id] is its index in the depth first order of the tree.
class TreeNode({
  required final int id,
  required final int? parent,

  /// The position of the component among the children that its parent
  /// declared, or null when it was added at runtime.
  required final int? declarationIndex,
  required final String type,

  /// The hash code of the key of the component, which is equal for named
  /// keys with the same name.
  required final int? key,

  /// The identity hash code of the component, which is how references to it
  /// are recognized while the fields of other objects are read.
  required final int identity,

  /// A short description of the state of the component, such as its position,
  /// that tells declared siblings of the same type apart.
  required final String? hint,
});

/// A tree of components that was described by the `HotReloadConnector`.
class ComponentTree(final List<TreeNode> nodes) {
  late final Map<int, List<TreeNode>> _children = () {
    final children = <int, List<TreeNode>>{};
    for (final node in nodes) {
      final parent = node.parent;
      if (parent != null) {
        (children[parent] ??= []).add(node);
      }
    }
    return children;
  }();

  late final Map<int, int> _byIdentity = {
    for (final node in nodes) node.identity: node.id,
  };

  factory ComponentTree.fromJson(Map<String, dynamic> json) {
    final nodes = (json['nodes'] as List).cast<Map<String, dynamic>>();
    return ComponentTree([
      for (final (index, node) in nodes.indexed)
        TreeNode(
          id: index,
          parent: node['parent'] as int?,
          declarationIndex: node['declaration_index'] as int?,
          type: node['type'] as String,
          key: node['key'] as int?,
          identity: node['identity'] as int,
          hint: node['hint'] as String?,
        ),
    ]);
  }

  TreeNode get root => nodes.first;

  /// The children of [id] that its parent declared, in declaration order.
  List<TreeNode> declaredChildren(int id) {
    return [
      ...?_children[id]?.where((node) => node.declarationIndex != null),
    ]..sort((a, b) => a.declarationIndex!.compareTo(b.declarationIndex!));
  }

  /// The ids of [id] and all of its descendants.
  Iterable<int> subtree(int id) sync* {
    yield id;
    for (final child in _children[id] ?? const <TreeNode>[]) {
      yield* subtree(child.id);
    }
  }

  /// The id of the component with the identity hash code [identity].
  int? idOf(int identity) => _byIdentity[identity];

  /// A short name of the component [id] for messages, such as
  /// `World > Player #2`.
  String label(int id) {
    final names = <String>[];
    int? current = id;
    while (current != null) {
      final node = nodes[current];
      if (node.parent != null) {
        final index = node.declarationIndex;
        names.add(index == null ? node.type : '${node.type} #$index');
      }
      current = node.parent;
    }
    return names.isEmpty ? nodes[id].type : names.reversed.join(' > ');
  }
}

/// How the components of the trees of a merging reload correspond to each
/// other.
///
/// The old tree is the shadow that was built with the code before the reload,
/// the check tree is a second build of it to find values that aren't
/// deterministic, the new tree was built with the code after the reload, and
/// the live tree is the running game.
class TreeMatch({
  /// The components that are in the old tree and in the new tree, by the id
  /// in the old tree.
  required final Map<int, int> oldToNew,
  required final Map<int, int> oldToLive,
  required final Map<int, int> oldToCheck,

  /// The components that only the new tree has, which are moved to the live
  /// parent that is given with them.
  required final List<({int newId, int liveParent})> added,

  /// The live components that the new code doesn't declare anymore.
  required final List<int> removed,

  /// The live components whose declaration index changed, with the new one.
  required final List<({int liveId, int declarationIndex})> reindexed,
  required final List<String> warnings,
}) {
  late final Map<int, int> newToOld = {
    for (final entry in oldToNew.entries) entry.value: entry.key,
  };
  late final Map<int, int> liveToOld = {
    for (final entry in oldToLive.entries) entry.value: entry.key,
  };
  late final Map<int, int> checkToOld = {
    for (final entry in oldToCheck.entries) entry.value: entry.key,
  };
}

/// Matches the trees of a merging reload with each other, see [TreeMatch].
///
/// The old, check and live trees were built by the same code, so their
/// declared components are matched exactly by their declaration index. The
/// code changed between the old and the new tree, so those are aligned like
/// the lines of a text diff, see [alignChildren].
TreeMatch matchTrees({
  required ComponentTree old,
  required ComponentTree check,
  required ComponentTree updated,
  required ComponentTree live,
}) {
  final oldToNew = <int, int>{};
  final oldToLive = <int, int>{};
  final oldToCheck = <int, int>{};
  final added = <({int newId, int liveParent})>[];
  final removed = <int>[];
  final reindexed = <({int liveId, int declarationIndex})>[];
  final warnings = <String>[];

  TreeNode? sameDeclaration(
    ComponentTree tree,
    int? parent,
    TreeNode oldNode,
  ) {
    if (parent == null) {
      return null;
    }
    final node = tree
        .declaredChildren(parent)
        .where((node) => node.declarationIndex == oldNode.declarationIndex)
        .firstOrNull;
    if (node != null && node.type != oldNode.type) {
      warnings.add(
        '${tree.label(node.id)} is a ${node.type} where the code declares a '
        '${oldNode.type}, so it was skipped.',
      );
      return null;
    }
    return node;
  }

  void visit(int oldId, int newId, int? liveId, int? checkId) {
    oldToNew[oldId] = newId;
    if (liveId != null) {
      oldToLive[oldId] = liveId;
      final oldIndex = old.nodes[oldId].declarationIndex;
      final newIndex = updated.nodes[newId].declarationIndex;
      if (newIndex != null && newIndex != oldIndex) {
        reindexed.add((liveId: liveId, declarationIndex: newIndex));
      }
    }
    if (checkId != null) {
      oldToCheck[oldId] = checkId;
    }

    final alignment = alignChildren(
      old.declaredChildren(oldId),
      updated.declaredChildren(newId),
    );
    for (final (oldChild, newChild) in alignment.pairs) {
      visit(
        oldChild.id,
        newChild.id,
        sameDeclaration(live, liveId, oldChild)?.id,
        sameDeclaration(check, checkId, oldChild)?.id,
      );
    }
    for (final oldChild in alignment.removed) {
      final liveChild = sameDeclaration(live, liveId, oldChild);
      if (liveChild != null) {
        removed.add(liveChild.id);
      }
    }
    if (liveId != null) {
      for (final newChild in alignment.added) {
        added.add((newId: newChild.id, liveParent: liveId));
      }
    }
  }

  if (old.root.type != updated.root.type || old.root.type != live.root.type) {
    throw FlameCliException(
      'The game class changed from ${live.root.type} to '
      '${updated.root.type}, which needs a hot restart.',
    );
  }
  visit(old.root.id, updated.root.id, live.root.id, check.root.id);

  return TreeMatch(
    oldToNew: oldToNew,
    oldToLive: oldToLive,
    oldToCheck: oldToCheck,
    added: added,
    removed: removed,
    reindexed: reindexed,
    warnings: warnings,
  );
}

/// Aligns the declared children of a component in the old and the new tree.
///
/// Children with the same named key are paired first. The rest is aligned
/// like the lines of a text diff, as the longest common subsequence of their
/// types, where a pair that also has the same [TreeNode.hint] counts more.
/// That way a component that is inserted between others doesn't shift which
/// old component each of the following ones is paired with.
({
  List<(TreeNode, TreeNode)> pairs,
  List<TreeNode> removed,
  List<TreeNode> added,
})
alignChildren(List<TreeNode> oldChildren, List<TreeNode> newChildren) {
  final pairs = <(TreeNode, TreeNode)>[];
  final newByKey = <int, TreeNode>{
    for (final child in newChildren)
      if (child.key != null) child.key!: child,
  };
  final keyed = <TreeNode>{};
  final oldRest = <TreeNode>[];
  for (final child in oldChildren) {
    final match = child.key == null ? null : newByKey[child.key];
    if (match != null && match.type == child.type && keyed.add(match)) {
      pairs.add((child, match));
    } else {
      oldRest.add(child);
    }
  }
  final newRest = newChildren.where((child) => !keyed.contains(child)).toList();

  int score(TreeNode a, TreeNode b) {
    if (a.type != b.type) {
      return 0;
    }
    return a.hint != null && a.hint == b.hint ? 2 : 1;
  }

  final n = oldRest.length;
  final m = newRest.length;
  final table = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      final s = score(oldRest[i], newRest[j]);
      var best = table[i + 1][j] > table[i][j + 1]
          ? table[i + 1][j]
          : table[i][j + 1];
      if (s > 0 && table[i + 1][j + 1] + s > best) {
        best = table[i + 1][j + 1] + s;
      }
      table[i][j] = best;
    }
  }

  final removed = <TreeNode>[];
  final added = <TreeNode>[];
  var i = 0;
  var j = 0;
  while (i < n && j < m) {
    final s = score(oldRest[i], newRest[j]);
    if (s > 0 && table[i][j] == table[i + 1][j + 1] + s) {
      pairs.add((oldRest[i], newRest[j]));
      i++;
      j++;
    } else if (table[i + 1][j] >= table[i][j + 1]) {
      removed.add(oldRest[i]);
      i++;
    } else {
      added.add(newRest[j]);
      j++;
    }
  }
  removed.addAll(oldRest.skip(i));
  added.addAll(newRest.skip(j));
  return (pairs: pairs, removed: removed, added: added);
}
