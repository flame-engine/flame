import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/statement.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueChoice', () {
    test('.kind', () {
      const choiceSet = DialogueChoice([]);
      expect(choiceSet.options.isEmpty, true);
      expect(choiceSet.kind, StatementKind.choice);
    });
  });
}
