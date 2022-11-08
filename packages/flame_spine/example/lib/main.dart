import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: SpineExampleGame()));
}

class SpineExampleGame extends FlameGame
    with HasTappableComponents, DoubleTapDetector {
  @override
  Color backgroundColor() {
    return const Color(0xFFE5E5E5);
  }

  @override
  void onDoubleTap() {
    paused = !paused;
    super.onDoubleTap();
  }

  @override
  Future<void> onLoad() async {
    final skeleton = await loadSkeleton('spineboy');
    final animations = await loadAnimations('spineboy');

    add(
      MyComponent(
        skeleton: skeleton,
        animations: animations,
        size: Vector2.all(500),
      ),
    );
  }
}

class MyComponent extends SpineComponent
    with TapCallbacks, HasGameRef<SpineExampleGame> {
  MyComponent({
    required this.skeleton,
    required this.animations,
    required super.size,
  }) : super(renderer: SkeletonRender(skeleton: skeleton));

  final SkeletonAnimation skeleton;
  final List<String> animations;

  bool isClicked = false;

  int _index = 0;

  @override
  Future<void>? onLoad() {
    renderer.animation = animations[_index];

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    renderer.playState = PlayState.paused;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    _index = (_index + 1) % (animations.length - 1);

    renderer.playState = PlayState.playing;
    renderer.animation = animations[_index];
  }
}
