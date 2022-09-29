# Writing tests

- All new functionality must be tested, if at all possible. When fixing a bug, tests must be added
  to ensure that this bug would not reappear in the future.

- Run `melos run coverage` to execute all tests in the "coverage" mode. The results will be saved
  in the `coverage/index.html` file, which can be opened in a browser. Try to achieve 100% coverage
  for any new functionality added.

- Every source file should have a corresponding test file, with the `_test` suffix. For example,
  if you're making a `SpookyEffect` and the source file is `src/effects/spooky_effect.dart`, then
  the test file should be `test/effects/spooky_effect_test.dart` mirroring the source directory.

- The test file should contain a `main()` function with a single `group()` whose name matches the
  name of the class being tested. If the source file contains multiple public classes, then each of
  them should have its own group. For example:

  ```dart
  void main() {
    group('SpookyEffect', () {
      // tests here
    });
  }
  ```

- For a larger class, multiple groups can be created inside the top-level group, allowing to
  navigate the test suite easier. The names of the nested groups should be capitalized.

- The names of the individual tests should normally start with a lowercase.

- Often, you would need to define multiple helper classes to run the tests. Such classes should be
  private (start with an underscore), and placed at the end of the file. The reason for this is that
  whenever some test breaks, the first thing one needs to do is to go into the test file and run all
  the tests. Having the `main()` function at the top of the file makes this process much easier.


## Types of tests


### Simple tests

```dart
test('the name of the test', () {
  expect(...);
});
```

This is the simplest kind of test available, and also the fastest. Use these tests for checking
some classes/methods that can function in isolation from the rest of the Flame framework.


### FlameGame tests

It is very common to want to have a `FlameGame` instance inside a test, so that you can add some
components to it and verify various behaviors. The following approach is recommended:

```dart
testWithFlameGame('the name of the test', (game) async {
  game.add(...);
  await game.ready();

  expect(...);
});
```

Here the `game` instance that is passed to the test body is a fully initialized game that behaves
as if it was mounted to a `GameWidget`. The `game.ready()` method waits until all the scheduled
components are loaded and mounted to the component tree.

The time within the `game` can be advanced with `game.update(dt)`.

If you need to have a custom game inside this test (say, a game with some mixin), then use

```dart
testWithGame<_MyGame>(
  'the name of the test',
  _MyGame.new,
  (game) async {
    // test body...
  },
);
```


### Widget tests

Sometimes having a "naked" `FlameGame` is insufficient, and you want to have access to the Flutter
infrastructure as well. That is, to have a game mounted into a real `GameWidget` embedded into an
actual Flutter framework. In such cases, use

```dart
testWidgets('test name', (tester) async {
  final game = _MyGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await tester.pump();

  // At this point the game is fully initialized, and you can run your checks
  // against it.
  expect(...);

  // Equivalent to game.update(0)
  await tester.pump();

  // Advances in-game time by 20 milliseconds
  await tester.pump(const Duration(milliseconds: 20));
});
```

There are some additional methods available on the `tester` controller, for example in order to
simulate taps, or drags, or key presses.


### Golden tests

These tests verify that things render as intended. The process of creating a golden test is
simple:

1. Write the test, using the following template:

   ```dart
   testGolden(
     'the name of the test',
     (game) async {
        // Set up the game by adding the necessary components
        // You can add `expect()` checks here too, if you want to
     },
     size: Vector2(300, 200),
     goldenFile: '.../_goldens/my_test_file.png',
   );
   ```

   Here the `size` parameter determines the size of the game canvas and of the output image. The
   `goldenFile` parameter is the name of the file where you want to store the "golden" results. This
   should be a relative path to the `test/_goldens` directory, starting from your test file.

2. Run

   ```console
   flutter test --update-goldens
   ```

   this would create the golden file for the first time. Open the file to verify that it renders
   exactly as you intended. If not, then delete the file and go back to step 1.

3. Subsequent runs of `flutter test` will check whether the output of the golden test matches the
   saved golden file. If not, Flutter will save the image-diff files into the `failures/` directory
   where your test is located.

```{note}
Avoid using text in your golden tests -- it does not render reliably across
different platforms, due to font discrepancies and differences in
anti-aliasing algorithms.
```


### Random tests

These are the tests that use a random number generator in order to construct a randomized input and
then check its correctness. Use as follows:

```dart
testRandom('test name', (Random random) {
  // Use [random] to generate random input
});
```

You can add `repeatCount: 1000` parameter to run this test the specified number of times, each one
with a different seed. It is useful to run a high `repeatCount` when developing the test, to ensure
that it doesn't break. However, when submitting the test to the main repository, avoid repeatCounts
higher than 10.

If the test breaks at some particular seed, then that seed will be shown in the test output. Add it
as the `seed: NNN` parameter to your test, and you'll be able to run it for the same seed as long
as you need until the test is fixed. Do not leave the `seed:` parameter when submitting your code,
as it defeats the purpose of having the test randomized.
