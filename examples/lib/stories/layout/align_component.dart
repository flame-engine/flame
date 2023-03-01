import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/layout.dart';

class AlignComponentExample extends FlameGame {
  static const String description = '''
    In this example the AlignComponent is used to arrange the circles
    so that there is one in the middle and 8 more surrounding it in
    the shape of a diamond.
    
    The arrangement will remain intact if you change the window size.
  ''';

  @override
  void onLoad() {
    addAll([
      AlignComponent(
        child: CircleComponent(
          radius: 40,
          children: [
            SizeEffect.by(
              Vector2.all(25),
              EffectController(
                infinite: true,
                duration: 0.75,
                reverseDuration: 0.5,
              ),
            ),
            AlignComponent(
              alignment: Anchor.topCenter,
              child: CircleComponent(
                radius: 10,
                anchor: Anchor.bottomCenter,
              ),
              keepChildAnchor: true,
            ),
            AlignComponent(
              alignment: Anchor.bottomCenter,
              child: CircleComponent(
                radius: 10,
                anchor: Anchor.topCenter,
              ),
              keepChildAnchor: true,
            ),
            AlignComponent(
              alignment: Anchor.centerLeft,
              child: CircleComponent(
                radius: 10,
                anchor: Anchor.centerRight,
              ),
              keepChildAnchor: true,
            ),
            AlignComponent(
              alignment: Anchor.centerRight,
              child: CircleComponent(
                radius: 10,
                anchor: Anchor.centerLeft,
              ),
              keepChildAnchor: true,
            ),
          ],
        ),
        alignment: Anchor.center,
      ),
      AlignComponent(
        child: CircleComponent(radius: 30),
        alignment: Anchor.topCenter,
      ),
      AlignComponent(
        child: CircleComponent(radius: 30),
        alignment: Anchor.bottomCenter,
      ),
      AlignComponent(
        child: CircleComponent(radius: 30),
        alignment: Anchor.centerLeft,
      ),
      AlignComponent(
        child: CircleComponent(radius: 30),
        alignment: Anchor.centerRight,
      ),
      AlignComponent(
        child: CircleComponent(radius: 10),
        alignment: const Anchor(0.25, 0.25),
      ),
      AlignComponent(
        child: CircleComponent(radius: 10),
        alignment: const Anchor(0.25, 0.75),
      ),
      AlignComponent(
        child: CircleComponent(radius: 10),
        alignment: const Anchor(0.75, 0.25),
      ),
      AlignComponent(
        child: CircleComponent(radius: 10),
        alignment: const Anchor(0.75, 0.75),
      ),
    ]);
  }
}
