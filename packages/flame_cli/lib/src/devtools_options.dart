import 'dart:io';

import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/project_files.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// The name of the file in the root of a project that stores which DevTools
/// extensions are enabled for it.
const devToolsOptionsFileName = 'devtools_options.yaml';

/// The name of the Flame DevTools extension in [devToolsOptionsFileName].
const flameExtensionName = 'flame';

/// The `devtools_options.yaml` of the project that [directory] is in.
File devToolsOptionsFile(Directory directory) {
  return File(
    p.join(findProjectRoot(directory).path, devToolsOptionsFileName),
  );
}

/// Enables the Flame DevTools extension in [optionsFile], the
/// `devtools_options.yaml` of a project, so that the DevTools show the Flame
/// tab right away instead of asking whether to enable the extension.
///
/// The file is created when it does not exist, and otherwise only the entry
/// of the extension is changed, so that the other settings in the file are
/// kept. Returns whether the file was changed.
bool enableFlameExtension(File optionsFile) {
  if (!optionsFile.existsSync()) {
    optionsFile.writeAsStringSync(
      'description: This file stores settings for Dart & Flutter DevTools.\n'
      'documentation: $_documentationUrl\n'
      'extensions:\n'
      '  - $flameExtensionName: true\n',
    );
    return true;
  }

  final content = optionsFile.readAsStringSync();
  final Object? document;
  try {
    document = loadYaml(content);
  } on YamlException catch (error, stackTrace) {
    Error.throwWithStackTrace(
      FlameCliException(
        'Could not read ${optionsFile.path}: ${error.message}',
        exitCode: ExitCode.data,
      ),
      stackTrace,
    );
  }

  final extensions = document is Map ? document['extensions'] : null;
  final editor = YamlEditor(content);
  if (extensions is! List) {
    if (document is! Map) {
      editor.update([], {
        'extensions': [
          {flameExtensionName: true},
        ],
      });
    } else {
      editor.update(
        ['extensions'],
        [
          {flameExtensionName: true},
        ],
      );
    }
  } else {
    final index = extensions.indexWhere(
      (entry) => entry is Map && entry.containsKey(flameExtensionName),
    );
    if (index == -1) {
      editor.appendToList(['extensions'], {flameExtensionName: true});
    } else if ((extensions[index] as Map)[flameExtensionName] == true) {
      return false;
    } else {
      editor.update(['extensions', index, flameExtensionName], true);
    }
  }
  final updated = editor.toString();
  optionsFile.writeAsStringSync(
    updated.endsWith('\n') ? updated : '$updated\n',
  );
  return true;
}

const _documentationUrl =
    'https://docs.flutter.dev/tools/devtools/extensions#configure-extension-enablement-states';
