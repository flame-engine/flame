import 'package:jenny/src/structure/expressions/functions/plural.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('PluralFn', () {
    test('apples-apples-apples', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {plural(0, "apple")} {plural(1, "apple")} {plural(2, "apple")} 
          {plural(11, "apple")} {plural(20, "apple")} {plural(21, "apple")} 
          {plural(101, "apple")} {plural(111, "apple")} {plural(1111, "apple")}
          
          {plural(1, "% table")} - {plural(5, "% table")}
          {plural(1, "% foot", "% feet")} - {plural(20, "% foot", "% feet")}
          ===
        ''',
        testPlan: '''
          line: apples apple apples
          line: apples apples apple
          line: apple apples apples
          line: 1 table - 5 tables
          line: 1 foot - 20 feet
        ''',
      );
    });

    test('auto plurals', () {
      String plural(int n, String word) {
        final f = PluralFn(NumLiteral(n), [StringLiteral(word)], YarnProject());
        return '$n ${f.value}';
      }

      expect(plural(1, 'spoon'), '1 spoon');
      expect(plural(2, 'spoon'), '2 spoons');
      expect(plural(21, 'fox'), '21 fox');
      expect(plural(30, 'fox'), '30 foxes');
      expect(plural(101, 'fox'), '101 fox');
      expect(plural(111, 'fox'), '111 foxes');
      expect(plural(121, 'fox'), '121 fox');
      expect(plural(-5, 'dollar'), '-5 dollars');
      expect(plural(-1, 'dollar'), '-1 dollar');
      expect(plural(17, 'bench'), '17 benches');
      expect(plural(2, 'stash'), '2 stashes');
      expect(plural(200, 'ass'), '200 asses');
      expect(plural(100500, 'zombie'), '100500 zombies');
      expect(plural(3, 'ally'), '3 allies');
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{plural(1)}\n===\n',
          ),
        hasTypeError(
          'TypeError: function plural() requires at least 2 arguments\n'
          '>  at line 3 column 11:\n'
          '>  {plural(1)}\n'
          '>            ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{plural(1, 2, 3, 4)}\n===\n',
          ),
        hasTypeError(
          'TypeError: function plural() requires at most 3 arguments\n'
          '>  at line 3 column 20:\n'
          '>  {plural(1, 2, 3, 4)}\n'
          '>                     ^\n',
        ),
      );
    });

    test('invalid argument 1 type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{plural("", "apple")}\n===\n',
          ),
        hasTypeError(
          'TypeError: the first argument in plural() should be numeric\n'
          '>  at line 3 column 9:\n'
          '>  {plural("", "apple")}\n'
          '>          ^\n',
        ),
      );
    });

    test('invalid argument 2 type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{plural(7, 3, "apple")}\n===\n',
          ),
        hasTypeError(
          'TypeError: a string argument is expected\n'
          '>  at line 3 column 12:\n'
          '>  {plural(7, 3, "apple")}\n'
          '>             ^\n',
        ),
      );
    });

    test('invalid argument 3 type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{plural(7, "apple", false)}\n===\n',
          ),
        hasTypeError(
          'TypeError: a string argument is expected\n'
          '>  at line 3 column 21:\n'
          '>  {plural(7, "apple", false)}\n'
          '>                      ^\n',
        ),
      );
    });
  });
}
