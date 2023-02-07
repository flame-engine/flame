import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      icon: Path()
        ..moveTo(-2.5, 5)
        ..lineTo(-2.5, -5)
        ..lineTo(6, 0)
        ..close(),
    );
  }
}
