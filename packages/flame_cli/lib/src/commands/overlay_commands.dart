import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';

/// Lists the registered overlays of the game and which of them are active.
class OverlaysCommand extends FlameCommand {
  OverlaysCommand(super.out, super.workingDirectory) {
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
    final response = await connection.call('getOverlays');
    final overlays = (response['overlays'] as List).cast<String>();
    final active = ((response['active'] as List?) ?? []).cast<String>();

    if (argResults!.flag('json')) {
      out.writeln(toJsonOutput({'overlays': overlays, 'active': active}));
      return ExitCodes.success;
    }

    if (overlays.isEmpty) {
      out.writeln('The game has no registered overlays.');
      return ExitCodes.success;
    }
    for (final overlay in overlays) {
      out.writeln('$overlay${active.contains(overlay) ? ' (shown)' : ''}');
    }
    return ExitCodes.success;
  }
}

/// Shows, hides or navigates to an overlay.
class OverlayCommand extends Command<int> {
  OverlayCommand(StringSink out, Directory workingDirectory) {
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

class _SetOverlayCommand extends FlameCommand {
  _SetOverlayCommand(super.out, super.workingDirectory, {required this.active});

  final bool active;

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
    await connection.call(
      'setOverlay',
      args: {'overlay': _overlay, 'active': active.toString()},
    );
    out.writeln('${active ? 'Showed' : 'Hid'} the overlay $_overlay.');
    return ExitCodes.success;
  }
}

class _OnlyOverlayCommand extends FlameCommand {
  _OnlyOverlayCommand(super.out, super.workingDirectory);

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
    await connection.call('navigateToOverlay', args: {'overlay': _overlay});
    out.writeln('Showed only the overlay $_overlay.');
    return ExitCodes.success;
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
