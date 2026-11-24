@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flame_cli/src/create_templates.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_templates');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  final packages = p.normalize(p.absolute('..'));

  for (final template in CreateTemplate.all) {
    test(
      'the ${template.name} template is analyzed and formatted cleanly',
      () async {
        const name = 'my_game';
        final project = Directory(p.join(directory.path, template.name));
        for (final MapEntry(key: path, value: contents)
            in template.files.entries) {
          File(p.join(project.path, path))
            ..createSync(recursive: true)
            ..writeAsStringSync(contents.replaceAll('{{name}}', name));
        }
        File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync('''
name: $name
publish_to: none

environment:
  sdk: ">=3.13.0 <4.0.0"

dependencies:
  flame: any
  flutter:
    sdk: flutter

dev_dependencies:
  flame_lint: any
  flame_test: any
  flutter_test:
    sdk: flutter

dependency_overrides:
  flame:
    path: ${p.join(packages, 'flame')}
  flame_lint:
    path: ${p.join(packages, 'flame_lint')}
  flame_test:
    path: ${p.join(packages, 'flame_test')}
''');
        File(
          p.join(project.path, 'analysis_options.yaml'),
        ).writeAsStringSync(
          'include: package:flame_lint/analysis_options.yaml\n',
        );

        await _run('flutter', ['pub', 'get'], project);
        await _run('flutter', ['analyze', '--fatal-infos'], project);
        await _run('dart', [
          'format',
          '--output=none',
          '--set-exit-if-changed',
          '.',
        ], project);
      },
    );
  }
}

Future<void> _run(
  String executable,
  List<String> arguments,
  Directory directory,
) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: directory.path,
    runInShell: Platform.isWindows,
  );
  expect(
    result.exitCode,
    0,
    reason:
        '$executable ${arguments.join(' ')}\n${result.stdout}${result.stderr}',
  );
}
