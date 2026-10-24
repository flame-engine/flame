import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/game_responses.dart';
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

/// The service extensions of the game, with typed arguments and results.
///
/// They are built on [FlameConnection.call], which is the only place where
/// the JSON responses of the game are handled untyped.
extension FlameServiceExtensions on FlameConnection {
  /// The component tree of the game, or null if the game has no tree.
  Future<ComponentNode?> getComponentTree() async {
    final response = await call('getComponentTree');
    final tree = response['component_tree'] as Map<String, dynamic>?;
    return tree == null ? null : ComponentNode.fromJson(tree);
  }

  /// The details of the component with the given [id].
  Future<ComponentInfo> getComponentInfo(int id) async {
    return ComponentInfo.fromJson(
      await call('getComponentInfo', args: {'id': '$id'}),
    );
  }

  /// Sets an [attribute] of the position component with the given [id] to
  /// [value], in the format that the `setPositionComponentAttributes`
  /// service extension expects.
  Future<void> setPositionComponentAttribute(
    int id,
    String attribute,
    String value,
  ) async {
    await call(
      'setPositionComponentAttributes',
      args: {'id': '$id', 'attribute': attribute, 'value': value},
    );
  }

  /// Whether the game loop is paused.
  Future<bool> getPaused() async {
    final response = await call('getPaused');
    return response['paused'] == true;
  }

  /// Pauses or resumes the game loop.
  Future<void> setPaused({required bool paused}) async {
    await call('setPaused', args: {'paused': '$paused'});
  }

  /// Advances the paused game by one frame of [time] seconds.
  Future<void> step(double time) async {
    await call('step', args: {'step_time': '$time'});
  }

  /// Whether the debug mode is on for the game, or for the component with
  /// the given [id].
  Future<bool> getDebugMode({int? id}) async {
    final response = await call('getDebugMode', args: {'id': ?id?.toString()});
    return response['debug_mode'] == true;
  }

  /// Turns the debug mode on or off for the game, or for the component with
  /// the given [id].
  Future<void> setDebugMode({required bool debugMode, int? id}) async {
    await call(
      'setDebugMode',
      args: {'debug_mode': '$debugMode', 'id': ?id?.toString()},
    );
  }

  /// The registered and the shown overlays of the game.
  Future<Overlays> getOverlays() async {
    return Overlays.fromJson(await call('getOverlays'));
  }

  /// Shows or hides the [overlay].
  Future<void> setOverlay(String overlay, {required bool active}) async {
    await call('setOverlay', args: {'overlay': overlay, 'active': '$active'});
  }

  /// Shows the [overlay] and hides all the other ones.
  Future<void> navigateToOverlay(String overlay) async {
    await call('navigateToOverlay', args: {'overlay': overlay});
  }

  /// Renders the game through the camera, or the world directly when
  /// [world] is true or a [rect] in world coordinates is given.
  ///
  /// See [SnapshotOptions] for the other [options].
  Future<Snapshot> getGameSnapshot({
    required double pixelRatio,
    bool world = false,
    WorldRect? rect,
    SnapshotOptions options = const SnapshotOptions(),
  }) async {
    return Snapshot.fromJson(
      await call(
        'getGameSnapshot',
        args: {
          'pixelRatio': '$pixelRatio',
          if (world) 'world': 'true',
          if (rect != null)
            'rect': '${rect.x},${rect.y},${rect.width},${rect.height}',
          ...options.args,
        },
      ),
    );
  }

  /// Renders the component with the given [id].
  ///
  /// See [SnapshotOptions] for the other [options].
  Future<Snapshot> getComponentSnapshot(
    int id, {
    required double pixelRatio,
    SnapshotOptions options = const SnapshotOptions(),
  }) async {
    return Snapshot.fromJson(
      await call(
        'getComponentSnapshot',
        args: {'id': '$id', 'pixelRatio': '$pixelRatio', ...options.args},
      ),
    );
  }

  /// Where the [component] is on the canvas, at its [anchor], which is either
  /// a name like `center` or `x,y` between 0 and 1, and the center when it is
  /// not given.
  Future<Vector2> getComponentCanvasPosition(
    ComponentReference component, {
    String? anchor,
  }) async {
    final response = await call(
      'getComponentCanvasPosition',
      args: {...component.args, 'anchor': ?anchor},
    );
    return (
      x: (response['x'] as num).toDouble(),
      y: (response['y'] as num).toDouble(),
    );
  }

  /// Taps the game at [position], in canvas coordinates.
  Future<void> tap(Vector2 position) async {
    await call('tap', args: {'x': '${position.x}', 'y': '${position.y}'});
  }

  /// Drags across the game from [from] to [to], in canvas coordinates, with
  /// [steps] updates in between.
  Future<void> drag(Vector2 from, Vector2 to, {required int steps}) async {
    await call(
      'drag',
      args: {
        'fromX': '${from.x}',
        'fromY': '${from.y}',
        'toX': '${to.x}',
        'toY': '${to.y}',
        'steps': '$steps',
      },
    );
  }

  /// Presses, holds down or releases the [key].
  Future<void> key(String key, {KeyAction action = KeyAction.press}) async {
    await call('key', args: {'key': key, 'action': action.name});
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
