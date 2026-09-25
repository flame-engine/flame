import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

const _gameSnapshotExtension = 'ext.flame_devtools.getGameSnapshot';
const _componentSnapshotExtension = 'ext.flame_devtools.getComponentSnapshot';
const _componentTreeExtension = 'ext.flame_devtools.getComponentTree';

final _parser = ArgParser()
  ..addOption(
    'uri',
    abbr: 'u',
    help:
        'The Dart VM Service URI of the running game, as printed by '
        '`flutter run`.',
    mandatory: true,
  )
  ..addOption(
    'output',
    abbr: 'o',
    help: 'The file that the PNG image is written to.',
    defaultsTo: 'flame_snapshot.png',
  )
  ..addOption(
    'component',
    abbr: 'c',
    help:
        'The id of a single component to render instead of the whole game. '
        'Use --tree to list the ids.',
  )
  ..addOption(
    'pixel-ratio',
    abbr: 'p',
    help: 'The pixel ratio that the whole game is rendered with.',
    defaultsTo: '1',
  )
  ..addFlag(
    'tree',
    abbr: 't',
    negatable: false,
    help: 'Print the component tree with the id of every component.',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Print this usage information.',
  );

/// Takes a snapshot of a running Flame game through the Dart VM Service.
///
/// Run `dart run flame_test:snapshot --help` for usage information.
Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  final ArgResults results;
  try {
    results = _parser.parse(arguments);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(stderr);
    exitCode = 64;
    return;
  }

  final pixelRatio = double.tryParse(results.option('pixel-ratio')!);
  if (pixelRatio == null || pixelRatio <= 0) {
    stderr.writeln('--pixel-ratio has to be a positive number.');
    exitCode = 64;
    return;
  }

  final VmService service;
  try {
    service = await vmServiceConnectUri(
      webSocketUri(results.option('uri')!).toString(),
    );
  } on Object catch (error) {
    stderr.writeln('Could not connect to the Dart VM Service: $error');
    exitCode = 69;
    return;
  }

  try {
    final isolateId = await _findGameIsolate(service);
    if (isolateId == null) {
      stderr.writeln(
        'No Flame game was found. Make sure that the game is running in '
        'debug mode and that a FlameGame has been created.',
      );
      exitCode = 69;
      return;
    }

    if (results.flag('tree')) {
      final response = await service.callServiceExtension(
        _componentTreeExtension,
        isolateId: isolateId,
      );
      final tree = response.json!['component_tree'] as Map<String, dynamic>;
      stdout.write(formatComponentTree(tree));
      return;
    }

    final componentId = results.option('component');
    final response = componentId == null
        ? await service.callServiceExtension(
            _gameSnapshotExtension,
            isolateId: isolateId,
            args: {'pixelRatio': pixelRatio.toString()},
          )
        : await service.callServiceExtension(
            _componentSnapshotExtension,
            isolateId: isolateId,
            args: {'id': componentId},
          );

    final snapshot = response.json!['snapshot'] as String? ?? '';
    if (snapshot.isEmpty) {
      stderr.writeln('No component with the id $componentId was found.');
      exitCode = 65;
      return;
    }

    final file = File(results.option('output')!);
    await file.writeAsBytes(base64Decode(snapshot));
    stdout.writeln(file.absolute.path);
  } on RPCError catch (error) {
    stderr.writeln('The snapshot failed: ${error.details ?? error.message}');
    exitCode = 70;
  } finally {
    await service.dispose();
  }
}

/// Converts the http URI that `flutter run` prints for the Dart VM Service
/// to the web socket URI that the service is connected through.
Uri webSocketUri(String uri) {
  final parsed = Uri.parse(uri.trim());
  final scheme = switch (parsed.scheme) {
    'https' || 'wss' => 'wss',
    _ => 'ws',
  };
  final segments = parsed.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty || segments.last != 'ws') {
    segments.add('ws');
  }
  return parsed.replace(scheme: scheme, pathSegments: segments);
}

/// Formats the tree returned by the `getComponentTree` service extension with
/// one component per line, indented by its depth in the tree.
String formatComponentTree(Map<String, dynamic> node, [int depth = 0]) {
  final buffer = StringBuffer()
    ..writeln('${'  ' * depth}${node['name']} (id: ${node['id']})');
  for (final child in node['children'] as List) {
    buffer.write(formatComponentTree(child as Map<String, dynamic>, depth + 1));
  }
  return buffer.toString();
}

Future<String?> _findGameIsolate(VmService service) async {
  final vm = await service.getVM();
  for (final isolateReference in vm.isolates ?? <IsolateRef>[]) {
    final isolate = await service.getIsolate(isolateReference.id!);
    if (isolate.extensionRPCs?.contains(_gameSnapshotExtension) ?? false) {
      return isolate.id;
    }
  }
  return null;
}

void _printUsage([IOSink? sink]) {
  (sink ?? stdout)
    ..writeln('Takes a snapshot of a running Flame game.')
    ..writeln()
    ..writeln('Usage: dart run flame_test:snapshot --uri <vm service uri>')
    ..writeln()
    ..writeln(_parser.usage);
}
