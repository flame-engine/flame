import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/src/effects/component_effect.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flutter/material.dart';

/// Change the color of a component over time.
///
/// Due to how this effect is implemented, and how Flutter's [ColorFilter]
/// class works, this effect can't be mixed with other [ColorEffect]s, when more
/// than one is added to the component, only the last one will have effect.
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
      // Currently there is a bug when opacity is 0 in the color filter.
      // "Expected a value of type 'SkDeletable', but got one of type 'Null'"
      // https://github.com/flutter/flutter/issues/89433
      max(_tween.transform(progress), 1 / 255),
    );
    target.tint(currentColor, paintId: paintId);
  }

  @override
  void reset() {
    super.reset();
    target.getPaint(paintId).colorFilter = _original;
  }
}
