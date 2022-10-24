
import 'package:test/test.dart';

import '../../test_scenario.dart';

void main() {
  group('NumLiteral', () {
    testScenario(
      testName: 'DecimalNumbers.yarn',
      input: r'''
        title: Start
        ---

        // Declarations (i.e. constant values)
        <<declare $myInteger = 1 as number>>
        <<declare $myFloat = 1.2 as number>>

        // Expressions
        <<if 1.2 >= 1.2>>
            Success
        <<endif>>

        // Inline expressions
        Here's a number: {45.1}

        ===
      ''',
      testPlan: '''
        line: Success
        line: Here's a number: 45.1
      ''',
      skip: true,
    );
  });
}
