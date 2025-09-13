import 'package:flame_3d_example/commands/destroy_command.dart';
import 'package:flame_3d_example/commands/reset_command.dart';
import 'package:flame_3d_example/commands/setup_command.dart';

const customCommandProviders = [
  ResetCommand.new,
  DestroyCommand.new,
  SetupCommand.new,
];
