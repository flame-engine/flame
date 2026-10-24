import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:io/io.dart';
import 'package:vm_service/vm_service.dart' hide Error;
import 'package:vm_service/vm_service_io.dart';

/// A connection to a Flame game that is running in debug mode, through the
/// service extensions that Flame registers for the DevTools extension.
class FlameConnection._(
  /// The URI of the Dart VM Service that the connection was made to, as it
  /// was passed to [connect].
  final String uri,
  final VmService _service,
  final String _isolateId,
  final Set<String> _extensions,
) {
  /// Creates a connection through a [service] that is already connected, to
  /// the isolate with [isolateId] that registered the Flame [extensions].
  FlameConnection.withService(
    String uri,
    VmService service,
    String isolateId,
    Set<String> extensions,
  ) : this._(uri, service, isolateId, extensions);

  static const _extensionPrefix = 'ext.flame_devtools.';

  /// Connects to the Dart VM Service at [uri] and finds the isolate that runs
  /// the Flame game.
  ///
  /// The [uri] can either be the http URI that `flutter run` prints, or the
  /// web socket URI of the service.
  static Future<FlameConnection> connect(String uri) async {
    final VmService service;
    try {
      service = await vmServiceConnectUri(webSocketUri(uri).toString());
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not connect to the Dart VM Service at $uri: $error',
          exitCode: ExitCode.unavailable,
        ),
        stackTrace,
      );
    }

    try {
      final vm = await service.getVM();
      for (final isolateReference in vm.isolates ?? <IsolateRef>[]) {
        final Isolate isolate;
        try {
          isolate = await service.getIsolate(isolateReference.id!);
        } on SentinelException {
          continue;
        }
        final extensions = {
          ...?isolate.extensionRPCs?.where(
            (extension) => extension.startsWith(_extensionPrefix),
          ),
        };
        if (extensions.isNotEmpty) {
          return FlameConnection._(uri, service, isolate.id!, extensions);
        }
      }
    } on Object catch (error, stackTrace) {
      await service.dispose();
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not list the isolates of the Dart VM Service at $uri: $error',
          exitCode: ExitCode.unavailable,
        ),
        stackTrace,
      );
    }

    await service.dispose();
    throw const FlameCliException(
      'No Flame game was found. Make sure that the game is running in debug '
      'mode and that a FlameGame has been created.',
      exitCode: ExitCode.unavailable,
    );
  }

  /// Calls the `ext.flame_devtools.[method]` service extension with [args]
  /// and returns the decoded response.
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    final extension = '$_extensionPrefix$method';
    if (!_extensions.contains(extension)) {
      throw FlameCliException(
        'The running game does not support $extension, update Flame to the '
        'latest version.',
        exitCode: ExitCode.unavailable,
      );
    }

    try {
      final response = await _service.callServiceExtension(
        extension,
        isolateId: _isolateId,
        args: args,
      );
      return response.json ?? {};
    } on RPCError catch (error, stackTrace) {
      if (_isDisconnected(error)) {
        Error.throwWithStackTrace(
          const FlameCliException(
            'The game is no longer running, the connection to it was closed.',
            exitCode: ExitCode.unavailable,
          ),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(
        FlameCliException(
          error.details ?? error.message,
          exitCode: error.code == RPCErrorKind.kInvalidParams.code
              ? ExitCode.data
              : ExitCode.software,
        ),
        stackTrace,
      );
    } on SentinelException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'The game is no longer running: ${error.sentinel.valueAsString}',
          exitCode: ExitCode.unavailable,
        ),
        stackTrace,
      );
    }
  }

  Future<void> dispose() => _service.dispose();

  static bool _isDisconnected(RPCError error) {
    return error.code == RPCErrorKind.kServiceDisappeared.code ||
        error.code == RPCErrorKind.kConnectionDisposed.code ||
        (error.code == RPCErrorKind.kServerError.code &&
            error.message == RPCErrorKind.kConnectionDisposed.message);
  }
}

/// Converts the http URI that `flutter run` prints for the Dart VM Service
/// to the web socket URI that the service is connected through.
Uri webSocketUri(String uri) {
  final parsed = Uri.parse(uri.trim());
  final scheme = switch (parsed.scheme) {
    'https' || 'wss' => 'wss',
    _ => 'ws',
  };
  final segments = parsed.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty || segments.last != 'ws') {
    segments.add('ws');
  }
  return parsed.replace(scheme: scheme, pathSegments: segments);
}
