// Builds a package's shader assets from the GLSL sources in its `shaders/`
// directory.
//
// Every Dart dependency that ships a top-level `shaders/` directory is made
// available, so a shader can `#include <pkg_name/foo.glsl>`.
//
//   dart run flame_3d:build_shaders [--with-web-gpu] [watch]

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '_build_shaderbundle.dart' as shaderbundle;
import '_build_wgslbundle.dart' as wgslbundle;

void main(List<String> arguments) async {
  final withWebGpu = arguments.contains('--with-web-gpu');
  final root = Directory.current;
  final assets = Directory.fromUri(root.uri.resolve('assets/shaders'));
  final shaders = Directory.fromUri(root.uri.resolve('shaders'));
  final packageShaderDirs = await _resolvePackageShaderDirs();

  await _build(shaders, assets, packageShaderDirs, withWebGpu: withWebGpu);

  if (arguments.contains('watch')) {
    stdout.writeln('Running in watch mode');
    shaders.watch(recursive: true).listen((_) {
      _build(shaders, assets, packageShaderDirs, withWebGpu: withWebGpu);
    });
  }
}

Future<void> _build(
  Directory shaders,
  Directory assets,
  List<Directory> packageShaderDirs, {
  required bool withWebGpu,
}) async {
  if (!shaders.existsSync()) {
    stderr.writeln('Missing shader directory');
    return;
  }
  assets.createSync(recursive: true);

  // Unique shader base names, each needs a matching `.vert` and `.frag`.
  // Nested files (e.g. the `shaders/flame_3d/` `#include` chunks) are ignored.
  final names = shaders
      .listSync()
      .whereType<File>()
      .map((f) => f.path.split(Platform.pathSeparator).last.split('.').first)
      .toSet();

  await shaderbundle.build(names, shaders, assets, packageShaderDirs);
  if (withWebGpu) {
    wgslbundle.build(names, shaders, assets, packageShaderDirs);
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
      // `flutter` ships no shader chunks, they are included from the engine.
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
