import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:test/test.dart';

import '../test_scenario.dart';

void main() {
  group('DialogueChoice', () {
    test('.kind', () {
      const choiceSet = DialogueChoice([]);
      expect(choiceSet.options.isEmpty, true);
      expect(choiceSet.kind, StatementKind.choice);
    });

    testScenario(
      testName: 'Options.yarn',
      input: '''
        title: A
        ---
        -> Go to B
            <<jump B>>
        -> Go to C
            <<jump C>>
        ===
        title: B
        ---
        Node B
        ===
        title: C
        ---
        Node C
        ===
      ''',
      testPlan: '''
        run: A
        option: Go to B
        option: Go to C
        select: 2
        line: Node C
      ''',
    );

    testScenario(
      testName: 'SkippedOptions.yarn',
      input: '''
        title: Start
        ---
        // These options exist in the node, but are never actually added to 
        // the set of options at runtime.
        <<if false>>
            -> Shh...
            -> Ugh fine sure
        <<endif>>
        ===
        ''',
      testPlan: '',
    );
  });
}
