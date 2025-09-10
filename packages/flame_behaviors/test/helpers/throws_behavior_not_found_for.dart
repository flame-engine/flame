import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter_test/flutter_test.dart';

/// A matcher for [StateError]s thrown when a certain behavior is not found.
Matcher throwsBehaviorNotFoundFor<T extends Behavior>() => throwsA(
  isStateError.having(
    (e) => e.message,
    'message',
    equals('No behavior of type $T found.'),
  ),
);
