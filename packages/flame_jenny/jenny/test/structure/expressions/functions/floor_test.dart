import 'package:test/test.dart';

import '../../../test_scenario.dart';

void main() {
  group('FloorFn', () {
    test('floor() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2     -> {floor(2)}
          2.3   -> {floor(2.3)}
          2.5   -> {floor(2.5)}
          2.99  -> {floor(2.99)}
          -0.3  -> {floor(-0.3)}
          -0.95 -> {floor(-0.95)}
          ===
        ''',
        testPlan: '''
          line: 2     -> 2
          line: 2.3   -> 2
          line: 2.5   -> 2
          line: 2.99  -> 2
          line: -0.3  -> -1
          line: -0.95 -> -1
        ''',
      );
    });
  });
}
