import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    final width = settings.leftPanelWidth;

    return Container(
      constraints: BoxConstraints.tightFor(width: width),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0xA1000000),
            offset: Offset(2, 0),
          ),
        ],
        color: Color(0xFF383838),
      ),
    );
  }
}
