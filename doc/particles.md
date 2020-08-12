# Particles

Flame offers a basic, yet robust and extendable particle system. The core concept of this system is the `Particle` class, which is very similar in its behavior to the `ParticleComponent`.

The most basic usage of `Particle` with `BaseGame` would look as following:

```dart
import 'package:flame/components/particle_component.dart';

// ... 

game.add(
    // Wrapping a [Particle] with [ParticleComponent]
    // which maps [Component] lifecycle hooks to [Particle] ones
    // and embeds a trigger for destroying the component.
    ParticleComponent(
        particle: CircleParticle()
    )
);
```

When using `Particle` with custom `Game` implementation, please ensure that `Particle` `update` and `render` lifecycle hooks are called during each game loop frame.

Main approaches to implement desired particle effects:
* Composition of existing behaviors
* Use behavior chaining (just a syntactic sugar of the first one)
* Using `ComputedParticle`

Composition works in a similar fashion to those of Flutter widgets by defining the effect from top to bottom. Chaining allows to express same composition trees more fluently by defining behaviors from bottom to top. Computed particles in their turn fully delegate implementation of the behavior to your code. Any of the approaches could be used in conjunction with existing behaviors where needed.

Below you can find an example of a effect showing a burst of circles, accelerating from `(0, 0)` to a random directions using all three approaches defined above.
```dart
Random rnd = Random();
Function randomOffset = () => Offset(
    rnd.nextDouble() * 200 - 100, 
    rnd.nextDouble() * 200 - 100,
);

// Composition
// Defining particle effect as set of nested
// behaviors from top to bottom, one within another: 
// ParticleComponent 
//   > ComposedParticle 
//     > AcceleratedParticle 
//       > CircleParticle
game.add(
    ParticleComponent(
        particle: Particle.generate(
            count: 10,
            generator: (i) => AcceleratedParticle(
                acceleration: randomOffset(),
                child: CircleParticle(
                    paint: Paint()..color = Colors.red
                )
            )
        )
    )    
);

// Chaining
// Expresses same behavior as above, but with more fluent API.
// Only [Particles] with [SingleChildParticle] mixin can be used as chainable behaviors.
game.add(
    Particle
        .generate(
            count: 10,
            generator: (i) => CircleParticle(paint: Paint()..color = Colors.red)
                .accelerating(randomOffset())
        )
        .asComponent()
);

// Computed Particle
// All the behavior is defined explicitly. Offers greater flexibility
// compared to built-in behaviors.
game.add(
    Particle
        .generate(
            count: 10,
            generator: (i) {
                final position = Offset.zero;
                final speed = Offset.zero;
                final acceleration = randomOffset();
                final paint = Paint()..color = Colors.red;

                return  ComputedParticle(
                    renderer: (canvas, _) {
                        speed += acceleration;
                        position += speed;
                        canvas.drawCircle(position, 10, paint);
                    }
                );
            }
        )
        .asComponent()
)
```

You can find more examples of using different built-int particles in various combinations [here](/doc/examples/particles/lib/main.dart).

## Lifecycle

Behavior common to all `Particle`s is that all of them accept `lifespan` parameter. This value is used to make `ParticleComponent` self-destroy, once its internal `Particle` has reached the end of its life. Time within the `Particle` itself is tracked using the Flame `Timer`. It could be configured with `double`, representing seconds (with microsecond precision) by passing it into the corresponding `Particle` constructor. 

```dart
Particle(lifespan: .2); // will live for 200ms
Particle(lifespan: 4); // will live for 4s
```

It is also possible to reset `Particle` lifespan by using `setLifespan` method, which accepts a `double` of seconds. 

```dart
final particle = Particle(lifespan: 2);

// ... at some point of time later
particle.setLifespan(2) // will live for another 2s from this moment
```

During its lifetime, `Particle` tracks the time it was alive and exposes it with a `progress` getter, which is spanning between 0.0 to 1.0. Its value could be used in a similar fashion as `value` of `AnimationController` in Flutter.

