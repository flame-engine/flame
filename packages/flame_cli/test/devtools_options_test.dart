import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    file = File(p.join(directory.path, devToolsOptionsFileName));
  });

  tearDown(() => directory.deleteSync(recursive: true));

  group('devToolsOptionsFile', () {
    test('is in the root of the project', () {
      File(p.join(directory.path, 'pubspec.yaml')).createSync();
      final lib = Directory(p.join(directory.path, 'lib'))..createSync();

      expect(devToolsOptionsFile(lib).path, file.path);
    });
  });

  group('enableFlameExtension', () {
    test('creates the file when it does not exist', () {
      expect(enableFlameExtension(file), isTrue);

      expect(file.readAsStringSync(), contains('extensions:\n  - flame: true'));
      expect(file.readAsStringSync(), startsWith('description:'));
    });

    test('leaves an enabled extension alone', () {
      const content = 'extensions:\n  - flame: true\n';
      file.writeAsStringSync(content);

      expect(enableFlameExtension(file), isFalse);

      expect(file.readAsStringSync(), content);
    });

    test('enables a disabled extension and keeps the rest', () {
      file.writeAsStringSync(
        '# my settings\n'
        'description: Settings\n'
        'extensions:\n'
        '  - provider: true\n'
        '  - flame: false\n',
      );

      expect(enableFlameExtension(file), isTrue);

      expect(
        file.readAsStringSync(),
        '# my settings\n'
        'description: Settings\n'
        'extensions:\n'
        '  - provider: true\n'
        '  - flame: true\n',
      );
    });

    test('adds the extension to the other extensions', () {
      file.writeAsStringSync('extensions:\n  - provider: true\n');

      expect(enableFlameExtension(file), isTrue);

      expect(
        file.readAsStringSync(),
        'extensions:\n  - provider: true\n  - flame: true\n',
      );
    });

    test('adds the extensions to a file without any', () {
      file.writeAsStringSync('description: Settings\n');

      expect(enableFlameExtension(file), isTrue);

      expect(
        file.readAsStringSync(),
        'description: Settings\nextensions:\n  - flame: true\n',
      );
    });

    test('adds the extensions to an empty file', () {
      file.writeAsStringSync('');

      expect(enableFlameExtension(file), isTrue);

      expect(file.readAsStringSync(), 'extensions:\n  - flame: true\n');
    });

    test('reports a file that cannot be read', () {
      file.writeAsStringSync('extensions: [\n');

      expect(
        () => enableFlameExtension(file),
        throwsA(
          isA<FlameCliException>().having(
            (e) => e.message,
            'message',
            contains('Could not read'),
          ),
        ),
      );
    });
  });
}
