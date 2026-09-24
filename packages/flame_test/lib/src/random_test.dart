import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

final _seedGenerator = Random();
// Maximum value allowed for `Random.nextInt()`
const _maxSeed = 1 << 32;

/// Get the random seed for a test. If the [seed] parameter is passed in,
/// it takes precedence. Otherwise, if the compile-time environment variable
/// `RANDOM_SEED` is set (`flutter test --dart-define=RANDOM_SEED=NNN`), it is
/// used. If neither is set, returns null.
///
/// When `RANDOM_SEED` is set, every randomized test in the run becomes
/// deterministic: each test starts from that seed and each repeat of a test
/// offsets it by the repeat index.
int? seedFromEnvironment(int? seed) {
  if (seed != null) {
    return seed;
  }

  // ignore: do_not_use_environment
  const seedString = String.fromEnvironment(
    'RANDOM_SEED',
  );
  if (seedString.isEmpty) {
    return null;
  }
  return int.tryParse(seedString);
}

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
/// times, each time with a different seed. When the seed is fixed, either
/// through the `seed` parameter or the `RANDOM_SEED` environment variable,
/// repeat number `i` uses `seed + i` so that the repeats stay distinct while
/// remaining reproducible.
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
  final resolvedSeed = seedFromEnvironment(seed);
  for (var i = 0; i < repeatCount; i++) {
    final seed0 = resolvedSeed != null
        ? resolvedSeed + i
        : _seedGenerator.nextInt(_maxSeed);
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

typedef TestWidgetsCallback =
    Future<void> Function(
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
/// to run for that specific seed. The `RANDOM_SEED` environment variable is
/// honored in the same way as for [testRandom].
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
  final resolvedSeed =
      seedFromEnvironment(seed) ?? _seedGenerator.nextInt(_maxSeed);
  testWidgets(
    '$description [seed=$resolvedSeed]',
    (WidgetTester widgetTester) => callback(Random(resolvedSeed), widgetTester),
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    tags: tags,
  );
}
