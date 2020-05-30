import 'package:flutter/material.dart' hide Animation;
import 'package:flame/animation.dart';

import './sprite_widget.dart';

import 'dart:math';

class AnimationWidget extends StatefulWidget {
  final Animation animation;
  final bool center;
  final bool play;

  AnimationWidget({
    this.animation,
    this.play = true,
    this.center = false,
  }) : assert(animation.loaded(), 'Animation must be loaded');

  @override
  State createState() => _AnimationWidget();
}

class _AnimationWidget extends State<AnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double _lastUpdated;

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
        final now = DateTime.now().millisecond.toDouble();

        final dt = max(0, (now - _lastUpdated) / 1000).toDouble();
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
      _lastUpdated = DateTime.now().millisecond.toDouble();
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
    return SpriteWidget(
        sprite: widget.animation.getSprite(), center: widget.center);
  }
}
