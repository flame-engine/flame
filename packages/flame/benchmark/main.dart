import 'render_components_benchmark.dart';
import 'update_components_benchmark.dart';

Future<void> main() async {
  await RenderComponentsBenchmark.main();
  await UpdateComponentsBenchmark.main();
}
