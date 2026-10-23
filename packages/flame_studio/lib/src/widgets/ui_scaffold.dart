import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flame_studio/src/widgets/dock/dock_layout.dart';
import 'package:flame_studio/src/widgets/dock/dock_panel.dart';
import 'package:flame_studio/src/widgets/studio_chrome.dart';
import 'package:flame_studio/src/widgets/toolbar/flame_studio_toolbar.dart';
import 'package:flame_studio/src/widgets/viewport/gizmo_overlay.dart';
import 'package:flame_studio/src/widgets/viewport/viewport_tool_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class const UiScaffold({required final Widget gameApp, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarHeight = ref.watch(toolbarHeightProvider);
    final leftWidth = ref.watch(
      dockProvider(DockSide.left).select((dock) => dock.width),
    );
    final rightWidth = ref.watch(
      dockProvider(DockSide.right).select((dock) => dock.width),
    );
    return Container(
      color: ref.watch(themeProvider).backdropColor,
      child: Stack(
        textDirection: ref.watch(textDirectionProvider),
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                leftWidth + 20,
                toolbarHeight + 20,
                rightWidth + 20,
                20,
              ),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  textDirection: ref.watch(textDirectionProvider),
                  children: [
                    gameApp,
                    const IgnorePointer(child: GizmoOverlay()),
                    const ViewportToolLayer(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: toolbarHeight,
            bottom: 0,
            child: const StudioChrome(child: DockPanel(DockSide.left)),
          ),
          Positioned(
            right: 0,
            top: toolbarHeight,
            bottom: 0,
            child: const StudioChrome(child: DockPanel(DockSide.right)),
          ),
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: StudioChrome(child: FlameStudioToolbar()),
          ),
          const Positioned.fill(child: StudioChrome(child: TooltipLayer())),
        ],
      ),
    );
  }
}
