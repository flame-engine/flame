import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/flare/flare_actor_component.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_controls.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = MyGame();
  runApp(game.widget);
}

class MyGame extends BaseGame with TapDetector, DoubleTapDetector {
  final TextConfig fpsTextConfig = TextConfig(color: BasicPalette.white.color);

  final paint = Paint()..color = const Color(0xFFE5E5E5E5);
  final List<String> _animations = ['Wave', 'Dance'];
  int _currentAnimation = 0;
  MinionComponent minionComponent;
  MinionController minionController;

  bool loaded = false;

  MyGame() {
    minionController = MinionController();
    minionComponent = MinionComponent(minionController);
    minionComponent.x = 0;
    minionComponent.y = 0;
    add(BGComponent());
    add(minionComponent);
    minionComponent.playStand();
  }

  @override
  bool debugMode() => true;

  @override
  void onTap() {
    minionComponent.playJump();
  }

  @override
  void onDoubleTap() {
    cycleAnimation();
  }

  void cycleAnimation() {
    if (_currentAnimation == 1) {
      _currentAnimation = 0;
    } else {
      _currentAnimation++;
    }
    minionComponent.minionController.play(_animations[_currentAnimation]);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).toString(), Position(0, 10));
    }
  }
}

class MinionController extends FlareControls {}

class MinionComponent extends FlareActorComponent {
  MinionController minionController;

  MinionComponent(this.minionController)
      : super(
          'assets/Bob_Minion.flr',
          controller: minionController,
          width: 306,
          height: 228,
        );

  void playStand() {
    minionController.play("Stand");
  }

  void playDance() {
    minionController.play("Dance");
  }

  void playJump() {
    minionController.play("Jump");
  }

  void playWave() {
    minionController.play("Wave");
  }
}

class BGComponent extends Component with Resizable {
  @override
  void render(Canvas c) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    c.drawRect(rect, paint);
  }

  @override
  void update(double t) {}
}
