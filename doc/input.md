# Input

In order to handle user input, you can use the libraries provided by Flutter for regular apps: [Gesture Recognizers](https://flutter.io/gestures/).

However, in order to bind them, use the `Flame.util.addGestureRecognizer` method; in doing so, you'll make sure they are properly unbound when the game widget is not being rendered, and so the rest of your screens will work appropriately.

For example, to add a tap listener ("on click"):

```dart
    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
        ..onTapDown = (TapDownDetails evt) => game.handleInput(evt.globalPosition.dx, evt.globalPosition.dy));
```

Where `game` is a reference to your game object and `handleInput` is a method you create to handle the input inside your game.

If your game doesn't have other screens, just call this after your `runApp` call, in the `main` method.

Here are some example of more complex Gesture Recognizers:

```dart
    MyGame() {
        // other init...

        Flame.util.addGestureRecognizer(createDragRecognizer());
        Flame.util.addGestureRecognizer(createTapRecognizer());
    }

    GestureRecognizer createDragRecognizer() {
        return new ImmediateMultiDragGestureRecognizer()
            ..onStart = (Offset position) => this.handleDrag(position);
    }

    TapGestureRecognizer createTapRecognizer() {
        return new TapGestureRecognizer()
            ..onTapUp = (TapUpDetails details) => this.handleTap(details.globalPosition);;
    }
```
__ATTENTION:__ `Flame.util.addGestureRecognizer` must be called after the `runApp`, otherwise Flutter's `GestureBinding` will not be initialized yet and exceptions will occur.

## Tapeable components

Flame also offers a simple helper to make it easier to handle tap events on `PositionComponent`, by using the `mixin` `Tapeable` your components can override the following methods, enabling easy to use tap events on your Component. 

```dart
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
```

Minimal component example:

```
import 'package:flame/components/component.dart';
import 'package:flame/components/events/gestures.dart';

class TapeableComponent extends PositionComponent with Tapeable {

  // update, render ommited

  @override
  void onTapUp(TapUpDetails details) {
    print("tap up");
  }

  @override
  void onTapDown(TapDownDetails details) {
    print("tap down");
  }

  @override
  void onTapCancel() {
    print("tap cancel");
  }
}

__ATTENTION:__ Since Tapeable uses `Flame.util.addGestureRecognizer` no `Tapeable` component can be added on the Game before the `runApp` method has been called.
