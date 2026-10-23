import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Switches the game view to [tool], and shows whether it is in use.
class const ViewportToolButton(final ViewportTool tool, {super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool = ref.watch(viewportToolProvider);
    return ToolbarButton(
      icon: _icon(tool),
      toggled: currentTool == tool,
      onClick: () => ref.read(viewportToolProvider.notifier).use(tool),
    );
  }

  static Path _icon(ViewportTool tool) {
    return switch (tool) {
      // A mouse pointer.
      ViewportTool.interact =>
        Path()
          ..moveTo(-3, -5)
          ..lineTo(-3, 4)
          ..lineTo(-0.8, 1.8)
          ..lineTo(1.2, 5)
          ..lineTo(2.8, 4.2)
          ..lineTo(0.9, 1.1)
          ..lineTo(3.8, 1.1)
          ..close(),
      // A selection frame around a point.
      ViewportTool.select =>
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(const Rect.fromLTRB(-5, -4, 5, 4))
          ..addRect(const Rect.fromLTRB(-4, -3, 4, 3))
          ..addRect(const Rect.fromLTRB(-1.5, -1.5, 1.5, 1.5)),
    };
  }
}
