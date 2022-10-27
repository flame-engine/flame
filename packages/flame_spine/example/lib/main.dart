import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:spine_flutter/spine_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final game = SpineExampleGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
    );
  }
}

class SpineExampleGame extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() {
    return const Color(0xFFE5E5E5);
  }

  @override
  Future<void> onLoad() async {
    final skeleton = await loadSkeleton('spineboy');
    final animations = await loadAnimations('spineboy');

    add(
      MyComponent(
        skeleton: skeleton,
        animations: animations,
        size: Vector2.all(300),
      ),
    );
  }
}

class MyComponent extends SpineComponent with TapCallbacks {
  MyComponent({
    required this.skeleton,
    required this.animations,
    required super.size,
  }) : super(renderer: SkeletonRender(skeleton: skeleton));

  final SkeletonAnimation skeleton;
  final Set<String> animations;

  bool isClicked = false;

  int _index = 0;

  @override
  Future<void>? onLoad() {
    renderer.animation = animations.elementAt(_index);

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
    renderer.animation = animations.elementAt(_index);
  }
}
