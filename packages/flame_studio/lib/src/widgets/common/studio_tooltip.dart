import 'dart:async';

import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The tooltip that is currently shown, if any.
///
/// The studio doesn't have an [Overlay], so tooltips are requested through
/// this provider and drawn by the [TooltipLayer], which sits on top of the
/// whole studio.
final tooltipProvider = NotifierProvider<TooltipController, TooltipRequest?>(
  TooltipController.new,
);

/// A tooltip with [message], shown below the widget that is linked to [link].
///
/// It is aligned with the left edge of that widget, or with its right edge
/// when [alignRight] is true, to keep it inside of the window.
@immutable
class const TooltipRequest({
  required final String message,
  required final LayerLink link,
  final bool alignRight = false,
});

class TooltipController() extends Notifier<TooltipRequest?> {
  @override
  TooltipRequest? build() => null;

  // ignore: use_setters_to_change_properties
  void show(TooltipRequest request) => state = request;

  /// Hides the tooltip, if it is the one linked to [link].
  void hide(LayerLink link) {
    if (state?.link == link) {
      state = null;
    }
  }
}

/// Shows [message] in a tooltip when the pointer hovers over [child] for a
/// moment. The tooltip is hidden when the pointer leaves or presses [child].
class const StudioTooltip({
  required final String message,
  required final Widget child,
  super.key,
}) extends ConsumerStatefulWidget {
  static const Duration delay = Duration(milliseconds: 500);

  @override
  ConsumerState<StudioTooltip> createState() => _StudioTooltipState();
}

class _StudioTooltipState() extends ConsumerState<StudioTooltip> {
  final LayerLink _link = LayerLink();
  Timer? _timer;

  @override
  void dispose() {
    // The tooltip layer stops showing the tooltip once its link is gone.
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleShow() {
    _timer?.cancel();
    _timer = Timer(StudioTooltip.delay, _show);
  }

  void _show() {
    final box = context.findRenderObject();
    if (!mounted || box is! RenderBox || !box.attached) {
      return;
    }
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final windowWidth = MediaQuery.maybeSizeOf(context)?.width;
    ref
        .read(tooltipProvider.notifier)
        .show(
          TooltipRequest(
            message: widget.message,
            link: _link,
            alignRight: windowWidth != null && center.dx > windowWidth / 2,
          ),
        );
  }

  void _hide() {
    _timer?.cancel();
    ref.read(tooltipProvider.notifier).hide(_link);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _hide(),
        child: Listener(
          onPointerDown: (_) => _hide(),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Draws the tooltip requested through the [tooltipProvider].
///
/// It must cover the whole studio and be above everything else in it. It
/// doesn't take part in hit testing.
class const TooltipLayer({super.key}) extends ConsumerWidget {
  static const double maxWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(tooltipProvider);
    if (request == null) {
      return const SizedBox.shrink();
    }
    final theme = ref.watch(themeProvider);
    final alignment = request.alignRight
        ? (Alignment.bottomRight, Alignment.topRight)
        : (Alignment.bottomLeft, Alignment.topLeft);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: request.link,
              showWhenUnlinked: false,
              targetAnchor: alignment.$1,
              followerAnchor: alignment.$2,
              offset: const Offset(0, 4),
              child: Container(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.tooltipColor,
                  border: Border.all(color: theme.fieldBorderColor),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x80000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(request.message),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
