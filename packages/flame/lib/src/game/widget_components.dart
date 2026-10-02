import 'package:flame/src/components/widget_component.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Parent data for the children of [GameRenderBox], linking each child render
/// box to the [WidgetComponent] that hosts it.
class WidgetComponentParentData() extends ContainerBoxParentData<RenderBox> {
  WidgetComponent? component;

  /// The transform from the child's coordinates to the local coordinates of
  /// the [GameRenderBox], as of the last time the child was painted, or null
  /// when the child was not painted during the last paint.
  Matrix4? paintTransform;

  /// Whether the child has been painted during the current paint.
  bool paintedThisFrame = false;
}

/// Wraps the widget of a [WidgetComponent] so that the [GameRenderBox] knows
/// which component a child render box belongs to.
@internal
class const WidgetComponentParentDataWidget({
  required final WidgetComponent component,
  required super.child,
  super.key,
}) extends ParentDataWidget<WidgetComponentParentData> {
  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as WidgetComponentParentData;
    if (parentData.component != component) {
      parentData.component = component;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RenderGameWidget;
}

/// Hosts the widget of a [WidgetComponent] in the Flutter tree.
///
/// Rebuilds the hosted subtree when the component's widget changes, without
/// rebuilding the whole `GameWidget`, and excludes the subtree from focus and
/// semantics while the component is not being painted.
@internal
class const WidgetComponentHost({
  required final WidgetComponent component,
  super.key,
}) extends StatefulWidget {
  @override
  State<WidgetComponentHost> createState() => _WidgetComponentHostState();
}

class _WidgetComponentHostState() extends State<WidgetComponentHost> {
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.component.hostListenable.addListener(_onComponentChanged);
  }

  @override
  void didUpdateWidget(WidgetComponentHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component != widget.component) {
      oldWidget.component.hostListenable.removeListener(_onComponentChanged);
      widget.component.hostListenable.addListener(_onComponentChanged);
    }
  }

  @override
  void dispose() {
    widget.component.hostListenable.removeListener(_onComponentChanged);
    super.dispose();
  }

  void _onComponentChanged() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      if (_rebuildScheduled) {
        return;
      }
      _rebuildScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _rebuildScheduled = false;
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    return WidgetComponentParentDataWidget(
      component: component,
      child: ExcludeFocus(
        excluding: !component.isPainted,
        child: ExcludeSemantics(
          excluding: !component.isPainted,
          child: component.widget,
        ),
      ),
    );
  }
}
