import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/src/effects/component_effect.dart';
import 'package:material_ui/material_ui.dart';

/// Change the color of a component over time.
///
/// Due to how this effect is implemented, and how Flutter's [ColorFilter]
/// class works, this effect can't be mixed with other [ColorEffect]s, when more
/// than one is added to the component, only the last one will have effect.
class ColorEffect(
  final Color color,
  super.controller, {
  double opacityFrom = 0,
  double opacityTo = 1,
  final String? paintId,
  super.onComplete,
  super.key,
}) extends ComponentEffect<HasPaint> {
  ColorFilter? _original;
  late final Tween<double> _tween;

  this
    : assert(
        opacityFrom >= 0 &&
            opacityFrom <= 1 &&
            opacityTo >= 0 &&
            opacityTo <= 1,
        'Opacity value should be between 0 and 1',
      ),
      _tween = Tween(begin: opacityFrom, end: opacityTo);

  @override
  Future<void> onMount() async {
    super.onMount();

    _original = target.getPaint(paintId).colorFilter;
  }

  @override
  void apply(double progress) {
    final currentColor = color.withValues(
      alpha: min(max(_tween.transform(progress), 0), 1),
    );
    target.tint(currentColor, paintId: paintId);
  }

  @override
  void reset() {
    super.reset();
    target.getPaint(paintId).colorFilter = _original;
  }
}
