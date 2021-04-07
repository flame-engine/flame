# Particles

Flame offers a basic, yet robust and extendable particle system. The core concept of this system is
the `Particle` class, which is very similar in its behavior to the `ParticleComponent`.

The most basic usage of a `Particle` with `BaseGame` would look as following:

```dart
import 'package:flame/components/particle_component.dart';

// ... 

game.add(
    // Wrapping a [Particle] with [ParticleComponent]
    // which maps the [Component] lifecycle hooks to the [Particle] ones
    // and embeds a trigger for removing the component.
    ParticleComponent(
      particle: CircleParticle()
    )
);
```

When using `Particle` with a custom `Game` implementation, please ensure that the `Particle`'s
`update` and `render` lifecycle hooks are called during each game loop frame.

The main approaches to implement the desired particle effects are:
 - Composition of existing behaviors
 - Use behavior chaining (just a syntactic sugar of the first one)
 - Using `ComputedParticle`

Composition works in a similar fashion to those of Flutter widgets by defining the effect from top
to bottom. Chaining allows to express the same composition trees more fluently by defining behaviors
from bottom to top. Computed particles in their turn fully delegate implementation of the behavior
to your code. Any of the approaches could be used in conjunction with existing behaviors where
needed.

Below you can find an example of an effect that shows a burst of circles, accelerating from `(0, 0)`
towards random directions using all three approaches defined above.

```dart
Random rng = Random();
Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

// Composition
// Defining particle effect as a set of nested behaviors from top to bottom, one within another:
// ParticleComponent 
//   > ComposedParticle 
//     > AcceleratedParticle 
//       > CircleParticle
game.add(
  ParticleComponent(
    particle: Particle.generate(
      count: 10,
      generator: (i) => AcceleratedParticle(
        acceleration: randomVector2(),
        child: CircleParticle(
          paint: Paint()..color = Colors.red,
        )
      )
    )
  )
);

// Chaining
// Expresses the same behavior as above, but with a more fluent API.
// Only [Particles] with [SingleChildParticle] mixin can be used as chainable behaviors.
game.add(
  Particle
    .generate(
      count: 10,
      generator: (i) {
       return CircleParticle(
         paint: Paint()..color = Colors.red,
       ).accelerating(randomVector2())
      },
    )
    .asComponent()
);

// Computed Particle
// All the behaviors are defined explicitly. Offers greater flexibility compared to built-in
// behaviors.
game.add(
  Particle
    .generate(
      count: 10,
      generator: (i) {
        final position = Vector2.zero();
        final speed = Vector2.zero();
        final acceleration = randomVector2();
        final paint = Paint()..color = Colors.red;

        return  ComputedParticle(
          renderer: (canvas, _) {
            speed += acceleration;
            position += speed;
            canvas.drawCircle(position, 10, paint);
          },
        );
      }
    )
    .asComponent()
)
```

You can find more examples of using different built-in particles in various combinations
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/particles).

## Lifecycle

Behavior common to all `Particle`s is that all of them accept a `lifespan` parameter. This value is
used to make the `ParticleComponent` self-remove, once its internal `Particle` has reached the end
of its life. The time within the `Particle` itself is tracked using a Flame `Timer`. It could be
configured with a `double`, representing seconds (with microsecond precision) by passing it into the
corresponding `Particle` constructor.

```dart
Particle(lifespan: .2); // will live for 200ms
Particle(lifespan: 4); // will live for 4s
```

It is also possible to reset the `Particle` lifespan by using `setLifespan` method, which accepts a
`double` that represents seconds.

```dart
final particle = Particle(lifespan: 2);

// ... at some point in time later
particle.setLifespan(2) // will live for another 2s from this moment
```

During its lifetime, the `Particle` tracks the time it was alive and exposes it with a `progress`
getter, which is spanning between 0.0 to 1.0. Its value could be used in a similar fashion as
`value` of `AnimationController` in Flutter.

```dart
final particle = Particle(lifespan: 2.0);

game.add(ParticleComponent(particle: particle));

// Will print values from 0 to 1 with a step length of .1: 0, 0.1, 0.2 ... 0.9, 1.0
Timer.periodic(duration * .1, () => print(particle.progress));
```

The lifespan is passed down to all the descendants of a given `Particle`, if it supports any of the
nesting behaviors.

## Built-in particles

Flame ships with a few built-in `Particle` behaviors:
* The `TranslatedParticle`, translates its `child` by the given `Vector2`
* The `MovingParticle`, moves its `child` between two predefined `Vector2`, it supports `Curve`
* The `AcceleratedParticle`, allows basic physics based effects, like gravitation or speed dampening
* The `CircleParticle`, renders circles of all shapes and sizes
* The `SpriteParticle`, renders a `Sprite` within a `Particle` effect
* The `ImageParticle`, renders a *dart:ui* `Image` within a `Particle` effect
* The `ComponentParticle`, renders a Flame `Component` within a `Particle` effect
* The `FlareParticle`, renders a Flare animation within a `Particle` effect

