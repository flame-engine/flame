### MoveEffect

Applied to `PositionComponent`s, this effect can be used to move the component to a new position, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

Usage example:
```dart
import 'package:flame/effects/effects.dart';

// Square is a PositionComponent
square.addEffect(MoveEffect(
  destination: Position(200, 200),
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

### ScaleEffect

Applied to `PositionComponent`s, this effect can be used to change the width and height of the component, using an [animation curve](https://api.flutter.dev/flutter/animation/Curves-class.html).

Usage example:
```dart
import 'package:flame/effects/effects.dart';

// Square is a PositionComponent
square.addEffect(ScaleEffect(
  size: Size(300, 300),
  speed: 250.0,
  curve: Curves.bounceInOut,
));
```

