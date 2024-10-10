import 'package:flame_console/flame_console.dart';

class MemoryConsoleRepository extends ConsoleRepository {
  const MemoryConsoleRepository({
    List<String> commands = const [],
  }) : _commands = commands;

  final List<String> _commands;

  @override
  Future<void> addToCommandHistory(String command) async {
    _commands.add(command);
  }

  @override
  Future<List<String>> listCommandHistory() async {
    return _commands;
  }
}
