
import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/statement.dart';
import 'package:test/test.dart';

void main() {
  group('DialogueChoice', () {
    test('.kind', () {
      final choiceSet = DialogueChoice([]);
      expect(choiceSet.options.isEmpty, true);
      expect(choiceSet.kind, StatementKind.choice);
    });
  });
}
