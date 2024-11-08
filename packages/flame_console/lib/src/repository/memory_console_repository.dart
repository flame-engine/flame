import 'package:flame_console/flame_console.dart';

/// An implementation of a [ConsoleRepository] that stores the command history
/// in memory.
class MemoryConsoleRepository extends ConsoleRepository {
  MemoryConsoleRepository({
    List<String>? commands,
  }) : _commands = commands ?? <String>[];

  late final List<String> _commands;

  @override
  Future<void> addToCommandHistory(String command) async {
    _commands.add(command);
  }

  @override
  Future<List<String>> listCommandHistory() async {
    return _commands;
  }
}
