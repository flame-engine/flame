// ignore_for_file: use_primary_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:vm_service/vm_service.dart';
// ignore: depend_on_referenced_packages
import 'package:vm_service/vm_service_io.dart';

/// Measures what `StandardCollisionDetection.raycast` allocates with the old
/// code path and with the nearest first one (`nearestFirstRaycast`), and how
/// long it takes, in AOT code, with no manual steps.
///
/// It runs `benchmark/raycast_allocation_app.dart` in a profile build, with
/// `flutter run --machine`, connects to its VM service, and for each case asks
/// the app to cast rays.
///
/// The allocations are counted by tracing the allocations of the classes in
/// [_defaultClasses] (and `--classes`), which the VM records one by one, so the
/// number of objects of each class per ray is exact, and what the VM service
/// allocates itself is measured with no rays and subtracted. The allocation
/// profile of the VM is not used, as its counters miss most of the objects
/// that AOT code allocates. Only the objects of the traced classes are
/// counted, and their sizes are not measured, so these are objects per ray,
/// not bytes. The time is measured by the app, without tracing.
///
///     dart run benchmark/tool/measure_raycast_allocations.dart [options]
///
/// Options:
///
///     --device=macos       The device to run on. It needs to be a desktop one.
///     --reps=3             The timings of each code path in each case.
///     --seconds=2          The time that each timing should take.
///     --trace-rays=20000   The rays that the allocations are counted for.
///     --classes=a,b        More classes to count, by name.
///     --filter=text        Only the cases whose name has the text.
///     --csv=path           Also write the results to a CSV file.
///     --trace=_List,_Double
///                          Instead of measuring, show the stacks that
///                          allocate objects of these classes, with each code
///                          path.
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
      for (final count in [5, 10, 20, 50, 100]) _Case(kind, 'dense', count),
    ],
    // Real hitboxes, to see the allocations of everything that a ray does.
    for (final kind in ['simple', 'polygons', 'paths', 'mixed']) ...[
      for (final count in [100, 500]) _Case(kind, 'spread', count),
      for (final count in [20, 50, 100, 200]) _Case(kind, 'dense', count),
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
      'timing_rays',
      'trace_rays',
      'old_objects_per_ray',
      'new_objects_per_ray',
      'old_us_per_ray',
      'new_us_per_ray',
      'old_us_min',
      'old_us_max',
      'new_us_min',
      'new_us_max',
      'old_classes',
      'new_classes',
    ].join(','),
  ];
  try {
    await app.connect(options.extraClasses);
    if (options.trace.isNotEmpty) {
      await _traceCases(app, cases, options);
      return;
    }
    stdout
      ..writeln()
      ..writeln(
        'Raycast, old code path vs nearest first, in ${app.description}.\n'
        'objects/ray: exact, from tracing the allocations of ${app.traced} '
        'classes in ${options.traceRays} rays, without what the VM service '
        'allocates itself. us/ray: median (fastest-slowest) of '
        '${options.reps} timings of ~${options.seconds} s, with no tracing.\n',
      )
      ..writeln(
        _row([
          'case',
          'old obj/ray',
          'new obj/ray',
          'old us/ray',
          'new us/ray',
          'objects/ray of each class: old | new',
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

/// The classes whose allocations are counted, which is where the code of a
/// raycast allocates. Classes that are not found are skipped, and the ones
/// whose name starts with `_Record` are all counted.
const _defaultClasses = [
  '_List',
  '_GrowableList',
  '_Closure',
  '_Double',
  '_Mint',
  '_Float32List',
  '_Float64List',
  '_Int32List',
  '_Uint8List',
  '_Map',
  '_Set',
  '_SuspendState',
  '_Future',
  '_SyncStarIterator',
  '_SyncStarIterable',
  '_ListIterator',
  'Vector2',
  'Vector3',
  'Vector4',
  'Matrix3',
  'Matrix4',
  'Aabb2',
  'Ray2',
  'RaycastResult',
  'LineSegment',
  'Rect',
  'Offset',
  'Size',
  'Path',
];

/// The objects per ray under which a class is not shown. What the VM service
/// allocates while measuring varies by a few objects, which is this many per
/// ray with the default 2000 rays.
const _noiseFloor = 0.02;

String _row(List<String> columns) {
  const widths = [22, 13, 13, 25, 25, 0];
  return [
    for (var i = 0; i < columns.length; i++) columns[i].padRight(widths[i]),
  ].join();
}

class _Options {
  _Options(List<String> arguments) {
    for (final argument in arguments) {
      final match = RegExp(r'^--([\w-]+)=(.*)$').firstMatch(argument);
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
        case 'trace-rays':
          traceRays = int.parse(value);
        case 'classes':
          extraClasses = value.split(',');
        case 'filter':
          filter = value;
        case 'csv':
          csvPath = value;
        case 'trace':
          trace = value;
        default:
          throw ArgumentError('Unknown option: $argument');
      }
    }
  }

  String device = 'macos';
  int reps = 3;
  double seconds = 2;
  int traceRays = 20000;
  List<String> extraClasses = [];
  String filter = '';
  String? csvPath;
  String trace = '';
}

class _Case {
  _Case(this.kind, this.scene, this.count);

  final String kind;
  final String scene;
  final int count;

  String get id => '$scene/$kind/$count';
}

T _median<T extends num>(List<T> values) {
  final sorted = List<T>.of(values)..sort();
  return sorted[sorted.length ~/ 2];
}

/// What was allocated in [measured] and not in [control], by class.
Map<String, int> _minus(Map<String, int> measured, Map<String, int> control) {
  return {
    for (final entry in measured.entries)
      if (entry.value > (control[entry.key] ?? 0))
        entry.key: entry.value - (control[entry.key] ?? 0),
  };
}

/// The classes with the most objects, as `name objects/ray`.
String _top(Map<String, int> counts, int rays, {int count = 4}) {
  final entries =
      counts.entries.where((e) => e.value / rays >= _noiseFloor).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  if (entries.isEmpty) {
    return '-';
  }
  return entries
      .take(count)
      .map((e) => '${e.key} ${(e.value / rays).toStringAsFixed(2)}')
      .join(', ');
}

class _CaseResult {
  _CaseResult({
    required this.testCase,
    required this.traceRays,
    required this.timingRays,
    required this.oldCounts,
    required this.newCounts,
    required this.oldMicros,
    required this.newMicros,
    required this.oldRange,
    required this.newRange,
    required this.truncated,
  });

  final _Case testCase;
  final int traceRays;
  final int timingRays;
  final Map<String, int> oldCounts;
  final Map<String, int> newCounts;

  /// The microseconds per ray.
  final double oldMicros;
  final double newMicros;

  /// The fastest and the slowest of the timings, in microseconds per ray.
  final (double, double) oldRange;
  final (double, double) newRange;

  /// Whether the VM may have dropped allocation samples.
  final bool truncated;

  double _objects(Map<String, int> counts) =>
      counts.values.fold(0, (sum, count) => sum + count) / traceRays;

  static String _timing(double median, (double, double) range) {
    final (fastest, slowest) = range;
    final digits = [median, fastest, slowest].map((m) => m.toStringAsFixed(2));
    final [m, f, s] = digits.toList();
    return '$m ($f-$s)';
  }

  String row() => _row([
    testCase.id,
    _objects(oldCounts).toStringAsFixed(3),
    _objects(newCounts).toStringAsFixed(3),
    _timing(oldMicros, oldRange),
    _timing(newMicros, newRange),
    [
      '${_top(oldCounts, traceRays)} | ${_top(newCounts, traceRays)}',
      if (truncated) '(TRUNCATED: some allocations were not recorded)',
    ].join('  '),
  ]);

  String _classes(Map<String, int> counts) => counts.entries
      .where((e) => e.value / traceRays >= _noiseFloor)
      .map((e) => '${e.key}:${(e.value / traceRays).toStringAsFixed(4)}')
      .join(';');

  String csv() => [
    testCase.id,
    timingRays,
    traceRays,
    _objects(oldCounts).toStringAsFixed(4),
    _objects(newCounts).toStringAsFixed(4),
    oldMicros.toStringAsFixed(3),
    newMicros.toStringAsFixed(3),
    oldRange.$1.toStringAsFixed(3),
    oldRange.$2.toStringAsFixed(3),
    newRange.$1.toStringAsFixed(3),
    newRange.$2.toStringAsFixed(3),
    _classes(oldCounts),
    _classes(newCounts),
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
  final timingRays = (options.seconds * 1e6 / max(microsPerRay, 0.01))
      .clamp(20000, 5000000)
      .round();

  // The time, with no tracing. The code paths take turns.
  final oldMicros = <int>[];
  final newMicros = <int>[];
  for (var rep = 0; rep < options.reps; rep++) {
    oldMicros.add(
      (await cast(timingRays, nearestFirst: false))['micros'] as int,
    );
    newMicros.add(
      (await cast(timingRays, nearestFirst: true))['micros'] as int,
    );
  }

  // The objects allocated, with tracing, and with no rays as the control.
  var truncated = false;
  Future<Map<String, int>> count({
    required int rays,
    required bool nearestFirst,
  }) async {
    final counted = await app.countAllocations(
      rays,
      (chunk) => cast(chunk, nearestFirst: nearestFirst),
    );
    truncated |= counted.truncated;
    return counted.counts;
  }

  final controlLong = await app.countAllocations(
    options.traceRays,
    (chunk) => cast(0, nearestFirst: false),
  );
  final oldCounts = _minus(
    await count(rays: options.traceRays, nearestFirst: false),
    controlLong.counts,
  );
  final newCounts = _minus(
    await count(rays: options.traceRays, nearestFirst: true),
    controlLong.counts,
  );
  return _CaseResult(
    testCase: testCase,
    traceRays: options.traceRays,
    timingRays: timingRays,
    oldCounts: oldCounts,
    newCounts: newCounts,
    oldMicros: _median(oldMicros) / timingRays,
    newMicros: _median(newMicros) / timingRays,
    oldRange: (
      oldMicros.reduce(min) / timingRays,
      oldMicros.reduce(max) / timingRays,
    ),
    newRange: (
      newMicros.reduce(min) / timingRays,
      newMicros.reduce(max) / timingRays,
    ),
    truncated: truncated,
  );
}

/// Shows which stacks allocate the objects of the classes in `--trace`, for
/// each case and code path, to find out where the allocations come from.
Future<void> _traceCases(
  _App app,
  List<_Case> cases,
  _Options options,
) async {
  const rays = 20000;
  for (final testCase in cases) {
    Future<Map<String, dynamic>> cast(int count, {required bool nearestFirst}) {
      return app.cast(
        kind: testCase.kind,
        scene: testCase.scene,
        count: testCase.count,
        rays: count,
        nearestFirst: nearestFirst,
      );
    }

    await cast(0, nearestFirst: false);
    await cast(rays, nearestFirst: false);
    await cast(rays, nearestFirst: true);
    for (final className in options.trace.split(',')) {
      for (final (label, nearestFirst) in [('old', false), ('new', true)]) {
        final stacks = await app.traceAllocations(
          className,
          () => cast(rays, nearestFirst: nearestFirst),
        );
        final counts = <String, int>{};
        for (final stack in stacks) {
          counts[stack] = (counts[stack] ?? 0) + 1;
        }
        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        stdout.writeln(
          '\n${testCase.id} $label $className: ${stacks.length} allocations '
          'in $rays rays, ${sorted.length} different stacks',
        );
        for (final entry in sorted.take(5)) {
          stdout.writeln('  ${entry.value}x ${entry.key}');
        }
      }
    }
  }
}

/// The objects allocated in some rays, by class, and whether the VM may have
/// dropped some of the samples that record them.
typedef _Counted = ({Map<String, int> counts, bool truncated});

/// The app run by `flutter run --machine`, and its VM service.
class _App {
  _App._(this._process);

  /// The samples that one chunk of rays may have without the VM dropping some,
  /// which it does when its buffer of samples is full.
  static const _sampleBufferLimit = 40000;

  /// The fewest rays in a chunk.
  static const _minChunk = 10;

  final Process _process;
  final log = <String>[];
  final _wsUri = Completer<String>();
  final _started = Completer<void>();
  String? _appId;
  VmService? _service;
  String? _isolateId;
  String description = '';

  /// The names of the classes that are traced, by their ids.
  final _tracedClasses = <String, String>{};

  /// The same names, by the numeric ids that the samples have, which are the
  /// ends of the ids of the classes (`classes/123`).
  final _namesByClassId = <int, String>{};

  int get traced => _tracedClasses.length;

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

  Future<void> connect(List<String> extraClasses) async {
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

    // The classes to count.
    final wanted = {..._defaultClasses, ...extraClasses};
    final classes = await service.getClassList(_isolateId!);
    for (final ref in classes.classes ?? <ClassRef>[]) {
      final name = ref.name;
      if (name != null &&
          (wanted.contains(name) || name.startsWith('_Record'))) {
        _tracedClasses[ref.id!] = name;
        final numeric = int.tryParse(ref.id!.split('/').last);
        if (numeric != null) {
          _namesByClassId[numeric] = name;
        }
      }
    }
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

  /// The objects of the traced classes allocated while [work] cast [rays] rays,
  /// in chunks, as many as the VM can record at a time.
  Future<_Counted> countAllocations(
    int rays,
    Future<void> Function(int chunk) work, {
    int chunk = 2000,
  }) async {
    final service = _service!;
    final isolateId = _isolateId!;
    final counts = <String, int>{};
    var truncated = false;
    for (final id in _tracedClasses.keys) {
      await service.setTraceClassAllocation(isolateId, id, true);
    }
    try {
      // With no rays, it still does the same calls, as a control.
      // A chunk that records as many samples as the limit may have lost some,
      // so it is discarded and done again in half the rays.
      var remaining = rays;
      var size = chunk;
      var first = true;
      while (remaining > 0 || first) {
        first = false;
        final n = min(size, remaining);
        final origin = (await service.getVMTimelineMicros()).timestamp!;
        await work(n);
        final samples = await service.getAllocationTraces(
          isolateId,
          timeOriginMicros: origin,
          timeExtentMicros: 10 * 60 * 1000000,
        );
        final list = samples.samples ?? <CpuSample>[];
        if (list.length >= _sampleBufferLimit) {
          if (n > _minChunk) {
            size = n ~/ 2;
            continue;
          }
          truncated = true;
        }
        remaining -= n;
        for (final sample in list) {
          final name = _namesByClassId[sample.classId];
          if (name != null) {
            counts[name] = (counts[name] ?? 0) + 1;
          }
        }
      }
    } finally {
      for (final id in _tracedClasses.keys) {
        await service.setTraceClassAllocation(isolateId, id, false);
      }
    }
    return (counts: counts, truncated: truncated);
  }

  /// The stacks, one per object, that allocated the objects of the class while
  /// [work] ran, as the names of their five innermost functions.
  Future<List<String>> traceAllocations(
    String className,
    Future<void> Function() work,
  ) async {
    final service = _service!;
    final isolateId = _isolateId!;
    final classes = await service.getClassList(isolateId);
    final classRef = classes.classes!.firstWhere((c) => c.name == className);
    final origin = (await service.getVMTimelineMicros()).timestamp!;
    await service.setTraceClassAllocation(isolateId, classRef.id!, true);
    try {
      await work();
    } finally {
      await service.setTraceClassAllocation(isolateId, classRef.id!, false);
    }
    final samples = await service.getAllocationTraces(
      isolateId,
      classId: classRef.id,
      timeOriginMicros: origin,
      timeExtentMicros: 10 * 60 * 1000000,
    );
    final functions = samples.functions ?? <ProfileFunction>[];
    String name(int index) {
      final function = functions[index].function;
      if (function is FuncRef) {
        final owner = function.owner;
        final ownerName = owner is ClassRef ? '${owner.name}.' : '';
        return '$ownerName${function.name}';
      }
      return function is NativeFunction ? function.name ?? '?' : '$function';
    }

    return [
      for (final sample in samples.samples ?? <CpuSample>[])
        (sample.stack ?? <int>[]).take(5).map(name).join(' < '),
    ];
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
