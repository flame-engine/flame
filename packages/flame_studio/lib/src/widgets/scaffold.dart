import 'package:flame_studio/src/core/settings.dart';
import 'package:flame_studio/src/widgets/left_panel.dart';
import 'package:flame_studio/src/widgets/left_panel_grip.dart';
import 'package:flame_studio/src/widgets/toolbar/flame_studio_toolbar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Scaffold extends ConsumerWidget {
  const Scaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = Settings.of(context);
    return Container(
      color: settings.backdropColor,
      child: Stack(
        textDirection: settings.textDirection,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              settings.leftPanelWidth + 20,
              ref.watch(toolbarHeightProvider) + 20,
              20,
              20,
            ),
            child: child,
          ),
          const LeftPanel(),
          const LeftPanelGrip(),
          const FlameStudioToolbar(),
        ],
      ),
    );
  }
}
