import 'package:flame_3d/graphics.dart';
import 'package:flame_3d_example/example_app.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GpuBackend.initialize(); // Optional but some backends might require it.

  runApp(const ExampleApp());
}
