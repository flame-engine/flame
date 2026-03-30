import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shader compilation', () {
    test('shader bundles are up-to-date with sources', () async {
      final packageRoot = Directory.current;
      final assetsDir = Directory.fromUri(
        packageRoot.uri.resolve('assets/shaders'),
      );

      final bundles = assetsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.shaderbundle'))
          .toList();

      final before = {
        for (final bundle in bundles) bundle.path: bundle.readAsBytesSync(),
      };

      // Recompile shaders from source.
      final result = await Process.run(
        'dart',
        ['run', 'bin/build_shaders.dart'],
        workingDirectory: packageRoot.path,
      );

      expect(
        result.exitCode,
        equals(0),
        reason: 'Shader compilation failed:\n${result.stderr}',
      );

      for (final bundle in bundles) {
        final name = bundle.uri.pathSegments.last;
        expect(
          bundle.readAsBytesSync(),
          equals(before[bundle.path]),
          reason:
              'Shader bundle "$name" is out of sync with its sources. '
              'Run: dart run bin/build_shaders.dart',
        );
      }
    });
  });
}
