import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A [Process] whose output is controlled by the test, and whose input is
/// recorded.
class FakeProcess implements Process {
  FakeProcess({int? exitCode}) {
    if (exitCode != null) {
      exit(exitCode);
    }
  }

  final _exitCode = Completer<int>();
  final _stdout = StreamController<List<int>>();
  final _stderr = StreamController<List<int>>();
  final _input = StringBuffer();

  /// Everything that was written to the [stdin] of the process so far.
  String get input => _input.toString();

  /// Whether [exit] has been called.
  bool get exited => _exitCode.isCompleted;

  /// Prints [line] on the standard output of the process.
  void printLine(String line) => _stdout.add(utf8.encode('$line\n'));

  /// Prints [line] on the standard error of the process.
  void printError(String line) => _stderr.add(utf8.encode('$line\n'));

  /// Makes the process exit with [code].
  void exit(int code) {
    _stdout.close();
    _stderr.close();
    stdin.close();
    _exitCode.complete(code);
  }

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;

  @override
  late final IOSink stdin = IOSink(_InputConsumer(_input));

  @override
  int get pid => 4242;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    exit(-1);
    return true;
  }
}

class _InputConsumer implements StreamConsumer<List<int>> {
  _InputConsumer(this.buffer);

  final StringBuffer buffer;

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    return stream.forEach((bytes) => buffer.write(utf8.decode(bytes)));
  }

  @override
  Future<void> close() async {}
}
