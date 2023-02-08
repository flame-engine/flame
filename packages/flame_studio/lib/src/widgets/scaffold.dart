import 'package:flame_studio/src/core/settings.dart';
import 'package:flame_studio/src/widgets/left_panel.dart';
import 'package:flame_studio/src/widgets/left_panel_grip.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar.dart';
import 'package:flutter/widgets.dart';

class Scaffold extends StatelessWidget {
  const Scaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    return Container(
      color: settings.backdropColor,
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
          const LeftPanelGrip(),
          const Toolbar(),
        ],
      ),
    );
  }
}
