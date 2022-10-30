import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

final _seedGenerator = Random();
// Maximum value allowed for `Random.nextInt()`
const _maxSeed = 1 << 32;

/// This function is equivalent to `test(name, body)`, except that it is
/// better suited for randomized testing: it will create a Random
/// generator and pass it to the test body, but also record the seed
/// that was used for creating the random generator. Thus, if a test
/// fails for a specific rare seed, it would be easy to reproduce this
/// failure.
///
/// In order for this to work properly, all random numbers used within
/// `testRandom()` must be obtained through the provided random generator.
///
/// Example of use:
/// ```dart
/// testRandom('description', (Random random) {
///   expect(random.nextDouble() == random.nextDouble(), false);
/// });
/// ```
/// Then if the test output shows that the test failed with seed `s`,
/// simply adding parameter `seed=s` into the function will force it
/// to use that specific seed.
///
/// Optional parameter `repeatCount` allows the test to be repeated multiple
/// times, each time with a different seed.
@isTest
void testRandom(
  String name,
  void Function(Random random) body, {
  int? seed,
  String? testOn,
  Timeout? timeout,
  dynamic skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  int repeatCount = 1,
}) {
  assert(repeatCount > 0, 'repeatCount needs to be a positive number');
  for (var i = 0; i < repeatCount; i++) {
    final seed0 = seed ?? _seedGenerator.nextInt(_maxSeed);
    test(
      '$name [seed=$seed0]',
      () => body(Random(seed0)),
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }
}

typedef TestWidgetsCallback = Future<void> Function(
  Random random,
  WidgetTester widgetTester,
);

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
/// ```dart
/// testRandomWidgets(
///   'description',
///   (Random random, WidgetTester tester) async {
///     ...
///   },
/// );
/// ```
/// Then if the test output shows that the test failed with seed `s`,
/// simply adding parameter `seed=s` into the function will force it
/// to run for that specific seed.
@isTest
void testWidgetsRandom(
  String description,
  TestWidgetsCallback callback, {
  int? seed,
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  dynamic tags,
}) {
  seed ??= _seedGenerator.nextInt(_maxSeed);
  testWidgets(
    '$description [seed=$seed]',
    (WidgetTester widgetTester) => callback(Random(seed), widgetTester),
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    tags: tags,
  );
}
