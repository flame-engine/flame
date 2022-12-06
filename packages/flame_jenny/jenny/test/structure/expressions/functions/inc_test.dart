import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('IncFn', () {
    test('inc() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {inc(2)}
          2.3   -> {inc(2.3)}
          2.5   -> {inc(2.5)}
          2.99  -> {inc(2.99)}
          -0.3  -> {inc(-0.3)}
          -0.95 -> {inc(-0.95)}
          -1.05 -> {inc(-1.05)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 3
          line: 2.3   -> 3
          line: 2.5   -> 3
          line: 2.99  -> 3
          line: -0.3  -> 0
          line: -0.95 -> 0
          line: -1.05 -> -1
        ''',
      );
    });
  });
}
