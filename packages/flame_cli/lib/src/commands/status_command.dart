import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/control_commands.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:flame_cli/src/run_controller.dart';
import 'package:io/io.dart';

/// Reports whether a game that was started with `flame run` is running for
/// the project, and whether it can be reached through the Dart VM Service.
///
/// It exits with success only when the game is running and reachable, so
/// that scripts can wait for the game to start or check that it is still
/// there.
class StatusCommand(
  final StringSink out,
  final Directory workingDirectory, {
  GameConnector? connect,
}) extends Command<int> {
  this {
    argParser
      ..addOption(
        'uri',
        abbr: 'u',
        help:
            'The Dart VM Service URI of a game that was not started with '
            '`flame run`, to check whether it is reachable.',
      )
      ..addFlag(
        'json',
        negatable: false,
        help: 'Print the status as JSON instead of text.',
      );
    addPortOption(argParser);
  }

  final GameConnector _connect = connect ?? FlameConnection.connect;

  @override
  String get name => 'status';

  @override
  String get category => CommandCategories.launching;

  @override
  String get description =>
      'Show whether the game that was started with `flame run` is running '
      'and reachable, together with its Dart VM Service URI and control '
      'port. Exits with 0 only when the game is running and reachable.';

  @override
  Future<int> run() async {
    final uriOption = argResults!.option('uri');
    final port = parsePortOption(argResults!, usage);
    if (uriOption != null && port != null) {
      throw UsageException('--uri cannot be combined with --port.', usage);
    }

    final status = uriOption == null
        ? await _runStatus(port ?? findControlPort(workingDirectory))
        : <String, Object?>{'running': true, 'vmServiceUri': uriOption};
    final uri = status['vmServiceUri'] as String?;
    if (status['running'] == true && uri != null) {
      status.addAll(await _gameStatus(uri));
      if (uriOption != null) {
        status['running'] = status['reachable'];
      }
    }

    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput(status));
    } else {
      _printStatus(status);
    }
    final ok = status['running'] == true && status['reachable'] == true;
    return (ok ? ExitCode.success : ExitCode.unavailable).code;
  }

  Future<Map<String, Object?>> _runStatus(int? port) async {
    if (port == null) {
      return {
        'running': false,
        'error':
            'No game that was started with `flame run` was found for this '
            'project.',
      };
    }
    final Map<String, dynamic> response;
    try {
      response = await sendRunRequest(
        workingDirectory,
        RunRequest.status,
        port: port,
      );
    } on FlameCliException catch (error) {
      return {'running': false, 'controlPort': port, 'error': error.message};
    }
    final uri = response['vmServiceUri'] as String?;
    return {
      'running': true,
      'projectDirectory': response['projectDirectory'],
      'controlPort': response['controlPort'] ?? port,
      'processId': response['processId'],
      'vmServiceUri': uri,
      if (uri == null) 'reachable': false,
      if (uri == null)
        'error':
            'The game is still starting, it has not reported its Dart VM '
            'Service URI yet.',
    };
  }

  Future<Map<String, Object?>> _gameStatus(String uri) async {
    final FlameConnection connection;
    try {
      connection = await _connect(uri);
    } on FlameCliException catch (error) {
      return {'reachable': false, 'error': error.message};
    }
    try {
      final response = await connection.call('getPaused');
      return {'reachable': true, 'paused': response['paused']};
    } on FlameCliException {
      return {'reachable': true};
    } finally {
      await connection.dispose();
    }
  }

  void _printStatus(Map<String, Object?> status) {
    String yesOrNo(Object? value) => value == true ? 'yes' : 'no';

    out.writeln('Running: ${yesOrNo(status['running'])}');
    final fields = {
      'Project': status['projectDirectory'],
      'Control port': status['controlPort'],
      'Process id of flutter run': status['processId'],
      'Dart VM Service URI': status['vmServiceUri'],
    };
    for (final MapEntry(:key, :value) in fields.entries) {
      if (value != null) {
        out.writeln('$key: $value');
      }
    }
    if (status.containsKey('reachable')) {
      out.writeln('Reachable: ${yesOrNo(status['reachable'])}');
    }
    if (status.containsKey('paused')) {
      out.writeln('Paused: ${yesOrNo(status['paused'])}');
    }
    final error = status['error'];
    if (error != null) {
      out.writeln(error);
    }
  }
}
