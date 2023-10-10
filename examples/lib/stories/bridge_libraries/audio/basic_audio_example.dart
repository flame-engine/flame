import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class BasicAudioExample extends FlameGame {
  static const String description = '''
    This example showcases the most basic Flame Audio functionalities.

    1. Use the static FlameAudio class to easily fire a sfx using the default
    configs for the button tap.
    2. Uses a custom AudioPool for extremely efficient audio loading and pooling
    for tapping elsewhere.
    3. Uses the Bgm utility for background music.
  ''';

  BasicAudioExample() : super(world: BasicAudioWorld());
}

class BasicAudioWorld extends World with HasGameReference {
  static final Paint black = BasicPalette.black.paint();
  static final Paint gray = const PaletteEntry(Color(0xFFCCCCCC)).paint();
  static final TextPaint text = TextPaint(
    style: TextStyle(color: BasicPalette.white.color),
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
    addAll(
      [
        ButtonComponent(
          position: Vector2(20, 20),
          size: Vector2(game.size.x - 40, game.size.y * (4 / 5)),
          button: RectangleComponent(paint: black),
          onPressed: fireOne,
          children: [
            TextComponent(
              text: 'Click here for 1',
              textRenderer: text,
              position: Vector2(0, 0),
            ),
          ],
        ),
        ButtonComponent(
          position: Vector2(20, game.size.y - game.size.y / 5),
          size: Vector2(game.size.x - 40, game.size.y / 5),
          button: RectangleComponent(paint: gray),
          onPressed: fireTwo,
          children: [
            TextComponent(
              text: 'Click here for 2',
              textRenderer: text,
              position: Vector2(0, 0),
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
