import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentTreeProvider =
    StateNotifierProvider<ComponentTreeObserver, ComponentTreeState>((ref) {
      final gameState = ref.watch(gameControllerProvider);
      return ComponentTreeObserver(gameState.game as FlameGame?);
    });

@immutable
class ComponentTreeNode {
  const ComponentTreeNode._(this.component, this.children);

  factory ComponentTreeNode.fromComponent(Component component) {
    return ComponentTreeNode._(
      component,
      component.hasChildren
          ? component.children.map(ComponentTreeNode.fromComponent).toList()
          : null,
    );
  }

  final Component component;
  final List<ComponentTreeNode>? children;
  String get name => component.runtimeType.toString();
  bool get hasChildren => children?.isNotEmpty ?? false;

  @override
  bool operator ==(Object other) =>
      other is ComponentTreeNode &&
      component == other.component &&
      listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(component, children);
}

@immutable
class ComponentTreeState {
  ComponentTreeState(Component? rootComponent)
    : root = rootComponent == null
          ? null
          : ComponentTreeNode.fromComponent(rootComponent);

  final ComponentTreeNode? root;

  @override
  bool operator ==(Object other) =>
      other is ComponentTreeState && root == other.root;

  @override
  int get hashCode => root?.hashCode ?? 0;
}

class ComponentTreeObserver extends StateNotifier<ComponentTreeState> {
  ComponentTreeObserver(Component? rootComponent)
    : super(ComponentTreeState(rootComponent)) {
    if (rootComponent != null) {
      _refresh();
    }
  }

  static const Duration refreshFrequency = Duration(milliseconds: 300);

  void _refresh() {
    if (!mounted) {
      // The Future.delayed may complete after the observer was disposed.
      return;
    }
    final newState = ComponentTreeState(state.root!.component);
    if (newState != state) {
      state = newState;
    }
    Future.delayed(refreshFrequency, _refresh);
  }
}
