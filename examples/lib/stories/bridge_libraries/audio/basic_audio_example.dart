import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart';

class BasicAudioExample extends FlameGame {
  static const String description = '''
    This example showcases the most basic Flame Audio functionalities.

    1. Use the static FlameAudio class to easily fire a sfx using the default
    configs for the button tap.
    2. Uses a custom AudioPool for extremely efficient audio loading and pooling
    for tapping elsewhere.
    3. Uses the Bgm utility for background music.
  ''';

  static final Paint black = BasicPalette.black.paint();
  static final Paint gray = const PaletteEntry(Color(0xFFCCCCCC)).paint();
  static final TextPaint topTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.lightBlue.color),
  );
  static final TextPaint bottomTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );

  late AudioPool pool;

  @override
  Future<void> onLoad() async {
    pool = await FlameAudio.createPool(
      'sfx/fire_2.mp3',
      minPlayers: 3,
      maxPlayers: 4,
    );
    startBgmMusic();
    final firstButtonSize = Vector2(size.x - 40, size.y * (4 / 5));
    final secondButtonSize = Vector2(size.x - 40, size.y / 5);
    addAll(
      [
        ButtonComponent(
          position: Vector2(20, 20),
          size: firstButtonSize,
          button: RectangleComponent(paint: black, size: firstButtonSize),
          onPressed: fireOne,
          children: [
            TextComponent(
              text: 'Click here for 1',
              textRenderer: topTextPaint,
              position: firstButtonSize / 2,
              anchor: Anchor.center,
              priority: 1,
            ),
          ],
        ),
        ButtonComponent(
          position: Vector2(20, size.y - size.y / 5),
          size: secondButtonSize,
          button: RectangleComponent(paint: gray, size: secondButtonSize),
          onPressed: fireTwo,
          children: [
            TextComponent(
              text: 'Click here for 2',
              textRenderer: bottomTextPaint,
              position: secondButtonSize / 2,
              anchor: Anchor.center,
              priority: 1,
            ),
          ],
        ),
      ],
    );
  }

  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music/bg_music.ogg');
  }

  void fireOne() {
    FlameAudio.play('sfx/fire_1.mp3');
  }

  void fireTwo() {
    pool.start();
  }

  @override
  void onRemove() {
    FlameAudio.bgm.dispose();
  }
}
