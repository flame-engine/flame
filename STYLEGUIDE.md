# Style Guide

This is a general style guide that shall govern over all Flame repositories. The aim is to keep
all codebases clean and pristine. This includes high level guidance to help with simple decisions
in the day-to-day development life.

This extends rules on the official [Flutter Style
Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and [Effective Dart
Patterns](https://dart.dev/guides/language/effective-dart). Those rules apply unless otherwise
specified in this document.

Note that this is not yet an exhaustive guide, and consider it a work in progress. PRs are welcome!

## Code Formatting

### Max line length

For all files, including markdown, keep each line within a hundred or less characters.

### Trailing Commas and Wrapping

List of elements must always be all in one line or one element per line. This includes parameters,
arguments, collection literals, etc. Furthermore, if multiline, the last element must have a
trailing comma.

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
* You must always use relative imports for imports within the Flame library (internal imports must
  be relative).
* Omit `./` for relative imports from the same directory.
* Avoid importing groups of APIs internally, for example, importing `lib/effects.dart` just to use
  `ScaleEffect`.
* Order your imports by:
  * Three main blocks, each separated by exactly one empty line:
    * Dart SDK dependencies,
    * External libraries/Flutter imports,
    * Internal (same library) imports.
  * Then, for each block, order alphabetically.
    * For relative imports, that means further away (more `../`) imports will be first.

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
import '../components/mixins/tappable.dart';
import '../components/position_component.dart';
import '../fps_counter.dart';
import 'camera.dart';
import 'game.dart';
import 'viewport.dart';
```

## Code Structure
### Global Variables

Do not use public global variables or constants; namespace everything inside appropriate scopes.

### Asserts

Use asserts to detect contract violation.

Example:

````dart
void something(int smaller, int bigger) {
  assert(small < bigger, 'smaller is not smaller than bigger');
  // ...
}
````

## Comments

* For any `//` comments, always add a space after the second slash and before the next character.
* Use `//` (or block comments) for comments about the code; use `///` for dartdocs about APIs.

### TODO

TODO comments should follow this template: `// TODO(username): Comment`

I.e., double slash, one space, `TODO` in caps followed by your name in parenthesis, colon, one space
and the comment, capitalized as a sentence. No need to include a period if it's a single sentence.

```dart
// bad: missing identifier, mixed-case "TODO" and lowercase comment

// Todo: this thing should be that thing
final thisThing = 13;

// good:

// TODO(wolfenrain): This thing should be that thing
const thisThing = 13;
```


### Dartdocs

#### Consider adding examples

Some elements may benefit from a simple usage example.

#### Avoid useless code documentation

Avoid documentation that just repeats the obvious. For example, `void doStuff()` be documented as
"Method that does stuff".

#### Consider adding linkage between docs

You should use `[]` (brackets) to link dartdoc elements that can be referenced on the same file.
Also, consider adding a "See also" section to element documentation.
