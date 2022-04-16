import 'dart:math';

import 'package:flutter/material.dart' hide Animation;

import '../../components.dart';
import 'sprite_painter.dart';

export '../sprite_animation.dart';

/// {@template flame.widgets.sprite_animation_widget}
/// A [StatelessWidget] that renders a [SpriteAnimation].
/// {@endtemplate}
class SpriteAnimationWidget extends StatelessWidget {
  /// {@macro flame.widgets.sprite_animation_widget}
  const SpriteAnimationWidget({
    required this.controller,
    this.anchor = Anchor.topLeft,
    Key? key,
  }) : super(key: key);

  /// The positioning [Anchor].
  final Anchor anchor;

  final SpriteAnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: SpritePainter(
            controller.animation.getSprite(),
            anchor,
          ),
        );
      },
    );
  }
}

class SpriteAnimationController extends AnimationController {
  SpriteAnimationController({
    required TickerProvider vsync,
    required this.animation,
  }) : super(vsync: vsync) {
    duration = Duration(seconds: animation.totalDuration().ceil());
  }

  final SpriteAnimation animation;

  double? _lastUpdated;

  @override
  void notifyListeners() {
    super.notifyListeners();

    final now = DateTime.now().millisecond.toDouble();
    final dt = max(0, (now - (_lastUpdated ?? 0)) / 1000).toDouble();
    animation.update(dt);
    _lastUpdated = now;
  }
}
