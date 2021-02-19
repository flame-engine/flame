# Styleguide

This is WIP! It is definitely not complete. We just starting putting this together.

## Imports

* Never include unused or duplicated imports.
* You must always use relative imports for imports within the Flame library.
* Omit `./` for relative imports from the same directory.
* Order your imports by:
* * Three main blocks, each separated by exactly one empty line:
* * * Dart SDK dependencies,
* * * External libraries/Flutter imports,
* * * Internal (same library) imports.
* * Then, for each block, order alphabetically.
* * * For relative imports, that means further away (more `../`) imports will be first.

For example:

```
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder, Viewport;
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../../extensions.dart';
import '../components/component.dart';
import '../components/mixins/has_game_ref.dart';
import '../components/mixins/tapable.dart';
import '../components/position_component.dart';
import '../fps_counter.dart';
import 'camera.dart';
import 'game.dart';
import 'viewport.dart';
```