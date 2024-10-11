# Particles

Flame 提供了一个基础但强大且可扩展的粒子系统。该系统的核心概念是 `Particle` 类，它的行为与 `ParticleSystemComponent` 非常相似。

在 `FlameGame` 中最基本的 `Particle` 用法如下：

```dart
import 'package:flame/components.dart';

// ...

game.add(
  // Wrapping a Particle with ParticleSystemComponent
  // which maps Component lifecycle hooks to Particle ones
  // and embeds a trigger for removing the component.
  ParticleSystemComponent(
    particle: CircleParticle(),
  ),
);
```

在自定义 `Game` 实现中使用 `Particle` 时，请确保在每个游戏循环中都调用 `update` 和 `render` 方法。

实现所需粒子效果的主要方法有：

- 组合现有行为。
- 使用行为链（只是第一个方法的语法糖）。
- 使用 `ComputedParticle`。

组合的工作方式与 Flutter 组件类似，通过从上到下定义效果。行为链允许通过从下到上的方式更流畅地表达相同的组合树。而计算粒子则完全将行为的实现委托给你的代码。在需要时，可以将上述任一方法与现有行为结合使用。

```dart
Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;

// Composition.
//
// Defining a particle effect as a set of nested behaviors from top to bottom,
// one within another:
//
// ParticleSystemComponent
//   > ComposedParticle
//     > AcceleratedParticle
//       > CircleParticle
game.add(
  ParticleSystemComponent(
    particle: Particle.generate(
      count: 10,
      generator: (i) => AcceleratedParticle(
        acceleration: randomVector2(),
        child: CircleParticle(
          paint: Paint()..color = Colors.red,
        ),
      ),
    ),
  ),
);

// Chaining.
//
// Expresses the same behavior as above, but with a more fluent API.
// Only Particles with SingleChildParticle mixin can be used as chainable behaviors.
game.add(
  ParticleSystemComponent(
    particle: Particle.generate(
      count: 10,
      generator: (i) => pt.CircleParticle(paint: Paint()..color = Colors.red)
    )
  )
);

// Computed Particle.
//
// All the behaviors are defined explicitly. Offers greater flexibility
// compared to built-in behaviors.
game.add(
  ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        generator: (i) {
          Vector2 position = Vector2.zero();
          Vector2 speed = Vector2.zero();
          final acceleration = randomVector2();
          final paint = Paint()..color = Colors.red;

          return ComputedParticle(
            renderer: (canvas, _) {
              speed += acceleration;
              position += speed;
              canvas.drawCircle(Offset(position.x, position.y), 1, paint);
            }
        );
      }
    )
  )
);
```

See more [examples of how to use built-in particles in various
combinations](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/particles_example.dart).


## Lifecycle

所有 `Particle` 都有一个通用的行为，即它们都接受一个 `lifespan` 参数。
该参数用于在其内部 `Particle` 达到生命周期结束时，让 `ParticleSystemComponent` 自动移除自身。`Particle` 内部的时间使用 Flame 的 `Timer` 类进行跟踪。
可以在相应的 `Particle` 构造函数中传递一个以秒为单位（具有微秒级精度）的 `double` 类型参数来配置生命周期。

```dart
Particle(lifespan: .2); // will live for 200ms.
Particle(lifespan: 4); // will live for 4s.
```

还可以使用 `setLifespan` 方法来重置 `Particle` 的生命周期，该方法同样接受以秒为单位的 `double` 类型参数。

```dart
final particle = Particle(lifespan: 2);

// ... after some time.
particle.setLifespan(2) // will live for another 2s.
```

在其生命周期内，`Particle` 会跟踪其存活的时间，并通过 `progress` getter 暴露该信息，该 getter 返回一个介于 `0.0` 到 `1.0` 之间的值。
这个值的使用方式与 Flutter 中 `AnimationController` 类的 `value` 属性类似。

