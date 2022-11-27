import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('FloorFn', () {
    test('floor() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {ceil(2)}
          2.3   -> {ceil(2.3)}
          2.5   -> {ceil(2.5)}
          2.99  -> {ceil(2.99)}
          -0.3  -> {ceil(-0.3)}
          -0.95 -> {ceil(-0.95)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 2
          line: 2.3   -> 3
          line: 2.5   -> 3
          line: 2.99  -> 3
          line: -0.3  -> 0
          line: -0.95 -> 0
        ''',
      );
    });
  });
}