```dart
final duration = const Duration(seconds: 2);
final particle = Particle(lifespan: duration.inMicroseconds / Durations.microsecondsPerSecond);

game.add(ParticleComponent(particle: particle));

// Will print values from 0 to 1 with step of .1: 0, 0.1, 0.2 ... 0.9, 1.0
Timer.periodic(duration * .1, () => print(particle.progress));
```
The lifespan is passed down to all the descendants of a given `Particle`, if it supports any of the nesting behaviors.

## Built-in particles

Flame ships with a few built-in `Particle` behaviors:
* The `TranslatedParticle`, translates its `child` by given `Offset`
* The `MovingParticle`, moves its `child` between two predefined `Offset`, supports `Curve`
* The `AcceleratedParticle`, allows basic physics based effects, like gravitation or speed dampening
* The `CircleParticle`, renders circles of all shapes and sizes
* The `SpriteParticle`, renders Flame `Sprite` within a `Particle` effect
* The `ImageParticle`, renders *dart:ui* `Image` within a `Particle` effect
* The `ComponentParticle`, renders Flame `Component` within a `Particle` effect
* The `FlareParticle`, renders Flare animation within a `Particle` effect

More examples of using these behaviors together are available [here](/doc/examples/particles/lib/main.dart). All the implementations are available in [particles](/lib/particles) folder in the Flame source.

## Translated Particle

Simply translates underlying `Particle` to a specified `Offset` within the rendering `Canvas`.
Does not change or alter its position, consider using `MovingParticle` or `AcceleratedParticle` where change of position is required.
Same effect could be achieved by translating the `Canvas` layer.

```dart
game.add(
    ParticleComponent(
        particle: TranslatedParticle(
            // Will translate child Particle effect to
            // the center of game canvas
            offset: game.size.center(Offset.zero),
            child: Particle(),
        )
    )
);
```

## Moving Particle

Moves child `Particle` between `from` and `to` `Offset`s during its lifespan. Supports `Curve` via `CurvedParticle`.

```dart
game.add(
    ParticleComponent(
        particle: MovingParticle(
            // Will move from corner to corner of the
            // game canvas
            from: game.size.topLeft(Offset.zero),
            to: game.size.bottomRight(Offset.zero),
            child: Particle(),
        )
    )
);
```

## Accelerated Particle

A basic physics particle which allows you to specify its initial `position`, `speed` and `acceleration` and let the `update` cycle do the rest. All three are specified as `Offset`s, 
which you can think of as vectors. It works especially well for physics-based "bursts", but it is not limited to that.
Unit of the `Offset` value is _logical px/s_. So a speed of `Offset(0, 100)` will move a child `Particle` by 100 logical pixels of the device every second of game time.

```dart
final rnd = Random();
game.add(
    ParticleComponent(
        particle: AcceleratedParticle(
            // Will fire off in the center of game canvas
            position: game.size.center(Offset.zero),
            // With random initial speed of Offset(-100..100, 0..-100)
            speed: Offset(rnd.nextDouble() * 200 - 100, -rnd.nextDouble() * 100),
            // Accelerating downwards, simulating "gravity"
            speed: Offset(0, 100),
            child: Particle(),
        )
    )
);
```

## Circle Particle

A `Particle` which renders circle with given `Paint` at the zero offset of passed `Canvas`. Use in conjunction with `TranslatedParticle`, `MovingParticle` or `AcceleratedParticle` 
in order to achieve desired positioning.

```dart
game.add(
    ParticleComponent(
        particle: CircleParticle(
            radius: game.size.width / 2,
            paint: Paint()..color = Colors.red.withOpacity(.5),
        )
    )
);
```

## Sprite Particle
Allows you to embed Flame's `Sprite` into your particle effects. Useful when consuming graphics for the effect from `SpriteSheet`.
```dart
game.add(
    ParticleComponent(
        particle: SpriteParticle(
          sprite: Sprite('sprite.png'),
          size: Position(64, 64),
        )
    )
);
```

