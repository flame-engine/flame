import 'package:flame/components.dart';
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
        child: CircleComponent(radius: 40),
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
