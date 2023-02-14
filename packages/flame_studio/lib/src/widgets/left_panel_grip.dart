import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/left_panel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftPanelGrip extends ConsumerWidget {
  const LeftPanelGrip({super.key});

  /// Tracks the initial coordinates of a drag event. This can be static
  /// because we support only one drag at a time.
  static double _delta = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelWidth = ref.watch(leftPanelWidthProvider);

    return Row(
      textDirection: ref.watch(textDirectionProvider),
      children: [
        Container(
          constraints: BoxConstraints.tightFor(width: panelWidth - 5.0),
        ),
        GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            _delta = panelWidth - details.globalPosition.dx;
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            final mutableWidth = ref.read(leftPanelWidthProvider.notifier);
            mutableWidth.setValue(_delta + details.globalPosition.dx);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Container(
              constraints: const BoxConstraints.tightFor(width: 10.0),
            ),
          ),
        ),
      ],
    );
  }
}
