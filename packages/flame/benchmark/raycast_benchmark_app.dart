import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'raycast_benchmark.dart' as raycast;

/// Runs `raycast_benchmark.dart` as an app, so that it can be measured in a
/// profile or release build, in AOT code like a game has, which `flutter test`
/// cannot do. It prints the same table and exits when it is done.
///
/// From the `examples` directory, which has a macOS runner:
///
///     flutter build macos --release -t ../packages/flame/benchmark/raycast_benchmark_app.dart
///     build/macos/Build/Products/Release/examples.app/Contents/MacOS/examples
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mode = kReleaseMode
      ? 'release'
      : kProfileMode
      ? 'profile'
      : 'debug';
  // ignore: avoid_print
  print('Mode: $mode');
  await raycast.main();
  exit(0);
}
