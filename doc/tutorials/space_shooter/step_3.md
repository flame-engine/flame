# Adding animations and depth

We now have something that looks more like a game, having a graphic for our spaceship and being
able to directly control it.

But our game so far is too boring, the starship is just a static sprite and the background is
just a black screen.

In this step we will look how to improve that, we will replace the static graphic of the player
to an animation and will create a cool sense of depth and movement by adding a parallax to the
background of the game.

So lets start by adding the animation to the player ship! For that, we will something that we
call Sprite Animations, which is an animation that is composed by a collection of sprites, each
one representing one frame, and the animation effect is achieved by rendering one sprite after
the other through a timeframe.

To better visualize, this is the animation that we will be using, note how this image holds 4
individual images (or frames).

![](app/assets/images/player.png)

Flame provides us specialized classes to deal with such image: `SpriteAnimation` and its component
wrapper `SpriteAnimationComponent` and changing our `Player` component to be an animation is quite
simple, take a look on how the component will look like now:

```dart
class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(32, 48),
      ),
    );

    position = game.size / 2;
    width = 100;
    height = 150;
    anchor = Anchor.center;
  }

  // Other methods omitted
}
```

So lets break down the changes:
 - First we changed our `Player` component to extend from `SpriteAnimationComponent` instead of
`SpriteComponent`
 - In the `onLoad` method we are now using the `game.loadSpriteAnimation` helper instead of the
 `loadSprite` one, and setting the `animation` attribute with its returned value.

The `SpriteAnimationData` class might look complicated at first glance, but it is actually quite
simple, note how we used the `sequenced` constructor, which is a helper to load animation images
where the frames are already layed down in the sequence that they will play, then:

 - `amount` defines how many frames that animation have, in this case `4`
 - `stepTime` is the time in seconds that each frame will be rendered, before it gets replaced
to the next one.
 - `textureSize` is the size in pixels which defines each frame of the image.

With all of these informations, the `SpriteAnimationComponent` will now automatically play the
animation!

Now lets add some depth and dynamicity to our game background. Of course there are many ways of
doing so, in this tutorial we will explore the idea of the parallax scrolling. If you never heard
about it, it consist in a technique where background images move past the camera with different
speeds, this not only creates the sensation of depth but also improve a lot the movement feeling
of the game. If you want to read more about Parallax Scrolling, check this article
from [Wikipedia](https://en.wikipedia.org/wiki/Parallax_scrolling).

Flame provide classes to implement parallax scrolling out of the box, them being `Parallax` and
`ParallaxComponent`, so lets take a look how we can add that new feature to the game:

```dart
class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars_0.png'),
        ParallaxImageData('stars_1.png'),
        ParallaxImageData('stars_2.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }
}
```

Looking at the code above we notice that we are now using the `loadParallaxComponent` helper
method from the `FlameGame` class to directly load a `ParallaxComponent` and add it to our game.

The arguments used there goes a follows:
 - The first argument is a positional one, which should be a list of `ParallaxData`s. There are a
couple of types do `ParallaxData`s in Flame, in this tutorial we are using the `ParallaxImageData`
which describe a layer in the parallax scrolling effect that is an `image`. This list will tell
Flame all the layers that we want in our parallax.
 - `baseVelocity` is the base value for all the values, so by passing a `Vector2(0, -5)` to it
means that the slower of the layers will move at 0 pixels per second on the `x` axis and `-5`
pixels per second on the `y` axis.
 - Finally `velocityMultiplierDelta` is a vector that is applied to the base value for each layer,
and in our example the multiplicatin rate is `5` only on the `y` axis.


Give it a try running the game now, you will notice that it looks way more dynamic now, giving a
more convince feeling to the player that the spaceship is really crossing the stars!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step3
:show: popup code
```
