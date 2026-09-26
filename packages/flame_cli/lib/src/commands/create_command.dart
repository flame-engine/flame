import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/run_command.dart';
import 'package:flame_cli/src/create_templates.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:path/path.dart' as p;

/// Creates a new Flame game, the same way `flutter create` creates a new
/// Flutter app: without questions, with sensible defaults, and with options
/// to change them.
///
/// It runs `flutter create` for the platform folders and the pubspec, writes
/// the files of the chosen template on top, and adds the Flame packages with
/// `flutter pub add`, so that the newest compatible versions are used.
class CreateCommand extends Command<int> {
  CreateCommand(
    this.out,
    this.workingDirectory, {
    ProcessStarter? startProcess,
    StringSink? err,
  }) : _startProcess = startProcess ?? Process.start,
       _err = err ?? stderr {
    argParser
      ..addOption(
        'project-name',
        help:
            'The name of the game, which has to be a valid Dart package name. '
            'Defaults to the name of the output directory.',
      )
      ..addOption(
        'org',
        help:
            'The organization responsible for the game, in reverse domain '
            'name notation. It is used for the bundle and package identifiers.',
        defaultsTo: 'com.example',
      )
      ..addOption(
        'description',
        help: 'The description that ends up in the pubspec.yaml.',
        defaultsTo: 'A new Flame game.',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'The template to create the game from.',
        allowed: [for (final template in CreateTemplate.all) template.name],
        allowedHelp: {
          for (final template in CreateTemplate.all)
            template.name: template.description,
        },
        defaultsTo: CreateTemplate.basics.name,
      )
      ..addOption(
        'platforms',
        help:
            'The platforms supported by the game, as a comma separated list, '
            'passed on to `flutter create`. Defaults to all of them.',
      )
      ..addMultiOption(
        'packages',
        help:
            'Additional Flame packages to add, for example flame_audio or '
            'flame_tiled.',
      )
      ..addOption(
        'flame-version',
        help:
            'The version constraint of the flame package, for example ^1.30.0. '
            'Defaults to the newest version.',
      )
      ..addFlag(
        'overwrite',
        help: 'Overwrite the files of a game that already exists.',
      );
  }

  final StringSink out;
  final Directory workingDirectory;
  final ProcessStarter _startProcess;
  final StringSink _err;

  @override
  String get name => 'create';

  @override
  String get description =>
      'Create a new Flame game, like `flutter create` but with a game from a '
      'Flame template and the Flame packages set up.';

  @override
  String get invocation => 'flame create <output directory>';

