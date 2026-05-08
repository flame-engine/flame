import 'dart:convert';
import 'dart:io';

void main() {
  final parser = _OutputParser();

  stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(
        parser.processLine,
        onDone: () {
          parser.flush();
          exitCode = parser.success ? 0 : 1;
        },
      );
}

class _OutputParser {
  final _packages = [_PackageParser()];

  int get failed => _packages.sumBy((package) => package.failed);
  int get passed => _packages.sumBy((package) => package.passed);
  bool get success => failed == 0;

  void processLine(String line) {
    if (!line.startsWith('{')) {
      _packages.last.processPlainLine(line);
      return;
    }

    try {
      final event = jsonDecode(line) as Map<String, dynamic>;

      if (!_packages.last.processJsonEvent(event)) {
        _OutputWriter.info(line);
      }

      if (event['type'] == 'done') {
        _packages.add(_PackageParser());
      }
    } on FormatException {
      _OutputWriter.info(line);
      return;
    }
  }

  void flush() {
    _packages.last.flush();
    _OutputWriter.info('');
    final logLevel = success ? _LogLevel.success : _LogLevel.failure;
    _OutputWriter.log(logLevel, 'Total: $passed passed, $failed failed');
  }
}

class _PackageParser {
  static final _dependencyLinePattern = RegExp(
    r'^\s+\S+ \d+\.\S+.*available\)$',
  );

  var _suppressedDependencyCount = 0;

  final _activeTests = <int, _TestEntry>{};
  var passed = 0;
  var failed = 0;

  void processPlainLine(String line) {
    if (_dependencyLinePattern.hasMatch(line)) {
      _suppressedDependencyCount++;
      return;
    }

    flush();
    _OutputWriter.info(line);
  }

  void flush() {
    if (_suppressedDependencyCount > 0) {
      _flushDependencyBlock();
    }
  }

  bool processJsonEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;

    switch (type) {
      case 'start':
      case 'suite':
      case 'allSuites':
      case 'group':
        break;

      case 'testStart':
        final test = event['test'] as Map<String, dynamic>?;
        final id = test?['id'] as int?;
        final name = test?['name'] as String?;
        if (id == null || name == null) {
          return false;
        }
        _activeTests[id] = (name: name, output: StringBuffer());

      case 'print':
        final id = event['testID'] as int?;
        final test = _activeTests[id];
        if (test == null) {
          return false;
        }
        test.output.writeln(event['message'] ?? '');

      case 'error':
        final id = event['testID'] as int?;
        final test = _activeTests[id];
        if (test == null) {
          return false;
        }
        test.output.writeln(event['error'] ?? '');
        final stack = event['stackTrace'] as String?;
        if (stack != null && stack.isNotEmpty) {
          test.output.writeln(stack);
        }

      case 'testDone':
        final id = event['testID'] as int?;
        if (id == null) {
          return false;
        }
        if (event['hidden'] == true) {
          _activeTests.remove(id);
          break;
        }
        final test = _activeTests.remove(id);
        final result = event['result'] as String?;
        if (result == 'success') {
          passed++;
        } else {
          failed++;
          _OutputWriter.info('');
          _OutputWriter.failure('━━━ FAIL: ${test?.name ?? 'unknown test'}');
          final output = test?.output;
          if (output != null && output.isNotEmpty) {
            _OutputWriter.failure(output.toString());
          } else {
            _OutputWriter.failure('━━━ No output captured for this test.');
          }
        }

      case 'done':
        final logLevel = failed > 0 ? _LogLevel.failure : _LogLevel.success;
        _OutputWriter.log(logLevel, '$passed passed, $failed failed');

      default:
        // unknown - pass through
        return false;
    }

    return true;
  }

  void _flushDependencyBlock() {
    _OutputWriter.info(
      '  ($_suppressedDependencyCount packages have newer versions available)',
    );
    _suppressedDependencyCount = 0;
  }
}

extension _SumBy<T> on List<T> {
  int sumBy(int Function(T) selector) {
    return fold(0, (sum, element) => sum + selector(element));
  }
}

typedef _TestEntry = ({String name, StringBuffer output});

enum _LogLevel { info, success, failure }

class _OutputWriter {
  _OutputWriter._();

  static const _ansiRed = '\x1B[31m';
  static const _ansiGreen = '\x1B[32m';
  static const _ansiReset = '\x1B[0m';

  static String _colored(String message, String color) {
    return '$color$message$_ansiReset';
  }

  static void info(String message) {
    stdout.writeln(message);
  }

  static void success(String message) {
    stdout.writeln(_colored(message, _ansiGreen));
  }

  static void failure(String message) {
    stderr.writeln(_colored(message, _ansiRed));
  }

  static void Function(String) logger(_LogLevel level) {
    return switch (level) {
      _LogLevel.info => info,
      _LogLevel.success => success,
      _LogLevel.failure => failure,
    };
  }

  static void log(_LogLevel level, String message) {
    logger(level)(message);
  }
}
