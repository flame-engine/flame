import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/material.dart';
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

class SpineExampleGame extends FlameGame with TapDetector {
  @override
  Color backgroundColor() {
    return const Color(0xFFE5E5E5);
  }

  late SkeletonRender renderer;
  late SkeletonAnimation skeleton;

  late Set<String> animations;

  @override
  void onTap() {
    print('tapped game');

    renderer = SkeletonRender(
      skeleton: skeleton,
      animation: animations.first,
    );
  }

  @override
  Future<void> onLoad() async {
    skeleton = await loadSkeleton('spineboy');
    animations = await loadAnimations('spineboy');

    renderer = SkeletonRender(
      skeleton: skeleton,
      animation: animations.last,
    );

    add(SpineComponent(renderer: renderer, size: Vector2.all(300)));
  }
}
