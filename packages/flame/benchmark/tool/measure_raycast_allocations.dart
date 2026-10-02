import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:vm_service/vm_service.dart';
// ignore: depend_on_referenced_packages
import 'package:vm_service/vm_service_io.dart';

/// Measures what `StandardCollisionDetection.raycast` allocates with the old
/// code path and with the nearest first one (`nearestFirstRaycast`), in AOT
/// code, with no manual steps.
///
/// It runs `benchmark/raycast_allocation_app.dart` in a profile build, with
/// `flutter run --machine`, connects to its VM service, and for each case
/// asks the app to cast rays while it reads the allocation profile of the VM
/// before and after. What the VM service allocates itself while it answers is
/// measured in the same way, with no rays, and subtracted.
///
///     dart run benchmark/tool/measure_raycast_allocations.dart [options]
///
/// Options:
///
///     --device=macos     The device to run on. It needs to be a desktop one.
///     --reps=3           The measurements of each code path in each case.
///     --seconds=2        The time that each measurement should take.
///     --filter=text      Only the cases whose name has the text.
///     --csv=path         Also write the results to a CSV file.
///
/// The first measurements need a profile build, which takes minutes.
Future<void> main(List<String> arguments) async {
  final options = _Options(arguments);
  final cases = [
    // Rectangles that do not allocate in rayIntersection, to see what the
    // code that casts the rays allocates, with a few to many hitboxes. The
    // misses are the worst case for the nearest first one, as it never stops
    // early, and the hits the best.
    for (final kind in ['stubMiss', 'stubHit']) ...[
      for (final count in [1, 5, 100, 500, 1000]) _Case(kind, 'spread', count),
      for (final count in [20, 100]) _Case(kind, 'dense', count),
    ],
    // Real hitboxes, to see the allocations of everything that a ray does.
    for (final kind in ['simple', 'polygons', 'paths', 'mixed']) ...[
      for (final count in [100, 500]) _Case(kind, 'spread', count),
      _Case(kind, 'dense', 50),
    ],
  ].where((c) => c.id.contains(options.filter)).toList();
  if (cases.isEmpty) {
    stdout.writeln('No case matches "${options.filter}".');
    return;
  }

  final app = await _App.start(options.device);
  final csv = <String>[
    [
      'case',
      'rays',
      'old_B_per_ray',
      'new_B_per_ray',
      'old_objects_per_ray',
      'new_objects_per_ray',
      'old_us_per_ray',
      'new_us_per_ray',
      'noise_B_per_ray',
      'retained_candidates',
      'retained_bytes',
    ].join(','),
  ];
  try {
    await app.connect();
    stdout
      ..writeln()
      ..writeln(
        'Allocations of the raycast, per ray, in ${app.description}.\n'
        '${options.reps} measurements of ~${options.seconds} s of each code '
        'path, medians, without what the VM service allocates itself.\n'
        'noise: the variation of the VM service allocations in the same case. '
        'kept: the _RayCandidate objects that the nearest first path keeps '
        'between rays (a pool; it never shrinks, so it only grows through the '
        'cases that run).\n',
      )
      ..writeln(
        _row([
          'case',
          'rays',
          'old B/ray',
          'new B/ray',
          'old obj/ray',
          'new obj/ray',
          'old us/ray',
          'new us/ray',
          'noise B/ray',
          'kept',
          'top allocations of old | of new (objects/ray)',
        ]),
      );
    for (final testCase in cases) {
      final result = await _measureCase(app, testCase, options);
      stdout.writeln(result.row());
      csv.add(result.csv());
    }
    stdout.writeln();
    final path = options.csvPath;
    if (path != null) {
      await File(path).writeAsString('${csv.join('\n')}\n');
      stdout.writeln('Written to $path');
    }
  } on Object catch (error, stackTrace) {
    stdout
      ..writeln('FAILED: $error\n$stackTrace')
      ..writeln('Last output of flutter:')
      ..writeln(app.log.reversed.take(25).toList().reversed.join('\n'));
    exitCode = 1;
  } finally {
    await app.stop();
  }
}

String _row(List<String> columns) {
  const widths = [22, 9, 11, 11, 12, 12, 11, 11, 12, 11, 0];
  return [
    for (var i = 0; i < columns.length; i++) columns[i].padRight(widths[i]),
  ].join();
}

class _Options {
  _Options(List<String> arguments) {
    for (final argument in arguments) {
      final match = RegExp(r'^--(\w+)=(.*)$').firstMatch(argument);
      if (match == null) {
        throw ArgumentError('Unknown argument: $argument');
      }
      final value = match.group(2)!;
      switch (match.group(1)) {
        case 'device':
          device = value;
        case 'reps':
          reps = int.parse(value);
        case 'seconds':
          seconds = double.parse(value);
        case 'filter':
          filter = value;
        case 'csv':
          csvPath = value;
        default:
          throw ArgumentError('Unknown option: $argument');
      }
    }
  }

  String device = 'macos';
  int reps = 3;
  double seconds = 2;
  String filter = '';
  String? csvPath;
}

