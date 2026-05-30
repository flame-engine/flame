import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Bundle a shader ('name'.frag & 'name'.vert) into a single shader bundle and
/// store it in the assets directory.
///
/// This script is just a temporary way to bundle shaders. In the long run
/// Flutter might support auto-bundling themselves but until then we have to
/// do it manually.
///
/// Run from the package root whose shaders are being built. When invoked
/// from a consumer package via `dart run flame_3d:build_shaders`, the
/// consumer's own `shaders/` is bundled. Every Dart dependency that ships a
/// top-level `shaders/` directory is added to impellerc's include path under
/// its package name, so shaders can `#include <pkg_name/foo.glsl>` against
/// any of them. `<flutter/...>` resolves to the engine builtins.
void main(List<String> arguments) async {
  final root = Directory.current;
  final assets = Directory.fromUri(root.uri.resolve('assets/shaders'));
  final shaders = Directory.fromUri(root.uri.resolve('shaders'));
  final packageShaderDirs = await _resolvePackageShaderDirs();

  await compute(assets, shaders, packageShaderDirs);
  if (arguments.contains('watch')) {
    stdout.writeln('Running in watch mode');
    shaders.watch(recursive: true).listen((event) {
      compute(assets, shaders, packageShaderDirs);
    });
  }
}

/// Returns every Dart dependency's top-level `shaders/` directory, so an
/// `#include <pkg_name/foo.glsl>` can resolve to
/// `<pkg-root>/shaders/pkg_name/foo.glsl`.
Future<List<Directory>> _resolvePackageShaderDirs() async {
  final configUri = await Isolate.packageConfig;
  if (configUri == null) {
    throw Exception(
      'Unable to locate package_config.json. Run `dart pub get` first.',
    );
  }

  final configFile = File.fromUri(configUri);
  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
  final result = <Directory>[];
  for (final package in packages) {
    final name = package['name'] as String;
    if (name == 'flutter') {
      // `flutter` ships no shader chunks; its includes come from the engine.
      continue;
    }

    final rootUriRaw = package['rootUri'] as String;
    final rootUri = configUri.resolve(
      rootUriRaw.endsWith('/') ? rootUriRaw : '$rootUriRaw/',
    );

    final shaderDir = Directory.fromUri(rootUri.resolve('shaders/'));
    if (shaderDir.existsSync()) {
      result.add(shaderDir);
    }
  }
  return result;
}

Future<void> compute(
  Directory assets,
  Directory shaders,
  List<Directory> packageShaderDirs,
) async {
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

  final impellerC = await findImpellerC();
  final engineShaderLib = impellerC.resolve('./shader_lib/').toFilePath();

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

  final engineArtifactsDir = findEngineArtifactsDir();

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
