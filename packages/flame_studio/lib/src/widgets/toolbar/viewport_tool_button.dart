import 'dart:math';

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
      // Arrows pointing in all four directions.
      ViewportTool.move =>
        Path()
          ..addRect(const Rect.fromLTRB(-3.5, -0.6, 3.5, 0.6))
          ..addRect(const Rect.fromLTRB(-0.6, -3.5, 0.6, 3.5))
          ..addPolygon(const [
            Offset(0, -5.5),
            Offset(-2, -3),
            Offset(2, -3),
          ], true)
          ..addPolygon(const [
            Offset(0, 5.5),
            Offset(-2, 3),
            Offset(2, 3),
          ], true)
          ..addPolygon(const [
            Offset(-5.5, 0),
            Offset(-3, -2),
            Offset(-3, 2),
          ], true)
          ..addPolygon(const [
            Offset(5.5, 0),
            Offset(3, -2),
            Offset(3, 2),
          ], true),
      ViewportTool.rotate => _rotateIcon(),
      // A frame with a filled corner.
      ViewportTool.scale =>
        Path()
          ..addRect(const Rect.fromLTRB(-5, -5, 5, -4))
          ..addRect(const Rect.fromLTRB(4, -5, 5, 5))
          ..addRect(const Rect.fromLTRB(-5, 4, 5, 5))
          ..addRect(const Rect.fromLTRB(-5, -5, -4, 5))
          ..addRect(const Rect.fromLTRB(-5, 0, 0, 5)),
    };
  }

  /// A circular arrow.
  static Path _rotateIcon() {
    const start = -0.8 * pi;
    const sweep = 1.5 * pi;
    const end = start + sweep;
    final arc = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 4.6),
        start,
        sweep,
        true,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 3.4),
        end,
        -sweep,
        false,
      )
      ..close();
    final tip = Offset(cos(end), sin(end)) * 4;
    final tangent = Offset(-sin(end), cos(end));
    final normal = Offset(cos(end), sin(end));
    return arc..addPolygon([
      tip + tangent * 2.2,
      tip + normal * 2.2,
      tip - normal * 2.2,
    ], true);
  }
}