class _Case {
  _Case(this.kind, this.scene, this.count);

  final String kind;
  final String scene;
  final int count;

  String get id => '$scene/$kind/$count';
}

/// The (objects, bytes) allocated of each class.
typedef _Allocations = Map<String, (int, int)>;

int _objects(_Allocations a) => a.values.fold(0, (sum, e) => sum + e.$1);

int _bytes(_Allocations a) => a.values.fold(0, (sum, e) => sum + e.$2);

/// What was allocated in [measured] and not in [control], class by class.
_Allocations _minus(_Allocations measured, _Allocations control) {
  final result = <String, (int, int)>{};
  for (final entry in measured.entries) {
    final (controlCount, controlSize) = control[entry.key] ?? (0, 0);
    final count = entry.value.$1 - controlCount;
    final size = entry.value.$2 - controlSize;
    if (count > 0 && size > 0) {
      result[entry.key] = (count, size);
    }
  }
  return result;
}

T _median<T extends num>(List<T> values) {
  final sorted = List<T>.of(values)..sort();
  return sorted[sorted.length ~/ 2];
}

String _top(_Allocations allocations, int rays) {
  final entries = allocations.entries.toList()
    ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
  final top = entries
      .take(3)
      .where((e) => e.value.$1 / rays >= 0.005)
      .map((e) => '${e.key} ${(e.value.$1 / rays).toStringAsFixed(2)}');
  return top.isEmpty ? '-' : top.join(', ');
}

/// One code path measured several times.
class _Measurements {
  final nets = <_Allocations>[];
  final micros = <int>[];

  /// The measurement with the median of the bytes.
  _Allocations get median {
    final sorted = List.of(nets)
      ..sort((a, b) => _bytes(a).compareTo(_bytes(b)));
    return sorted[sorted.length ~/ 2];
  }
}

class _CaseResult {
  _CaseResult({
    required this.testCase,
    required this.rays,
    required this.old,
    required this.nearest,
    required this.noise,
    required this.keptObjects,
    required this.keptBytes,
  });

  final _Case testCase;
  final int rays;
  final _Measurements old;
  final _Measurements nearest;

  /// The variation of the control allocations, in bytes.
  final int noise;
  final int keptObjects;
  final int keptBytes;

  double _perRay(num value) => value / rays;

  double get oldBytes => _perRay(_median(old.nets.map(_bytes).toList()));
  double get newBytes => _perRay(_median(nearest.nets.map(_bytes).toList()));
  double get oldObjects => _perRay(_median(old.nets.map(_objects).toList()));
  double get newObjects =>
      _perRay(_median(nearest.nets.map(_objects).toList()));
  double get oldMicros => _median(old.micros) / rays;
  double get newMicros => _median(nearest.micros) / rays;

  String row() => _row([
    testCase.id,
    '$rays',
    oldBytes.toStringAsFixed(1),
    newBytes.toStringAsFixed(1),
    oldObjects.toStringAsFixed(3),
    newObjects.toStringAsFixed(3),
    oldMicros.toStringAsFixed(2),
    newMicros.toStringAsFixed(2),
    _perRay(noise).toStringAsFixed(1),
    '$keptObjects',
    '${_top(old.median, rays)} | ${_top(nearest.median, rays)}',
  ]);

  String csv() => [
    testCase.id,
    rays,
    oldBytes.toStringAsFixed(2),
    newBytes.toStringAsFixed(2),
    oldObjects.toStringAsFixed(4),
    newObjects.toStringAsFixed(4),
    oldMicros.toStringAsFixed(3),
    newMicros.toStringAsFixed(3),
    _perRay(noise).toStringAsFixed(2),
    keptObjects,
    keptBytes,
  ].join(',');
}

Future<_CaseResult> _measureCase(
  _App app,
  _Case testCase,
  _Options options,
) async {
  Future<Map<String, dynamic>> cast(int rays, {required bool nearestFirst}) {
    return app.cast(
      kind: testCase.kind,
      scene: testCase.scene,
      count: testCase.count,
      rays: rays,
      nearestFirst: nearestFirst,
    );
  }

  // Builds the scene, warms up and finds out how many rays take some seconds.
  await cast(0, nearestFirst: false);
  await cast(20000, nearestFirst: false);
  await cast(20000, nearestFirst: true);
  final calibration = await cast(20000, nearestFirst: false);
  final microsPerRay = (calibration['micros'] as int) / 20000;
  final rays = (options.seconds * 1e6 / max(microsPerRay, 0.01))
      .clamp(100000, 5000000)
      .round();

  final old = _Measurements();
  final nearest = _Measurements();
  final controls = <int>[];
  for (var rep = 0; rep < options.reps; rep++) {
    for (final (measurements, nearestFirst) in [
      (old, false),
      (nearest, true),
    ]) {
      final control = await app.measure(
        () => cast(0, nearestFirst: nearestFirst),
      );
      Map<String, dynamic>? response;
      final run = await app.measure(() async {
        response = await cast(rays, nearestFirst: nearestFirst);
      });
      controls.add(_bytes(control));
      measurements.nets.add(_minus(run, control));
      measurements.micros.add(response!['micros'] as int);
    }
  }
  final (keptObjects, keptBytes) = await app.alive('_RayCandidate');
  return _CaseResult(
    testCase: testCase,
    rays: rays,
    old: old,
    nearest: nearest,
    noise: controls.reduce(max) - controls.reduce(min),
    keptObjects: keptObjects,
    keptBytes: keptBytes,
  );
}

