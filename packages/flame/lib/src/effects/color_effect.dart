import 'package:flutter/material.dart';

import '../../components.dart';
import 'component_effect.dart';
import 'controllers/effect_controller.dart';

/// Change the color of a component over time.
///
/// This effect applies incremental changes to the component's color, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class ColorEffect extends ComponentEffect<HasPaint> {
  final String? paintId;
  final Color color;
  late final ColorFilter? _original;
  late final Tween<double> _tween;

  ColorEffect(
    this.color,
    Offset offset,
    EffectController controller, {
    this.paintId,
  })  : _tween = Tween(begin: offset.dx, end: offset.dy),
        super(controller);

  @override
  Future<void> onMount() async {
    super.onMount();

    _original = target.getPaint(paintId).colorFilter;
  }

  @override
  void apply(double progress) {
    final currentColor = color.withOpacity(
      _tween.transform(progress),
    );
    target.tint(currentColor, paintId: paintId);
    super.apply(progress);
  }

  @override
  void reset() {
    super.reset();
    target.getPaint(paintId).colorFilter = _original;
  }
}
