import 'dart:async';
import 'dart:math';

import 'package:flame/components/particle_component.dart';
import 'package:flame/components/particles/circle_particle.dart';
import 'package:flame/components/particles/moving_particle.dart';
import 'package:flame/components/particles/translated_particle.dart';
import 'package:flame/components/particles/computed_particle.dart';
import 'package:flame/components/particles/image_particle.dart';
import 'package:flame/components/particles/rotating_particle.dart';
import 'package:flame/components/particles/accelerated_particle.dart';
import 'package:flame/components/particles/paint_particle.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

void main() async {
  Size gameSize;
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Flame.util.initialDimensions().then((size) => gameSize = size),
    Flame.images.loadAll(const ['zap.png']),
  ]);

  final game = MyGame(gameSize);
  runApp(game.widget);
}

class MyGame extends BaseGame {
  /// Defines dimensions of the sample
  /// grid to be displayed on the screen,
  /// 5x5 in this particular case
  static const gridSize = 5;
  static const steps = 5;

  /// Miscellaneous values used
  /// by examples below
  final Random rnd = Random();
  final StepTween steppedTween = StepTween(begin: 0, end: 5);
  final TextConfig fpsTextConfig = const TextConfig(
    color: const Color(0xFFFFFFFF),
  );

  Offset cellSize;
  Offset halfCellSize;

  MyGame(Size screenSize) {
    size = screenSize;
    cellSize = Offset(size.width / gridSize, size.height / gridSize);
    halfCellSize = cellSize * .5;

    // Spawn new particles every second
    Timer.periodic(const Duration(seconds: 1), (_) => spawnParticles());
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
      steppedComputedParticle(),
      reuseParticles(),
      imageParticle(),
      reuseImageParticle(),
      rotatingImage(),
      acceleratedParticles(),
      paintParticle(),
    ];

    // Place all the [Particle] instances
    // defined above in a grid on the screen
    // as per defined grid parameters
    do {
      final particle = particles.removeLast();
      final col = particles.length % gridSize;
      final row = particles.length ~/ gridSize;
      final cellCenter =
          cellSize.scale(col.toDouble(), row.toDouble()) + (cellSize * .5);

      add(
        TranslatedParticle(
          lifespan: 1.0,
          offset: cellCenter,
          child: particle,
        ),
      );
    } while (particles.isNotEmpty);
  }

  /// Returns random [Offset] within a virtual
  /// grid cell
  Offset randomCellOffset() {
    return cellSize.scale(rnd.nextDouble(), rnd.nextDouble()) - halfCellSize;
  }

  /// Returns random [Color] from primary swatches
  /// of material palette
  Color randomMaterialColor() {
    return Colors.primaries[rnd.nextInt(Colors.primaries.length)];
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
        final currentColumn = (cellSize.dx / 5) * i - halfCellSize.dx;
        return MovingParticle(
          from: Offset(currentColumn, -halfCellSize.dy),
          to: Offset(currentColumn, halfCellSize.dy),
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

  /// Same example as above, but using awesome [Inverval]
  /// curve, which "schedules" transition to happen between
  /// certain values of progress. In this example, circles will
  /// move from their initial to their final position
  /// when progress is changing from 0.2 to 0.6 respectively.
  Particle intervalMovingParticle() {
    return Particle.generate(
      count: 5,
      generator: (i) => MovingParticle(
        curve: Interval(.2, .6, curve: Curves.easeInOutCubic),
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
      lifespan: 2,
      renderer: (canvas, particle) => canvas.drawCircle(
        Offset.zero,
        particle.progress * halfCellSize.dx,
        Paint()
          ..color = Color.lerp(
            Colors.red,
            Colors.blue,
            particle.progress,
          ),
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
          (1 - steppedProgress) * halfCellSize.dx,
          Paint()
            ..color = Color.lerp(
              Colors.red,
              Colors.blue,
              steppedProgress,
            ),
        );
      },
    );
  }

  /// Particle which is used in example below
  Particle reusablePatricle;

  /// A burst of white circles which actually using a single circle
  /// as a form of optimization. Look for reusing parts of particle effects
  /// whenever possible, as there are limits which are relatively easy to reach.
  Particle reuseParticles() {
    reusablePatricle ??= circle();

    return Particle.generate(
      count: 10,
      generator: (i) => MovingParticle(
        curve: Interval(rnd.nextDouble() * .1, rnd.nextDouble() * .8 + .1),
        to: randomCellOffset() * .5,
        child: reusablePatricle,
      ),
    );
  }

  /// Simple static image particle which doesn't do much.
  /// Images are great examples of where assets should
  /// be reused across particles. See example below for more details.
  Particle imageParticle() {
    return ImageParticle(
      size: const Size.square(24),
      image: Flame.images.loadedFiles['zap.png'],
    );
  }

  /// Particle which is used in example below
  Particle reusableImageParticle;

  /// A single [imageParticle] is drawn 9 times
  /// in a grid within grid cell. Looks as 9 particles
  /// to user, saves us 8 particle objects.
  Particle reuseImageParticle() {
    const count = 9;
    const perLine = 3;
    const imageSize = 24.0;
    final colWidth = cellSize.dx / perLine;
    final rowHeight = cellSize.dy / perLine;

    reusableImageParticle ??= imageParticle();

    return Particle.generate(
      count: count,
      generator: (i) => TranslatedParticle(
          offset: Offset(
            (i % perLine) * colWidth - halfCellSize.dx + imageSize,
            (i ~/ perLine) * rowHeight - halfCellSize.dy + imageSize,
          ),
          child: reusableImageParticle),
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
      count: 10,
      generator: (i) => AcceleratedParticle(
        speed:
            Offset(rnd.nextDouble() * 600 - 300, -rnd.nextDouble() * 600) * .4,
        acceleration: const Offset(0, 600),
        child: rotatingImage(initialAngle: rnd.nextDouble() * pi),
      ),
    );
  }

  /// [PaintParticle] allows to perform basic composite operations
  /// by specifying custom [Paint].
  /// Be aware that it's very easy to get *really* bad performance
  /// misusing composites.
  Particle paintParticle() {
    final List<Color> colors = [
      const Color(0xffff0000),
      const Color(0xff00ff00),
      const Color(0xff0000ff),
    ];
    final List<Offset> positions = [
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

  @override
  bool debugMode() => true;
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode()) {
      fpsTextConfig.render(canvas, '${fps(120).toStringAsFixed(2)}fps',
          Position(0, size.height - 24));
    }
  }
}

/// A curve which maps sinus output (-1..1,0..pi)
/// to an oscillating (0..1..0,0..1), essentially "ease-in-out and back"
class SineCurve extends Curve {
  @override
  double transformInternal(double t) {
    return (sin(pi * (t * 2 - 1 / 2)) + 1) / 2;
  }
}
