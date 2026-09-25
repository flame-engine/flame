import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('vmServiceUriFile is placed in .dart_tool of the project', () {
    expect(
      vmServiceUriFile(directory).path,
      p.join(directory.path, '.dart_tool', 'flame', 'vm_service_uri'),
    );
  });

  group('findProjectRoot', () {
    test('finds the closest directory with a pubspec', () {
      File(p.join(directory.path, 'pubspec.yaml')).createSync();
      final lib = Directory(p.join(directory.path, 'lib', 'src'))
        ..createSync(recursive: true);

      expect(findProjectRoot(lib).path, directory.absolute.path);
      expect(findProjectRoot(directory).path, directory.absolute.path);
    });

    test('prefers a nested project over its parent', () {
      File(p.join(directory.path, 'pubspec.yaml')).createSync();
      final example = Directory(p.join(directory.path, 'example'))
        ..createSync();
      File(p.join(example.path, 'pubspec.yaml')).createSync();

      expect(findProjectRoot(example).path, example.absolute.path);
    });

    test('falls back to the directory itself', () {
      final child = Directory(p.join(directory.path, 'child'))..createSync();

      expect(findProjectRoot(child).path, child.absolute.path);
    });
  });

  group('findVmServiceUriFile', () {
    test('finds the file in the directory itself', () {
      final file = vmServiceUriFile(directory)..createSync(recursive: true);

      expect(findVmServiceUriFile(directory)?.path, file.absolute.path);
    });

    test('finds the file in a parent directory', () {
      final file = vmServiceUriFile(directory)..createSync(recursive: true);
      final child = Directory(p.join(directory.path, 'lib', 'src'))
        ..createSync(recursive: true);

      expect(findVmServiceUriFile(child)?.path, file.absolute.path);
    });

    test('returns null when there is no file', () {
      expect(findVmServiceUriFile(directory), isNull);
    });
  });
}
