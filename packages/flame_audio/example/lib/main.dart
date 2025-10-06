import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart' hide Animation;

void main() {
  runApp(GameWidget(game: AudioGame()));
}

/// This example game showcases three possible use cases:
///
/// 1. Use the static FlameAudio class to easily fire a sfx using the default
/// configs for the button tap.
/// 2. Uses a custom AudioPool for extremely efficient audio loading and pooling
/// for tapping elsewhere.
/// 3. Uses the Bgm utility for background music.
class AudioGame extends FlameGame with TapCallbacks {
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
  }

  Rect get button => Rect.fromLTWH(20, size.y - 300, size.x - 40, 200);

  Future<void> startBgmMusic() async {
    await FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('music/bg_music.ogg');
  }

  void fireOne() {
    FlameAudio.play('sfx/fire_1.mp3');
  }

  void fireTwo() {
    pool.start();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), black);

    text.render(
      canvas,
      '(click anywhere for 1)',
      Vector2(size.x / 2, 200),
      anchor: Anchor.topCenter,
    );

    canvas.drawRect(button, gray);

    text.render(
      canvas,
      'click here for 2',
      Vector2(size.x / 2, size.y - 200),
      anchor: Anchor.bottomCenter,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (button.containsPoint(event.canvasPosition)) {
      fireTwo();
    } else {
      fireOne();
    }
  }
}