## Image Particle
Renders given `dart:ui` image within the particle tree. 
```dart
// During game initialisation
await Flame.images.loadAll(const [
    'image.png'
]);

// ...

// Somewhere during the game loop
game.add(
    ParticleComponent(
        particle: ImageParticle(
          size: const Size.square(24),
          image: Flame.images.loadedFiles['image.png'],
        );
    )
);
```

## Animation Particle
A `Particle` which embeds a Flame `Animation`. By default, aligns `Animation`s `stepTime` so that it's fully played during the `Particle` lifespan. It's possible to override this behavior with `alignAnimationTime` parameter.

```dart
final spritesheet = SpriteSheet(
  imageName: 'spritesheet.png',
  textureWidth: 16,
  textureHeight: 16,
  columns: 10,
  rows: 2
);

game.add(
    ParticleComponent(
        particle: AnimationParticle(
          animation: spritesheet.createAnimation(0, stepTime: 0.1),
        );
    )
);
```

## Component Particle
This `Particle` allows you to embed a Flame `Component` within the particle effects. The `Component` could have its own `update` lifecycle and
could be reused across different effect trees. If the only thing you need is to add some dynamics to an instance of a certain `Component`, 
please consider adding it to the `game` directly, without the `Particle` in the middle.

```dart
var longLivingRect = RectComponent();

game.add(
    ParticleComponent(
        particle: ComponentParticle(
          component: longLivingRect
        );
    )
);

class RectComponent extends Component {
    void render(Canvas c) {
        c.drawRect(
            Rect.fromCenter(center: Offset.zero, width: 100, height: 100), 
            Paint()..color = Colors.red
        );
    }

    void update(double dt) {
        /// Will be called by parent [Particle]
    }
}
```

## Flare Particle

To use Flare within Flame, use the [`flame_flare`](https://github.com/flame-engine/flame_flare) package.

It will provide a class `FlareParticle` that is a container for `FlareActorAnimation`, it propagates `update` and `render` hooks to its child.

```dart
import 'package:flame_flare/flame_flare.dart';

// During game initialisation
const flareSize = 32.0;
final flareAnimation = FlareActorAnimation('assets/sparkle.flr');
flareAnimation.width = flareSize; 
flareAnimation.height = flareSize;

// Somewhere in game
game.add(
    ParticleComponent(
        particle: FlareParticle(flare: flareAnimation);
    )
);
```

## Computed Particle
A `Particle` which could help you when:
* Default behavior is not enough
* Complex effects optimization
* Custom easings

When created, delegates all the rendering to a supplied `ParticleRenderDelegate` which is called on each frame
to perform necessary computations and render something to the `Canvas`

```dart
game.add(
    ParticleComponent(
        // Renders a circle which gradually
        // changes its color and size during the particle lifespan
        particle: ComputedParticle(
            renderer: (canvas, particle) => canvas.drawCircle(
                Offset.zero,
                particle.progress * 10,
                Paint()
                  ..color = Color.lerp(
                    Colors.red,
                    Colors.blue,
                    particle.progress,
                  ),
            ),
        )
    )
)
```

## Nesting behavior

Flame's implementation of particles follows same pattern of extreme composition as Flutter widgets. That
is achieved by encapsulating small pieces of behavior in every of particles and then nesting these behaviors together to achieve desired visual effect.

Two entities allowing `Particle` to nest each other are: `SingleChildParticle` mixin and `ComposedParticle` class.

`SingleChildParticle` may help you with creating `Particles` with a custom behavior.
For example, randomly positioning it's child during each frame:
```dart
var rnd = Random();
class GlitchParticle extends Particle with SingleChildParticle {
    @override
    Particle child;

    GlitchParticle({
      @required this.child,
      double lifespan,
    }) : super(lifespan: lifespan);

    @override
    render(Canvas canvas)  {
        canvas.save();
        canvas.translate(rnd.nextDouble() * 100, rnd.nextDouble() * 100);

        // Will also render the child
        super.render();

        canvas.restore();
    }
}
```

`ComposedParticle` could be used either as standalone or within existing `Particle` tree. 
