import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';

class LeftPanelGrip extends StatelessWidget {
  const LeftPanelGrip({super.key});

  /// Tracks the initial coordinates of a drag event. This can be static
  /// because we support only one drag at a time.
  static double _delta = 0;

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    final panelWidth = settings.leftPanelWidth;
    return Row(
      textDirection: settings.textDirection,
      children: [
        Container(
          constraints: BoxConstraints.tightFor(width: panelWidth - 5.0),
        ),
        GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            _delta = panelWidth - details.globalPosition.dx;
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            settings.leftPanelWidth = _delta + details.globalPosition.dx;
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
