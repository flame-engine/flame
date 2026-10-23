import 'package:flame/components.dart' show Component;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The components that are expanded in the Hierarchy.
///
/// This lives outside of the Hierarchy panel so that it survives switching
/// tabs, and so that other panels can reveal a component in the Hierarchy.
final hierarchyExpansionProvider =
    NotifierProvider<HierarchyExpansion, Set<Component>>(
      HierarchyExpansion.new,
    );

class HierarchyExpansion() extends Notifier<Set<Component>> {
  @override
  Set<Component> build() {
    final game = ref.watch(gameControllerProvider.select((s) => s.game));
    return {if (game case final Component root) root};
  }

  void toggle(Component component) {
    if (state.contains(component)) {
      state = {...state}..remove(component);
    } else {
      state = {...state, component};
    }
  }

  /// Expands all ancestors of [component], so that it becomes visible.
  void reveal(Component component) {
    final ancestors = component.ancestors().toList();
    if (!state.containsAll(ancestors)) {
      state = {...state, ...ancestors};
    }
  }
}
