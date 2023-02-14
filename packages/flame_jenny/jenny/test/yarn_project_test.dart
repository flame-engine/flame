import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('YarnProject', () {
    test('set a locale', () {
      final yarn = YarnProject();
      expect(yarn.locale, 'en');
      yarn.locale = 'uk';
      expect(yarn.locale, 'uk');
    });

    test('set an unknown locale', () {
      final yarn = YarnProject();
      expect(
        () => yarn.locale = 'Klingon',
        hasDialogueError('Unknown locale "Klingon"'),
      );
    });

    test('set locale after parsing', () {
      final yarn = YarnProject()..parse('title:A\n---\n===\n');
      expect(
        () => yarn.locale = 'sv',
        hasDialogueError(
          'The locale cannot be changed after nodes have been added',
        ),
      );
    });
  });
}