  @override
  String get category => CommandCategories.creating;

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 1) {
      throw UsageException('Pass the output directory of the game.', usage);
    }
    final directory = Directory(
      p.normalize(p.join(workingDirectory.path, rest.single)),
    );
    final projectName =
        argResults!.option('project-name') ?? p.basename(directory.path);
    final nameError = validateProjectName(projectName);
    if (nameError != null) {
      throw UsageException(nameError, usage);
    }
    final org = argResults!.option('org')!;
    if (!RegExp(
      r'^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*$',
    ).hasMatch(org)) {
      throw UsageException(
        '--org has to be in reverse domain name notation, like com.example.',
        usage,
      );
    }
    final template = CreateTemplate.byName(argResults!.option('template')!)!;
    final overwrite = argResults!.flag('overwrite');
    if (!overwrite &&
        File(p.join(directory.path, 'pubspec.yaml')).existsSync()) {
      throw FlameCliException(
        '${directory.path} already contains a project. Pass --overwrite to '
        'replace its files.',
        exitCode: ExitCodes.data,
      );
    }

    final flutterCreateArguments = [
      'create',
      '--empty',
      '--project-name',
      projectName,
      '--org',
      org,
      '--description',
      argResults!.option('description')!,
      if (argResults!.option('platforms') != null)
        '--platforms=${argResults!.option('platforms')}',
      if (overwrite) '--overwrite',
      directory.path,
    ];
    await _flutter(flutterCreateArguments, 'create the Flutter project');

    _writeTemplate(template, directory, projectName);

    await _flutter(
      ['pub', 'remove', 'flutter_lints'],
      'remove flutter_lints',
      workingDirectory: directory,
      ignoreFailure: true,
    );
    final flameVersion = argResults!.option('flame-version');
    await _flutter(
      [
        'pub',
        'add',
        if (flameVersion == null) 'flame' else 'flame@$flameVersion',
        'dev:flame_lint',
        if (template.hasTests) 'dev:flame_test',
        ...argResults!.multiOption('packages'),
      ],
      'add the Flame packages',
      workingDirectory: directory,
    );

    final relative = p.relative(directory.path, from: workingDirectory.path);
    out.writeln(
      '\nCreated the Flame game $projectName in $relative from the '
      '${template.name} template.\n'
      '\n'
      'To run it:\n'
      '  cd $relative\n'
      '  flame run\n',
    );
    return ExitCodes.success;
  }

  void _writeTemplate(
    CreateTemplate template,
    Directory directory,
    String projectName,
  ) {
    final files = {
      ...template.files,
      'analysis_options.yaml':
          'include: package:flame_lint/analysis_options.yaml\n',
    };
    final generatedTest = File(
      p.join(directory.path, 'test', 'widget_test.dart'),
    );
    if (generatedTest.existsSync()) {
      generatedTest.deleteSync();
    }
    for (final entry in files.entries) {
      final content = entry.value
          .replaceAll('{{name}}', projectName)
          .replaceAll('{{description}}', argResults!.option('description')!);
      File(p.join(directory.path, entry.key))
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }
  }

  Future<void> _flutter(
    List<String> arguments,
    String purpose, {
    Directory? workingDirectory,
    bool ignoreFailure = false,
  }) async {
    final Process process;
    try {
      process = await _startProcess(
        'flutter',
        arguments,
        workingDirectory: (workingDirectory ?? this.workingDirectory).path,
        runInShell: Platform.isWindows,
        mode: ProcessStartMode.normal,
      );
    } on ProcessException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not start `flutter`: ${error.message}\n'
          'Make sure that Flutter is installed and on your PATH.',
          exitCode: ExitCodes.unavailable,
        ),
        stackTrace,
      );
    }
    await Future.wait([
      utf8.decoder.bind(process.stdout).forEach(out.write),
      utf8.decoder.bind(process.stderr).forEach(_err.write),
    ]);
    final exitCode = await process.exitCode;
    if (exitCode != 0 && !ignoreFailure) {
      throw FlameCliException(
        '`flutter ${arguments.join(' ')}` failed with exit code $exitCode, '
        'so it was not possible to $purpose.',
      );
    }
  }
}

const _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

const _reservedNames = {
  'collection',
  'flame',
  'flame_lint',
  'flame_test',
  'flutter',
  'flutter_test',
  'meta',
  'test',
};

/// Returns why [name] cannot be the name of a game, or null if it can.
///
/// The rules are the ones of `flutter create`: a lowercase Dart identifier
/// that is not a keyword and does not clash with the packages a game depends
/// on.
String? validateProjectName(String name) {
  if (!RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name) ||
      _dartKeywords.contains(name)) {
    final suggestion = name
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(RegExp('[^a-z0-9_]'), '');
    final suggestionIsValid =
        suggestion.isNotEmpty &&
        suggestion != name &&
        validateProjectName(suggestion) == null;
    return '"$name" is not a valid Dart package name'
        '${suggestionIsValid ? ', try "$suggestion" instead' : ''}. '
        'The name has to consist of lowercase letters, digits and '
        'underscores, cannot start with a digit and cannot be a reserved '
        'word. Pass --project-name to use a different name than the '
        'directory.';
  }
  if (_reservedNames.contains(name)) {
    return '"$name" cannot be the name of a game, it would clash with the '
        'package of that name that the game depends on.';
  }
  return null;
}
