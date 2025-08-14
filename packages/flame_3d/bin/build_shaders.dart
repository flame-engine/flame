import 'dart:convert';
import 'dart:io';

/// Bundle a shader ('name'.frag & 'name'.vert) into a single shader bundle and
/// store it in the assets directory.
///
/// This script is just a temporary way to bundle shaders. In the long run
/// Flutter might support auto-bundling themselves but until then we have to
/// do it manually.
///
/// Note: this script should be run from the root of the package:
/// packages/flame_3d
void main(List<String> arguments) async {
  final root = Directory.current;
  final assets = Directory.fromUri(root.uri.resolve('assets/shaders'));
  final shaders = Directory.fromUri(root.uri.resolve('shaders'));

  await compute(assets, shaders);
  if (arguments.contains('watch')) {
    stdout.writeln('Running in watch mode');
    shaders.watch(recursive: true).listen((event) {
      compute(assets, shaders);
    });
  }
}

Future<void> compute(Directory assets, Directory shaders) async {
  // Delete all the bundled shaders so we can replace them with new ones.
  if (assets.existsSync()) {
    assets.deleteSync(recursive: true);
  }
  // Create if not exists.
  assets.createSync(recursive: true);

  if (!shaders.existsSync()) {
    return stderr.writeln('Missing shader directory');
  }

  // Get a list of unique shader names. Each shader should have a .frag and
  // .vert with the same basename to be considered a bundle.
  final uniqueShaders = shaders
      .listSync()
      .whereType<File>()
      .map((f) => f.path.split(Platform.pathSeparator).last.split('.').first)
      .toSet();

  for (final name in uniqueShaders) {
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

    stdout.writeln('Computing shader "$name"');
    final impellerC = await findImpellerC();
    final result = await Process.run(impellerC.toFilePath(), [
      '--sl=${assets.path}${Platform.pathSeparator}$name.shaderbundle',
      '--shader-bundle=${jsonEncode(bundle)}',
    ]);

    if (result.exitCode != 0) {
      return stderr.writeln(result.stderr);
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
Uri findEngineArtifactsDir({String? dartPath}) {
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
Future<Uri> findImpellerC() async {
  /////////////////////////////////////////////////////////////////////////////
  /// 1. If the `IMPELLERC` environment variable is set, use it.
  ///

  // ignore: do_not_use_environment
  const impellercEnvVar = String.fromEnvironment('IMPELLERC');
  if (impellercEnvVar != '') {
    if (!doesFileExist(impellercEnvVar)) {
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

  final engineArtifactsDir = findEngineArtifactsDir();

  // No need to get fancy. Just search all the possible directories rather than
  // picking the correct one for the specific host type.
  Uri? found;
  final tried = <Uri>[];
  for (final variant in _impellercLocations) {
    final impellercPath = engineArtifactsDir.resolve(variant);
    if (doesFileExist(impellercPath.toFilePath())) {
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

bool doesFileExist(String path) {
  return File(path).existsSync();
}
