import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flame_studio/src/widgets/left_panel.dart';
import 'package:flame_studio/src/widgets/toolbar.dart';
import 'package:flutter/widgets.dart';

class Scaffold extends StatelessWidget {
  const Scaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = FlameStudioSettings.of(context);
    return Container(
      color: const Color(0xFF484848),
      child: Stack(
        textDirection: settings.textDirection,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              settings.leftPanelWidth + 20,
              settings.toolbarHeight + 20,
              20,
              20,
            ),
            child: child,
          ),
          const LeftPanel(),
          const Toolbar(),
        ],
      ),
    );
  }
}
