import 'package:flutter/material.dart' hide Animation;
import 'package:flame/animation.dart';

import './flame_sprite_widget.dart';

import 'dart:math';

class FlameAnimationWidget extends StatefulWidget {
  final Animation animation;
  final bool center;
  final bool play;

  FlameAnimationWidget({
    this.animation,
    this.play = true,
    this.center = false,
  }) : assert(animation.loaded(), 'Animation must be loaded');

  @override
  State createState() => _FlameAnimationWidget();
}

class _FlameAnimationWidget extends State<FlameAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  int _lastUpdated;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play) {
      _initAnimation();
    } else {
      _pauseAnimation();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..addListener(() {
        final now = DateTime.now().millisecond;

        final dt = max(0, (now - _lastUpdated) / 1000);
        widget.animation.update(dt);

        setState(() {
          _lastUpdated = now;
        });
      });

    widget.animation.onCompleteAnimation = _pauseAnimation;

    if (widget.play) {
      _initAnimation();
    }
  }

  void _initAnimation() {
    setState(() {
      widget.animation.reset();
      _lastUpdated = DateTime.now().millisecond;
      _controller.repeat(
          // -/+ 60 fps
          period: const Duration(milliseconds: 16));
    });
  }

  void _pauseAnimation() {
    setState(() {
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(ctx) {
    return FlameSpriteWidget(
        sprite: widget.animation.getSprite(), center: widget.center);
  }
}
