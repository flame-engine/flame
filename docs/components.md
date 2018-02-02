# Components

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

The intermediate inheritance `PositionComponent` adds `x`, `y`, `width`, `height` and `angle` to your Components, as well as some useful methods like distance and angleBetween.

The most commonly used implementation, `SpriteComponent`, can be created with a `Sprite`:

```
    import 'package:flame/component.dart';

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

* The `AnimationComponent` takes an `Animation` object and renders a cyclic animated sprite (more details about Animations [here](docs/images.md#Animation))
* The `ParallaxComponent` can render a parallax background with several frames
* The `Box2DComponent`, that has a physics engine built-in (using the [Box2D](https://github.com/google/box2d.dart) port for Dart)

[TODO] make the in-depth guide for Components!