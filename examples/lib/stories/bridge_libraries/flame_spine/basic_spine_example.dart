import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_spine/flame_spine.dart';

class FlameSpineExample extends FlameGame with TapDetector {
  static const String description = '''
    This example shows how to load a Spine animation. Tap on the screen to try
    different states of the animation.
  ''';

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
    await initSpineFlutter();
    // Load the Spineboy atlas and skeleton data from asset files
    // and create a SpineComponent from them, scaled down and
    // centered on the screen
    spineboy = await SpineComponent.fromAssets(
      atlasFile: 'assets/spine/spineboy.atlas',
      skeletonFile: 'assets/spine/spineboy-pro.skel',
      scale: Vector2(0.4, 0.4),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );

    // Set the "walk" animation on track 0 in looping mode
    spineboy.animationState.setAnimationByName(0, 'walk', true);
    await add(spineboy);
  }

  @override
  void onTap() {
    _stateIndex = (_stateIndex + 1) % states.length;
    spineboy.animationState.setAnimationByName(0, states[_stateIndex], true);
  }

  @override
  void onDetach() {
    // Dispose the native resources that have been loaded for spineboy.
    spineboy.dispose();
  }
}
