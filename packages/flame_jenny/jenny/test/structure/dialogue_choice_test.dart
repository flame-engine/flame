import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:test/test.dart';

import '../test_scenario.dart';

void main() {
  group('DialogueChoice', () {
    test('.kind', () {
      const choiceSet = DialogueChoice([]);
      expect(choiceSet.options.isEmpty, true);
    });

    test('Options.yarn', () {
      testScenario(
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
    });

    test('SkippedOptions.yarn', () {
      testScenario(
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

    test('options with dynamic text', () {
      testScenario(
        input: r'''
          <<declare $money = 100>>
          <<declare $player = "Steve">>
          ------------
          title: Start
          ------------
          -> Hi, My name is [bold]{$player}[/bold]
          -> I can give you only {$money / 2} coins -- that's all I have
          ===
        ''',
        testPlan: '''
          option: Hi, My name is Steve
          option: I can give you only 50.0 coins -- that's all I have
          select: 1
        ''',
      );
    });
  });
}
