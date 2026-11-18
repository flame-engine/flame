// The measurements of the scene benchmark, shared by the `flutter test`
// harness and the AOT profile app: see README.md.
//
// ignore_for_file: avoid_print, do_not_use_environment
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'dart:developer' show Service;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flame_3d/graphics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'scene_benchmark.dart';

/// How a run measures [BenchmarkGame], from `--dart-define`s.
class BenchmarkRun({
  /// Measured frames.
  final int frames = const int.fromEnvironment(
    'BENCH_FRAMES',
    defaultValue: 600,
  ),

  /// Frames rendered before measuring, for the JIT to settle.
  final int warmup = const int.fromEnvironment(
    'BENCH_WARMUP',
    defaultValue: 400,
  ),

  /// Frames timed whole, waiting for the GPU.
  final int gpuFrames = const int.fromEnvironment(
    'BENCH_GPU_FRAMES',
    defaultValue: 24,
  ),

  /// Where to write the results as JSON, if anywhere.
  final String out = const String.fromEnvironment('BENCH_OUT'),
}) {
  /// The scene, from `BENCH_OBJECTS`, `BENCH_TRIANGLES` and `BENCH_SHADOWS`.
  static BenchmarkConfig get config => BenchmarkConfig(
    objects: const int.fromEnvironment('BENCH_OBJECTS', defaultValue: 200),
    triangleScale: double.parse(
      const String.fromEnvironment('BENCH_TRIANGLES', defaultValue: '1'),
    ),
    shadows: const bool.fromEnvironment('BENCH_SHADOWS', defaultValue: true),
  );

  /// The layer's render scale in [gpu] (`BENCH_RENDER_SCALE`): more pixels
  /// per logical pixel make the GPU's work dominate the frame.
  static double get renderScale => double.parse(
    const String.fromEnvironment('BENCH_RENDER_SCALE', defaultValue: '1'),
  );

  /// What to measure: `cpu`, `alloc` (CPU and allocations, which need the VM
  /// service), `gpu` or `all` (the default).
  static const String mode = String.fromEnvironment(
    'BENCH_MODE',
    defaultValue: 'all',
  );

  /// The results so far.
  final Map<String, Object> results = {};

  /// Writes [results] to [out], when given.
  void save() {
    if (out.isNotEmpty && results.isNotEmpty) {
      File(out).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(results),
      );
    }
  }

  static const double _dt = 1 / 120;

  /// Renders one frame of [game] into a picture, waits until the GPU has
  /// finished it (as a frame paced by the display would), and returns the
  /// times the update and the render took, in microseconds.
  Future<(int, int)> _frame(BenchmarkGame game, Stopwatch clock) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    clock
      ..reset()
      ..start();
    game.update(_dt);
    final update = clock.elapsedMicroseconds;
    game.render(canvas);
    final render = clock.elapsedMicroseconds - update;
    clock.stop();
    final picture = recorder.endRecording();
    // Reading the pixels of the picture waits for the layer's image, and so
    // for every pass submitted before it.
    final image = picture.toImageSync(4, 4);
    await image.toByteData();
    image.dispose();
    picture.dispose();
    return (update, render);
  }

  /// Measures the CPU time of [frames] frames, and the time of each phase
  /// when built with `FLAME_3D_PROFILE`.
  Future<void> cpu(BenchmarkGame game) async {
    final clock = Stopwatch();
    for (var i = 0; i < warmup; i++) {
      await _frame(game, clock);
    }
    final profile = kProfileRender
        ? (RenderProfile.active = RenderProfile())
        : null;
    final updates = <int>[];
    final renders = <int>[];
    final layerTimes = <int>[];
    for (var i = 0; i < frames; i++) {
      final (update, render) = await _frame(game, clock);
      updates.add(update);
      renders.add(render);
      layerTimes.add(game.layer.lastRenderTime.inMicroseconds);
    }
    RenderProfile.active = null;

    final stats = game.layer.renderStats;
    print('');
    print('== Scene: ${_describe(game)}');
    print(
      '== CPU per frame (${kDebugMode ? 'JIT' : 'AOT'}, $frames frames '
      'after $warmup warm-up)',
    );
    _printTimes('update (simulation)', updates);
    _printTimes('game.render', renders);
    _printTimes('Scene3DComponent.render', layerTimes);
    print('== Device stats of the last frame');
    print('  $stats');
    results['scene'] = _describe(game);
    results['update'] = _summary(updates);
    results['render'] = _summary(renders);
    results['layer'] = _summary(layerTimes);
    results['stats'] = {
      'drawCalls': stats.drawCalls,
      'shadowDrawCalls': stats.shadowDrawCalls,
      'instances': stats.instances,
      'triangles': stats.triangles,
      'pipelineChanges': stats.pipelineChanges,
      'stateChanges': stats.stateChanges,
      'materialChanges': stats.materialChanges,
      'uniformUploads': stats.uniformUploads,
      'uploadedBytes': stats.uploadedBytes,
      'particles': stats.particles,
    };

    if (profile != null) {
      print('== Phases, microseconds per frame (main pass / shadow pass)');
      final phases = <String, Object>{};
      for (final phase in RenderPhase.values) {
        final main = profile.microseconds(phase) / frames;
        final shadow = profile.microseconds(phase, shadow: true) / frames;
        phases[phase.name] = {'main': main, 'shadow': shadow};
        print(
          '  ${phase.name.padRight(14)}'
          '${main.toStringAsFixed(1).padLeft(9)}'
          '${shadow.toStringAsFixed(1).padLeft(9)}',
        );
      }
      print(
        '  ${'total'.padRight(14)}'
        '${(profile.totalMicroseconds / frames).toStringAsFixed(1).padLeft(9)}',
      );
      results['phases'] = phases;
    }
  }

  String _describe(BenchmarkGame game) {
    final c = game.config;
    return '${c.objects} objects x${c.triangleScale} triangles, '
        '${c.characters} skinned, ${c.translucentParts} translucent, '
        '${c.additiveParts} additive, ${c.particleSystems} particle systems, '
        'shadows ${c.shadows}, ${c.activePointLights}/${c.pointLights} point '
        'lights, msaa ${c.msaa}';
  }

  void _printTimes(String name, List<int> values) {
    final s = _summary(values);
    print(
      '  ${name.padRight(26)} median ${_ms(s['median']!)}  '
      'mean ${_ms(s['mean']!)}  p90 ${_ms(s['p90']!)}  min ${_ms(s['min']!)}',
    );
  }

  String _ms(double micros) => '${(micros / 1000).toStringAsFixed(3)} ms';

  Map<String, double> _summary(List<int> values) {
    final sorted = [...values]..sort();
    final mean = values.fold<int>(0, (a, b) => a + b) / values.length;
    return {
      'median': sorted[sorted.length ~/ 2].toDouble(),
      'mean': mean,
      'p90': sorted[(sorted.length * 0.9).floor()].toDouble(),
      'min': sorted.first.toDouble(),
    };
  }

  /// Counts the objects allocated per frame with the VM service.
  Future<void> allocations(BenchmarkGame game) async {
    final info = await Service.getInfo();
    final uri = info.serverWebSocketUri;
    if (uri == null) {
      print('== Allocations: run with --enable-vmservice to count them');
      return;
    }
    final socket = await WebSocket.connect(uri.toString());
    final replies = socket.asBroadcastStream();
    final isolate = Service.getIsolateId(Isolate.current)!;
    var id = 0;
    Future<Map<String, (int, int)>> profile({required bool reset}) async {
      id++;
      socket.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': '$id',
          'method': 'getAllocationProfile',
          'params': {'isolateId': isolate, if (reset) 'reset': true},
        }),
      );
      final reply = await replies.first as String;
      final result = (jsonDecode(reply) as Map<String, dynamic>)['result'];
      if (result == null) {
        throw StateError('getAllocationProfile failed: $reply');
      }
      final members = (result as Map<String, dynamic>)['members'] as List;
      return {
        for (final member in members.cast<Map<String, dynamic>>())
          '${(member['class'] as Map<String, dynamic>)['name']}': (
            member['instancesAccumulated'] as int,
            member['accumulatedSize'] as int,
          ),
      };
    }

    Future<Map<String, (int, int)>> window(int frames) async {
      await profile(reset: true);
      final clock = Stopwatch();
      for (var i = 0; i < frames; i++) {
        await _frame(game, clock);
      }
      return await profile(reset: false);
    }

    // The frames rendered without the layer count what the rest of the frame
    // (the update, the picture, waiting for the GPU) allocates.
    const frames = 200;
    game.layer.renders = false;
    final idle = await window(frames);
    game.layer.renders = true;
    final busy = await window(frames);
    final perClass = <String, (double, double)>{};
    var instances = 0.0;
    var bytes = 0.0;
    for (final MapEntry(:key, value: (count, size)) in busy.entries) {
      final (idleCount, idleSize) = idle[key] ?? (0, 0);
      final n = (count - idleCount) / frames;
      final b = (size - idleSize) / frames;
      if (n.abs() > 0.05) {
        perClass[key] = (n, b);
        instances += n;
        bytes += b;
      }
    }
    final top = perClass.entries.toList()
      ..sort((a, b) => b.value.$1.compareTo(a.value.$1));
    print(
      '== Allocations per frame by the render of the layer '
      '(${kDebugMode ? 'JIT' : 'AOT'}, approximate)',
    );
    print(
      '  ${instances.toStringAsFixed(1)} objects, '
      '${(bytes / 1024).toStringAsFixed(1)} KiB',
    );
    for (final entry in top.take(25)) {
      print(
        '  ${entry.key.padRight(36)}'
        '${entry.value.$1.toStringAsFixed(2).padLeft(9)}'
        '${entry.value.$2.toStringAsFixed(0).padLeft(9)} B',
      );
    }
    results['allocations'] = {
      'objects': instances,
      'bytes': bytes,
      'top': {
        for (final entry in top.take(25))
          entry.key: {'objects': entry.value.$1, 'bytes': entry.value.$2},
      },
    };
    await socket.close();
  }

  /// Times whole frames at phone resolution, waiting for the GPU to finish
  /// each: on the software Vulkan of `flutter test`, a rough proxy of the
  /// GPU's work.
  Future<void> gpu(BenchmarkGame game) async {
    game.layer.renderScale = renderScale;
    final clock = Stopwatch();
    final size = game.canvasSize;
    Future<int> frame() async {
      final total = Stopwatch()..start();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      game
        ..update(_dt)
        ..render(canvas);
      final picture = recorder.endRecording();
      // Reading a pixel waits for the layer's image to be rendered.
      final image = picture.toImageSync(size.x.ceil(), size.y.ceil());
      await image.toByteData();
      image.dispose();
      picture.dispose();
      return total.elapsedMicroseconds;
    }

    for (var i = 0; i < 4; i++) {
      await frame();
    }
    final times = <int>[];
    for (var i = 0; i < gpuFrames; i++) {
      times.add(await frame());
    }
    clock.stop();
    print(
      '== Whole frames at ${size.x.toInt()}x${size.y.toInt()} logical, '
      'render scale $renderScale, waiting for the GPU ($gpuFrames frames)',
    );
    _printTimes('frame', times);
    print('  ${game.layer.renderStats}');
    results['gpuFrame'] = _summary(times);
  }
}
