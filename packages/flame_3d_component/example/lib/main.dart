import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_3d_component/flame_3d_component.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: ExampleGame()));
}

/// A 3D skeleton walking between two regular 2D Flame layers: a parallax
/// background behind it and an animated sprite in front of it.
class ExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('assets/images/parallax/bg.png'),
        ParallaxImageData('assets/images/parallax/mountain-far.png'),
        ParallaxImageData('assets/images/parallax/mountains.png'),
        ParallaxImageData('assets/images/parallax/trees.png'),
        ParallaxImageData('assets/images/parallax/foreground-trees.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
      filterQuality: FilterQuality.none,
    );
    camera.backdrop.add(parallax);

    world.add(Skeleton());

    camera.viewport.add(Ember());
    camera.viewport.add(
      TextComponent(
        text: 'A flutter_scene model between two Flame layers',
        position: Vector2.all(16),
      ),
    );
  }
}

/// The 3D object. It fills the whole game area and renders with a transparent
/// background, so the parallax behind it stays visible.
class Skeleton extends Component3D {
  Skeleton()
    : super(
        anchor: Anchor.center,
        // The model is about 2.2 units tall with its feet at the origin.
        camera: PerspectiveCamera(
          position: Vector3(0, 1.8, -5.2),
          target: Vector3(0, 1.0, 0),
        ),
      );

  late final Node model;
  double _turn = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Model by Kay Lousberg, https://kaylousberg.itch.io/kaykit-skeletons
    model = await Node.fromGlbAsset('assets/models/skeleton.glb');
    root.add(model);

    final walk = model.findAnimationByName('Walking_A');
    if (walk != null) {
      model.createAnimationClip(walk)
        ..loop = true
        ..play();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _turn += dt * 0.5;
    model.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), _turn);
  }
}

/// A regular sprite animation walking back and forth in front of the model.
class Ember extends SpriteAnimationComponent with HasGameRef {
  Ember()
    : super(
        size: Vector2.all(96),
        anchor: Anchor.bottomCenter,
      );

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'assets/images/ember.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
    add(
      MoveByEffect(
        Vector2(gameRef.size.x - size.x * 2, 0),
        EffectController(
          duration: 4,
          reverseDuration: 4,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(this.size.x, size.y - 16);
  }
}
