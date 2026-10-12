import 'package:flame/game.dart';
import 'package:flame_svg/svg_paths_animation.dart';
import 'package:flame_svg/svg_paths_animation_component.dart';

class SvgPathsAnimationExample() extends FlameGame {
  static const description = '''
    A grid of invaders, each an SvgPathsAnimationComponent whose frames are
    separate SVG files. Every frame lasts less than the time between two
    frames, and each loop ends with a pause: during these gaps the frames
    shown last remain. The invaders start at different times, and the
    hitboxes of the frames shown are rendered.
  ''';

  static const _columns = 5;
  static const _rows = 4;
  static const _invaderWidth = 60.0;
  static const _spacing = 30.0;

  @override
  Future<void> onLoad() async {
    final invader1 = await _load([
      'invader1',
      'invader1_feet_in',
      'invader1_left_arm_up',
      'invader1_left_arm_up_feet_in',
      'invader1',
      'invader1_feet_in',
      'invader1_right_arm_up',
      'invader1_right_arm_up_feet_in',
      'invader1_arms_up',
      'invader1_arms_up_feet_in',
    ]);
    final invader2 = await _load([
      'invader2',
      'invader2_feet_out',
      'invader2_left_arm_out',
      'invader2_left_arm_out_feet_out',
      'invader2',
      'invader2_feet_out',
      'invader2_right_arm_out',
      'invader2_right_arm_out_feet_out',
      'invader2_arms_out',
      'invader2_arms_out_feet_out',
    ]);

    const cell = _invaderWidth + _spacing;
    final origin =
        (size - Vector2(_columns * cell - _spacing, _rows * cell - _spacing)) /
        2;
    for (var row = 0; row < _rows; row++) {
      final animation = row.isEven ? invader1 : invader2;
      for (var column = 0; column < _columns; column++) {
        final area = animation.area;
        final component = SvgPathsAnimationComponent(
          // Each component has its own ticker for the shared animation.
          animation,
          renderHitboxes: true,
          size: Vector2(
            _invaderWidth,
            _invaderWidth * area.height / area.width,
          ),
          position: origin + Vector2(column * cell, row * cell),
        );
        // Start each invader at a different time of its loop.
        component.animationTicker.update((row * _columns + column) * 0.3);
        add(component);
      }
    }
  }

  /// Loads the [frames] of an invader: each one is shown for 0.3 seconds
  /// every 0.4 seconds, and each loop ends with a pause.
  static Future<SvgPathsAnimation> _load(List<String> frames) {
    return SvgPathsAnimation.load(
      [
        for (var i = 0; i < frames.length; i++)
          SvgPathsAnimationFrameData(
            fileName: 'assets/svgs/${frames[i]}.svg',
            start: i * 0.4,
            duration: 0.3,
          ),
      ],
      duration: frames.length * 0.4 + 0.8,
    );
  }
}
