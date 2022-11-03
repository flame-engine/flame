
import 'package:test/test.dart';

import '../../test_scenario.dart';

void main() {
  group('UserDefinedCommand', () {
    testScenario(testName: 'Commands.yarn',
      input: '''
        title: Start
        ---
        // Testing commands

        <<flip Harley3 +1>>

        // Commands that begin with keywords
        <<toggle>>

        <<settings>>

        <<iffy>>

        <<nulled>>

        <<orion>>

        <<andorian>>

        <<note>>

        <<isActive>>

        // Commands with a single character
        <<p>>

        // Commands with colons
        <<hide Collision:GermOnPorch>>
        ===
      ''',
      testPlan: '''
        command: flip Harley3 +1
        command: toggle
        command: settings
        command: iffy
        command: nulled
        command: orion
        command: andorian
        command: note
        command: isActive
        command: p
        command: hide Collision:GermOnPorch
      ''',
      skip: true,
    );
  });
}
