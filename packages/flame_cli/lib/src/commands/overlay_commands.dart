import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:io/io.dart';

/// Lists the registered overlays of the game and which of them are active.
class OverlaysCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
    argParser.addFlag(
      'json',
      negatable: false,
      help: 'Print the overlays as JSON instead of text.',
    );
  }

  @override
  String get name => 'overlays';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description =>
      'List the registered overlays of the game and which of them are shown.';

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final overlays = await connection.getOverlays();
    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput(overlays.toJson()));
      return ExitCode.success.code;
    }

    if (overlays.registered.isEmpty) {
      out.writeln('The game has no registered overlays.');
      return ExitCode.success.code;
    }
    for (final overlay in overlays.registered) {
      final shown = overlays.active.contains(overlay) ? ' (shown)' : '';
      out.writeln('$overlay$shown');
    }
    return ExitCode.success.code;
  }
}

/// Shows, hides or navigates to an overlay.
class OverlayCommand(StringSink out, Directory workingDirectory)
    extends Command<int> {
  this {
    addSubcommand(_SetOverlayCommand(out, workingDirectory, active: true));
    addSubcommand(_SetOverlayCommand(out, workingDirectory, active: false));
    addSubcommand(_OnlyOverlayCommand(out, workingDirectory));
  }

  @override
  String get name => 'overlay';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description => 'Show or hide an overlay of the game.';
}

class _SetOverlayCommand(
  super.out,
  super.workingDirectory, {
  required final bool active,
}) extends FlameCommand {
  @override
  String get name => active ? 'show' : 'hide';

  @override
  String get description => active
      ? 'Show an overlay, in addition to the ones already shown.'
      : 'Hide an overlay.';

  @override
  String get invocation => 'flame overlay $name <overlay name>';

  late String _overlay;

  @override
  void validate() {
    _overlay = overlayNameArgument(this);
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.setOverlay(_overlay, active: active);
    out.writeln('${active ? 'Showed' : 'Hid'} the overlay $_overlay.');
    return ExitCode.success.code;
  }
}

class _OnlyOverlayCommand(super.out, super.workingDirectory)
    extends FlameCommand {
  @override
  String get name => 'only';

  @override
  String get description => 'Show an overlay and hide all the other ones.';

  @override
  String get invocation => 'flame overlay only <overlay name>';

  late String _overlay;

  @override
  void validate() {
    _overlay = overlayNameArgument(this);
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.navigateToOverlay(_overlay);
    out.writeln('Showed only the overlay $_overlay.');
    return ExitCode.success.code;
  }
}

/// Reads the single overlay name argument of a command.
String overlayNameArgument(Command<int> command) {
  final rest = command.argResults!.rest;
  if (rest.length != 1) {
    throw UsageException(
      'Pass the name of one overlay, use the overlays command to list them.',
      command.usage,
    );
  }
  return rest.single;
}
