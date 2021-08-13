import 'dart:math';
import 'package:meta/meta.dart';
import 'package:flutter_test/flutter_test.dart';

final _rnd = Random(); // for generating seeds
const _maxSeed = 4294967296;

/// This function is equivalent to `test(name, body)`, except that it is
/// better suited for randomized testing: it will create a Random
/// generator and pass it to the test body, but also record the seed
/// that was used for creating the random generator. Thus, if a test
/// fails for a specific rare seed, it would be easy to reproduce this
/// failure.
///
/// In order for this to work properly, all random number generation
/// within `testRandom()` must be performed through the provided random
/// generator.
///
/// Example of use:
///
///     testRandom('description', (Random random) {
///       expect(random.nextDouble() == random.nextDouble(), false);
///     });
///
/// Then if the test output shows that the test failed with seed `S`,
/// simply adding parameter `seed=S` into the function will force it
/// to run for that specific seed.
///
@isTest
void testRandom(
  String name,
  void Function(Random random) body, {
  String? testOn,
  Timeout? timeout,
  dynamic skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  int? seed,
}) {
  seed ??= _rnd.nextInt(_maxSeed);
  test(
    '$name [seed=$seed]',
    () => body(Random(seed)),
    testOn: testOn,
    timeout: timeout,
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}

/// This function is equivalent to `testWidgets(name, body)`, except that
/// it is better suited for randomized testing: it will create a Random
/// generator and pass it to the test body, but also record the seed
/// that was used for creating the random generator. Thus, if a test
/// fails for a specific rare seed, it would be easy to reproduce this
/// failure.
///
/// In order for this to work properly, all random number generation
/// within `testRandomWidgets()` must be performed through the provided
/// random generator.
///
/// Example of use:
///
///     testRandomWidgets(
///       'description',
///       (Random random, WidgetTester tester) async {
///         ...
///       },
///     );
///
/// Then if the test output shows that the test failed with seed `S`,
/// simply adding parameter `seed=S` into the function will force it
/// to run for that specific seed.
///
@isTest
void testWidgetsRandom(
  String description,
  Future<void> Function(Random random, WidgetTester widgetTester) callback, {
  bool? skip,
  Timeout? timeout,
  Duration? initialTimeout,
  bool semanticsEnabled = true,
  dynamic tags,
  int? seed,
}) {
  seed ??= _rnd.nextInt(_maxSeed);
  testWidgets(
    '$description [seed=$seed]',
    (WidgetTester widgetTester) => callback(Random(seed), widgetTester),
    skip: skip,
    timeout: timeout,
    initialTimeout: initialTimeout,
    semanticsEnabled: semanticsEnabled,
    tags: tags,
  );
}
