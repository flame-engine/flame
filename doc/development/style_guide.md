# Flame Style Guide

This is a general style guide for writing code within Flame and adjacent projects. We strive to
maintain the code clean and readable -- both for the benefit of the users who will need to study
this code in order to understand how a particular feature works or debug something that is breaking,
and for the benefit of the current and future maintainers.

This guide extends upon the official [Dart's style guide][effective dart]. Please make sure to read
that document first, as it is sure to improve your skill in Dart programming.


## Code Formatting

Most of the code formatting rules are enforced automatically via the linter. Run the following
commands to ensure the code is conformant and to fix any easy formatting problems:

```console
flutter analyze
flutter format .
```


## Code Structure


### Imports

- If you're using an external symbol that's defined in multiple libraries, prefer importing the
  smallest of them. For example, use `package:meta/meta.dart` to import annotations like
  `@protected`, or `dart:ui` to import `Canvas`.

- Never import `package:flutter/cupertino.dart` or `package:flutter/material.dart` -- prefer
  a much smaller library `package:flutter/widgets.dart` if you're working with widgets.


### Exports

- Strongly prefer to have only one public class per file, and name the file after that class.
  Having several private classes within the file is perfectly reasonable.

- A possible exception to this rule is if the "main" class requires some small "helper" classes
  that need to be public. Or if the file hosts multiple very small related classes.

- The "main" class in a file should be located at the start of the file (right after the imports
  section), so that it can be seen immediately upon opening the file. All other definitions,
  including typedefs, helper classes and functions, should be moved below the main class.

- If multiple public symbols are defined in a file, then they must be exported explicitly using
  the `export ... show ...` statement. For example:

  ```dart
  export 'src/effects/provider_interfaces.dart'
    show
      AnchorProvider,
      AngleProvider,
      PositionProvider,
      ScaleProvider,
      SizeProvider;
  ```


### Assertions

Use `assert`s to detect contract violations, or pre-condition/post-condition failures. Sometimes,
however, using exceptions would be more appropriate. The following rules of thumb apply:

- Use an assert with a clear error message to check for a condition that is in developers' control.
  For example, when creating a component that takes an `opacity` level as an input, you should check
  whether the value is in the range from 0 to 1. Consider also including the value itself into the
  error message, to make it easier for the developer to debug the error:

  ```dart
  assert(0 <= opacity && opacity <= 1, 'The opacity value must be from 0 to 1: $opacity');
  ```

  Always use asserts as early as possible to detect possible violations. For example, check the
  validity of `opacity` in the constructor/setter, instead of in the render function.

  When adding such an assert, also include a test that checks that the assert triggers. This test
  would verify that the component does not accept invalid input, and that the error message is what
  you expect it to be.

- Use an assert without an error message to check for a condition that cannot be triggered by the
  developer through any means known to you. If such an assert does trigger, it would indicate a bug
  in the Flame framework.

  Such asserts serve as "mini-tests" directly in the code, and protect against future refactorings
  that could create an erroneous internal state. It should not be possible to write a test that
  would deliberately trigger such an assert.

- Use an explicit if-check with an exception to test for a condition that may be outside of the
  developer's control (i.e. it may depend on the environment or on user's input). When deciding
  whether to use an assert or exception, consider the following question: is it possible for the
  error condition to occur in production even after the developer has done extensive testing on
  their side?


### Class structure

- Consider putting all class constructors at the top of the class. This makes it much easier to see
  how the class ought to be used.

- Try to make as much of your class' API private as possible, do not expose members "just in case".
  This makes it much easier to modify/refactor the class later without it being a breaking change.

  Remember to document all your public members! Documenting things is harder than it looks, and one
  way to avoid the burden of documentation is to make as many variables private as possible.

- If a class exposes a `List<X>` or `Vector2` property -- it is **NOT** an invitation to modify
  them at will! Consider such properties as read-only, unless the documentation explicitly says that
  they are allowed to be modified.

- When a class becomes sufficiently big, consider adding *regions* inside it, which help with code
  navigation and collapsing (note the lack of space after `//`):

  ```dart
  //#region Region description
  ...
  //#endregion
  ```

- If a class has a private member that needs to be exposed via a getter/setter, prefer the following
  code structure:

  ```dart
  class MyClass {
    MyClass();

    ...
    int _variable;
    ...

    /// Docs for both the getter and the setter.
    int get variable => _variable;
    set variable(int value) {
      assert(value >= 0, 'variable must be non-negative: $value');
      _variable = value;
    }
  }
  ```

  This would gather all private variables in a single block near the top of the class, allowing one
  to quickly see what data the class has.


## Documentation

- Use dartdocs `///` to explain the meaning/purpose of a class, method, or a variable.

- Use regular comments `//` to explain implementation details of a particular code fragment. That
  is, these comments explain HOW something works.

- Use markdown documentation in `doc/` folder to give the high-level overview of the functionality,
  and especially how it fits into the overall Flame framework.


### Dartdocs

- Check the [Flutter Documentation Guide] -- it contains lots of great advice on writing good
  documentation.
  - However, disregard the advice about writing in a passive voice.

- Class documentation should ideally start with the class name itself, and follow a pattern such as:

  ```dart
  /// [MyClass] is ...
  /// [MyClass] serves as ...
  /// [MyClass] does the following ...
  ```

  The reason for such convention is that often the documentation for a class becomes sufficiently
  long, and it may not be immediately apparent when looking at the top of the doc what exactly is
  being documented there.

- Method documentation should start with a verb in the present simple tense, with the method name
  as an implicit subject. Add a paragraph break after the first sentence. Try to think about what
  could be unclear to the users of the method; and mention any pre- and post-conditions.
  For example:

  ```dart
  /// Adds a new [child] into the container, and becomes the owner of that
  /// child.
  ///
  /// The child will be disposed of when this container is destroyed.
  /// It is an error to try to add a child that already belongs to another
  /// container.
  void addChild(T child) { ... }
  ```

  Avoid stating the obvious (or at least only the obvious).

- Constructor documentation may follow either the style of a method (i.e. "Creates ...",
  "Constructs ..."), or of the class but omitting the name of the class (i.e. "Rectangular-shaped
  component"). Constructor documentation may be omitted if (1) it's the main constructor of the
  class, and (2) all the parameters are obvious and coincide with the public members of the class.

  **Do not** use macros to copy the class documentation into the constructor's dartdoc. Generally,
  the class documentation answers the question "what the class is", whereas the constructor docs
  answer "how it will be constructed".


### Main docs

This refers to the docs on the main Flame Documentation website, the one you're reading right now.
The main documentation site serves as a place where people go to learn about various functionality
available in Flame. If you're adding a new class, then it must be documented both at the dartdocs
level, and on the main docs site. The latter serves the purposes of discoverability of your class.
Without the docs site, your class might never be used (or at least used less than it could have
been), because the developers would simply not know about it.

When adding the documentation to the main docs site, consider also including an example directly
into the docs. This will make readers more excited about trying this new functionality.

Check the [Documentation] manual about how to work with the docs site.

The following style rules generally apply when writing documentation:

- Maximum line length of 100 characters;
- Prefer to define external links at the bottom of the document, so as to make reading the plain
  text of the document easier;
- Separate headers from the preceding content with 2 blank lines -- this makes it easier to see the
  sections within the plain text.
- Lists should start at the beginning of the line and sublists should be indented with 2 spaces.


[effective dart]: https://dart.dev/guides/language/effective-dart
[flutter documentation guide]: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo#documentation-dartdocs-javadocs-etc
[documentation]: documentation.md