More examples of how to use these behaviors together are available
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/particles).
All the implementations are available in the
[particles](https://github.com/flame-engine/flame/tree/main/packages/flame/lib/src/particles)
folder in the Flame source.

## TranslatedParticle

Simply translates the underlying `Particle` to a specified `Vector2` within the rendering `Canvas`.
Does not change or alter its position, consider using `MovingParticle` or `AcceleratedParticle`
where change of position is required.

Same effect could be achieved by translating the `Canvas` layer.

```dart
game.add(
  ParticleComponent(
    particle: TranslatedParticle(
      // Will translate child Particle effect to
      // the center of game canvas
      position: game.size / 2,
      child: Particle(),
    )
  )
);
```

## MovingParticle

Moves the child `Particle` between `from` and `to` `Vector2`s during its lifespan. Supports `Curve`
via `CurvedParticle`.

```dart
game.add(
  ParticleComponent(
    particle: MovingParticle(
      // Will move from corner to corner of the game canvas
      from: Vector2.zero(),
      to: game.size,
      child: Particle(),
    )
  )
);
```

## AcceleratedParticle

A basic physics particle which allows you to specify its initial `position`, `speed` and
`acceleration` and let the `update` cycle do the rest. All three are specified as `Vector2`s.

It works especially well for physics-based "bursts", but it is not limited to that.
The unit of the `Vector2` values for `speed` and `acceleration` are _logical px/s_. So a speed of
`Vector2(0, 100)` will move a child `Particle` by 100 logical pixels of the device every second of
game time.

```dart
final rng = Random();
Vector2 randomVector2() => (Vector2.random(random) - Vector2.random(rng)) * 100;

game.add(
  ParticleComponent(
    particle: AcceleratedParticle(
      // Will fire off in the center of game canvas
      position: game.size / 2,
      // With a random initial speed of Vector2(-100..100, 0..-100)
      speed: randomVector2(),
      // Accelerates downwards, simulating "gravity"
      speed: Vector2(0, 100),
      child: Particle(),
    )
  )
);
```

## CircleParticle

A `Particle` which renders a circle with given `Paint` at the zero offset of passed `Canvas`. Use in
conjunction with `TranslatedParticle`, `MovingParticle` or `AcceleratedParticle` in order to achieve
desired positioning.

```dart
game.add(
  ParticleComponent(
    particle: CircleParticle(
      radius: game.size.x / 2,
      paint: Paint()..color = Colors.red.withOpacity(.5),
    )
  )
);
```

## SpriteParticle

Allows you to embed a `Sprite` into your particle effect. It's useful when consuming graphics for
the effect from a `SpriteSheet` for example.

```dart
game.add(
  ParticleComponent(
    particle: SpriteParticle(
      sprite: Sprite(spriteImage),
      size: Vector2(64, 64),
    )
  )
);
```

## ImageParticle

Renders the given `dart:ui` image within the particle tree.

```dart
// Within your game or component's `onLoad` method
await Flame.images.load('image.png');

// ...

// At some point during the game loop
game.add(
  ParticleComponent(
    particle: ImageParticle(
      size: Vector2.all(24),
      image: Flame.images.fromCache('image.png'),
    );
  )
);
```

## AnimationParticle

A `Particle` which embeds a Flame `Animation`. By default, it aligns the `Animation`s `stepTime` so
that it's fully played during the `Particle` lifespan. It's possible to override this behavior with
the `alignAnimationTime` parameter.

```dart
final spritesheet = SpriteSheet(
  image: yourSpriteSheetImage,
  srcSize: Vector2.all(16.0),
);

game.add(
  ParticleComponent(
    particle: AnimationParticle(
      animation: spritesheet.createAnimation(0, stepTime: 0.1),
    );
  )
);
```

## ComponentParticle

This `Particle` allows you to embed a Flame `Component` within the particle effect. The `Component`
could have its own `update` lifecycle and could be reused across different particle effect trees.

If the only thing you need is to add some dynamics to an instance of a certain `Component`, please
consider adding it to the `game` directly and use the normal effects system for examples, without
the `Particle` in the middle.

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
  @override
  void render(Canvas c) {
    c.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 100, height: 100),
      Paint()..color = Colors.red
    );
  }

  @override
  void update(double dt) {
    /// Will be called by parent [Particle]
  }
}
```

## FlareParticle

To use Flare within Flame, use the [`flame_flare`](https://github.com/flame-engine/flame_flare)
package.

It will provide a class, `FlareParticle`, that is a container for `FlareActorAnimation` and it
propagates `update` and `render` hooks to its child.

```dart
import 'package:flame_flare/flame_flare.dart';

// Within your game or component's `onLoad` method
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

## ComputedParticle

A `Particle` which could help you when:
* Default behavior is not enough
* Complex effects optimization
* Custom easings

When created, it delegates all the rendering to a supplied `ParticleRenderDelegate` which is called
on each frame to perform necessary computations and render something to the `Canvas`.

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

Flame's implementation of particles follows the same pattern of extreme composition as Flutter
widgets. That is achieved by encapsulating small pieces of behavior in every particle and then
nesting these behaviors together to achieve the desired visual effect.

Two entities that allow `Particle`s to nest each other are: `SingleChildParticle` mixin and
`ComposedParticle` class.

A `SingleChildParticle` may help you with creating `Particles` with a custom behavior.
For example, randomly positioning its child during each frame:

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

The `ComposedParticle` could be used either as a standalone or within an existing `Particle` tree.
