import 'dart:io';

import 'package:flame_studio/clients/clients.dart';
import 'package:flutter_test/flutter_test.dart';

Directory _createTempDirectory() {
  final directory = Directory.systemTemp.createTempSync();
  addTearDown(() => directory.deleteSync(recursive: true));
  return directory;
}

void main() {
  group(FileSystemClient, () {
    test('can be instantiated without a directory picker', () {
      expect(FileSystemClient.new, returnsNormally);
    });

    test('listFiles goes into subdirectories when recursive', () async {
      final directory = _createTempDirectory();
      File('${directory.path}/a/b.txt').createSync(recursive: true);
      File('${directory.path}/c.txt').createSync();
      final client = FileSystemClient(directoryPicker: () async => null);

      expect(await client.listFiles(directory.path), hasLength(1));
      expect(
        await client.listFiles(directory.path, recursive: true),
        hasLength(2),
      );
    });

    test('readFileBytes reads the contents of a file', () async {
      final directory = _createTempDirectory();
      final file = File('${directory.path}/a.bin')..writeAsBytesSync([1, 2]);
      final client = FileSystemClient(directoryPicker: () async => null);

      expect(await client.readFileBytes(file.path), equals([1, 2]));
    });

    group('pickDirectory', () {
      test('returns the picked path', () async {
        final client = FileSystemClient(directoryPicker: () async => '/a/b');

        expect(await client.pickDirectory(), equals('/a/b'));
      });

      test('returns null when cancelled', () async {
        final client = FileSystemClient(directoryPicker: () async => null);

        expect(await client.pickDirectory(), isNull);
      });
    });

    group('directoryExists', () {
      test('returns true for an existing directory', () async {
        final directory = Directory.systemTemp.createTempSync();
        addTearDown(() => directory.deleteSync(recursive: true));

        expect(
          await FileSystemClient().directoryExists(directory.path),
          isTrue,
        );
      });

      test('returns false for a missing directory', () async {
        final directory = Directory.systemTemp.createTempSync()..deleteSync();

        expect(
          await FileSystemClient().directoryExists(directory.path),
          isFalse,
        );
      });
    });

    group('fileExists', () {
      test('returns whether the file exists', () async {
        final directory = _createTempDirectory();
        final file = File('${directory.path}/a.txt')..writeAsStringSync('a');

        expect(await FileSystemClient().fileExists(file.path), isTrue);
        expect(
          await FileSystemClient().fileExists('${directory.path}/b.txt'),
          isFalse,
        );
      });
    });

    group('listFiles', () {
      test('returns an empty list for a missing directory', () async {
        final directory = Directory.systemTemp.createTempSync()..deleteSync();

        expect(await FileSystemClient().listFiles(directory.path), isEmpty);
      });

      test('returns only files, filtered by extension', () async {
        final directory = _createTempDirectory();
        File('${directory.path}/a.json').writeAsStringSync('{}');
        File('${directory.path}/b.txt').writeAsStringSync('b');
        Directory('${directory.path}/c.json').createSync();

        expect(
          await FileSystemClient().listFiles(directory.path),
          unorderedEquals([
            '${directory.path}/a.json',
            '${directory.path}/b.txt',
          ]),
        );
        expect(
          await FileSystemClient().listFiles(
            directory.path,
            extension: '.json',
          ),
          equals(['${directory.path}/a.json']),
        );
      });
    });

    group('writeFile and readFile', () {
      test('creates parent directories and round-trips contents', () async {
        final directory = _createTempDirectory();
        final path = '${directory.path}/nested/dir/a.txt';

        await FileSystemClient().writeFile(path, 'hello');

        expect(await FileSystemClient().readFile(path), equals('hello'));
      });
    });

    group('deleteFile', () {
      test('deletes the file', () async {
        final directory = _createTempDirectory();
        final file = File('${directory.path}/a.txt')..writeAsStringSync('a');

        await FileSystemClient().deleteFile(file.path);

        expect(file.existsSync(), isFalse);
      });
    });
  });
}
