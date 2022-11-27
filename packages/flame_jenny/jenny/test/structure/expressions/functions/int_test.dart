import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('IntFn', () {
    test('int() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {int(2)}
          2.3   -> {int(2.3)}
          2.5   -> {int(2.5)}
          2.99  -> {int(2.99)}
          -0.3  -> {int(-0.3)}
          -0.95 -> {int(-0.95)}
          -1.05 -> {int(-1.05)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 2
          line: 2.3   -> 2
          line: 2.5   -> 2
          line: 2.99  -> 2
          line: -0.3  -> 0
          line: -0.95 -> 0
          line: -1.05 -> -1
        ''',
      );
    });
  });
}
