
# Widget, Game and World


## 2.0 Foundations

These are the first steps of creating a new Flame game from scratch.  
Similar to Flame [Getting Started](https://docs.flame-engine.org/latest/#id1)
guide.  

Replace the whole ```main.dart``` file with the following:  

```dart
import 'package:flutter/widgets.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(world: MyWorld()),
    ),
  );
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    print("The world is MINE!");
  }
}
```

Save and run it from the VS Code terminal (```Ctrl + J```).  
The command is: ```flutter run```, then choose your device from the available
list.  

You should see a black background in a new window.  
The console will contain the *"The world is MINE!"* message, maybe you have to
scroll a little bit upwards, because of the printed flutter commands and
messages.  

Alright, here we have an empty but working application.  

In the next step we will create the sprite component and it's settings.
