import 'package:flame_studio/src/widgets/panels/hierarchy_view.dart';
import 'package:flame_studio/src/widgets/panels/inspector_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DockSide() {
  left,
  right,
}

/// A tab that can be shown inside of a dock, such as the Hierarchy.
@immutable
class const DockTab({
  required final String title,
  required final String tooltip,
  required final WidgetBuilder builder,
});

/// The tabs shown in each dock, in order.
final dockTabsProvider = Provider.family<List<DockTab>, DockSide>(
  (ref, side) => switch (side) {
    DockSide.left => [
      DockTab(
        title: 'Hierarchy',
        tooltip: 'The tree of components in the game',
        builder: (_) => const HierarchyView(),
      ),
    ],
    DockSide.right => [
      DockTab(
        title: 'Inspector',
        tooltip: 'The properties of the selected component',
        builder: (_) => const InspectorView(),
      ),
    ],
  },
);

final dockProvider =
    NotifierProvider.family<DockController, DockState, DockSide>(
      DockController.new,
    );

@immutable
class const DockState({required final double width, final int activeTab = 0}) {
  DockState copyWith({double? width, int? activeTab}) {
    return DockState(
      width: width ?? this.width,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DockState &&
      width == other.width &&
      activeTab == other.activeTab;

  @override
  int get hashCode => Object.hash(width, activeTab);
}

class DockController(final DockSide side) extends Notifier<DockState> {
  static const minWidth = 200.0;
  static const maxWidth = 500.0;

  @override
  DockState build() {
    return DockState(width: side == DockSide.left ? 260.0 : 300.0);
  }

  void setWidth(double value) {
    state = state.copyWith(width: value.clamp(minWidth, maxWidth));
  }

  void selectTab(int index) {
    state = state.copyWith(activeTab: index);
  }
}
