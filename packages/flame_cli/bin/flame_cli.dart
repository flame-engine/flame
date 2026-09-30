import 'dart:io';

import 'package:flame_cli/flame_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await FlameCommandRunner().run(arguments);
}
