import 'children_traversal_benchmark.dart' as children_traversal;
import 'collision_detection_benchmark.dart' as collision_detection;
import 'component_churn_benchmark.dart' as component_churn;
import 'components_at_point_benchmark.dart' as components_at_point;
import 'priority_change_benchmark.dart' as priority_change;
import 'render_components_benchmark.dart' as render_components;
import 'type_query_benchmark.dart' as type_query;
import 'update_components_benchmark.dart' as update_components;

Future<void> main() async {
  await children_traversal.main();
  await component_churn.main();
  await priority_change.main();
  await type_query.main();
  await update_components.main();
  await render_components.main();
  await components_at_point.main();
  await collision_detection.main();
}