/// The app run by `flutter run --machine`, and its VM service.
class _App {
  _App._(this._process);

  final Process _process;
  final log = <String>[];
  final _wsUri = Completer<String>();
  final _started = Completer<void>();
  String? _appId;
  VmService? _service;
  String? _isolateId;
  String description = '';

  static Future<_App> start(String device) async {
    final entry = Platform.script.resolve('../raycast_allocation_app.dart');
    final examples = Platform.script.resolve('../../../../examples');
    stdout.writeln('Starting the app (a profile build can take minutes)...');
    final process = await Process.start(
      'flutter',
      [
        'run',
        '-d',
        device,
        '--profile',
        '--machine',
        '-t',
        entry.toFilePath(),
      ],
      workingDirectory: examples.toFilePath(),
    );
    final app = _App._(process);
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(app._onLine);
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(app.log.add);
    return app;
  }

  void _onLine(String line) {
    log.add(line);
    if (!line.startsWith('[')) {
      return;
    }
    try {
      for (final message in jsonDecode(line) as List<dynamic>) {
        final event = (message as Map<String, dynamic>)['event'];
        final params = message['params'] as Map<String, dynamic>?;
        if (event == 'app.debugPort' && !_wsUri.isCompleted) {
          _appId = params!['appId'] as String;
          _wsUri.complete(params['wsUri'] as String);
        } else if (event == 'app.started' && !_started.isCompleted) {
          _started.complete();
        }
      }
    } on Object {
      // Not a message that matters.
    }
  }

  Future<void> connect() async {
    final uri = await _wsUri.future.timeout(const Duration(minutes: 15));
    await _started.future.timeout(const Duration(minutes: 5));
    final service = _service = await vmServiceConnectUri(uri);
    final vm = await service.getVM();
    description = '${vm.version?.split(' ').first} ${vm.targetCPU}';
    for (var attempt = 0; attempt < 30 && _isolateId == null; attempt++) {
      for (final ref in (await service.getVM()).isolates ?? <IsolateRef>[]) {
        final isolate = await service.getIsolate(ref.id!);
        if (isolate.extensionRPCs?.contains('ext.flame.raycast') ?? false) {
          _isolateId = ref.id;
        }
      }
      if (_isolateId == null) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    if (_isolateId == null) {
      throw StateError('No isolate has the extension ext.flame.raycast');
    }
    final check = await cast(
      kind: 'simple',
      scene: 'spread',
      count: 1,
      rays: 1,
      nearestFirst: false,
    );
    if (check['profileMode'] != true) {
      throw StateError('The app is not a profile build: $check');
    }
    description = 'a profile build (AOT), $description';
  }

  Future<Map<String, dynamic>> cast({
    required String kind,
    required String scene,
    required int count,
    required int rays,
    required bool nearestFirst,
  }) async {
    final response = await _service!.callServiceExtension(
      'ext.flame.raycast',
      isolateId: _isolateId,
      args: {
        'kind': kind,
        'scene': scene,
        'count': '$count',
        'rays': '$rays',
        'nearestFirst': '$nearestFirst',
      },
    );
    return response.json!;
  }

  /// What the isolate allocated while [work] ran.
  Future<_Allocations> measure(Future<void> Function() work) async {
    final service = _service!;
    await service.getAllocationProfile(_isolateId!, reset: true, gc: true);
    await work();
    final profile = await service.getAllocationProfile(_isolateId!);
    return {
      for (final member in profile.members ?? <ClassHeapStats>[])
        if ((member.instancesAccumulated ?? 0) > 0)
          member.classRef?.name ?? '?': (
            member.instancesAccumulated ?? 0,
            member.accumulatedSize ?? 0,
          ),
    };
  }

  /// The (objects, bytes) of the class that are alive after a GC.
  Future<(int, int)> alive(String className) async {
    final profile = await _service!.getAllocationProfile(_isolateId!, gc: true);
    for (final member in profile.members ?? <ClassHeapStats>[]) {
      if (member.classRef?.name == className) {
        return (member.instancesCurrent ?? 0, member.bytesCurrent ?? 0);
      }
    }
    return (0, 0);
  }

  Future<void> stop() async {
    await _service?.dispose();
    if (_appId != null) {
      _process.stdin.writeln(
        jsonEncode([
          {
            'id': 1,
            'method': 'app.stop',
            'params': {'appId': _appId},
          },
        ]),
      );
    }
    await _process.exitCode.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _process.kill();
        return -1;
      },
    );
  }
}
