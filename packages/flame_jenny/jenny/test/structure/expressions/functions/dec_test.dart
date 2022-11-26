import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('DecFn', () {
    test('dec() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {dec(2)}
          2.3   -> {dec(2.3)}
          2.5   -> {dec(2.5)}
          2.99  -> {dec(2.99)}
          -0.3  -> {dec(-0.3)}
          -0.95 -> {dec(-0.95)}
          -1.05 -> {dec(-1.05)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 1
          line: 2.3   -> 2
          line: 2.5   -> 2
          line: 2.99  -> 2
          line: -0.3  -> -1
          line: -0.95 -> -1
          line: -1.05 -> -2
        ''',
      );
    });
  });
}
