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
  @override final StringSink out,
  final Directory workingDirectory, {
  GameConnector? connect,
}) extends Command<int> with JsonOutput {
  this {
    argParser.addOption(
      'uri',
      abbr: 'u',
      help:
          'The Dart VM Service URI of a game that was not started with '
          '`flame run`, to check whether it is reachable.',
    );
    addPortOption(argParser);
    addJsonFlag(argParser);
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

    var status = uriOption == null
        ? await _runStatus(port ?? findControlPort(workingDirectory))
        : GameStatus(running: true, vmServiceUri: uriOption);
    final uri = status.vmServiceUri;
    if (status.running && uri != null) {
      status = await _withGameStatus(status, uri);
      if (uriOption != null) {
        status = status.copyWith(running: status.reachable ?? false);
      }
    }

    if (jsonOutput) {
      out.writeln(toJsonOutput(status.toJson()));
    } else {
      _printStatus(status);
    }
    final ok = status.running && status.reachable == true;
    return (ok ? ExitCode.success : ExitCode.unavailable).code;
  }

  Future<GameStatus> _runStatus(int? port) async {
    if (port == null) {
      return const GameStatus(
        running: false,
        error:
            'No game that was started with `flame run` was found for this '
            'project.',
      );
    }
    final RunResponse response;
    try {
      response = await sendRunRequest(
        workingDirectory,
        RunRequest.status,
        port: port,
      );
    } on FlameCliException catch (error) {
      return GameStatus(
        running: false,
        controlPort: port,
        error: error.message,
      );
    }
    final runStatus = response.status;
    final uri = runStatus?.vmServiceUri;
    return GameStatus(
      running: true,
      projectDirectory: runStatus?.projectDirectory,
      controlPort: runStatus?.controlPort ?? port,
      processId: runStatus?.processId,
      vmServiceUri: uri,
      reachable: uri == null ? false : null,
      error: uri == null
          ? 'The game is still starting, it has not reported its Dart VM '
                'Service URI yet.'
          : null,
    );
  }

  Future<GameStatus> _withGameStatus(GameStatus status, String uri) async {
    final FlameConnection connection;
    try {
      connection = await _connect(uri);
    } on FlameCliException catch (error) {
      return status.copyWith(reachable: false, error: error.message);
    }
    try {
      return status.copyWith(
        reachable: true,
        paused: await connection.getPaused(),
      );
    } on FlameCliException {
      return status.copyWith(reachable: true);
    } finally {
      await connection.dispose();
    }
  }

  void _printStatus(GameStatus status) {
    const yesOrNo = {true: 'yes', false: 'no'};

    out.writeln('Running: ${yesOrNo[status.running]}');
    final fields = {
      'Project': status.projectDirectory,
      'Control port': status.controlPort,
      'Process id of flutter run': status.processId,
      'Dart VM Service URI': status.vmServiceUri,
    };
    for (final MapEntry(:key, :value) in fields.entries) {
      if (value != null) {
        out.writeln('$key: $value');
      }
    }
    if (status.reachable case final reachable?) {
      out.writeln('Reachable: ${yesOrNo[reachable]}');
    }
    if (status.paused case final paused?) {
      out.writeln('Paused: ${yesOrNo[paused]}');
    }
    if (status.error case final error?) {
      out.writeln(error);
    }
  }
}

/// What `flame status` reports about a game, where the fields that are not
/// known are null.
class const GameStatus({
  /// Whether `flame run` answered, or with `--uri` whether the game could be
  /// reached.
  required final bool running,
  final String? projectDirectory,
  final int? controlPort,
  final int? processId,
  final String? vmServiceUri,

  /// Whether the Flame game could be reached through [vmServiceUri].
  final bool? reachable,
  final bool? paused,

  /// Why the game is not running or not reachable.
  final String? error,
}) {
  /// A copy of this status where the given fields are replaced.
  GameStatus copyWith({
    bool? running,
    bool? reachable,
    bool? paused,
    String? error,
  }) {
    return GameStatus(
      running: running ?? this.running,
      projectDirectory: projectDirectory,
      controlPort: controlPort,
      processId: processId,
      vmServiceUri: vmServiceUri,
      reachable: reachable ?? this.reachable,
      paused: paused ?? this.paused,
      error: error ?? this.error,
    );
  }

  Map<String, Object> toJson() {
    return {
      'running': running,
      'projectDirectory': ?projectDirectory,
      'controlPort': ?controlPort,
      'processId': ?processId,
      'vmServiceUri': ?vmServiceUri,
      'reachable': ?reachable,
      'paused': ?paused,
      'error': ?error,
    };
  }
}
