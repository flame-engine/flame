import 'package:test/test.dart';

import '../../test_scenario.dart';

void main() {
  group('IfCommand', () {
    testScenario(
      testName: 'IfStatements.yarn',
      input: '''
        title: Start
        ---
        <<if true>>
          Player: Hey, Sally. #line:794945
          Sally: Oh! Hi. #line:2dc39b
          Sally: You snuck up on me. #line:34de2f
          Sally: Don't do that. #line:dcc2bc
        <<else>>
          Player: Hey. #line:a8e70c
          Sally: Hi. #line:305cde
        <<endif>>
        ===
      ''',
      testPlan: '''
        line: Player: Hey, Sally.
        line: Sally: Oh! Hi.
        line: Sally: You snuck up on me.
        line: Sally: Don't do that.
      ''',
      skip: true,
    );
  });
}
