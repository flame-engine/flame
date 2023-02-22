import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/left_panel.dart';
import 'package:flame_studio/src/widgets/left_panel_grip.dart';
import 'package:flame_studio/src/widgets/toolbar/flame_studio_toolbar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UiScaffold extends ConsumerWidget {
  const UiScaffold({required this.gameApp, super.key});

  final Widget gameApp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarHeight = ref.watch(toolbarHeightProvider);
    return Container(
      color: ref.watch(themeProvider).backdropColor,
      child: Stack(
        textDirection: ref.watch(textDirectionProvider),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              ref.watch(leftPanelWidthProvider) + 20,
              toolbarHeight + 20,
              20,
              20,
            ),
            child: ClipRect(child: gameApp),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, toolbarHeight, 0, 0),
            child: const LeftPanel(),
          ),
          const LeftPanelGrip(),
          const FlameStudioToolbar(),
        ],
      ),
    );
  }
}
