import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('DecimalFn', () {
    test('decimal() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {decimal(2)}
          2.3   -> {decimal(2.3)}
          2.5   -> {decimal(2.5)}
          2.99  -> {decimal(2.99)}
          -0.3  -> {decimal(-0.3)}
          -0.95 -> {decimal(-0.95)}
          -1.05 -> {decimal(-1.05)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 0
          line: 2.3   -> 0.2999999999999998
          line: 2.5   -> 0.5
          line: 2.99  -> 0.9900000000000002
          line: -0.3  -> -0.3
          line: -0.95 -> -0.95
          line: -1.05 -> -0.050000000000000044
        ''',
      );
    });
  });
}
