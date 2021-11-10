import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final game = RiveExampleGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
    );
  }
}

class RiveExampleGame extends FlameGame with HasTappableComponents {
  @override
  Color backgroundColor() {
    return const Color(0xFFFFFFFF);
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final skillsArtboard =
        await loadArtboard(RiveFile.asset('assets/skills.riv'));
    add(SkillsAnimationComponent(skillsArtboard));
  }
}

class SkillsAnimationComponent extends RiveComponent with Tappable {
  SkillsAnimationComponent(Artboard artboard)
      : super(
          artboard: artboard,
          size: Vector2.all(550),
        );

  SMIInput<double>? _levelInput;

  @override
  Future<void>? onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "Designer's Test",
    );
    if (controller != null) {
      artboard.addController(controller);
      _levelInput = controller.findInput<double>('Level');
      _levelInput?.value = 0;
    }
    return super.onLoad();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final levelInput = _levelInput;
    if (levelInput == null) {
      return false;
    }
    levelInput.value = (levelInput.value + 1) % 3;
    return true;
  }
}

class Square extends PositionComponent with HasGameRef<RiveExampleGame> {
  late final Paint paint;

  Square(Vector2 position) {
    this.position.setFrom(position);
    size.setValues(100, 100);
    paint = PaintExtension.random(withAlpha: 0.9, base: 100);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), paint);
  }
}
