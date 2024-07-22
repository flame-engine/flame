import 'dart:convert';
import 'dart:io';

/// Bundle a shader (<name>.frag & <name>.vert) into a single shader bundle and
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
      .map((f) => f.path.split('/').last.split('.').first)
      .toSet();

  for (final name in uniqueShaders) {
    final bundle = {
      'TextureFragment': {
        'type': 'fragment',
        'file': '${shaders.path}/$name.frag',
      },
      'TextureVertex': {
        'type': 'vertex',
        'file': '${shaders.path}/$name.vert',
      },
    };

    stdout.writeln('Computing shader "$name"');
    final result = await Process.run(impellerC, [
      '--sl=${assets.path}/$name.shaderbundle',
      '--shader-bundle=${jsonEncode(bundle)}',
    ]);

    if (result.exitCode != 0) {
      return stderr.writeln(result.stderr);
    }
  }
}

final impellerC =
    '${Platform.environment['FLUTTER_HOME']}/bin/cache/artifacts/engine/darwin-x64/impellerc';
