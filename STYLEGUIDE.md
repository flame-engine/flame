# Style Guide

This is a general style guide that shall govern over the Flame Engine repository. The aim is to keep a common stable general environment.
This includes high level guidance to help with simple decisions in the day-to-day development life.

This extends rules on the official [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).


## Code formatting

### Trailing Commas and Wrapping

List of elements must always be all in one line or one element per line. This includes parameters, arguments, collection literals, etc. Furthermore, if multiline, the last element must have a trailing comma.

For the sake of example, let's use a function invocation (the same apply for all cases):

```
// good
foo(p1, p2, p3)

// good
foo(
    p1,
    p2,
    p3,
)

// bad: missing trailing comma
foo(
    p1,
    p2,
    p3
)

// bad: mixed argument lines
foo(
    p1, p2,
    p3,
)

// bad: mixed argument lines
foo(f1,
    f2)
```

### Imports

* Never include unused or duplicated imports.
* You must always use relative imports for imports within the Flame library.
* Omit `./` for relative imports from the same directory.
* TODO Do/Do not use the imports grouping internally (like component.dart, extensions.dart, etc).
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

### Identifiers

Use all [effective dart patterns](https://dart.dev/guides/language/effective-dart)

* Avoid using global constants, but if you do use, name it prefixing with a `k`.

```dart
// Do not:
const someConstant = 42;

// Do instead:
const kSomeConstant = 42;
```

### Comments

* Add an identifier for TODO comments
* Use full capitalized TODO

```dart

// Do not:
// Todo: This thing should be that thing
final thisThing = 13;

// Do instead:
// TODO(wofstein): This thing should be that thing
const thisThing = 13;
```

### Asserts

* Use asserts to detect contract violation.
* Use asserts to run debug only code

Example:
````dart
void something(int smaller, int bigger) {
  assert(small < bigger, "smaller is not smaller than bigger");
  assert((){
    // debug only code
  });
  
  //...
}

````



## Code documentation 

Specific guides for dartdoc documentation.

#### Use impersonal tone

Avoid using words such as "you", "ours" and "yours" on code documentation

#### Consider adding examples

Some elements may benefit from a simple usage example.

#### Avoid useless code documentation

Avoid documentation that just repeats the obvious. 
For example, `void doStuff()` be documented as "Method that does stuff".

#### Consider adding linkage between docs

Consider adding a "See also" section to element documentation
