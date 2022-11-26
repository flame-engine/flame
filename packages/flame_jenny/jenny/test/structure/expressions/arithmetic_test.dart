import 'package:test/test.dart';

import '../../test_scenario.dart';

void main() {
  group('arithmetic operations', () {
    testScenario(
      testName: 'Expressions.yarn',
      input: r'''
        <<declare $int = 0>>
        <<declare $bool = true>>
        <<declare $math = 0>>
        ---
        title: Start
        ---
        // Expression testing
        <<set $int to 1>>
        1. {$int == 1}
        2. {$int != 2}

        // Test unary operators
        3. {!$bool == false}
        4. {-$int == -1}
        5. {-$int == 0 - 1}

        // Test more complex expressions
        <<set $math = 5 * 2 - 2 * -1 >>
        6. {$math is 12}

        // Test % operator
        <<set $math = 12 >>
        <<set $math = $math % 5 >>
        7. {$math is 2}

        // Test floating point math
        8. {1 / 2 == 0.5}
        9. {0.1 + 0.1 == 0.2}
        ===
      ''',
      testPlan: '''
        line: 1. true
        line: 2. true
        line: 3. true
        line: 4. true
        line: 5. true
        line: 6. true
        line: 7. true
        line: 8. true
        line: 9. true
      ''',
    );
  });
}
