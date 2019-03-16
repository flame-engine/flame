# Components

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

The intermediate inheritance `PositionComponent` adds `x`, `y`, `width`, `height` and `angle` to your Components, as well as some useful methods like distance and angleBetween.

The most commonly used implementation, `SpriteComponent`, can be created with a `Sprite`:

```dart
    import 'package:flame/components/component.dart';

    Sprite sprite = new Sprite('player.png');

    const size = 128.0;
    var player = new SpriteComponent.fromSprite(size, size, sprite); // width, height, sprite

    // screen coordinates
    player.x = ... // 0 by default
    player.y = ... // 0 by default
    player.angle = ... // 0 by default

    player.render(canvas); // it will render only if the image is loaded and the x, y, width and height parameters are not null
```

Every `Component` has a few other methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using the base game, you can alternatively use these methods on your own game loop.

The `resize` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add` method. You need to apply here any changes to the x, y, width and height of your component, or any other changes, due to the screen resizing. You can start these variables here, as the sprite won't be rendered until everything is set.

The `destroy` method can be implemented to return true and warn the `BaseGame` that your object is marked for destruction, and it will be remove after the current update loop. It will then no longer be rendered or updated.

The `isHUD` method can be implemented to return true (default false) to make the `BaseGame` ignore the `camera` for this element.

There are also other implementations:

* The `AnimationComponent` takes an `Animation` object and renders a cyclic animated sprite (more details about Animations [here](doc/images.md#Animation))
* The `ParallaxComponent` can render a parallax background with several frames
* The `Box2DComponent`, that has a physics engine built-in (using the [Box2D](https://github.com/google/box2d.dart) port for Dart)

## Animation Component

This component uses an instance of the [Animation](doc/images.md#Animation) class to represent a Component that has a sprite that runs a single cyclic animation.

This will create a simple three frame animation

```dart
    List<Sprite> sprites = [0, 1, 2].map((i) => new Sprite('player_${i}.png')).toList();
    this.player = new AnimationComponent(64.0, 64.0, new Animation.spriteList(sprites, stepTime: 0.01));
```

If you have a spritesheet, you can use the `sequenced` constructor, identical to the one provided by the `Animation` class (check more details in [the appropriate section](doc/images.md#Animation)):

```dart
    this.player = new AnimationComponent.sequenced(64.0, 64.0, 'player.png', 2);
```

If you are not using `BaseGame`, don't forget this component needs to be update'd even if static, because the animation object needs to be ticked to move the frames.


## Composed componend

A mixin that helps you to make a `Component` wraps other components. It is useful to group visual components through a hierarchy. Ehen implemented, makes every item in its `components` colection field be updated and rendered with teh same conditions .

Example of usage, where vitibility oof two components are handled by a wrapper:

```dart
class GameOverPanel extends PositionComponent with Resizable, ComposedComponent {
  bool visible = false;

  GameOverText gameOverText;
  GameOverButton gameOverButton;

  GameOverPanel(Image spriteImage) : super() {
    gameOverText = GameOverText(spriteImage); // GameOverText is a Component
    gameOverButton = GameOverButton(spriteImage); // GameOverRestart is a SpriteComponent

    components..add(gameOverText)..add(gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    } // If not, neither of its `components` will be rendered
  }
}
```



## Parallax Component

This Component can be used to render pretty backgrounds, by drawing several transparent images on top of each other, each dislocated by a tiny amount.

The rationale is that when you look at the horizon and moving, closer objects seem to move faster than distant ones.

This component simulates this effect, making a very realistic background.

Create it like so:

```dart
    this.bg = new ParallaxComponent();
    this.bg.load([ 'bg/1.png', 'bg/2.png', 'bg/3.png' ]);
```

Then, render it as any other component.

Like the AnimationComponent, even if your parallax is static, you must call update on this component, so it runs its animation.

## Box2D Component

Flame comes with a basic integration with the Flutter implementation of [Box2D](https://github.com/google/box2d.dart).

The whole concept of a box2d's World is mapped to the `Box2DComponent` component; every Body should be a `BodyComponent`, and added directly to the `Box2DComponent`, and not to the game list.

So you can have HUD and other non-physics-related components in your game list, and also as many `Box2DComponents` as you'd like (normally one, I guess), and then add your physical entities to your Components instance. When the Component is updated, it will use box2d physics engine to properly update every child.

You can see a more complete example of box2d usage on [this WIP game](https://github.com/feroult/haunt) made by @feroult (beware, though, it uses 0.6.x version of flame, but the Box2D related apis are unchanged).

## Tiled Component

Currently we have a very basic implementation of a Tiled component. This API uses the lib [Tiled](https://github.com/feroult/tiled.dart) to parse map files and render visible layers.

A example of how to use the API can be found [here](https://github.com/luanpotter/flame/tree/master/examples/tiled). 
