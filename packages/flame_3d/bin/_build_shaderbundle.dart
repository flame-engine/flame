import 'dart:convert';
import 'dart:io';

/// Build each shader in [names] into a `.shaderbundle` asset in [assets].
///
/// Each name must have a matching `.vert` and `.frag` in [shaders]. Stale
/// `.shaderbundle` files are removed first and other assets are left untouched.
Future<void> build(
  Iterable<String> names,
  Directory shaders,
  Directory assets,
  List<Directory> packageShaderDirs,
) async {
  for (final file in assets.listSync().whereType<File>()) {
    if (file.path.endsWith('.shaderbundle')) {
      file.deleteSync();
    }
  }

  final impellerC = await _findImpellerC();
  final engineShaderLib = impellerC.resolve('./shader_lib/').toFilePath();

  for (final name in names) {
    final bundle = {
      'TextureFragment': {
        'type': 'fragment',
        'file': '${shaders.path}${Platform.pathSeparator}$name.frag',
      },
      'TextureVertex': {
        'type': 'vertex',
        'file': '${shaders.path}${Platform.pathSeparator}$name.vert',
      },
    };

    stdout.writeln('Computing shader bundle "$name"');
    final result = await Process.run(impellerC.toFilePath(), [
      '--sl=${assets.path}${Platform.pathSeparator}$name.shaderbundle',
      '--shader-bundle=${jsonEncode(bundle)}',
      '--include=${shaders.path}',
      for (final dir in packageShaderDirs) '--include=${dir.path}',
      '--include=$engineShaderLib',
    ]);

    if (result.exitCode != 0) {
      stderr.writeln('Failed to compile shader "$name":\n${result.stderr}');
      exitCode = 1;
    }
  }
}

// Copied from https://github.com/bdero/flutter_gpu_shaders/blob/master/lib/environment.dart#L53
const _macosHostArtifacts = 'darwin-x64';
const _linuxHostArtifacts = 'linux-x64';
const _windowsHostArtifacts = 'windows-x64';

const _impellercLocations = [
  '$_macosHostArtifacts/impellerc',
  '$_linuxHostArtifacts/impellerc',
  '$_windowsHostArtifacts/impellerc.exe',
];

/// Locate the engine artifacts cache directory in the Flutter SDK.
Uri _findEngineArtifactsDir({String? dartPath}) {
  // Could be:
  //   `/path/to/flutter/bin/cache/dart-sdk/bin/dart`
  //   `/path/to/flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester`
  //   `/path/to/.user/shared/caches/94cf8c8fad31206e440611e309757a5a9b3be712/dart-sdk/bin/dart`
  final dartExec = Uri.file(dartPath ?? Platform.resolvedExecutable);

  Uri? cacheDir;
  // Search backwards through the segment list until finding `bin` and `cache`
  // in sequence.
  for (var i = dartExec.pathSegments.length - 1; i >= 0; i--) {
    if (dartExec.pathSegments[i] == 'dart-sdk' ||
        dartExec.pathSegments[i] == 'artifacts') {
      // Note: The final empty string denotes that this is a directory path.
      cacheDir = dartExec.replace(
        pathSegments: dartExec.pathSegments.sublist(0, i) + [''],
      );
      break;
    }
  }
  if (cacheDir == null) {
    throw Exception(
      'Unable to find Flutter SDK cache directory! '
      'Dart executable: `${dartExec.toFilePath()}`',
    );
  }

  // We should now have a path of `/path/to/flutter/bin/cache/`.
  final engineArtifactsDir = cacheDir.resolve(
    './artifacts/engine/',
  ); // Note: The final slash is important.

  return engineArtifactsDir;
}

/// Locate the ImpellerC offline shader compiler in the engine artifacts cache
/// directory.
Future<Uri> _findImpellerC() async {
  /////////////////////////////////////////////////////////////////////////////
  /// 1. If the `IMPELLERC` environment variable is set, use it.
  ///

  // ignore: do_not_use_environment
  const impellercEnvVar = String.fromEnvironment('IMPELLERC');
  if (impellercEnvVar != '') {
    if (!File(impellercEnvVar).existsSync()) {
      throw Exception(
        'IMPELLERC environment variable is set, '
        "but it doesn't point to a valid file!",
      );
    }
    return Uri.file(impellercEnvVar);
  }

  /////////////////////////////////////////////////////////////////////////////
  /// 3. Search for the `impellerc` binary within the host-specific artifacts.
  ///

  final engineArtifactsDir = _findEngineArtifactsDir();

  // No need to get fancy. Just search all the possible directories rather than
  // picking the correct one for the specific host type.
  Uri? found;
  final tried = <Uri>[];
  for (final variant in _impellercLocations) {
    final impellercPath = engineArtifactsDir.resolve(variant);
    if (File(impellercPath.toFilePath()).existsSync()) {
      found = impellercPath;
      break;
    }
    tried.add(impellercPath);
  }
  if (found == null) {
    throw Exception(
      'Unable to find impellerc! Tried the following locations: $tried',
    );
  }

  return found;
}
