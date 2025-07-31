import 'package:example/commands/destroy_command.dart';
import 'package:example/commands/reset_command.dart';

const customCommandProviders = [
  ResetCommand.new,
  DestroyCommand.new,
];