```dart
final particle = Particle(lifespan: 2.0);

game.add(ParticleSystemComponent(particle: particle));

// Will print values from 0 to 1 with step of .1: 0, 0.1, 0.2 ... 0.9, 1.0.
Timer.periodic(duration * .1, () => print(particle.progress));
```

如果某个 `Particle` 支持嵌套行为，那么它的所有子代都会继承该 `Particle` 的 `lifespan`。


## Built-in particles

Flame 提供了一些内置的 `Particle` 行为：

- `TranslatedParticle`：按照给定的 `Vector2` 平移其 `child`
- `MovingParticle`：在两个预定义的 `Vector2` 之间移动其 `child`，支持 `Curve`
- `AcceleratedParticle`：允许基于基础物理的效果，例如重力或速度衰减
- `CircleParticle`：渲染各种形状和大小的圆形
- `SpriteParticle`：在 `Particle` 效果中渲染 Flame 的 `Sprite`
- `ImageParticle`：在 `Particle` 效果中渲染 *dart:ui* 的 `Image`
- `ComponentParticle`：在 `Particle` 效果中渲染 Flame 的 `Component`
- `FlareParticle`：在 `Particle` 效果中渲染 Flare 动画

See more [examples of how to use built-in Particle behaviors
together](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/particles_example.dart).
All the implementations are available in the [particles folder on the
Flame repository.](https://github.com/flame-engine/flame/tree/main/packages/flame/lib/src/particles)


## TranslatedParticle

简单地将底层的 `Particle` 平移到渲染 `Canvas` 中指定的 `Vector2` 位置。不会改变其位置，如果需要改变位置，可以考虑使用 `MovingParticle` 或 `AcceleratedParticle`。
同样的效果也可以通过平移 `Canvas` 图层来实现。

```dart
game.add(
  ParticleSystemComponent(
    particle: TranslatedParticle(
      // Will translate the child Particle effect to the center of game canvas.
      offset: game.size / 2,
      child: Particle(),
    ),
  ),
);
```


## MovingParticle

在其生命周期内，将子 `Particle` 从 `from` 位置移动到 `to` 位置（`Vector2` 类型）。通过 `CurvedParticle` 支持 `Curve`。

```dart
game.add(
  ParticleSystemComponent(
    particle: MovingParticle(
      // Will move from corner to corner of the game canvas.
      from: Vector2.zero(),
      to: game.size,
      child: CircleParticle(
        radius: 2.0,
        paint: Paint()..color = Colors.red,
      ),
    ),
  ),
);
```


## AcceleratedParticle

一个基础的物理粒子，允许你指定其初始 `position`（位置）、`speed`（速度）和 `acceleration`（加速度），并让 `update` 循环处理其余的工作。
所有这三个属性都以 `Vector2` 形式指定，可以将其视为向量。
它在基于物理的“爆发”效果中表现尤为出色，但并不限于此。
`Vector2` 的单位是*逻辑像素/秒*。因此，速度为 `Vector2(0, 100)` 表示子 `Particle` 每秒沿设备的 Y 轴方向移动 100 个逻辑像素。

```dart
final rnd = Random();
Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 100;

game.add(
  ParticleSystemComponent(
    particle: AcceleratedParticle(
      // Will fire off in the center of game canvas
      position: game.canvasSize/2,
      // With random initial speed of Vector2(-100..100, 0..-100)
      speed: Vector2(rnd.nextDouble() * 200 - 100, -rnd.nextDouble() * 100),
      // Accelerating downwards, simulating "gravity"
      // speed: Vector2(0, 100),
      child: CircleParticle(
        radius: 2.0,
        paint: Paint()..color = Colors.red,
      ),
    ),
  ),
);
```


## CircleParticle

一个在传递的 `Canvas` 的零偏移位置使用给定的 `Paint` 渲染圆形的 `Particle`。
可与 `TranslatedParticle`、`MovingParticle` 或 `AcceleratedParticle` 结合使用，以实现期望的定位效果。

```dart
game.add(
  ParticleSystemComponent(
    particle: CircleParticle(
      radius: game.size.x / 2,
      paint: Paint()..color = Colors.red.withOpacity(.5),
    ),
  ),
);
```


## SpriteParticle

允许在粒子效果中嵌入 `Sprite`。

```dart
game.add(
  ParticleSystemComponent(
    particle: SpriteParticle(
      sprite: Sprite('sprite.png'),
      size: Vector2(64, 64),
    ),
  ),
);
```


## ImageParticle

在粒子树中渲染给定的 `dart:ui` 图像。

```dart
// During game initialization
await Flame.images.loadAll(const [
  'image.png',
]);

// ...

// Somewhere during the game loop
final image = await Flame.images.load('image.png');

game.add(
  ParticleSystemComponent(
    particle: ImageParticle(
      size: Vector2.all(24),
      image: image,
    );
  ),
);
```


## ScalingParticle

在其生命周期内，将子 `Particle` 的缩放比例从 `1` 变为 `to`。

```dart
game.add(
  ParticleSystemComponent(
    particle: ScalingParticle(
      lifespan: 2,
      to: 0,
      curve: Curves.easeIn,
      child: CircleParticle(
        radius: 2.0,
        paint: Paint()..color = Colors.red,
      )
    );
  ),
);
```


## SpriteAnimationParticle

一个嵌入 `SpriteAnimation` 的 `Particle`。默认情况下，将 `SpriteAnimation` 的 `stepTime` 对齐，使其在 `Particle` 的生命周期内完全播放。
可以通过 `alignAnimationTime` 参数来覆盖此行为。

```dart
final spriteSheet = SpriteSheet(
  image: yourSpriteSheetImage,
  srcSize: Vector2.all(16.0),
);

game.add(
  ParticleSystemComponent(
    particle: SpriteAnimationParticle(
      animation: spriteSheet.createAnimation(0, stepTime: 0.1),
    );
  ),
);
```


## ComponentParticle

该 `Particle` 允许在粒子效果中嵌入一个 `Component`。

该 `Component` 可以拥有自己的 `update` 生命周期，并可在不同的效果树中复用。

如果你只需要为某个 `Component` 实例添加一些动态效果，请考虑将其直接添加到 `game` 中，而不使用 `Particle` 作为中介。

```dart
final longLivingRect = RectComponent();

game.add(
  ParticleSystemComponent(
    particle: ComponentParticle(
      component: longLivingRect
    );
  ),
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


## ComputedParticle

当以下情况发生时，该 `Particle` 可以帮助你：

- 默认行为不够用
- 优化复杂效果
- 自定义缓动效果

创建时，它将所有渲染工作委托给提供的 `ParticleRenderDelegate`，该委托会在每一帧被调用以执行必要的计算并将内容渲染到 `Canvas` 上。

```dart
game.add(
  ParticleSystemComponent(
    // Renders a circle which gradually changes its color and size during the
    // particle lifespan.
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
    ),
  ),
)
```


## Nesting behavior

Flame 的粒子实现遵循与 Flutter 组件相同的极致组合模式。其实现方式是将行为拆分为小块并封装在每个粒子中，然后将这些行为嵌套在一起，以实现期望的视觉效果。

允许 `Particle` 相互嵌套的两个实体是：`SingleChildParticle` 混入（mixin）和 `ComposedParticle` 类。

`SingleChildParticle` 可以帮助你创建具有自定义行为的 `Particle`。例如，在每一帧随机定位其子元素：

`SingleChildParticle` 可以帮助你创建具有自定义行为的 `Particle`。

例如，在每一帧随机定位其子元素：

```dart
var rnd = Random();

class GlitchParticle extends Particle with SingleChildParticle {
  Particle child;

  GlitchParticle({
    required this.child,
    super.lifespan,
  });

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

`ComposedParticle` 可以作为独立粒子使用，也可以用于现有的 `Particle` 树中。
