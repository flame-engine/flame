import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flame_studio/src/widgets/dock/dock_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A resizable panel on one [side] of the studio, showing one of its tabs at
/// a time.
class const DockPanel(final DockSide side, {super.key}) extends ConsumerWidget {
  static const double _gripWidth = 6.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final dock = ref.watch(dockProvider(side));
    final tabs = ref.watch(dockTabsProvider(side));
    final activeTab = dock.activeTab.clamp(0, tabs.length - 1);
    final isLeft = side == DockSide.left;

    return Container(
      constraints: BoxConstraints.tightFor(width: dock.width),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: const Color(0xA1000000),
            offset: Offset(isLeft ? 2 : -2, 0),
          ),
        ],
        color: theme.panelColor,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TabBar(side, tabs, activeTab),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(tabs[activeTab].title),
                  child: Builder(builder: tabs[activeTab].builder),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? null : 0,
            right: isLeft ? 0 : null,
            width: _gripWidth,
            child: _DockGrip(side),
          ),
        ],
      ),
    );
  }
}

class const _TabBar(
  final DockSide side,
  final List<DockTab> tabs,
  final int activeTab,
) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Container(
      height: theme.tabBarHeight,
      color: theme.tabBarColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tabs.length; i++)
            _Tab(
              tabs[i],
              isActive: i == activeTab,
              onTap: () => ref.read(dockProvider(side).notifier).selectTab(i),
            ),
        ],
      ),
    );
  }
}

class const _Tab(
  final DockTab tab, {
  required final bool isActive,
  required final VoidCallback onTap,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return StudioTooltip(
      message: tab.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: isActive
                ? BoxDecoration(
                    color: theme.panelColor,
                    border: Border(
                      top: BorderSide(color: theme.accentColor, width: 2),
                    ),
                  )
                : null,
            child: Text(
              tab.title,
              style: TextStyle(
                color: isActive ? theme.textColor : theme.dimTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The handle on the inner edge of a dock, used to resize it.
class const _DockGrip(final DockSide side) extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DockGrip> createState() => _DockGripState();
}

class _DockGripState() extends ConsumerState<_DockGrip> {
  double _startWidth = 0;
  double _startX = 0;

  @override
  Widget build(BuildContext context) {
    final side = widget.side;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          _startWidth = ref.read(dockProvider(side)).width;
          _startX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          final delta = details.globalPosition.dx - _startX;
          ref
              .read(dockProvider(side).notifier)
              .setWidth(_startWidth + (side == DockSide.left ? delta : -delta));
        },
      ),
    );
  }
}
