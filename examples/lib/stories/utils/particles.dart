import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/timer.dart' as flame_timer;
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesGame extends BaseGame {
  /// Defines dimensions of the sample
  /// grid to be displayed on the screen,
  /// 5x5 in this particular case
  static const gridSize = 5.0;
  static const steps = 5;

  /// Miscellaneous values used
  /// by examples below
  final Random rnd = Random();
  final StepTween steppedTween = StepTween(begin: 0, end: 5);
  final trafficLight = TrafficLightComponent();
  final TextConfig fpsTextConfig = TextConfig(
    color: const Color(0xFFFFFFFF),
  );

  /// Defines the lifespan of all the particles in these examples
  final sceneDuration = const Duration(seconds: 1);

  Vector2 get cellSize => size / gridSize;
  Vector2 get halfCellSize => cellSize / 2;

  @override
  Future<void> onLoad() async {
    await images.load('zap.png');
    await images.load('boom.png');

    // Spawn new particles every second
    Timer.periodic(sceneDuration, (_) => spawnParticles());
  }

  /// Showcases various different uses of [Particle]
  /// and its derivatives
  void spawnParticles() {
    // Contains sample particles, in order by complexity
    // and amount of used features. Jump to source for more explanation on each
    final particles = <Particle>[
      circle(),
      smallWhiteCircle(),
      movingParticle(),
      randomMovingParticle(),
      alignedMovingParticles(),
      easedMovingParticle(),
      intervalMovingParticle(),
      computedParticle(),
      chainingBehaviors(),
      steppedComputedParticle(),
      reuseParticles(),
      imageParticle(),
      reuseImageParticle(),
      rotatingImage(),
      acceleratedParticles(),
      paintParticle(),
      spriteParticle(),
      animationParticle(),
      fireworkParticle(),
      componentParticle(),
    ];

    // Place all the [Particle] instances
    // defined above in a grid on the screen
    // as per defined grid parameters
    do {
      final particle = particles.removeLast();
      final col = particles.length % gridSize;
      final row = (particles.length ~/ gridSize).toDouble();
      final cellCenter = (cellSize..multiply(Vector2(col, row))) + halfCellSize;

      add(
        // Bind all the particles to a [Component] update
        // lifecycle from the [BaseGame].
        TranslatedParticle(
          lifespan: 1,
          offset: cellCenter.toOffset(),
          child: particle,
        ).asComponent(),
      );
    } while (particles.isNotEmpty);
  }

  /// Simple static circle, doesn't move or
  /// change any of its attributes
  Particle circle() {
    return CircleParticle(
      paint: Paint()..color = Colors.white10,
    );
  }

  /// This one will is a bit smaller,
  /// and a bit less transparent
  Particle smallWhiteCircle() {
    return CircleParticle(
      radius: 5.0,
      paint: Paint()..color = Colors.white,
    );
  }

  /// Particle which is moving from
  /// one predefined position to another one
  Particle movingParticle() {
    return MovingParticle(
      // This parameter is optional, will
      // default to [Offset.zero]
      from: const Offset(-20, -20),
      to: const Offset(20, 20),
      child: CircleParticle(paint: Paint()..color = Colors.amber),
    );
  }

  /// [Particle] which is moving to a random direction
  /// within each cell each time created
  Particle randomMovingParticle() {
    return MovingParticle(
      to: randomCellOffset(),
      child: CircleParticle(
        radius: 5 + rnd.nextDouble() * 5,
        paint: Paint()..color = Colors.red,
      ),
    );
  }

  /// Generates 5 particles, each moving
  /// symmetrically within grid cell
  Particle alignedMovingParticles() {
    return Particle.generate(
      count: 5,
      generator: (i) {
        final currentColumn = (cellSize.x / 5) * i - halfCellSize.x;
        return MovingParticle(
          from: Offset(currentColumn, -halfCellSize.y),
          to: Offset(currentColumn, halfCellSize.y),
          child: CircleParticle(
            radius: 2.0,
            paint: Paint()..color = Colors.blue,
          ),
        );
      },
    );
  }

  /// Burst of 5 particles each moving
  /// to a random direction within the cell
  Particle randomMovingParticles() {
    return Particle.generate(
      count: 5,
      generator: (i) => MovingParticle(
        to: randomCellOffset() * .5,
        child: CircleParticle(
          radius: 5 + rnd.nextDouble() * 5,
          paint: Paint()..color = Colors.deepOrange,
        ),
      ),
    );
  }

  /// Same example as above, but
  /// with easing, utilising [CurvedParticle] extension
  Particle easedMovingParticle() {
    return Particle.generate(
      count: 5,
      generator: (i) => MovingParticle(
        curve: Curves.easeOutQuad,
        to: randomCellOffset() * .5,
        child: CircleParticle(
          radius: 5 + rnd.nextDouble() * 5,
          paint: Paint()..color = Colors.deepPurple,
        ),
      ),
    );
  }

  /// Same example as above, but using awesome [Interval]
  /// curve, which "schedules" transition to happen between
  /// certain values of progress. In this example, circles will
  /// move from their initial to their final position
  /// when progress is changing from 0.2 to 0.6 respectively.
  Particle intervalMovingParticle() {
    return Particle.generate(
      count: 5,
      generator: (i) => MovingParticle(
        curve: const Interval(.2, .6, curve: Curves.easeInOutCubic),
        to: randomCellOffset() * .5,
        child: CircleParticle(
          radius: 5 + rnd.nextDouble() * 5,
          paint: Paint()..color = Colors.greenAccent,
        ),
      ),
    );
  }

  /// A [ComputedParticle] completely delegates all the rendering
  /// to an external function, hence It's very flexible, as you can implement
  /// any currently missing behavior with it.
  /// Also, it allows to optimize complex behaviors by avoiding nesting too
  /// many [Particle] together and having all the computations in place.
  Particle computedParticle() {
    return ComputedParticle(
      renderer: (canvas, particle) => canvas.drawCircle(
        Offset.zero,
        particle.progress * halfCellSize.x,
        Paint()
          ..color = Color.lerp(
            Colors.red,
            Colors.blue,
            particle.progress,
          )!,
      ),
    );
  }

  /// Using [ComputedParticle] to use custom tweening
  /// In reality, you would like to keep as much of renderer state
  /// defined outside and reused between each call
  Particle steppedComputedParticle() {
    return ComputedParticle(
      lifespan: 2,
      renderer: (canvas, particle) {
        const steps = 5;
        final steppedProgress =
            steppedTween.transform(particle.progress) / steps;

        canvas.drawCircle(
          Offset.zero,
          (1 - steppedProgress) * halfCellSize.x,
          Paint()
            ..color = Color.lerp(
              Colors.red,
              Colors.blue,
              steppedProgress,
            )!,
        );
      },
    );
  }

  /// Particle which is used in example below
  Particle? reusablePatricle;

  /// A burst of white circles which actually using a single circle
  /// as a form of optimization. Look for reusing parts of particle effects
  /// whenever possible, as there are limits which are relatively easy to reach.
  Particle reuseParticles() {
    reusablePatricle ??= circle();

    return Particle.generate(
      generator: (i) => MovingParticle(
        curve: Interval(rnd.nextDouble() * .1, rnd.nextDouble() * .8 + .1),
        to: randomCellOffset() * .5,
        child: reusablePatricle!,
      ),
    );
  }

  /// Simple static image particle which doesn't do much.
  /// Images are great examples of where assets should
  /// be reused across particles. See example below for more details.
  Particle imageParticle() {
    return ImageParticle(
      size: Vector2.all(24),
      image: images.fromCache('zap.png'),
    );
  }

  /// Particle which is used in example below
  Particle? reusableImageParticle;

  /// A single [imageParticle] is drawn 9 times
  /// in a grid within grid cell. Looks as 9 particles
  /// to user, saves us 8 particle objects.
  Particle reuseImageParticle() {
    const count = 9;
    const perLine = 3;
    const imageSize = 24.0;
    final colWidth = cellSize.x / perLine;
    final rowHeight = cellSize.y / perLine;

    reusableImageParticle ??= imageParticle();

    return Particle.generate(
      count: count,
      generator: (i) => TranslatedParticle(
        offset: Offset(
          (i % perLine) * colWidth - halfCellSize.x + imageSize,
          (i ~/ perLine) * rowHeight - halfCellSize.y + imageSize,
        ),
        child: reusableImageParticle!,
      ),
    );
  }

  /// [RotatingParticle] is a simple container which rotates
  /// a child particle passed to it.
  /// As you can see, we're reusing [imageParticle] from example above.
  /// Such a composability is one of the main implementation features.
  Particle rotatingImage({double initialAngle = 0}) {
    return RotatingParticle(from: initialAngle, child: imageParticle());
  }

  /// [AcceleratedParticle] is a very basic acceleration physics container,
  /// which could help implementing such behaviors as gravity, or adding
  /// some non-linearity to something like [MovingParticle]
  Particle acceleratedParticles() {
    return Particle.generate(
      generator: (i) => AcceleratedParticle(
        speed:
            Offset(rnd.nextDouble() * 600 - 300, -rnd.nextDouble() * 600) * .2,
        acceleration: const Offset(0, 200),
        child: rotatingImage(initialAngle: rnd.nextDouble() * pi),
      ),
    );
  }

  /// [PaintParticle] allows to perform basic composite operations
  /// by specifying custom [Paint].
  /// Be aware that it's very easy to get *really* bad performance
  /// misusing composites.
  Particle paintParticle() {
    final colors = [
      const Color(0xffff0000),
      const Color(0xff00ff00),
      const Color(0xff0000ff),
    ];
    final positions = [
      const Offset(-10, 10),
      const Offset(10, 10),
      const Offset(0, -14),
    ];

    return Particle.generate(
      count: 3,
      generator: (i) => PaintParticle(
        paint: Paint()..blendMode = BlendMode.difference,
        child: MovingParticle(
          curve: SineCurve(),
          from: positions[i],
          to: i == 0 ? positions.last : positions[i - 1],
          child: CircleParticle(
            radius: 20.0,
            paint: Paint()..color = colors[i],
          ),
        ),
      ),
    );
  }

  /// [SpriteParticle] allows easily embed
  /// Flame's [Sprite] into the effect.
  Particle spriteParticle() {
    return SpriteParticle(
      sprite: Sprite(images.fromCache('zap.png')),
      size: cellSize * .5,
    );
  }

  /// An [SpriteAnimationParticle] takes a Flame [SpriteAnimation]
  /// and plays it during the particle lifespan.
  Particle animationParticle() {
    return SpriteAnimationParticle(
      animation: getBoomAnimation(),
      size: Vector2(128, 128),
    );
  }

  /// [ComponentParticle] proxies particle lifecycle hooks
  /// to its child [Component]. In example below, [Component] is
  /// reused between particle effects and has internal behavior
  /// which is independent from the parent [Particle].
  Particle componentParticle() {
    return MovingParticle(
      from: (-halfCellSize * .2).toOffset(),
      to: (halfCellSize * .2).toOffset(),
      curve: SineCurve(),
      child: ComponentParticle(component: trafficLight),
    );
  }

  /// Not very realistic firework, yet it highlights
  /// use of [ComputedParticle] within other particles,
  /// mixing predefined and fully custom behavior.
  Particle fireworkParticle() {
    // A pallete to paint over the "sky"
    final paints = [
      Colors.amber,
      Colors.amberAccent,
      Colors.red,
      Colors.redAccent,
      Colors.yellow,
      Colors.yellowAccent,
      // Adds a nice "lense" tint
      // to overall effect
      Colors.blue,
    ].map((color) => Paint()..color = color).toList();

    return Particle.generate(
      generator: (i) {
        final initialSpeed = randomCellOffset();
        final deceleration = initialSpeed * -1;
        const gravity = Offset(0, 40);

        return AcceleratedParticle(
          speed: initialSpeed,
          acceleration: deceleration + gravity,
          child: ComputedParticle(renderer: (canvas, particle) {
            final paint = randomElement(paints);
            // Override the color to dynamically update opacity
            paint.color = paint.color.withOpacity(1 - particle.progress);

            canvas.drawCircle(
              Offset.zero,
              // Closer to the end of lifespan particles
              // will turn into larger glaring circles
              rnd.nextDouble() * particle.progress > .6
                  ? rnd.nextDouble() * (50 * particle.progress)
                  : 2 + (3 * particle.progress),
              paint,
            );
          }),
        );
      },
    );
  }

  /// [Particle] base class exposes a number
  /// of convenience wrappers to make positioning.
  ///
  /// Just remember that the less chaining and nesting - the
  /// better for performance!
  Particle chainingBehaviors() {
    final paint = Paint()..color = randomMaterialColor();
    final rect = ComputedParticle(
      renderer: (canvas, _) => canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 10, height: 10),
        paint,
      ),
    );

    final cellSizeOffset = cellSize.toOffset();
    final halfCellSizeOffset = halfCellSize.toOffset();

    return ComposedParticle(
      children: [
        rect
            .rotating(to: pi / 2)
            .moving(to: -cellSizeOffset)
            .scaled(2)
            .accelerated(acceleration: halfCellSizeOffset * 5)
            .translated(halfCellSizeOffset),
        rect
            .rotating(to: -pi)
            .moving(to: cellSizeOffset.scale(1, -1))
            .scaled(2)
            .translated(halfCellSizeOffset.scale(-1, 1))
            .accelerated(acceleration: halfCellSizeOffset.scale(-5, 5)),
      ],
    );
  }

  @override
  bool debugMode = true;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode) {
      fpsTextConfig.render(
        canvas,
        '${fps(120).toStringAsFixed(2)}fps',
        Vector2(0, size.y - 24),
      );
    }
  }

  /// Returns random [Offset] within a virtual
  /// grid cell
  Offset randomCellOffset() {
    return Offset(
      cellSize.x * rnd.nextDouble() - halfCellSize.x,
      cellSize.y * rnd.nextDouble() - halfCellSize.y,
    );
  }

  /// Returns random [Color] from primary swatches
  /// of material palette
  Color randomMaterialColor() {
    return Colors.primaries[rnd.nextInt(Colors.primaries.length)];
  }

  /// Returns a random element from a given list
  T randomElement<T>(List<T> list) {
    return list[rnd.nextInt(list.length)];
  }

  /// Sample "explosion" animation for [SpriteAnimationParticle] example
  SpriteAnimation getBoomAnimation() {
    const columns = 8;
    const rows = 8;
    const frames = columns * rows;
    final spriteImage = images.fromCache('boom.png');
    final spritesheet = SpriteSheet.fromColumnsAndRows(
      image: spriteImage,
      columns: columns,
      rows: rows,
    );
    final sprites = List<Sprite>.generate(frames, spritesheet.getSpriteById);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1);
  }
}

Future<BaseGame> loadGame() async {
  WidgetsFlutterBinding.ensureInitialized();

  return ParticlesGame();
}

/// A curve which maps sinus output (-1..1,0..pi)
/// to an oscillating (0..1..0,0..1), essentially "ease-in-out and back"
class SineCurve extends Curve {
  @override
  double transformInternal(double t) {
    return (sin(pi * (t * 2 - 1 / 2)) + 1) / 2;
  }
}

/// Sample for [ComponentParticle], changes its colors
/// each 2s of registered lifetime.
class TrafficLightComponent extends Component {
  final Rect rect = Rect.fromCenter(center: Offset.zero, height: 32, width: 32);
  final flame_timer.Timer colorChangeTimer = flame_timer.Timer(2, repeat: true);
  final colors = <Color>[
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  TrafficLightComponent() {
    colorChangeTimer.start();
  }

  @override
  void render(Canvas c) {
    c.drawRect(rect, Paint()..color = currentColor);
  }

  @override
  void update(double dt) {
    super.update(dt);
    colorChangeTimer.update(dt);
  }

  Color get currentColor {
    return colors[(colorChangeTimer.progress * colors.length).toInt()];
  }
}
