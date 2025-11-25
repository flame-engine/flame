import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSpineFlutter();
  runApp(const GameWidget.controlled(gameFactory: SpineExample.new));
}

class SpineExample extends FlameGame with TapCallbacks {
  late final SpineComponent spineboy;

  final states = [
    'walk',
    'aim',
    'death',
    'hoverboard',
    'idle',
    'jump',
    'portal',
    'run',
    'shoot',
  ];

  int _stateIndex = 0;

  @override
  Future<void> onLoad() async {
    // Load the Spineboy atlas and skeleton data from asset files
    // and create a SpineComponent from them, scaled down and
    // centered on the screen
    spineboy = await SpineComponent.fromAssets(
      atlasFile: 'assets/spineboy.atlas',
      skeletonFile: 'assets/spineboy-pro.skel',
      scale: Vector2(0.4, 0.4),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );

    // Set the "walk" animation on track 0 in looping mode
    spineboy.animationState.setAnimation(0, 'walk', true);
    await add(spineboy);
  }

  @override
  void onTapDown(_) {
    _stateIndex = (_stateIndex + 1) % states.length;
    spineboy.animationState.setAnimation(0, states[_stateIndex], true);
  }

  @override
  void onDetach() {
    // Dispose the native resources that have been loaded for spineboy.
    spineboy.dispose();
  }
}
