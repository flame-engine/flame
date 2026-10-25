import 'dart:async';

import 'package:flame/components.dart' show Component;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentTreeProvider =
    NotifierProvider<ComponentTreeObserver, ComponentTreeState>(
      ComponentTreeObserver.new,
    );

@immutable
class const ComponentTreeNode._(
  final Component component,
  final List<ComponentTreeNode>? children,
) {
  factory ComponentTreeNode.fromComponent(Component component) {
    return ComponentTreeNode._(
      component,
      component.hasChildren
          ? component.children.map(ComponentTreeNode.fromComponent).toList()
          : null,
    );
  }

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
// ignore: prefer_const_constructors_in_immutables
class ComponentTreeState(Component? rootComponent) {
  final ComponentTreeNode? root = rootComponent == null
      ? null
      : ComponentTreeNode.fromComponent(rootComponent);

  @override
  bool operator ==(Object other) =>
      other is ComponentTreeState && root == other.root;

  @override
  int get hashCode => root?.hashCode ?? 0;
}

/// Periodically takes a snapshot of the component tree of the current game.
///
/// Listeners are only notified when the structure of the tree changes.
class ComponentTreeObserver() extends Notifier<ComponentTreeState> {
  static const Duration refreshFrequency = Duration(milliseconds: 300);

  @override
  ComponentTreeState build() {
    final game = ref.watch(gameControllerProvider.select((s) => s.game));
    final root = switch (game) {
      final Component component => component,
      _ => null,
    };
    if (root != null) {
      final timer = Timer.periodic(
        refreshFrequency,
        (_) => state = ComponentTreeState(root),
      );
      ref.onDispose(timer.cancel);
    }
    return ComponentTreeState(root);
  }
}
