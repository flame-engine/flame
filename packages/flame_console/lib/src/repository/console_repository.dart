/// A repository to persist and read history of commands
abstract class ConsoleRepository {
  const ConsoleRepository();

  Future<void> addToCommandHistory(String command);
  Future<List<String>> listCommandHistory();
}
