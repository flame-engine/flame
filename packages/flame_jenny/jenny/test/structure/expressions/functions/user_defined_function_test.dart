import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

// See also: function_storage_test.dart
void main() {
  group('NumericUserDefinedFn', () {
    test('simple udf with numeric return type', () {
      num myFunction() {
        return 42;
      }

      final yarn = YarnProject()
        ..functions.addFunction0('answer', myFunction)
        ..parse(
          'title: A\n---\n'
          'The answer to life, Universe, and everything: { answer() }\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;
      line.evaluate();
      expect(line.text, 'The answer to life, Universe, and everything: 42');
    });
  });

  group('BooleanUserDefinedFn', () {
    test('simple udf with boolean return type', () {
      bool myFunction() {
        return false;
      }

      final yarn = YarnProject()
        ..functions.addFunction0('answer', myFunction)
        ..parse(
          'title: A\n---\n'
          'The Earth is flat -- true or false? { answer() }\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;
      line.evaluate();
      expect(line.text, 'The Earth is flat -- true or false? false');
    });
  });

  group('StringUserDefinedFn', () {
    test('simple udf with string return type', () {
      String myFunction() {
        return 'secret';
      }

      final yarn = YarnProject()
        ..functions.addFunction0('answer', myFunction)
        ..parse(
          'title: A\n---\n'
          'Your favorite color? { answer() }\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;
      line.evaluate();
      expect(line.text, 'Your favorite color? secret');
    });
  });
}
