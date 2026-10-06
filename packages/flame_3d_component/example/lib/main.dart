import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_3d_component/flame_3d_component.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: ExampleGame()));
}

/// A 3D skeleton walking between two regular 2D Flame layers: a parallax
/// background behind it and an animated sprite in front of it.
class ExampleGame() extends FlameGame {
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
        text:
            'A flutter_scene model between two Flame layers, '
            'drag to rotate it',
        position: Vector2.all(16),
      ),
    );
  }
}

/// The 3D object. It fills the whole game area and renders with a transparent
/// background, so the parallax behind it stays visible. Dragging rotates the
/// model.
class Skeleton() extends Component3D with DragCallbacks {
  this
    : super(
        anchor: Anchor.center,
        // The model is about 2.2 units tall with its feet at the origin.
        camera: PerspectiveCamera(
          position: Vector3(0, 1.8, 5.2),
          target: Vector3(0, 1.0, 0),
        ),
      );

  /// The imported model is animated, and the animation owns the transform
  /// of the node it is bound to, so the rotation is applied to this parent.
  final Node pivot = Node();
  double _yaw = 0;
  double _pitch = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Model by Kay Lousberg, https://kaylousberg.itch.io/kaykit-skeletons
    final model = await Node.fromGlbAsset('assets/models/skeleton.glb');
    pivot.add(model);
    root.add(pivot);

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
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _yaw += event.localDelta.x * 0.01;
    _pitch = (_pitch + event.localDelta.y * 0.01).clamp(-0.5, 0.5);
    pivot.rotation =
        Quaternion.axisAngle(Vector3(0, 1, 0), _yaw) *
        Quaternion.axisAngle(Vector3(1, 0, 0), _pitch);
  }
}

/// A regular sprite animation walking back and forth across the model, in
/// front of it.
class Ember() extends SpriteAnimationComponent with HasGameRef {
  this
    : super(
        size: Vector2.all(96),
        anchor: Anchor.bottomCenter,
      );

  static const _secondsPerCrossing = 4.0;
  double _time = 0;

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Walk back and forth between the screen edges, always measured
    // against the current game size so a resize never pushes it off screen.
    final phase = (_time / _secondsPerCrossing) % 2;
    final progress = phase < 1 ? phase : 2 - phase;
    final gameSize = gameRef.size;
    final travel = (gameSize.x - size.x).clamp(0.0, double.infinity);
    position = Vector2(size.x / 2 + progress * travel, gameSize.y * 0.7);
  }
}
